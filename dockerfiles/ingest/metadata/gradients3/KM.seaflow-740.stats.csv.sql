CREATE TABLE IF NOT EXISTS seaflow740_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  temp DOUBLE PRECISION,
  salinity DOUBLE PRECISION,
  conductivity DOUBLE PRECISION,
  par DOUBLE PRECISION,
  stream_pressure DOUBLE PRECISION,
  file_duration DOUBLE PRECISION,
  event_rate DOUBLE PRECISION,
  opp_evt_ratio DOUBLE PRECISION,
  pop TEXT,
  n_count DOUBLE PRECISION,
  chl_small DOUBLE PRECISION,
  pe DOUBLE PRECISION,
  fsc_small DOUBLE PRECISION,
  diam_lwr DOUBLE PRECISION,
  diam_mid DOUBLE PRECISION,
  diam_upr DOUBLE PRECISION,
  Qc_lwr DOUBLE PRECISION,
  Qc_mid DOUBLE PRECISION,
  Qc_upr DOUBLE PRECISION,
  quantile DOUBLE PRECISION,
  flag DOUBLE PRECISION,
  flow_rate DOUBLE PRECISION,
  flow_rate_se DOUBLE PRECISION,
  abundance DOUBLE PRECISION,
  abundance_se DOUBLE PRECISION
);

SELECT create_hypertable('seaflow740_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW seaflow740 AS
  SELECT
    time_bucket('1m', seaflow740_raw.time) AS time,
    pop,
    avg(lat) as lat,
    avg(lon) as lon,
    avg(temp) as temp,
    avg(salinity) as salinity,
    avg(conductivity) as conductivity,
    avg(par) as par,
    avg(stream_pressure) as stream_pressure,
    avg(file_duration) as file_duration,
    avg(event_rate) as event_rate,
    avg(opp_evt_ratio) as opp_evt_ratio,
    avg(n_count) as n_count,
    avg(chl_small) as chl_small,
    avg(pe) as pe,
    avg(fsc_small) as fsc_small,
    avg(diam_lwr) as diam_lwr,
    avg(diam_mid) as diam_mid,
    avg(diam_upr) as diam_upr,
    avg(Qc_lwr) as Qc_lwr,
    avg(Qc_mid) as Qc_mid,
    avg(Qc_upr) as Qc_upr,
    avg(quantile) as quantile,
    avg(flag) as flag,
    avg(flow_rate) as flow_rate,
    avg(flow_rate_se) as flow_rate_se,
    avg(abundance) as abundance,
    avg(abundance_se) as abundance_se
  FROM seaflow740_raw
  GROUP BY 1, 2
  ORDER BY 1;

CREATE OR REPLACE VIEW seaflow740_geo AS
  SELECT
    a.time,
    a.lat AS seaflow740_lat,
    a.lon AS seaflow740_lon,
    a.temp,
    a.salinity,
    a.conductivity,
    a.par,
    a.stream_pressure,
    a.file_duration,
    a.event_rate,
    a.opp_evt_ratio,
    a.n_count,
    a.chl_small,
    a.pe,
    a.fsc_small,
    a.diam_lwr,
    a.diam_mid,
    a.diam_upr,
    a.Qc_lwr,
    a.Qc_mid,
    a.Qc_upr,
    a.quantile,
    a.flag,
    a.flow_rate,
    a.flow_rate_se,
    a.abundance,
    a.abundance_se,
    a.pop,
    b.lat,
    b.lon
  FROM seaflow740 AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
