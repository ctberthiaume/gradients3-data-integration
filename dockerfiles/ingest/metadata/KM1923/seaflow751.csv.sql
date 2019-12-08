CREATE TABLE IF NOT EXISTS seaflow751_raw (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  pop TEXT,
  stream_pressure DOUBLE PRECISION,
  file_duration DOUBLE PRECISION,
  event_rate DOUBLE PRECISION,
  opp_evt_ratio DOUBLE PRECISION,
  n_count DOUBLE PRECISION,
  chl_med DOUBLE PRECISION,
  pe_med DOUBLE PRECISION,
  fsc_med DOUBLE PRECISION,
  diam_mid_med DOUBLE PRECISION,
  Qc_mid_med DOUBLE PRECISION,
  quantile DOUBLE PRECISION,
  flow_rate DOUBLE PRECISION
);

SELECT create_hypertable('seaflow751_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW seaflow751_file_ratios AS
SELECT
time_bucket('1m', seaflow751_raw.time) AS time,
avg(opp_evt_ratio) as opp_evt_ratio
FROM seaflow751_raw
WHERE quantile = 50
GROUP BY 1
ORDER BY 1;

CREATE OR REPLACE VIEW seaflow751 AS
  SELECT
    time_bucket('1m', seaflow751_raw.time) AS time,
    pop,
    avg(lat) as lat,
    avg(lon) as lon,
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
    avg(flow_rate) as flow_rate,
    avg(n_count) / (1000 * (select percentile_cont(0.5) within group (order by opp_evt_ratio) from seaflow751_file_ratios) * avg(flow_rate) * (avg(file_duration) / 60)) as abundance_picoeuk,
    avg(n_count) / (1000 * avg(opp_evt_ratio) * avg(flow_rate) * (avg(file_duration)/60)) as abundance
  FROM seaflow751_raw
  GROUP BY 1, 2
  ORDER BY 1;

CREATE OR REPLACE VIEW seaflow751_geo AS
  SELECT
    a.time,
    a.lat AS seaflow751_lat,
    a.lon AS seaflow751_lon,
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
    a.flow_rate,
    a.abundance_picoeuk,
    a.abundance,
    a.pop,
    b.lat,
    b.lon
  FROM seaflow751 AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
