#!/bin/bash -e
# Run as root after the container boots when configuration for
# dashboards or datasources changes. If the change is only to
# dashboard JSON then a no reboot is necessary. If the change is
# to anything in /etc then reboot the service.

# This doesn't seem ideal since the db password will be stored
# in /etc/grafana as world readable owned by root, as c set up
# by Grafana by default. But there's not really much to be done
# about it without a change from Grafana.

if [ -f "$ROPASSWORD__FILE" ]; then
    ROPASSWORD=$(< "$ROPASSWORD__FILE")
else
    echo "could not find read-only db user password file in env var ROPASSWORD__FILE"
    exit 1
fi

# If this container has a bind mount to external provisioning files at
# /app then copy them to the container. Also replace any
# templated credentials.
if [ -d /app/etc/grafana/provisioning/datasources ]; then
    echo "copying datasources configs"
    sed \
        -e "s/ROUSER/$ROUSER/g" \
        -e "s/ROPASSWORD/$ROPASSWORD/g" \
        /app/etc/grafana/provisioning/datasources/datasource.yaml \
        > /etc/grafana/provisioning/datasources/datasource.yaml
fi

if [ -d /app/etc/grafana/provisioning/dashboards ]; then
    echo "copying dashboard provider configs"
    cp /app/etc/grafana/provisioning/dashboards/providers.yaml \
        /etc/grafana/provisioning/dashboards
fi

if [ -d /app/var/lib/grafana/dashboards ]; then
    echo "copying dashboard configs"
    if [ ! -d /var/lib/grafana/dashboards ]; then
        mkdir /var/lib/grafana/dashboards
    fi
    cp /app/var/lib/grafana/dashboards/*.json \
        /var/lib/grafana/dashboards
    chown -R grafana:grafana /var/lib/grafana/dashboards/
fi

if [ -d /app/var/lib/grafana/plugins ]; then
    echo "copying plugins"
    for d in /app/var/lib/grafana/plugins/*; do
        if [ -d "$d" ]; then
            bname=$(basename "$d")
            echo "  - $bname"
            cp -r "$d" /var/lib/grafana/plugins/"$bname"
            chown -R grafana:grafana /var/lib/grafana/plugins/"$bname"
        fi
    done

fi
