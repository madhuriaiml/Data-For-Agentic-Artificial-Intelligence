-- ═══════════════════════════════════════════════════════════
-- SEMANTIC LAYER: mv_revenue_metrics
-- Revenue & payment KPIs as a Unity Catalog Metric View
-- Source: workspace.wanderbricks_gold.fact_payments
-- Query syntax: Use MEASURE() and GROUP BY ALL
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_semantic.mv_revenue_metrics
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  source: workspace.wanderbricks_gold.fact_payments
  comment: Revenue and payment KPIs for Wanderbricks business operations
  dimensions:
    - name: payment_year
      expr: payment_year
      display_name: Payment Year
    - name: payment_month
      expr: payment_month
      display_name: Payment Month
      format:
        type: date
        date_format: locale_short_month
    - name: payment_method
      expr: payment_method
      display_name: Payment Method
      synonyms: [payment type, payment mode]
  measures:
    - name: total_revenue
      expr: SUM(amount)
      display_name: Total Revenue
      comment: Sum of all payment amounts
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
    - name: total_payments
      expr: COUNT(1)
      display_name: Total Payments
    - name: avg_payment_amount
      expr: AVG(amount)
      display_name: Avg Payment Amount
      format:
        type: currency
        currency_code: USD
        decimal_places: {type: exact, places: 2}
    - name: successful_payments
      expr: COUNT(CASE WHEN is_successful = true THEN 1 END)
      display_name: Successful Payments
    - name: failed_payments
      expr: COUNT(CASE WHEN is_successful = false THEN 1 END)
      display_name: Failed Payments
    - name: payment_success_rate
      expr: COUNT(CASE WHEN is_successful = true THEN 1 END) / COUNT(1)
      display_name: Payment Success Rate
      format:
        type: percentage
        decimal_places: {type: exact, places: 2}
$$;