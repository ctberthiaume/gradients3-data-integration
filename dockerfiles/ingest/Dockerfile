FROM ubuntu:18.04
MAINTAINER Chris Berthiaume <chrisbee@uw.edu>

# rsync isn't needed, but installing it just in case
RUN apt-get update \
    && apt-get install -y python3-pip postgresql-client-10 nano curl rsync locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Set up UTF-8 locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY ./timescaledb-parallel-copy.linux-amd64 /usr/local/bin/timescaledb-parallel-copy
COPY ./supercronic-linux-amd64 /usr/local/bin/supercronic
COPY ./mc.linux-amd64 /usr/local/bin/mc
COPY ./requirements.txt /

RUN pip3 install -r /requirements.txt \
    && rm /requirements.txt \
    && mkdir /app

# Source dir for this repo should be mounted at /app

# Run command directly from source directory mounted from host
# system to make sure we can make changes at sea without
# rebuilding base image.
CMD ["/app/run.sh"]
