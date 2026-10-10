-- ═══════════════════════════════════════════════════════════
-- SEMANTIC LAYER: vw_executive_dashboard
-- Standard SQL view combining monthly KPIs across all domains
-- Combines revenue, bookings, users, and active hosts
-- Query syntax: Standard SQL (no MEASURE() needed)
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_semantic.vw_executive_dashboard AS
WITH revenue_monthly AS (
    SELECT
        payment_year  AS year,
        payment_month AS month,
        SUM(amount)   AS total_revenue,
        COUNT(*)       AS total_payments
    FROM workspace.wanderbricks_gold.fact_payments
    WHERE is_successful = true
    GROUP BY payment_year, payment_month
),
bookings_monthly AS (
    SELECT
        booking_year  AS year,
        booking_month AS month,
        COUNT(*)       AS total_bookings,
        SUM(total_amount) AS total_booking_value,
        AVG(stay_duration_days) AS avg_stay_days
    FROM workspace.wanderbricks_gold.fact_bookings
    WHERE status = 'confirmed'
    GROUP BY booking_year, booking_month
),
new_users_monthly AS (
    SELECT
        signup_year  AS year,
        signup_month AS month,
        COUNT(*)      AS new_users
    FROM workspace.wanderbricks_gold.dim_users
    GROUP BY signup_year, signup_month
),
active_hosts AS (
    SELECT COUNT(DISTINCT host_id) AS total_active_hosts
    FROM workspace.wanderbricks_gold.dim_hosts
    WHERE is_active = true
)
SELECT
    COALESCE(r.year, b.year, u.year)   AS year,
    COALESCE(r.month, b.month, u.month) AS month,
    COALESCE(r.total_revenue, 0)        AS total_revenue,
    COALESCE(r.total_payments, 0)       AS total_payments,
    COALESCE(b.total_bookings, 0)       AS total_bookings,
    COALESCE(b.total_booking_value, 0)  AS total_booking_value,
    COALESCE(b.avg_stay_days, 0)        AS avg_stay_days,
    COALESCE(u.new_users, 0)             AS new_users,
    (SELECT total_active_hosts FROM active_hosts) AS active_hosts
FROM revenue_monthly r
FULL OUTER JOIN bookings_monthly b
    ON r.year = b.year AND r.month = b.month
FULL OUTER JOIN new_users_monthly u
    ON COALESCE(r.year, b.year) = u.year
    AND COALESCE(r.month, b.month) = u.month;