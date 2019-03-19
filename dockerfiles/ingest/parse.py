#!/usr/bin/env python3
import click
import os
import subprocess
import sys


@click.command()
@click.option('-i', '--inputdir', required=True, type=click.Path(exists=True),
    help='Directory with input files')
@click.option('-m', '--metadir', required=True, type=click.Path(exists=True),
    help='Directory with parser executables')
@click.option('-o', '--outputdir', required=True, type=click.Path(exists=True),
    help='Directory for parsed CSV files')
@click.option('-v', '--verbose', is_flag=True)
def main(inputdir, metadir, outputdir, verbose):
    """
    Parse files in <inputdir>, write new CSV to <outputdir>.

    For each input file <inputdir>/<a>, parse with parser
    <metadir>/<a>.parser, writing to <outputdir>/<a>.csv. If no
    matching parser exists, skip.
    """
    def log(msg, file=sys.stdout):
        if verbose:
            print(msg, file=file)

    log('args: {}, {}, {}'.format(inputdir, metadir, outputdir))

    inputs, parsers = set(), set()

    for f in os.listdir(inputdir):
        if os.path.isfile(os.path.join(inputdir, f)):
            inputs.add(f)
            log('added {} to inputs'.format(f))

    for f in os.listdir(metadir):
        if os.path.isfile(os.path.join(metadir, f)) and f.endswith('.parser'):
            parsers.add(f.rsplit('.', 1)[0])
            log('added {} to parsers'.format(f))

    for base in inputs.intersection(parsers):
        log('considering common base {}'.format(base))
        p = os.path.join(metadir, base + '.parser')
        i = os.path.join(inputdir, base)
        o = os.path.join(outputdir, base + '.csv')
        log('calling <{} {} {}>'.format(p, i, o))
        try:
            output = subprocess.check_output(
                '{} {} {}'.format(p, i, o),
                stderr=subprocess.STDOUT,
                shell=True,
                universal_newlines=True,
                encoding='utf-8'
            )
        except subprocess.CalledProcessError as e:
            click.echo('parsing {} finished with exit code {}'.format(base, e.returncode), err=True)
            click.echo(e.output, err=True)
        else:
            click.echo('parsed "{}"'.format(base))


if __name__ == '__main__':
    main()
