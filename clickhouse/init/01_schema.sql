CREATE DATABASE IF NOT EXISTS reports;

CREATE TABLE IF NOT EXISTS reports.etl_state
(
    job         String,
    last_period Date,
    rows_loaded UInt32,
    finished_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(finished_at)
ORDER BY job;
