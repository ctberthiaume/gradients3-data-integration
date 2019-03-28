CREATE TABLE IF NOT EXISTS track (
  time TIMESTAMPTZ NOT NULL,
  heading_true_north DOUBLE PRECISION,
  knots DOUBLE PRECISION,
  kmh DOUBLE PRECISION
);

SELECT create_hypertable('track', 'time', if_not_exists := true);

CREATE OR REPLACE VIEW track_1m AS
  SELECT
    time_bucket('1m', track.time) AS time,
    avg(heading_true_north) as heading_true_north,
    avg(knots) as knots,
    avg(kmh) as kmh
  FROM track
  GROUP BY 1
  ORDER BY 1;

CREATE OR REPLACE VIEW track_geo AS
  SELECT
    a.time,
    a.heading_true_north,
    a.knots,
    a.kmh,
    b.lat,
    b.lon
  FROM track_1m AS a
  INNER JOIN geo_1m AS b
  ON a.time = b.time
  ORDER BY 1;
