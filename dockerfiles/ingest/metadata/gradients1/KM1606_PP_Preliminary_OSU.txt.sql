CREATE TABLE IF NOT EXISTS pp_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  sst DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  PP DOUBLE PRECISION,
  over_point7_micron_P DOUBLE PRECISION
);

SELECT create_hypertable('pp_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW pp AS
  SELECT
    time_bucket('1m', pp_raw.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(sst) as sst,
    avg(salinity) as salinity,
    avg(PP) as PP,
    avg(over_point7_micron_P) as over_point7_micron_P
  FROM pp_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW pp_geo AS
  SELECT
    a.time,
    a.lat AS pp_lat,
    a.lon AS pp_lon,
    a.sst,
    a.salinity,
    a.PP,
    a.over_point7_micron_P,
    b.lat,
    b.lon
  FROM pp AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
