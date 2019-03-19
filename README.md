# Gradients 3 Cruise Data Integration application stack

This is a project to build a data ingest and visualization application
customized for the April 2019 Gradients 3 oceanographic cruise.

## Application components

* Docker (infrastructure)
* TimescaleDB (time series data management)
* Grafana (time series data visualization)
* Supercronic (Docker compatible cron for periodic processing)
* Python 3 scripts (data parsing and higher-level job wrappers)
* Samba (realtime cruise data uploads)

## Usage

### Bring up the stack on a single node
docker swarm init  # once per reboot
docker stack deploy -c docker-compose.dataintegration.yml di

Bring up stack without querying a remote server to resolve image digest

```docker stack deploy --resolve-image never -c docker-compose.dataintegration.yml di```

Restart a service

```docker service scale di_grafana=0 && docker service scale di_grafana=1```

Bring down stack

```docker stack rm di```

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

