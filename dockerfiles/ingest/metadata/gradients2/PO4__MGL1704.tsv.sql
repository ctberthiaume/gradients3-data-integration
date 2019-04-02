CREATE TABLE IF NOT EXISTS po4_raw (
  time TIMESTAMPTZ NOT NULL,
  PO4 DOUBLE PRECISION
);

SELECT create_hypertable('po4_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW po4 AS
  SELECT
    time_bucket('1m', po4_raw.time) AS time,
    avg(PO4) as PO4
  FROM po4_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW po4_geo AS
  SELECT
    a.time,
    a.PO4,
    b.lat,
    b.lon
  FROM po4 AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
