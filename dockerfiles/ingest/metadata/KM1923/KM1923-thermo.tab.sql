CREATE TABLE IF NOT EXISTS uthsl_raw (
  time TIMESTAMPTZ NOT NULL,
  bow_temp DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  lab_temp DOUBLE PRECISION
);

SELECT create_hypertable('uthsl_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW uthsl AS
  SELECT
    time_bucket('1m', uthsl_raw.time) AS time,
    avg(bow_temp) as bow_temp,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(lab_temp) as lab_temp
  FROM uthsl_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW uthsl_geo AS
  SELECT
    a.time,
    a.bow_temp,
    a.conductivity,
    a.salinity,
    a.lab_temp,
    b.lat,
    b.lon
  FROM uthsl AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
