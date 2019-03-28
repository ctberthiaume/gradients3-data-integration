CREATE TABLE IF NOT EXISTS po4 (
  time TIMESTAMPTZ NOT NULL,
  PO4 DOUBLE PRECISION
);

SELECT create_hypertable('po4', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW po4_1m AS
  SELECT
    time_bucket('1m', po4.time) AS time,
    avg(PO4) as PO4
  FROM po4
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW po4_geo AS
  SELECT
    a.time,
    a.PO4,
    b.lat,
    b.lon
  FROM po4_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
