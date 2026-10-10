-- ═══════════════════════════════════════════════════════════
-- SEMANTIC LAYER: mv_user_analytics
-- User analytics KPIs with pre-aggregated SQL source
-- Joins dim_users with booking counts for repeat user analysis
-- Query syntax: Use MEASURE() and GROUP BY ALL
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_semantic.mv_user_analytics
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  source: >
    SELECT
        du.user_id,
        du.user_segment,
        du.is_business,
        du.signup_year,
        du.signup_month,
        du.country,
        COALESCE(ub.booking_count, 0) AS booking_count,
        CASE WHEN COALESCE(ub.booking_count, 0) > 1 THEN true ELSE false END AS is_repeat_user
    FROM workspace.wanderbricks_gold.dim_users du
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS booking_count
        FROM workspace.wanderbricks_gold.fact_bookings
        GROUP BY user_id
    ) ub ON du.user_id = ub.user_id
  comment: User analytics including signups, segments, and repeat booking behavior
  dimensions:
    - name: signup_year
      expr: signup_year
      display_name: Signup Year
    - name: signup_month
      expr: signup_month
      display_name: Signup Month
      format:
        type: date
        date_format: locale_short_month
    - name: user_segment
      expr: user_segment
      display_name: User Segment
      synonyms: [user type, customer type]
    - name: country
      expr: country
      display_name: Country
    - name: is_business
      expr: is_business
      display_name: Is Business
    - name: is_repeat_user
      expr: is_repeat_user
      display_name: Is Repeat User
  measures:
    - name: new_users
      expr: COUNT(1)
      display_name: New Users
    - name: new_business_users
      expr: COUNT(CASE WHEN is_business = true THEN 1 END)
      display_name: New Business Users
    - name: new_individual_users
      expr: COUNT(CASE WHEN is_business = false THEN 1 END)
      display_name: New Individual Users
    - name: business_pct
      expr: COUNT(CASE WHEN is_business = true THEN 1 END) / COUNT(1)
      display_name: Business Percentage
      format:
        type: percentage
        decimal_places: {type: exact, places: 2}
    - name: total_repeat_users
      expr: COUNT(CASE WHEN is_repeat_user = true THEN 1 END)
      display_name: Total Repeat Users
    - name: total_users_with_bookings
      expr: COUNT(CASE WHEN booking_count > 0 THEN 1 END)
      display_name: Users With Bookings
    - name: repeat_booking_rate
      expr: COUNT(CASE WHEN is_repeat_user = true THEN 1 END) / COUNT(CASE WHEN booking_count > 0 THEN 1 END)
      display_name: Repeat Booking Rate
      format:
        type: percentage
        decimal_places: {type: exact, places: 2}
$$;