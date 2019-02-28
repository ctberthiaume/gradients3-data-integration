import click
import os
import pendulum
import sys


@click.command()
@click.argument('input', type=click.File(mode='r', encoding='utf-8'), nargs=-1)
def main(input):
    header = ['time', 'lat', 'lon']
    print(','.join(header))

    for f in input:
        for line in f:
            try:
                outputs = parse_cnav_gpgga(line)
            except Exception as e:
                print(os.linesep.join(["Error with line:", line.rstrip(), str(e), '']), file=sys.stderr)
            else:
                if outputs:
                    print(','.join(outputs))


def parse_cnav_gpgga(line):
    cols = line.rstrip().split('\t')
    time = parse_time(cols[1])
    data = cols[-1].split(',')
    if data[0] == '$GPGGA':
        lat, ns = data[2:4]
        lon, ew = data[4:6]
        latdd = ggalat2dd(lat, ns)
        londd = ggalon2dd(lon, ew)
        return [time.isoformat(), latdd, londd]
    return None


def parse_time(t):
    y, doy, h, m, s = t.split(':')
    second = int(float(s))
    microsecond = int((float(s) - second) * 1000000)
    dt = pendulum.datetime(int(y), 1, 1, hour=int(h), minute=int(m), second=second, microsecond=microsecond)
    dt = dt.add(days=int(doy)-1)
    return dt


def ggalat2dd(coord, ewns):
    """GGA latitude string to decimal degrees string.

    Precision to 4 decimal places (11.132 m)
    e.g. "2116.6922" -> "21.2782"
    """
    degrees = int(coord[:2])
    minutes = float(coord[2:])
    if degrees > 90 or minutes > 60:
        raise ValueError("Invalid GGA latitude string '{}'".format(coord))
    if ewns is 'N':
        sign = 1
    else:
        sign = -1
    return "{:.4f}".format(sign * (degrees + (minutes / 60.0)))


def ggalon2dd(coord, ewns):
    """GGA longitude string to decimal degrees string.

    Precision to 4 decimal places (11.132 m)
    e.g. "2116.6922" -> "21.2782"
    """
    degrees = int(coord[:3])
    minutes = float(coord[3:])
    if degrees > 180 or minutes > 60:
        raise ValueError("Invalid GGA longitude string '{}'".format(coord))
    if ewns is 'E':
        sign = 1
    else:
        sign = -1
    return "{:.4f}".format(sign * (degrees + (minutes / 60.0)))


if __name__ == '__main__':
    main()
