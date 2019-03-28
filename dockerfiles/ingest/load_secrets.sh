#!/bin/bash

# Taken from postgres docker startup script to handle
# docker secrets from file.
# https://github.com/docker-library/postgres/blob/ef04f3055bab11b10d3d5c41a659acfacf2c850b/10/docker-entrypoint.sh
#
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

# Environment variables for secrets
# PGPASSWORD_FILE or PGPASSWORD
# ROPASSWORD_FILE or ROPASSWORD
# MINIO_ACCESS_KEY_FILE or MINIO_ACCESS_KEY
# MINIO_SECRET_KEY_FILE or MINIO_SECRET_KEY
file_env "PGPASSWORD"
file_env "ROPASSWORD"
file_env "MINIO_ACCESS_KEY"
file_env "MINIO_SECRET_KEY"
