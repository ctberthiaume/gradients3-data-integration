FROM ubuntu:18.04

# rsync isn't needed, but installing it just in case
RUN apt-get update \
    && apt-get install -y nano curl locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Set up UTF-8 locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY ./supercronic-linux-amd64 /usr/local/bin/supercronic
COPY ./mc.linux-amd64 /usr/local/bin/mc
COPY ./borg-linux64 /usr/local/bin/borg

# Normally mount /app as host bind mount. This is where
# crontab and other code run from crontab lives.
RUN mkdir /app

CMD ["/app/run.sh"]
