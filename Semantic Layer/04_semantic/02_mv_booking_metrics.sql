-- ═══════════════════════════════════════════════════════════
-- SEMANTIC LAYER: mv_booking_metrics
-- Booking analytics KPIs as a Unity Catalog Metric View
-- Source: workspace.wanderbricks_gold.fact_bookings
-- Join: dim_properties (many_to_one on property_id)
-- Query syntax: Use MEASURE() and GROUP BY ALL
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_semantic.mv_booking_metrics
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  source: workspace.wanderbricks_gold.fact_bookings
  comment: Booking analytics KPIs for Wanderbricks business operations
  joins:
    - name: dim_properties
      source: workspace.wanderbricks_gold.dim_properties
      on: source.property_id = dim_properties.property_id
      cardinality: many_to_one
  dimensions:
    - name: booking_year
      expr: booking_year
      display_name: Booking Year
    - name: booking_month
      expr: booking_month
      display_name: Booking Month
      format:
        type: date
        date_format: locale_short_month
    - name: booking_status
      expr: status
      display_name: Booking Status
      synonyms: [status, reservation status]
    - name: property_type
      expr: dim_properties.property_type
      display_name: Property Type
    - name: price_tier
      expr: dim_properties.price_tier
      display_name: Price Tier
  measures:
    - name: total_bookings
      expr: COUNT(1)
      display_name: Total Bookings
    - name: avg_stay_duration
      expr: AVG(stay_duration_days)
      display_name: Avg Stay Duration (Days)
      format:
        type: number
        decimal_places: {type: exact, places: 1}
    - name: total_guests
      expr: SUM(guests_count)
      display_name: Total Guests
    - name: total_booking_value
      expr: SUM(total_amount)
      display_name: Total Booking Value
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
    - name: avg_booking_value
      expr: AVG(total_amount)
      display_name: Avg Booking Value
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
$$;