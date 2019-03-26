#!/bin/bash
# 
# Requires env vars:
# GRAFANADB (location of grafana.db to backup, usually /var/lib/grafana/grafana.db)
# MINIO_ACCESS_KEY and MINIO_SECRET_KEY
# BORG_PASSPHRASE or BORG_PASSCOMMAND
# BORG_REPO (location of Borg repo, could be a mounted volume)
# FILECACHE_DIR (directory / volume mount point to store minio cached files)

# Upload grafana db to minio for backup
mc mb --ignore-existing minio/grafana-backup
mc cp -q "$GRAFANADB" minio/grafana-backup/

# Clear minio local file cache
if [ -n "$FILECACHE_DIR" -a -d "$FILECACHE_DIR" ]; then
    rm -rf "$FILECACHE_DIR"/*
fi

# Cache new buckets
for b in $(mc ls minio | awk '{print $NF}'); do
    mc cp --recursive -q minio/"$b" "$FILECACHE_DIR/$b"
done

# Hopefully BORG_REPO and BORG_PASSPHRASE or BORG_PASSCOMMAND are set by now
if ! borg info >/dev/null 2>&1; then
    borg init --encryption=repokey-blake2
    exitcode=$?
    echo "borg init finished with rc=$exitcode"
    if [ $exitcode -ne 0 ]; then
        exit $exitcode
    fi
fi

# Do the backup
# No need for borg files cache since we're re-downloading the buckets each time
borg create \
    --show-version \
    --stats \
    --list \
    --files-cache=disabled \
    -C auto,zstd \
    ::minio-{now:%Y-%m-%dT%H:%M:%S} \
    "$FILECACHE_DIR"
exitcode=$?
echo "borg create finished with rc=$exitcode"
if [ $exitcode -ne 0 ]; then
    exit $exitcode
fi

# Prune the repo
borg prune \
    --stats \
    --list \
    --keep-hourly 24 \
    --keep-daily 30
exitcode=$?
echo "borg prune finished with rc=$exitcode"
if [ $exitcode -ne 0 ]; then
    exit $exitcode
fi

# Check the repo
borg check
exitcode=$?
echo "borg check finished with rc=$exitcode"
if [ $exitcode -ne 0 ]; then
    exit $exitcode
fi
