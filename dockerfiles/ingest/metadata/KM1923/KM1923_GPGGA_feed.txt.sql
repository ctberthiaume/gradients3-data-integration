CREATE TABLE IF NOT EXISTS geo_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION
);

SELECT create_hypertable('geo_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW geo AS
  SELECT
    time_bucket('1m', geo_raw.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon
  FROM geo_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW geo_geo AS
  SELECT
    a.time,
    a.lat AS geo_lat,
    a.lon AS geo_lon,
    b.lat,
    b.lon
  FROM geo AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
