#!/bin/bash
# One-time setup of backup container
#
# Requires env vars:
# MINIO_ACCESS_KEY xor MINIO_ACCESS_KEY_FILE
# MINIO_SECRET_KEY_FILE xor MINIO_SECRET_KEY
# MINIO_ENDPOINT (e.g. hostname:port, no protocol),
# BORG_PASSPHRASE xor BORG_PASSPHRASE_FILE, or BORG_PASSCOMMAND
# BORG_REPO (location of Borg repo, could be a mounted volume)
# FILECACHE_DIR (directory / volume mount point to store minio cached files)

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
# MINIO_ACCESS_KEY_FILE or MINIO_ACCESS_KEY
# MINIO_SECRET_KEY_FILE or MINIO_SECRET_KEY
file_env "BORG_PASSPHRASE"  # or use BORG_PASSCOMMAND
file_env "MINIO_ACCESS_KEY"
file_env "MINIO_SECRET_KEY"

# Where we cache files
[ -n "$FILECACHE_DIR" ] && mkdir "$FILECACHE_DIR" 2>/dev/null

# Wait for minio
minio_status=$(curl -s -w "%{http_code}" "http://$MINIO_ENDPOINT/minio/health/ready")
until [[ $minio_status -eq 200 ]]; do
    echo "$MINIO_ENDPOINT - not ready, status $minio_status"
    sleep 5
    minio_status=$(curl -s -w "%{http_code}" "http://$MINIO_ENDPOINT/minio/health/ready")
done
echo "$MINIO_ENDPOINT - ready, status $minio_status"

# Create minio host config
# Make sure default minio bucket is created
set +o history
mc config host add minio "http://$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" --api "s3v4"
set -o history
mc ls minio/

exec /usr/local/bin/supercronic /app/crontab
