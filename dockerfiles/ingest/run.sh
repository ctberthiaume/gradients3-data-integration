#!/bin/bash

# Load secrets from files with this script in Docker secrets
# fashion.
. /app/load_secrets.sh

# Wait for postgres to come up
until pg_isready; do
    sleep 5
done

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
# Load DBNAMES. Need to handle here because arrays can't be loaded
# into environment, but file path can.
. "$DBNAMES_FILE"
for DBNAME in "${DBNAMES[@]}"; do
    # NOTE: The final / is necessary to make a minio bucket!
    mc mb --ignore-existing minio/"$MINIO_INPUT_BUCKET/$DBNAME/"
    mc mb --ignore-existing minio/"$MINIO_PARSED_BUCKET/$DBNAME/"
done
mc ls minio/
mc ls --recursive minio/

# This script creates dbs, read_only role, and sets permissions
/app/makedb.sh

exec /usr/local/bin/supercronic /app/crontab