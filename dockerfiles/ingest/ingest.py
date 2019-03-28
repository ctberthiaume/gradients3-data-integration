#!/usr/bin/env python3
import click
import os
import subprocess
import sys
import toml

@click.command()
@click.option('-v', '--verbose', count=True)
def main(verbose):
    """
    Import CSV data to Postgres database.

    For each CSV file OUTPUT_DIR/parsed/CURRENT_CRUISE/<a.csv>, import into
    $PGDATABASE based on SQL schema METADATA_DIR/CURRENT_CRUISE/<a.sql>
    and table listed in TOML file METADATA_DIR/CURRENT_CRUISE/<a.toml>.
    If matching SQL and TOML are missing skip ingest for that CSV.

    Required environment variables: PGHOST, PGUSER, PGPASSWORD,
    PGDATABASE, METADATA_DIR, CURRENT_CRUISE, OUTPUT_DIR.  DEBUG can be
    set to 1 to increase verbosity.
    """
    def info(msg):
        print(msg, file=sys.stdout)

    def error(msg):
        print(msg, file=sys.stderr)

    def debug(msg, file=sys.stdout):
        if verbose == 1:
            print(msg, file=file)

    # Env vars
    # First try to get DEBUG ENV var if -v not set
    if not verbose:
        try:
            verbose = os.environ['DEBUG']
        except KeyError:
            pass
        else:
            try:
                verbose = int(verbose)
            except TypeError:
                verbose = 0
    try:
        cruise = os.environ['CURRENT_CRUISE']
        metadir = os.path.join(os.environ['METADATA_DIR'], cruise)
        csvdir = os.path.join(os.environ['OUTPUT_DIR'], cruise, 'parsed')
    except KeyError as e:
        error('Missing env var: {}'.format(str(e)))
        sys.exit(1)

    debug('env args: {}, {}, {}, {}'.format(csvdir, metadir, cruise, verbose))

    for f in os.listdir(csvdir):
        if not f.endswith('.csv'):
            continue
        base = f.rsplit('.', 1)[0]
        csv = os.path.join(csvdir, f)
        sql = os.path.join(metadir, base + '.sql')
        spec = os.path.join(metadir, base + '.toml')
        if not (os.path.isfile(csv) and os.path.isfile(sql) and os.path.isfile(spec)):
            debug('Skipping {}'.format(f))
            continue

        debug('Importing {}'.format(f))
        try:
            output = subprocess.check_output(
                'psql < {}'.format(sql),
                stderr=subprocess.STDOUT,
                shell=True,
                universal_newlines=True,
                encoding='utf-8'
            )
            info('Loaded SQL script for {}'.format(f))
            debug(output)
        except subprocess.CalledProcessError as e:
            error('SQL script for {} finished with exit code {}'.format(f, e.returncode))
            error(e.output)
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
            info('Ingested {}'.format(f))
            debug(output)
        except subprocess.CalledProcessError as e:
            error('Ingest of {} finished with exit code {}'.format(f, e.returncode))
            error(copy_cmd)
            error(e.output)
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
