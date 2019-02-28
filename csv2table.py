#!/usr/bin/env python
import click
import os
import sys

@click.command()
@click.option('--text-columns', default='', show_default=True,
    help='comma-separated list of text columns')
@click.option('--time-column', default='time', show_default=True,
    help='time column')
@click.argument('table', nargs=1)
@click.argument('input', type=click.File(mode='r', encoding='utf-8'), nargs=1)
def main(text_columns, time_column, table, input):
    if text_columns:
        text = text_columns.split(',')
    else:
        text = []

    for line in input:
        fields = line.rstrip().split(',')
        try:
            time_i = fields.index(time_column)
        except ValueError:
            print('Input is missing a time column', file=sys.stderr)
            sys.exit(1)

        output = f'CREATE TABLE IF NOT EXISTS {table} ({os.linesep}'
        for i, f in enumerate(fields):
            if i == time_i:
                output += '  time TIMESTAMPTZ NOT NULL'
            elif f in text:
                output += f'  {f} TEXT'
            else:
                output += f'  {f} DOUBLE PRECISION'
            if i < len(fields) - 1:
                output += ','
            output += os.linesep
        output += f');'
        print(output)
        break

if __name__ == '__main__':
    main()
