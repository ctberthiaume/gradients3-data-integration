#!/usr/bin/env python3
import click
import os
import subprocess
import sys
import toml

@click.command()
@click.option('-c', '--csvdir', type=click.Path(exists=True), nargs=1, required=True,
    help='Directory with input CSV to import')
@click.option('-m', '--metadir', type=click.Path(exists=True), nargs=1, required=True,
    help='Directory with SQL schema and TOML spec files for each CSV file.')
@click.option('-v', '--verbose', is_flag=True)
def main(csvdir, metadir, verbose):
    """
    Import CSV data to Postgres database.

    Given CSV file <csv> (a.csv), import into $PGDATABASE based on
    SQL schema a.sql and table listed in TOML file spec a.toml. If
    matching SQL and TOML are missing skip ingest for that CSV.

    Environment variables PGHOST, PGUSER, PGPASSWORD, PGDATABASE
    should be set.
    """
    def log(msg, file=sys.stdout):
        if verbose:
            print(msg, file=file)

    log('args: {}, {}'.format(csvdir, metadir))

    for f in os.listdir(csvdir):
        base = f.rsplit('.', 1)[0]
        csv = os.path.join(csvdir, f)
        sql = os.path.join(metadir, base + '.sql')
        spec = os.path.join(metadir, base + '.toml')
        if not (os.path.isfile(csv) and os.path.isfile(sql) and os.path.isfile(spec)):
            print('Skipping {}'.format(f))
            continue

        print('Importing {}'.format(f))
        try:
            output = subprocess.check_output(
                'psql < {}'.format(sql),
                stderr=subprocess.STDOUT,
                shell=True,
                universal_newlines=True,
                encoding='utf-8'
            )
            print('Loaded SQL script for {}'.format(f))
            log(output)
        except subprocess.CalledProcessError as e:
            print('SQL script for {} finished with exit code {}'.format(f, e.returncode), file=sys.stderr)
            print(e.output, file=sys.stderr)
            continue

        with open(spec, mode='r', encoding='utf-8') as specfh:
            conf = toml.loads(specfh.read())
        format_args = {
            'table': conf['table'],
            'file': csv,
            'copyoptions': make_copy_options(conf)
        }
        copy_cmd = 'timescaledb-parallel-copy --truncate --workers 2 --batch-size 5000 --verbose \
            --connection "host=$PGHOST user=$PGUSER sslmode=disable" \
            --db-name $PGDATABASE --table {table} --file {file} --copy-options "{copyoptions}"'.format(**format_args)
        try:
            output = subprocess.check_output(
                copy_cmd,
                stderr=subprocess.STDOUT,
                shell=True,
                universal_newlines=True,
                encoding='utf-8'
            )
            print('Ingested {}'.format(f))
            log(output)
        except subprocess.CalledProcessError as e:
            print('Ingest of {} finished with exit code {}'.format(f, e.returncode), file=sys.stderr)
            print(e.output, file=sys.stderr)
            continue


def make_copy_options(conf):
    options = 'CSV HEADER'
    try:
        options += " NULL '{}'".format(conf['null'])
    except KeyError:
        pass
    return options


if __name__ == '__main__':
    main()
