CREATE TABLE IF NOT EXISTS par_raw (
  time TIMESTAMPTZ NOT NULL,
  par DOUBLE PRECISION
);

SELECT create_hypertable('par_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW par AS
  SELECT
    time_bucket('1m', par_raw.time) AS time,
    avg(par) as par
  FROM par_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW par_geo AS
  SELECT
    a.time,
    a.par,
    b.lat,
    b.lon
  FROM par AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
