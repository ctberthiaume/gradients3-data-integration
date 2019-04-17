CREATE TABLE IF NOT EXISTS o2ar_raw (
  time TIMESTAMPTZ NOT NULL,
  Lat DOUBLE PRECISION,
  Lon DOUBLE PRECISION,
  Temp DOUBLE PRECISION,
  Sal DOUBLE PRECISION,
  Biosat DOUBLE PRECISION,
  O2conc DOUBLE PRECISION,
  O2sat DOUBLE PRECISION
);

SELECT create_hypertable('o2ar_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW o2ar AS
  SELECT
    time_bucket('1m', o2ar_raw.time) AS time,
    avg(Lat) as Lat,
    avg(Lon) as Lon,
    avg(Temp) as Temp,
    avg(Sal) as Sal,
    avg(Biosat) as Biosat,
    avg(O2conc) as O2conc,
    avg(O2sat) as O2sat
  FROM o2ar_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW o2ar_geo AS
  SELECT
    a.time,
    a.Lat AS o2ar_Lat,
    a.Lon AS o2ar_Lon,
    a.Temp,
    a.Sal,
    a.Biosat,
    a.O2conc,
    a.O2sat,
    b.lat,
    b.lon
  FROM o2ar AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
