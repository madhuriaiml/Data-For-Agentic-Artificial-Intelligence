-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: fact_payments
-- Payment fact enriched with booking/user/property/host FKs
-- Grain: One row per payment
-- Sources: workspace.wanderbricks_silver.payments,
--          workspace.wanderbricks_gold.fact_bookings
-- Note: fact_bookings must be created before fact_payments
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.fact_payments AS
SELECT
    pmt.payment_id,
    pmt.booking_id,
    fb.user_id,
    fb.property_id,
    fb.host_id,
    CAST(pmt.amount AS DECIMAL(15,4))                       AS amount,
    pmt.payment_method,
    pmt.status,
    pmt.is_successful,
    pmt.payment_date,
    pmt.payment_month,
    pmt.payment_year,
    fb.check_in,
    fb.check_out,
    fb.total_amount                                        AS booking_total_amount
FROM workspace.wanderbricks_silver.payments pmt
LEFT JOIN workspace.wanderbricks_gold.fact_bookings fb
    ON pmt.booking_id = fb.booking_id;