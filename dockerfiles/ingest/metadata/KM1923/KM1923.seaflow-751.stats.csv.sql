CREATE TABLE IF NOT EXISTS seaflow751_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  temp DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  par DOUBLE PRECISION,
  stream_pressure DOUBLE PRECISION,
  file_duration DOUBLE PRECISION,
  event_rate DOUBLE PRECISION,
  opp_evt_ratio DOUBLE PRECISION,
  pop TEXT,
  n_count DOUBLE PRECISION,
  chl_med DOUBLE PRECISION,
  pe_med DOUBLE PRECISION,
  fsc_med DOUBLE PRECISION,
  diam_mid_med DOUBLE PRECISION,
  Qc_mid_med DOUBLE PRECISION,
  quantile DOUBLE PRECISION,
  flag DOUBLE PRECISION,
  flow_rate DOUBLE PRECISION
);

SELECT create_hypertable('seaflow751_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW seaflow751 AS
  SELECT
    time_bucket('1m', seaflow751_raw.time) AS time,
    pop,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(temp) as temp,
    avg(salinity) as salinity,
    avg(par) as par,
    avg(stream_pressure) as stream_pressure,
    avg(file_duration) as file_duration,
    avg(event_rate) as event_rate,
    avg(opp_evt_ratio) as opp_evt_ratio,
    avg(n_count) as n_count,
    avg(chl_med) as chl_med,
    avg(pe_med) as pe_med,
    avg(fsc_med) as fsc_med,
    avg(diam_mid_med) as diam_mid_med,
    avg(Qc_mid_med) as Qc_mid_med,
    avg(quantile) as quantile,
    avg(flag) as flag,
    avg(flow_rate) as flow_rate
  FROM seaflow751_raw
  GROUP BY 1, 2
  ORDER BY 1;

CREATE OR REPLACE VIEW seaflow751_geo AS
  SELECT
    a.time,
    a.lat AS seaflow751_lat,
    a.lon AS seaflow751_lon,
    a.temp,
    a.salinity,
    a.par,
    a.stream_pressure,
    a.file_duration,
    a.event_rate,
    a.opp_evt_ratio,
    a.n_count,
    a.chl_med,
    a.pe_med,
    a.fsc_med,
    a.diam_mid_med,
    a.Qc_mid_med,
    a.quantile,
    a.flag,
    a.flow_rate,
    a.pop,
    b.lat,
    b.lon
  FROM seaflow751 AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
