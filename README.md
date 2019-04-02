# Gradients 3 Cruise Data Integration application stack

This is a project to build a data ingest and visualization application
customized for the April 2019 Gradients 3 oceanographic cruise.

## Application components

* Docker (infrastructure)
* TimescaleDB (time series data management)
* Grafana (time series data visualization)
* Supercronic (Docker compatible cron for periodic processing)
* Python 3 scripts (data parsing and higher-level job wrappers)
* Minio (realtime cruise data uploads)
* Borg for backups

## Installation

* Clone this git repo somewhere
* Install Docker
* Pull the images used in this stack. I'm not sure why this is necessary, but just deploying the stack doesn't seem to reliably pull needed images.

```
docker pull grafana/grafana:6.0.0
docker pull ctberthiaume/ingest:gradients3
docker pull ctberthiaume/backup:gradients3
docker pull timescale/timescaledb:1.2.2-pg10
docker pull minio/minio:RELEASE.2019-03-20T22-38-47Z
```

## Usage

### Bring up the stack on a single node

First copy the `secrets_template` folder to `secrets` and change
passwords from the defaults.

Then start docker services

```
docker swarm init  # once
docker stack deploy -c docker-compose.dataintegration.yml di
```

To finish provisioning Grafana with any custom dashboards, datasources, plugins
located in `./dockerfiles/grafana/{etc,var}`, run bash as root on the Grafana container
and run `/app/provision.sh`. Assuming the stack is named `di` this runs the provisioning script and restarts Grafana.

```docker exec -it --user root $(docker ps | grep di_grafana | awk '{print $1}') bash -c '/app/provision.sh' && docker service scale di_grafana=0 && docker service scale di_grafana=1```

The official Timescaledb image warns that there aren't enough background workers.
See https://docs.timescale.com/v1.2/getting-started/configuring#workers.
To fix this update `/var/lib/postgresql/data/postgresql.conf` with the following values

```
max_worker_processes = 12
max_parallel_workers = 3
timescaledb.max_background_workers = 7
```

This can be done with `dockerfiles/timescaledb/provision.sh`

```
docker exec -it $(docker ps | grep di_timescaledb | awk '{print $1}') bash -c '/app/provision.sh' && docker service scale di_timescaledb=0 && docker service scale di_timescaledb=1
```

Bring up stack without querying a remote server to resolve image digest

```docker stack deploy --resolve-image never -c docker-compose.dataintegration.yml di```

To change the current cruise name

```docker service update --env-add CURRENT_CRUISE=gradients1 di_ingest```

This will restart the ingest service with a new CURRENT_CRUISE env var

To change the polling frequency of the ingest service, update `dockerfiles/ingest/crontab`
and then send SIGUSR2 signal to the main process in ingest (supercronic).
This will restart the service

```docker kill --signal SIGUSR2 container```

Bring down stack

```docker stack rm di```

Sometimes Docker leaves behind exited containers. Check with `docker container ls -a` and remove manually.

### Miscellaneous docker tasks

Mount a temporary container with an existing named storage volume

```docker run -it --rm --mount type=bind,src=$(pwd),dst=/mnt --mount type=volume,src=grafana-storage,dst=/gs ubuntu bash```

Use previous ephemeral docker container to add plugin files to grafana, starting from the plugin git repo containing a dist/ directory. Restart grafana after copy.

```docker run -it --rm --mount type=bind,src=$(pwd),dst=/mnt --mount type=volume,src=grafana-storage,dst=/gs ubuntu bash -c "rm -rf /gs/plugins/$(basename $(pwd))/* && cp -r /mnt/dist /gs/plugins/$(basename $(pwd)) && chown -R 472:472 /gs/plugins/$(basename $(pwd))"```

Start a temporary container to connect to postgres

```
docker run \
--net=host \
-it \
--rm \
-e "PGPASSWORD=password" \
timescale/timescaledb:latest-pg10 \
psql -h localhost -U postgres
```

## TimescaleDB data import

Fast CSV importer

```go get github.com/timescale/timescaledb-parallel-copy/cmd/timescaledb-parallel-copy

PGPASSWORD=password timescaledb-parallel-copy --copy-options "NULL 'NA' CSV HEADER" -db-name gradients2 -table seaflow -file instrument-files/seaflow_MGL1704/prelim-stat.csv --truncate

PGPASSWORD=password timescaledb-parallel-copy --copy-options "CSV HEADER" -db-name gradients2 -table nav -file instrument-files/nav.csv --truncate

PGPASSWORD=password timescaledb-parallel-copy --copy-options "CSV HEADER" -db-name gradients2 -table par -file instrument-files/par.csv --truncate
```

