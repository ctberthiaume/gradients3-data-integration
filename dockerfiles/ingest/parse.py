#!/usr/bin/env python3
import click
import os
import subprocess
import sys
from minio import Minio
from minio.error import ResponseError


@click.command()
@click.option('-v', '--verbose', count=True)
def main(verbose):
    """
    Parse files in minio, write to new CSV.

    For each input file MINIO_ENDPOINT/MINIO_INPUT_BUCKET/<a>, copy
    locally to OUTPUT_DIR/raw/<a>, parse with parser
    METADATA_DIR/CURRENT_CRUISE/<a>.parser, write to
    OUTPUT_DIR/parsed/<a>.csv and
    MINIO_ENDPOINT/MINIO_OUTPUT_BUCKET/<a>.csv. If no matching parser
    exists, skip.

    Required environment variables: MINIO_ENDPOINT, MINIO_ACCESS_KEY
    MINIO_SECRET_KEY, MINIO_INPUT_BUCKET, MINIO_PARSED_BUCKET,
    METADATA_DIR, CURRENT_CRUISE, OUTPUT_DIR.
    """
    def info(msg):
        print(msg, file=sys.stdout)

    def error(msg):
        print(msg, file=sys.stderr)

    def debug(msg, file=sys.stdout):
        if verbose == 1:
            print(msg, file=file)

    # Env vars, output locations
    try:
        endpoint = os.environ['MINIO_ENDPOINT']
        access_key = os.environ['MINIO_ACCESS_KEY']
        secret_key = os.environ['MINIO_SECRET_KEY']
        inbucket = os.environ['MINIO_INPUT_BUCKET']
        outbucket = os.environ['MINIO_PARSED_BUCKET']
        metadir = os.path.join(os.environ['METADATA_DIR'], os.environ['CURRENT_CRUISE'])
        outputdir = os.environ['OUTPUT_DIR']
    except KeyError as e:
        error('Missing env var: {}'format(str(e)))
        sys.exit(1)
    raw_subdir = os.path.join(outputdir, 'raw')
    parsed_subdir = os.path.join(outputdir, 'parsed')
    os.makedirs(raw_subdir, exist_ok=True)
    os.makedirs(parsed_subdir, exist_ok=True)

    # Everything but the access/secret keys
    debug('env args: {}, {}, {}, {}, {}'.format(endpoint, inbucket, outbucket, metadir, outputdir))

    # Make minio client
    client = Minio(endpoint, access_key=access_key, secret_key=secret_key, secure=False)

    # Find matching input files and parsers
    # Download then parse the matched input files
    inputs, parsers = set(), set()
    for obj in client.list_objects(inbucket):
        inputs.add(obj.object_name)
        debug('added {} to inputs'.format(obj.object_name))

    for f in os.listdir(metadir):
        if os.path.isfile(os.path.join(metadir, f)) and f.endswith('.parser'):
            parsers.add(f.rsplit('.', 1)[0])
            debug('added {} to parsers'.format(f))

    for base in inputs.intersection(parsers):
        debug('starting to parse {}'.format(base))
        p = os.path.join(metadir, base + '.parser')
        i = os.path.join(raw_subdir, base)
        o = os.path.join(parsed_subdir, base + '.csv')
        debug('downloading {}:{}/{} to {}'.format(endpoint, inbucket, base, i))

        try:
            client.fget_object(inbucket, base, i)
        except ResponseError as err:
            error(err)
            continue

        debug('calling <{} {} {}>'.format(p, i, o))
        try:
            output = subprocess.check_output(
                '{} {} {}'.format(p, i, o),
                stderr=subprocess.STDOUT,
                shell=True,
                universal_newlines=True,
                encoding='utf-8'
            )
        except subprocess.CalledProcessError as e:
            error('parsing {} finished with exit code {}'.format(base, e.returncode))
            error(e.output)
        else:
            info('parsed "{}"'.format(base))
            debug('uploading {} to {}:{}/{}'.format(o, endpoint, outbucket, os.path.basename(o)))
            try:
                client.fput_object(outbucket, os.path.basename(o), o)
            except ResponseError as err:
                error(err)


if __name__ == '__main__':
    main()
