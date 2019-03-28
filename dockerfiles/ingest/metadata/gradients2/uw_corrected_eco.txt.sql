CREATE TABLE IF NOT EXISTS eco (
  time TIMESTAMPTZ NOT NULL,
  CHL DOUBLE PRECISION,
  Scattering DOUBLE PRECISION,
  CDOM DOUBLE PRECISION
);

SELECT create_hypertable('eco', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW eco_1m AS
  SELECT
    time_bucket('1m', eco.time) AS time,
    avg(CHL) as CHL,
    avg(Scattering) as Scattering,
    avg(CDOM) as CDOM
  FROM eco
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
  FROM eco_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
