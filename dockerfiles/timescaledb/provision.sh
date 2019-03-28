#!/bin/bash -e
# Run after the container boots to configure db workers. These
# changes require a container reboot
# e.g.
# docker service scale stack_timescaledb=0
# docker service scale stack_timescaledb=1

if [ $# -lt 1 ]; then
    conffile=/var/lib/postgresql/data/postgresql.conf
else
    if [ ! -f "$1" ]; then
        echo "file does not exist"
        exit
    fi
    conffile=$1
fi

echo "original postgresql.conf worker values"
echo "======================================"
grep '^max_worker_processes =' "$conffile"
grep '^max_parallel_workers =' "$conffile"
grep '^timescaledb\.max_background_workers =' "$conffile"
echo ""
echo "new values to be set"
echo "===================="
echo "setting max_worker_processes = 12"
echo "setting max_parallel_workers = 3"
echo "timescaledb.max_background_workers = 7"

sed \
    -i \
    -e 's/^max_worker_processes = .*/max_worker_processes = 12/; s/^max_parallel_workers = .*/max_parallel_workers = 3/; s/^timescaledb\.max_background_workers = .*/timescaledb\.max_background_workers = 7/' \
    "$conffile"

echo ""
echo "confirm new values"
echo "=================="
grep '^max_worker_processes =' "$conffile"
grep '^max_parallel_workers =' "$conffile"
grep '^timescaledb\.max_background_workers =' "$conffile"
