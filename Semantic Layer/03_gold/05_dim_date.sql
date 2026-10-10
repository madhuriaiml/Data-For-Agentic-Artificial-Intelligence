-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: dim_date
-- Generated calendar dimension from min to max booking date
-- Grain: One row per day
-- Source: workspace.wanderbricks_silver.bookings (date range)
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.dim_date AS
WITH date_range AS (
    SELECT
        MIN(check_in) AS min_date,
        MAX(check_in) AS max_date
    FROM workspace.wanderbricks_silver.bookings
),
 dates AS (
    SELECT explode(sequence(min_date, max_date, interval 1 day)) AS date_val
    FROM date_range
)
SELECT
    date_val                                                 AS date_id,
    date_val                                                 AS full_date,
    YEAR(date_val)                                            AS year,
    MONTH(date_val)                                           AS month,
    QUARTER(date_val)                                         AS quarter,
    DAYOFWEEK(date_val)                                       AS day_of_week,
    DAYOFYEAR(date_val)                                       AS day_of_year,
    DATE_TRUNC('week', date_val)                             AS week_start,
    DATE_TRUNC('month', date_val)                            AS month_start,
    DATE_TRUNC('quarter', date_val)                          AS quarter_start,
    CASE
        WHEN MONTH(date_val) IN (12, 1, 2)  THEN 'Winter'
        WHEN MONTH(date_val) IN (3, 4, 5)   THEN 'Spring'
        WHEN MONTH(date_val) IN (6, 7, 8)   THEN 'Summer'
        ELSE 'Fall'
    END                                                       AS season,
    CONCAT(YEAR(date_val), '-Q', QUARTER(date_val))           AS year_quarter
FROM dates;