CREATE TABLE IF NOT EXISTS eco_raw (
  time TIMESTAMPTZ NOT NULL,
  CHL DOUBLE PRECISION,
  Scattering DOUBLE PRECISION,
  CDOM DOUBLE PRECISION
);

SELECT create_hypertable('eco_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW eco AS
  SELECT
    time_bucket('1m', eco_raw.time) AS time,
    avg(CHL) as CHL,
    avg(Scattering) as Scattering,
    avg(CDOM) as CDOM
  FROM eco_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW eco_geo AS
  SELECT
    a.time,
    a.CHL,
    a.Scattering,
    a.CDOM,
    b.lat,
    b.lon
  FROM eco AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
