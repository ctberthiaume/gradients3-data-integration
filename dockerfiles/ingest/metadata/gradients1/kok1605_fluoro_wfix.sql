CREATE TABLE IF NOT EXISTS chl_fluor (
  time TIMESTAMPTZ NOT NULL,
  chl_fluor DOUBLE PRECISION
);

SELECT create_hypertable('chl_fluor', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW chl_fluor_1m AS
  SELECT
    time_bucket('1m', chl_fluor.time) AS time,
    avg(chl_fluor) as chl_fluor
  FROM chl_fluor
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW chl_fluor_geo AS
  SELECT
    a.time,
    a.chl_fluor,
    b.lat,
    b.lon
  FROM chl_fluor_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
