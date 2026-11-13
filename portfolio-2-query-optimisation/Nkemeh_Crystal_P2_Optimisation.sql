
-- PurpleBank: Portfolio 2
-- Query Processing and Optimisation
-- Benchmark: Comparing query performance before and after indexing

-- ==================================================
-- 1. CREATE THE BENCHMARK SCHEMA
-- ==================================================

CREATE SCHEMA p2_benchmark;


-- ==================================================
-- 2. CREATE 100,000 FICTIONAL TRANSACTION RECORDS
-- ==================================================

CREATE TABLE p2_benchmark.transaction_history AS
SELECT
    g AS history_id,
    a.account_id,
    'PB-HIST-' || LPAD(g::TEXT, 6, '0') AS reference,
    TIMESTAMPTZ '2000-01-01 00:00:00+00'
        + g * INTERVAL '1 hour' AS created_at,
    ((g % 50000) + 100)::NUMERIC(18,2) AS amount,
    'NGN'::CHAR(3) AS currency,
    'successful'::VARCHAR(20) AS status
FROM generate_series(1, 100000) AS g
CROSS JOIN public.account AS a
WHERE a.account_number = '0123456789';


-- ==================================================
-- 3. ANALYSE AND VERIFY THE BENCHMARK RECORDS
-- ==================================================

ANALYZE p2_benchmark.transaction_history;

SELECT COUNT(*) AS test_rows
FROM p2_benchmark.transaction_history;


-- ==================================================
-- 4. COUNT TRANSACTIONS ON JANUARY 1, 2005
-- ==================================================

SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- ==================================================
-- 5. EXECUTION PLAN BEFORE INDEXING
-- ==================================================

-- Warm-up run: Ignore this execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- Measured Run 1: Record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- Measured Run 2: Record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- Measured Run 3: Record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- ==================================================
-- 6. CREATE INDEX ON TRANSACTION DATE
-- ==================================================

CREATE INDEX transaction_history_created_at_idx
ON p2_benchmark.transaction_history (created_at);

ANALYZE p2_benchmark.transaction_history;


-- ==================================================
-- 7. EXECUTION PLAN AFTER INDEXING
-- ==================================================

-- Warm-up run: Ignore this execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- Measured Run 1: Record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- Measured Run 2: Record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- Measured Run 3: Record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';


-- ==================================================
-- 8. VERIFY THE FINAL TRANSACTION COUNT
-- ==================================================

-- The expected result is 24 records.
-- Indexing should not change the query result.

SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE created_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- End of Portfolio 2 optimisation experiment.
