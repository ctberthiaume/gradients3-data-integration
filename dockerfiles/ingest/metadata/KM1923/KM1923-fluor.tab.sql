CREATE TABLE IF NOT EXISTS fluor_raw (
  time TIMESTAMPTZ NOT NULL,
  fluor DOUBLE PRECISION
);

SELECT create_hypertable('fluor_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW fluor AS
  SELECT
    time_bucket('1m', fluor_raw.time) AS time,
    avg(fluor) as fluor
  FROM fluor_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW fluor_geo AS
  SELECT
    a.time,
    a.fluor,
    b.lat,
    b.lon
  FROM fluor AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
