#!/bin/bash

export PGPASSWORD=$ROPASSWORD
export PGUSER=$ROUSER
export PGDATABASE=gradients3
OUTDIR="$OUTPUT_DIR/$MINIO_BINNED_BUCKET"

[ ! -d "$OUTDIR" ] && mkdir "$OUTDIR"

echo "time,lat,lon,alt,sat" >"$OUTDIR/nav.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', geo_raw.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(alt) as alt,
    avg(sat) as sat
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

echo "time,ocean_temp,conductivity,salinity,remote_temp" >"$OUTDIR/uthsl.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', uthsl_raw.time) AS time,
    avg(ocean_temp) as ocean_temp,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(remote_temp) as remote_temp
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

echo "time,flor" >"$OUTDIR/flor.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', flor_raw.time) AS time,
    avg(flor) as flor
FROM flor_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/flor.csv"

echo "time,lat,lon,pop,stream_pressure,file_duration,event_rate,opp_evt_ratio,n_count,chl_small,pe,fsc_small,diam_mid,Qc_mid,quantile,flow_rate,abundance" >"$OUTDIR/seaflow740.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('1m', seaflow740_geo.time) AS time,
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
FROM seaflow740_geo
WHERE quantile = 50
GROUP BY 1, 4
ORDER BY 1;
" >>"$OUTDIR/seaflow740.csv"

echo "time,Lat,Lon,Temp,Sal,Biosat,O2conc,O2sat" >"$OUTDIR/g3_o2ar.txt.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', o2ar_raw.time) AS time,
    avg(Lat) as Lat,
    avg(Lon) as Lon,
    avg(Temp) as Temp,
    avg(Sal) as Sal,
    avg(Biosat) as Biosat,
    avg(O2conc) as O2conc,
    avg(O2sat) as O2sat
FROM o2ar_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/g3_o2ar.txt.csv"

echo "time,CHL,cp650" >"$OUTDIR/KM1906_uw_prelim_acs.txt.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', acs_raw.time) AS time,
    avg(CHL) as CHL,
    avg(cp650) as cp650
FROM acs_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/KM1906_uw_prelim_acs.txt.csv"

echo "time,CHL_F,bbp,cdom" >"$OUTDIR/KM1906_uw_prelim_ecotriplet.txt.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', eco_raw.time) AS time,
    avg(CHL_F) as CHL_F,
    avg(bbp) as bbp,
    avg(cdom) as cdom
FROM eco_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/KM1906_uw_prelim_ecotriplet.txt.csv"

echo "time,CHL_F,bbp,cdom" >"$OUTDIR/KM1906_uw_prelim_LISST.txt.csv"
psql -t -A -F"," -c "
SELECT
    time_bucket('30m', lisst_raw.time) AS time,
    avg(POC_1point25_2um) as POC_1point25_2um,
    avg(POC_2_20um) as POC_2_20um,
    avg(POC_20_100um) as POC_20_100um
FROM lisst_raw
GROUP BY 1
ORDER BY 1;
" >>"$OUTDIR/KM1906_uw_prelim_LISST.txt.csv"

mc cp --recursive -q "$OUTDIR"/*.csv minio/"$MINIO_BINNED_BUCKET/"

