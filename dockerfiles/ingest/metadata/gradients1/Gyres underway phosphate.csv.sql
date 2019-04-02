CREATE TABLE IF NOT EXISTS po4_raw (
  time TIMESTAMPTZ NOT NULL,
  sample DOUBLE PRECISION,
  depth DOUBLE PRECISION,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  po4 DOUBLE PRECISION
);

SELECT create_hypertable('po4_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW po4 AS
  SELECT
    time_bucket('1m', po4_raw.time) AS time,
    avg(sample) as sample,
    avg(depth) as depth,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(po4) as po4
  FROM po4_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW po4_geo AS
  SELECT
    a.time,
    a.sample,
    a.depth,
    a.lat AS po4_lat,
    a.lon AS po4_lon,
    a.po4,
    b.lat,
    b.lon
  FROM po4 AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
