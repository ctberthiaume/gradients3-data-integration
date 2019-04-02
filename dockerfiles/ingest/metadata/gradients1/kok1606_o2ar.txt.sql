CREATE TABLE IF NOT EXISTS o2ar_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  temp DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  bio_sat DOUBLE PRECISION,
  NCP DOUBLE PRECISION,
  O2gasex DOUBLE PRECISION
);

SELECT create_hypertable('o2ar_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW o2ar AS
  SELECT
    time_bucket('1m', o2ar_raw.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(temp) as temp,
    avg(salinity) as salinity,
    avg(bio_sat) as bio_sat,
    avg(NCP) as NCP,
    avg(O2gasex) as O2gasex
  FROM o2ar_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW o2ar_geo AS
  SELECT
    a.time,
    a.lat AS o2ar_lat,
    a.lon AS o2ar_lon,
    a.temp,
    a.salinity,
    a.bio_sat,
    a.NCP,
    a.O2gasex,
    b.lat,
    b.lon
  FROM o2ar AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
