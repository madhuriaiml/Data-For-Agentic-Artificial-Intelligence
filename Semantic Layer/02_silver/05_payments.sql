-- ═══════════════════════════════════════════════════════════
-- SILVER LAYER: payments (cleansed + derived)
-- Status normalization, success flag, date truncation, DQ flag
-- Source: workspace.wanderbricks_bronze.payments
-- Target: workspace.wanderbricks_silver.payments
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_silver.payments AS
SELECT
    payment_id,
    booking_id,
    amount,
    LOWER(TRIM(payment_method))                           AS payment_method,
    LOWER(TRIM(status))                                   AS status,
    payment_date,
    -- Derived columns
    CASE WHEN LOWER(TRIM(status)) = 'completed' THEN true ELSE false END AS is_successful,
    DATE_TRUNC('month', payment_date)                       AS payment_month,
    YEAR(payment_date)                                      AS payment_year,
    -- Data quality flags
    CASE WHEN amount IS NULL OR amount <= 0 THEN true ELSE false END AS has_invalid_amount
FROM workspace.wanderbricks_bronze.payments;