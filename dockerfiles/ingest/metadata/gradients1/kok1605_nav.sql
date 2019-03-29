CREATE TABLE IF NOT EXISTS geo (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION
);

SELECT create_hypertable('geo', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW geo_1m AS
  SELECT
    time_bucket('1m', geo.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon
  FROM geo
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW geo_geo AS
  SELECT
    a.time,
    a.lat AS geo_lat,
    a.lon AS geo_lon,
    b.lat,
    b.lon
  FROM geo_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
