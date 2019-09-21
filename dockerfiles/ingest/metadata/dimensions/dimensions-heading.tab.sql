CREATE TABLE IF NOT EXISTS track_raw (
  time TIMESTAMPTZ NOT NULL,
  heading_true_north DOUBLE PRECISION,
  knots DOUBLE PRECISION
);

SELECT create_hypertable('track_raw', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW track AS
  SELECT
    time_bucket('1m', track_raw.time) AS time,
    avg(heading_true_north) as heading_true_north,
    avg(knots) as knots
  FROM track_raw
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW track_geo AS
  SELECT
    a.time,
    a.heading_true_north,
    a.knots,
    b.lat,
    b.lon
  FROM track AS a
  INNER JOIN geo AS b
  ON a.time = b.time
  ORDER BY 1;
