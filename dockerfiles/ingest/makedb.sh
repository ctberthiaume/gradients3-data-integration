#!/bin/bash
# Create basic structure of PostgreSQL/TimescaleDB database for a cruise
#
# Requirements:
# * psql client
# * environment variables PGHOST, PGUSER, PGPASSWORD, ROUSER, ROPASSWORD

# Create role if doesn't exist
uexists=$(psql postgres -tc "SELECT count(1) FROM pg_roles WHERE rolname='$ROUSER'")
if [ $uexists -eq 0 ]; then
    echo "making role $ROUSER"
    psql postgres -c "CREATE ROLE $ROUSER WITH LOGIN PASSWORD '$ROPASSWORD' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';"
fi

# Load DBNAMES. Need to handle here because arrays can't be loaded
# into environment, but file path can.
. "$DBNAMES_FILE"
for DBNAME in "${DBNAMES[@]}"; do
    # Make the database
    # Bit of a hack to do "IF NOT EXISTS"
    dbexists=$(psql postgres -tc "SELECT count(1) FROM pg_catalog.pg_database WHERE datname = '$DBNAME'")
    if [ $dbexists -eq 0 ]; then
        echo "making db $DBNAME"
        psql postgres <<EOF
CREATE DATABASE $DBNAME;
EOF
    fi
    psql "$DBNAME" <<EOF
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
EOF
    psql "$DBNAME" <<EOF
GRANT CONNECT ON DATABASE $DBNAME TO $ROUSER;
GRANT USAGE ON SCHEMA public TO $ROUSER;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $ROUSER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $ROUSER;
EOF
done

# # Make SeaFlow table
# #./csv2table.py --text-columns cruise,file,pop seaflow \
# #  instrument-files/seaflow_MGL1704/prelim-stat.csv

# # Make nav table
# #./csv2table.py nav instrument-files/nav.csv

# # Make par table
# #./csv2table.py par instrument-files/par.csv

