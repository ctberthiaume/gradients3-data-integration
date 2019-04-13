CREATE TABLE IF NOT EXISTS seaflow740 (
  time TIMESTAMPTZ NOT NULL,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
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

SELECT create_hypertable('seaflow740', 'time', if_not_exists := true);
