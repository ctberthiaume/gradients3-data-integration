CREATE TABLE IF NOT EXISTS acs (
  time TIMESTAMPTZ NOT NULL,
  CHL DOUBLE PRECISION,
  cp650 DOUBLE PRECISION
);

SELECT create_hypertable('acs', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW acs_1m AS
  SELECT
    time_bucket('1m', acs.time) AS time,
    avg(CHL) as CHL,
    avg(cp650) as cp650
  FROM acs
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW acs_geo AS
  SELECT
    a.time,
    a.CHL,
    a.cp650,
    b.lat,
    b.lon
  FROM acs_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
