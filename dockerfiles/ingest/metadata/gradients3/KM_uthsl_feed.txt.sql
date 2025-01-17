CREATE TABLE IF NOT EXISTS uthsl_raw (
  time TIMESTAMPTZ NOT NULL,
  ocean_temp DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  remote_temp DOUBLE PRECISION
);

SELECT create_hypertable('uthsl_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW uthsl AS
  SELECT
    time_bucket('1m', uthsl_raw.time) AS time,
    avg(ocean_temp) as ocean_temp,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(remote_temp) as remote_temp
  FROM uthsl_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW uthsl_geo AS
  SELECT
    a.time,
    a.ocean_temp,
    a.conductivity,
    a.salinity,
    a.remote_temp,
    b.lat,
    b.lon
  FROM uthsl AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
