CREATE TABLE IF NOT EXISTS geo_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  alt DOUBLE PRECISION,
  sat DOUBLE PRECISION
);

SELECT create_hypertable('geo_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW geo AS
  SELECT
    time_bucket('1m', geo_raw.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(alt) as alt,
    avg(sat) as sat
  FROM geo_raw
  GROUP BY 1
  ORDER BY 1;
