-- ═══════════════════════════════════════════════════════════
-- SEMANTIC LAYER: mv_host_performance
-- Host performance KPIs with pre-aggregated SQL source
-- Joins dim_hosts with properties, employees, and bookings
-- Query syntax: Use MEASURE() and GROUP BY ALL
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_semantic.mv_host_performance
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  source: >
    SELECT
        dh.host_id,
        dh.name AS host_name,
        dh.host_tier,
        dh.is_verified,
        dh.is_active,
        dh.rating,
        dh.country,
        dh.joined_at,
        props.total_properties,
        props.avg_base_price,
        props.total_max_capacity,
        emps.total_employees,
        emps.active_employees,
        bk.total_bookings,
        bk.total_booking_revenue,
        bk.avg_booking_value
    FROM workspace.wanderbricks_gold.dim_hosts dh
    LEFT JOIN (
        SELECT host_id, COUNT(*) AS total_properties,
               AVG(base_price) AS avg_base_price,
               SUM(max_guests) AS total_max_capacity
        FROM workspace.wanderbricks_gold.dim_properties
        GROUP BY host_id
    ) props ON dh.host_id = props.host_id
    LEFT JOIN (
        SELECT host_id, COUNT(*) AS total_employees,
               COUNT(CASE WHEN employment_status = 'active' THEN 1 END) AS active_employees
        FROM workspace.wanderbricks_gold.dim_employees
        GROUP BY host_id
    ) emps ON dh.host_id = emps.host_id
    LEFT JOIN (
        SELECT dp.host_id, COUNT(fb.booking_id) AS total_bookings,
               SUM(fb.total_amount) AS total_booking_revenue,
               AVG(fb.total_amount) AS avg_booking_value
        FROM workspace.wanderbricks_gold.dim_properties dp
        LEFT JOIN workspace.wanderbricks_gold.fact_bookings fb
            ON dp.property_id = fb.property_id
        GROUP BY dp.host_id
    ) bk ON dh.host_id = bk.host_id
  comment: Host performance KPIs including properties, employees, and booking revenue
  dimensions:
    - name: host_name
      expr: host_name
      display_name: Host Name
    - name: host_tier
      expr: host_tier
      display_name: Host Tier
      synonyms: [tier, host level]
    - name: is_verified
      expr: is_verified
      display_name: Is Verified
    - name: is_active
      expr: is_active
      display_name: Is Active
    - name: country
      expr: country
      display_name: Country
    - name: rating
      expr: rating
      display_name: Rating
      format:
        type: number
        decimal_places: {type: exact, places: 1}
  measures:
    - name: total_properties
      expr: SUM(total_properties)
      display_name: Total Properties
    - name: avg_base_price
      expr: AVG(avg_base_price)
      display_name: Avg Base Price
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
    - name: total_max_capacity
      expr: SUM(total_max_capacity)
      display_name: Total Max Capacity
    - name: total_employees
      expr: SUM(total_employees)
      display_name: Total Employees
    - name: active_employees
      expr: SUM(active_employees)
      display_name: Active Employees
    - name: total_bookings
      expr: SUM(total_bookings)
      display_name: Total Bookings
    - name: total_booking_revenue
      expr: SUM(total_booking_revenue)
      display_name: Total Booking Revenue
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
    - name: avg_booking_value
      expr: AVG(avg_booking_value)
      display_name: Avg Booking Value
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
$$;