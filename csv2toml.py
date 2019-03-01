#!/usr/bin/env python
import click
import csv
import os
import sys
import toml

@click.command()
@click.option('--text-columns', default='', show_default=True,
    help='comma-separated list of text columns')
@click.option('--group-by-columns', default='', show_default=True,
    help='comma-separated list of text columns for GROUP BY aggregations')
@click.argument('table', nargs=1)
@click.argument('input', type=click.Path(exists=True), nargs=1)
def main(text_columns, group_by_columns, table, input):
    if text_columns:
        text = text_columns.split(',')
    else:
        text = []

    with open(input, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)

    try:
        time_i = header.index('time')
    except ValueError:
        print('Input is missing a time column', file=sys.stderr)
        sys.exit(1)
    
    data = {
        'table': table,
        'fields': [
            { 'index': time_i, 'name': 'time', 'type': 'time' }
        ]
    }

    for i, f in enumerate(header):
        if i != time_i:
            if f in text:
                data['fields'].append({ 'index': i, 'name': f, 'type': 'text', 'groupby': False })
                if f in group_by_columns:
                    data['fields'][-1]['groupby'] = True
            else:
                data['fields'].append({ 'index': i, 'name': f, 'type': 'real' })

    data['fields'] = sorted(data['fields'], key=lambda x: x['index'])

    print(toml.dumps(data))


if __name__ == '__main__':
    main()
