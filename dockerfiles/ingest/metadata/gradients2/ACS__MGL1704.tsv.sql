CREATE TABLE IF NOT EXISTS acs_raw (
  time TIMESTAMPTZ NOT NULL,
  CHL DOUBLE PRECISION,
  cp650 DOUBLE PRECISION
);

SELECT create_hypertable('acs_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW acs AS
  SELECT
    time_bucket('1m', acs_raw.time) AS time,
    avg(CHL) as CHL,
    avg(cp650) as cp650
  FROM acs_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW acs_geo AS
  SELECT
    a.time,
    a.CHL,
    a.cp650,
    b.lat,
    b.lon
  FROM acs AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
