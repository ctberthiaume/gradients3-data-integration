CREATE TABLE IF NOT EXISTS tsgraw_raw (
  time TIMESTAMPTZ NOT NULL,
  temp1 DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  sound_velocity DOUBLE PRECISION,
  temp2 DOUBLE PRECISION
);

SELECT create_hypertable('tsgraw_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW tsgraw AS
  SELECT
    time_bucket('1m', tsgraw_raw.time) AS time,
    avg(temp1) as temp1,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(sound_velocity) as sound_velocity,
    avg(temp2) as temp2
  FROM tsgraw_raw
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
  FROM tsgraw AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
