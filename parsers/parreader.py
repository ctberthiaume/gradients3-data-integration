import click
import io
import os
import pendulum
import sys


@click.command()
@click.argument('input', type=click.File(mode='r', encoding='utf-8'), nargs=-1)
def main(input):
    header = ['time', 'par', 'temp', 'salinity']
    print(','.join(header))

    for f in input:
        for line in f:
            try:
                outputs = parse_par(line)
            except Exception as e:
                print(os.linesep.join(['Error with line:', line.rstrip(), str(e), '']), file=sys.stderr)
            else:
                if outputs:
                    print(','.join(outputs))


def parse_par(line):
    cols = line.rstrip().split('\t')
    time = parse_time(cols[1])
    par, temp, sal = [s.strip() for s in cols[-1].split(',')]
    # Are these floats?
    _, _, _ = float(par), float(temp), float(sal)
    return [time.isoformat(), par, temp, sal]


def parse_time(t):
    y, doy, h, m, s = t.split(':')
    second = int(float(s))
    microsecond = int((float(s) - second) * 1000000)
    dt = pendulum.datetime(int(y), 1, 1, hour=int(h), minute=int(m), second=second, microsecond=microsecond)
    dt = dt.add(days=int(doy)-1)
    return dt


if __name__ == '__main__':
    main()
