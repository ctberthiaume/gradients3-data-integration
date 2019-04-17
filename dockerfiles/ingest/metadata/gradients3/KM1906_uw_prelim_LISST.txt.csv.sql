CREATE TABLE IF NOT EXISTS lisst_raw (
  time TIMESTAMPTZ NOT NULL,
  POC_1point25_2um DOUBLE PRECISION,
  POC_2_20um DOUBLE PRECISION,
  POC_20_100um DOUBLE PRECISION
);

SELECT create_hypertable('lisst_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW lisst AS
  SELECT
    time_bucket('1m', lisst_raw.time) AS time,
    avg(POC_1point25_2um) as POC_1point25_2um,
    avg(POC_2_20um) as POC_2_20um,
    avg(POC_20_100um) as POC_20_100um
  FROM lisst_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW lisst_geo AS
  SELECT
    a.time,
    a.POC_1point25_2um,
    a.POC_2_20um,
    a.POC_20_100um,
    b.lat,
    b.lon
  FROM lisst AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
