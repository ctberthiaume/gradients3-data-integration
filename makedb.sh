#!/bin/sh
# Create basic structure of PostgreSQL/TimescaleDB database for a cruise
#
# Requirements:
# * psql client
# * environment variables PGHOST, PGUSER, PGPASSWORD

# Specify name for new database here
DBNAME=gradients2

# Make the database
# Bit of a hack to do "IF NOT EXISTS"
exists=$(psql -t -c "select count(1) from pg_catalog.pg_database where datname = '$DBNAME'")
if [ $exists -eq 0 ]; then
  psql <<EOF
CREATE DATABASE $DBNAME;
EOF
fi
psql "$DBNAME" <<EOF
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
EOF

# Make SeaFlow table
#./csv2table.py --text-columns cruise,file,pop seaflow \
#  instrument-files/seaflow_MGL1704/prelim-stat.csv

psql "$DBNAME" <<EOF
CREATE TABLE IF NOT EXISTS seaflow (
  cruise TEXT,
  file TEXT,
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  opp_evt_ratio DOUBLE PRECISION,
  flow_rate DOUBLE PRECISION,
  file_duration DOUBLE PRECISION,
  pop TEXT,
  n_count DOUBLE PRECISION,
  abundance DOUBLE PRECISION,
  fsc_small DOUBLE PRECISION,
  chl_small DOUBLE PRECISION,
  pe DOUBLE PRECISION
);
SELECT create_hypertable('seaflow', 'time');
EOF

# Make nav table
#./csv2table.py nav instrument-files/nav.csv

psql "$DBNAME" <<EOF
CREATE TABLE IF NOT EXISTS nav (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION
);
SELECT create_hypertable('nav', 'time');
EOF

# Make par table
#./csv2table.py par instrument-files/par.csv

psql "$DBNAME" <<EOF
CREATE TABLE IF NOT EXISTS par (
  time TIMESTAMPTZ NOT NULL,
  par DOUBLE PRECISION,
  temp DOUBLE PRECISION,
  salinity DOUBLE PRECISION
);
SELECT create_hypertable('par', 'time');
EOF
