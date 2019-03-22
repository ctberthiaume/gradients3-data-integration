CREATE TABLE IF NOT EXISTS seaflow (
  cruise TEXT,
  file TEXT,
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  opp_evt_ratio DOUBLE PRECISION,
  flow_rate DOUBLE PRECISION,
  file_duration DOUBLE PRECISION,
  pop TEXT,
  n_count DOUBLE PRECISION,
  abundance DOUBLE PRECISION,
  fsc_small DOUBLE PRECISION,
  chl_small DOUBLE PRECISION,
  pe DOUBLE PRECISION
);

SELECT create_hypertable('seaflow', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW seaflow_1m AS
  SELECT
    time_bucket('1m', seaflow.time) AS time,
    pop,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(opp_evt_ratio) as opp_evt_ratio,
    avg(flow_rate) as flow_rate,
    avg(file_duration) as file_duration,
    avg(n_count) as n_count,
    avg(abundance) as abundance,
    avg(fsc_small) as fsc_small,
    avg(chl_small) as chl_small,
    avg(pe) as pe
  FROM seaflow
  GROUP BY 1, 2
  ORDER BY 1;

CREATE OR REPLACE VIEW seaflow_geo AS
  SELECT
    a.time,
    a.lat AS seaflow_lat,
    a.lon AS seaflow_lon,
    a.opp_evt_ratio,
    a.flow_rate,
    a.file_duration,
    a.n_count,
    a.abundance,
    a.fsc_small,
    a.chl_small,
    a.pe,
    a.pop,
    b.lat,
    b.lon
  FROM seaflow_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
