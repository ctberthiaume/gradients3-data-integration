CREATE TABLE IF NOT EXISTS tsg_par (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  ocean_tmp DOUBLE PRECISION,
  par DOUBLE PRECISION
);

SELECT create_hypertable('tsg_par', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW tsg_par_1m AS
  SELECT
    time_bucket('1m', tsg_par.time) AS time,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(conductivity) as conductivity,
    avg(salinity) as salinity,
    avg(ocean_tmp) as ocean_tmp,
    avg(par) as par
  FROM tsg_par
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW tsg_par_geo AS
  SELECT
    a.time,
    a.lat AS tsg_par_lat,
    a.lon AS tsg_par_lon,
    a.conductivity,
    a.salinity,
    a.ocean_tmp,
    a.par,
    b.lat,
    b.lon
  FROM tsg_par_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
