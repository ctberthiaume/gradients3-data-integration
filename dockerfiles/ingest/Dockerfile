FROM ubuntu:18.04
MAINTAINER Chris Berthiaume <chrisbee@uw.edu>

# rsync isn't needed, but installing it just in case
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y python3-pip postgresql-client-10 nano curl rsync \
    && rm -rf /var/lib/apt/lists/*

COPY ./timescaledb-parallel-copy.linux-amd64 /usr/local/bin/timescaledb-parallel-copy
COPY ./supercronic-linux-amd64 /usr/local/bin/supercronic
COPY ./mc.linux-amd64 /usr/local/bin/mc
COPY ./requirements.txt /

RUN pip3 install -r /requirements.txt \
    && rm /requirements.txt \
    && mkdir /app

# Source dir for this repo should be mounted at /app

# For click python 3 text encoding compat
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Run command directly from source directory mounted from host
# system to make sure we can make changes at sea without
# rebuilding base image.
CMD ["/app/run.sh"]
