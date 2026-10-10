-- ═══════════════════════════════════════════════════════════
-- WANDERBRICKS SQL PLAYBOOK
-- 10 documented business queries for stakeholder self-service
-- Uses MEASURE() syntax for metric views + standard SQL for exec view
-- ═══════════════════════════════════════════════════════════
--
-- HOW TO QUERY METRIC VIEWS:
--   1. Wrap every measure with MEASURE() — e.g., MEASURE(`total_revenue`)
--   2. Always use GROUP BY ALL when selecting measures
--   3. Backtick all dimension and measure names
--   4. Never use SELECT * — list dimensions and measures explicitly
--   5. Never wrap MEASURE() in another aggregate like AVG(MEASURE(...))
--
-- STANDARD VIEWS (vw_executive_dashboard) query normally with SELECT *
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────
-- Q1: What is the total revenue?
-- Source: mv_revenue_metrics
-- ─────────────────────────────────────────────────────────────
SELECT MEASURE(`total_revenue`) AS `total_revenue`
FROM workspace.wanderbricks_semantic.mv_revenue_metrics
GROUP BY ALL;

-- ─────────────────────────────────────────────────────────────
-- Q2: What is the payment success rate by payment method?
-- Source: mv_revenue_metrics
-- ─────────────────────────────────────────────────────────────
SELECT `payment_method`,
       MEASURE(`payment_success_rate`) AS `payment_success_rate`,
       MEASURE(`successful_payments`)  AS `successful_payments`,
       MEASURE(`failed_payments`)       AS `failed_payments`
FROM workspace.wanderbricks_semantic.mv_revenue_metrics
GROUP BY ALL
ORDER BY `payment_success_rate` DESC;

-- ─────────────────────────────────────────────────────────────
-- Q3: How many bookings were made each month by status?
-- Source: mv_booking_metrics
-- ─────────────────────────────────────────────────────────────
SELECT `booking_month`,
       `booking_status`,
       MEASURE(`total_bookings`) AS `total_bookings`
FROM workspace.wanderbricks_semantic.mv_booking_metrics
GROUP BY ALL
ORDER BY `booking_month` ASC, `total_bookings` DESC;

-- ─────────────────────────────────────────────────────────────
-- Q4: What is the average stay duration by property type?
-- Source: mv_booking_metrics
-- ─────────────────────────────────────────────────────────────
SELECT `property_type`,
       MEASURE(`avg_stay_duration`) AS `avg_stay_duration`,
       MEASURE(`total_bookings`)    AS `total_bookings`
FROM workspace.wanderbricks_semantic.mv_booking_metrics
GROUP BY ALL
ORDER BY `avg_stay_duration` DESC;

-- ─────────────────────────────────────────────────────────────
-- Q5: Who are the top 10 hosts by total booking revenue?
-- Source: mv_host_performance
-- ─────────────────────────────────────────────────────────────
SELECT `host_name`,
       `host_tier`,
       MEASURE(`total_booking_revenue`) AS `total_revenue`,
       MEASURE(`total_bookings`)        AS `total_bookings`
FROM workspace.wanderbricks_semantic.mv_host_performance
GROUP BY ALL
ORDER BY `total_revenue` DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────
-- Q6: What is the distribution of host tiers?
-- Source: mv_host_performance
-- ─────────────────────────────────────────────────────────────
SELECT `host_tier`,
       MEASURE(`total_properties`) AS `total_properties`
FROM workspace.wanderbricks_semantic.mv_host_performance
GROUP BY ALL
ORDER BY `total_properties` DESC;

-- ─────────────────────────────────────────────────────────────
-- Q7: How many new users signed up each month?
-- Source: mv_user_analytics
-- ─────────────────────────────────────────────────────────────
SELECT `signup_month`,
       MEASURE(`new_users`) AS `new_users`
FROM workspace.wanderbricks_semantic.mv_user_analytics
GROUP BY ALL
ORDER BY `signup_month` ASC;

-- ─────────────────────────────────────────────────────────────
-- Q8: What percentage of users are business vs individual?
-- Source: mv_user_analytics
-- ─────────────────────────────────────────────────────────────
SELECT `user_segment`,
       MEASURE(`new_users`)   AS `new_users`,
       MEASURE(`business_pct`) AS `business_pct`
FROM workspace.wanderbricks_semantic.mv_user_analytics
GROUP BY ALL;

-- ─────────────────────────────────────────────────────────────
-- Q9: What is the repeat booking rate?
-- Source: mv_user_analytics
-- ─────────────────────────────────────────────────────────────
SELECT MEASURE(`repeat_booking_rate`)     AS `repeat_booking_rate`,
       MEASURE(`total_repeat_users`)      AS `total_repeat_users`,
       MEASURE(`total_users_with_bookings`) AS `total_users_with_bookings`
FROM workspace.wanderbricks_semantic.mv_user_analytics
GROUP BY ALL;

-- ─────────────────────────────────────────────────────────────
-- Q10: Executive summary — all KPIs for the latest month
-- Source: vw_executive_dashboard (standard SQL view)
-- ─────────────────────────────────────────────────────────────
SELECT *
FROM workspace.wanderbricks_semantic.vw_executive_dashboard
ORDER BY year DESC, month DESC
LIMIT 1;