CREATE TABLE IF NOT EXISTS underway_raw (
  time TIMESTAMPTZ NOT NULL,
  par DOUBLE PRECISION,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  heading DOUBLE PRECISION,
  speed DOUBLE PRECISION,
  bow_temp DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  lab_temp DOUBLE PRECISION,
  fluor DOUBLE PRECISION
);

SELECT create_hypertable('underway_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW underway AS
  SELECT
    time_bucket('1m', underway_raw.time) AS time,
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
