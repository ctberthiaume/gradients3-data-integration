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

# Load secrets from files with this script in Docker secrets
# fashion.
. /app/load_secrets.sh

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
