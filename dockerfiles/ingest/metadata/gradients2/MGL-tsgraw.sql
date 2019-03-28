CREATE TABLE IF NOT EXISTS tsgraw (
  time TIMESTAMPTZ NOT NULL,
  temp1 DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  sound_velocity DOUBLE PRECISION,
  temp2 DOUBLE PRECISION
);

SELECT create_hypertable('tsgraw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW tsgraw_1m AS
  SELECT
    time_bucket('1m', tsgraw.time) AS time,
    avg(temp1) as temp1,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(sound_velocity) as sound_velocity,
    avg(temp2) as temp2
  FROM tsgraw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW tsgraw_geo AS
  SELECT
    a.time,
    a.temp1,
    a.conductivity,
    a.salinity,
    a.sound_velocity,
    a.temp2,
    b.lat,
    b.lon
  FROM tsgraw_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
