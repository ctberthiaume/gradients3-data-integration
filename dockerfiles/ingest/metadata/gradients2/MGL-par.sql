CREATE TABLE IF NOT EXISTS par (
  time TIMESTAMPTZ NOT NULL,
  par DOUBLE PRECISION,
  temp DOUBLE PRECISION,
  salinity DOUBLE PRECISION
);

SELECT create_hypertable('par', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW par_15m AS
  SELECT
    time_bucket('15m', par.time) AS time,
    avg(par) as par,
    avg(temp) as temp,
    avg(salinity) as salinity
  FROM par
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW par_15m_geo AS
  SELECT
    a.time,
    a.par,
    a.temp,
    a.salinity,
    b.lat,
    b.lon
  FROM par_15m AS a
  INNER JOIN geo_15m AS b
  ON a.time = b.time
  ORDER BY 1;
