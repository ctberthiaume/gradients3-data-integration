#!/bin/bash

export PGPASSWORD=$ROPASSWORD
export PGUSER=$ROUSER
# Should have been set elsewhere by the time export runs
#PGDATABASE=$CURRENT_CRUISE
OUTDIR="$OUTPUT_DIR/$MINIO_BINNED_BUCKET"

[ ! -d "$OUTDIR" ] && mkdir "$OUTDIR"
rm "$OUTDIR"/*.csv 2>/dev/null

echo "time,par,lat,lon,heading,speed,bow_temp,conductivity,salinity,lab_temp,fluor" >"$OUTDIR/underway.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', underway_raw.time) AS time,
    avg(par) as par,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(heading) as heading,
    avg(speed) as speed,
    avg(bow_temp) as bow_temp,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(lab_temp) as lab_temp,
    avg(fluor) as fluor
FROM underway_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/underway.csv"

echo "time,lat,lon,pop,stream_pressure,file_duration,event_rate,opp_evt_ratio,n_count,chl,pe,fsc,diameter,Qc,quantile,flow_rate" >"$OUTDIR/seaflow751.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', seaflow751_geo.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    pop,
    avg(stream_pressure) as stream_pressure,
    avg(file_duration) as file_duration,
    avg(event_rate) as event_rate,
    avg(opp_evt_ratio) as opp_evt_ratio,
    avg(n_count) as n_count,
    avg(chl) as chl,
    avg(pe) as pe,
    avg(fsc) as fsc,
    avg(diameter) as diameter,
    avg(Qc) as Qc,
    avg(quantile) as quantile,
    avg(flow_rate) as flow_rate
FROM seaflow751_geo
WHERE quantile = 50
GROUP BY 1, 4
ORDER BY 1, 4;
" >>"$OUTDIR/seaflow751.csv"

mc cp --recursive -q "$OUTDIR"/*.csv minio/"$MINIO_BINNED_BUCKET/"
