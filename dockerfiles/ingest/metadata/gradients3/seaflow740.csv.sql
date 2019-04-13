CREATE TABLE IF NOT EXISTS seaflow740_raw (
  time TIMESTAMPTZ NOT NULL,
  pop TEXT,
  stream_pressure DOUBLE PRECISION,
  file_duration DOUBLE PRECISION,
  event_rate DOUBLE PRECISION,
  opp_evt_ratio DOUBLE PRECISION,
  n_count DOUBLE PRECISION,
  chl_small DOUBLE PRECISION,
  pe DOUBLE PRECISION,
  fsc_small DOUBLE PRECISION,
  diam_mid DOUBLE PRECISION,
  Qc_mid DOUBLE PRECISION,
  quantile DOUBLE PRECISION,
  flow_rate DOUBLE PRECISION,
  abundance DOUBLE PRECISION
);

SELECT create_hypertable('seaflow740_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW seaflow740 AS
  SELECT
    time_bucket('1m', seaflow740_raw.time) AS time,
    pop,
    avg(stream_pressure) as stream_pressure,
    avg(file_duration) as file_duration,
    avg(event_rate) as event_rate,
    avg(opp_evt_ratio) as opp_evt_ratio,
    avg(n_count) as n_count,
    avg(chl_small) as chl_small,
    avg(pe) as pe,
    avg(fsc_small) as fsc_small,
    avg(diam_mid) as diam_mid,
    avg(Qc_mid) as Qc_mid,
    avg(quantile) as quantile,
    avg(flow_rate) as flow_rate,
    avg(abundance) as abundance
  FROM seaflow740_raw
  GROUP BY 1, 2
  ORDER BY 1;

CREATE OR REPLACE VIEW seaflow740_geo AS
  SELECT
    a.time,
    a.stream_pressure,
    a.file_duration,
    a.event_rate,
    a.opp_evt_ratio,
    a.n_count,
    a.chl_small,
    a.pe,
    a.fsc_small,
    a.diam_mid,
    a.Qc_mid,
    a.quantile,
    a.flow_rate,
    a.abundance,
    a.pop,
    b.lat,
    b.lon
  FROM seaflow740 AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
