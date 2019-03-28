CREATE TABLE IF NOT EXISTS geo (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  alt DOUBLE PRECISION,
  sat DOUBLE PRECISION
);

SELECT create_hypertable('geo', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW geo_1m AS
  SELECT
    time_bucket('1m', geo.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(alt) as alt,
    avg(sat) as sat
  FROM geo
  GROUP BY 1
  ORDER BY 1;
