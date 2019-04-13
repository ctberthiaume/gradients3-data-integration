CREATE TABLE IF NOT EXISTS seaflow740_raw (
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

SELECT create_hypertable('seaflow740_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW seaflow740 AS
  SELECT *
  FROM seaflow740_raw
  ORDER BY seaflow740_raw.time;

CREATE OR REPLACE VIEW seaflow740_geo AS
  SELECT *
  FROM seaflow740_raw
  ORDER BY seaflow740_raw.time;
