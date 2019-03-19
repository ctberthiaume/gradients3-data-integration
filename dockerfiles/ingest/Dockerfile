FROM ubuntu:18.04
MAINTAINER Chris Berthiaume <chrisbee@uw.edu>

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y python3-pip postgresql-client-10 nano \
    && rm -rf /var/lib/apt/lists/*

COPY ./timescaledb-parallel-copy.linux-amd64 /usr/local/bin/timescaledb-parallel-copy
COPY ./supercronic-linux-amd64 /usr/local/bin/supercronic
COPY ./requirements.txt ./run.sh /

RUN pip3 install -r /requirements.txt \
    && rm /requirements.txt \
    && mkdir /app

# Source dir for this repo should be mounted at /app

# For click python 3 text encoding compat
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

CMD ["/run.sh"]
