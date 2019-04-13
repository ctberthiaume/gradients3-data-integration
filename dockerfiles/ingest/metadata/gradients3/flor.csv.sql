CREATE TABLE IF NOT EXISTS flor_raw (
  time TIMESTAMPTZ NOT NULL,
  flor DOUBLE PRECISION
);

SELECT create_hypertable('flor_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW flor AS
  SELECT
    time_bucket('1m', flor_raw.time) AS time,
    avg(flor) as flor
  FROM flor_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW flor_geo AS
  SELECT
    a.time,
    a.flor,
    b.lat,
    b.lon
  FROM flor AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
