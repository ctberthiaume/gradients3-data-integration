#!/usr/bin/env python3
import click
import os
import sys
import toml

lu = { 'text': 'TEXT', 'real': 'DOUBLE PRECISION', 'time': 'TIMESTAMPTZ NOT NULL' }

@click.command()
@click.option('--no-geo-join', default=False, is_flag=True, show_default=True,
    help="Don't produce the joined view to lat/lon, for example if this is the lat/lon data")
@click.argument('input', type=click.Path(exists=True), nargs=1)
def main(no_geo_join, input):
    with open(input, newline=None, encoding='utf-8') as f:
        toml_text = f.read()
    data = toml.loads(toml_text)
    print(create_table(data))
    print('')
    print(create_time_bucket_view(data))
    if not no_geo_join:
        print('')
        print(create_geo_join_view(data))


def create_table(data):
    sql_lines = ['CREATE TABLE IF NOT EXISTS {} ('.format(data['table'])]
    for i, f in enumerate(data['fields']):
        sql_lines.append('  {} {}'.format(f['name'], lu[f['type']]))
        if i < len(data['fields']) - 1:
            sql_lines[-1] += ','
    sql_lines.append(');')
    sql_lines.append('')
    sql_lines.append("SELECT create_hypertable('{}', 'time', if_not_exists := true);".format(data['table']))
    return os.linesep.join(sql_lines)


def create_time_bucket_view(data, bucket_width='1m'):
    real_fields = [x['name'] for x in data['fields'] if x['type'] == 'real']
    group_fields = [x['name'] for x in data['fields'] if x['type'] == 'text' and x['groupby']]
    sql_lines = ['CREATE OR REPLACE VIEW {}_{} AS'.format(data['table'], bucket_width)]
    sql_lines.append('  SELECT')
    sql_lines.append("    time_bucket('{}', {}.time) AS time".format(bucket_width, data['table']))

    for i, gf in enumerate(group_fields):
        sql_lines[-1] += ','
        sql_lines.append(f'    {gf}')

    for i, rf in enumerate(real_fields):
        sql_lines[-1] += ','
        sql_lines.append(f'    avg({rf}) as {rf}')
    
    sql_lines.append('  FROM {}'.format(data['table']))
    sql_lines.append('  GROUP BY 1')
    if group_fields:
        for i in range(len(group_fields)):
            sql_lines[-1] += f', {i+2}'
    sql_lines.append('  ORDER BY 1;')
    return os.linesep.join(sql_lines)


def create_geo_join_view(data, bucket_width='1m'):
    real_fields = [x['name'] for x in data['fields'] if x['type'] == 'real']
    group_fields = [x['name'] for x in data['fields'] if x['type'] == 'text' and x['groupby']]
    sql_lines = ['CREATE OR REPLACE VIEW {}_geo AS'.format(data['table'])]
    sql_lines.append('  SELECT')
    sql_lines.append("    a.time")
    for i, rf in enumerate(real_fields):
        sql_lines[-1] += ','
        if rf == 'lat' or rf == 'lon':
            sql_lines.append('    a.{} AS {}_{}'.format(rf, data['table'], rf))
        else:
            sql_lines.append(f'    a.{rf}')

    for i, gf in enumerate(group_fields):
        sql_lines[-1] += ','
        sql_lines.append(f'    a.{gf}')

    sql_lines[-1] += ','
    sql_lines.append('    b.lat')
    sql_lines[-1] += ','
    sql_lines.append('    b.lon')
    sql_lines.append('  FROM {}_{} AS a'.format(data['table'], bucket_width))
    sql_lines.append('  INNER JOIN geo_{} AS b'.format(bucket_width))
    sql_lines.append('  ON a.time = b.time')
    sql_lines.append('  ORDER BY 1;')
    return os.linesep.join(sql_lines)


if __name__ == '__main__':
    main()
