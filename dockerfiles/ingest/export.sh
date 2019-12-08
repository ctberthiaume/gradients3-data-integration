#!/bin/bash

export PGPASSWORD=$ROPASSWORD
export PGUSER=$ROUSER
# Should have been set elsewhere by the time export runs
#export PGDATABASE=$CURRENT_CRUISE
OUTDIR="$OUTPUT_DIR/$MINIO_BINNED_BUCKET"

[ ! -d "$OUTDIR" ] && mkdir "$OUTDIR"
rm "$OUTDIR"/*.csv 2>/dev/null

echo "time,lat,lon" >"$OUTDIR/nav.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', geo_raw.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon
FROM geo_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/nav.csv"

echo "time,knots" >"$OUTDIR/track.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', track_raw.time) AS time,
    avg(knots) as knots
FROM track_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/track.csv"

echo "time,bow_temp,conductivity,salinity,lab_temp" >"$OUTDIR/uthsl.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', uthsl_raw.time) AS time,
    avg(bow_temp) as bow_temp,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(lab_temp) as lab_temp
FROM uthsl_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/uthsl.csv"

echo "time,par" >"$OUTDIR/par.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', par_raw.time) AS time,
    avg(par) as par
FROM par_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/par.csv"

echo "time,fluor" >"$OUTDIR/flor.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', flor_raw.time) AS time,
    avg(fluor) as fluor
FROM fluor_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/flor.csv"

echo "time,lat,lon,pop,stream_pressure,file_duration,event_rate,opp_evt_ratio,n_count,chl_small,pe,fsc_small,diam_mid,Qc_mid,quantile,flow_rate,abundance" >"$OUTDIR/seaflow751.csv"
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
    avg(chl_small) as chl_small,
    avg(pe) as pe,
    avg(fsc_small) as fsc_small,
    avg(diam_mid) as diam_mid,
    avg(Qc_mid) as Qc_mid,
    avg(quantile) as quantile,
    avg(flow_rate) as flow_rate,
    avg(abundance) as abundance
FROM seaflow751_geo
WHERE quantile = 50
GROUP BY 1, 4
ORDER BY 1, 4;
" >>"$OUTDIR/seaflow751.csv"

mc cp --recursive -q "$OUTDIR"/*.csv minio/"$MINIO_BINNED_BUCKET/"
