-- ═══════════════════════════════════════════════════════════
-- BRONZE LAYER: payments
-- 1:1 raw mirror of source with ingestion timestamp
-- Source: samples.wanderbricks.payments
-- Target: workspace.wanderbricks_bronze.payments
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_bronze.payments AS
SELECT
    payment_id,
    booking_id,
    amount,
    payment_method,
    status,
    payment_date,
    current_timestamp() AS _ingested_at
FROM samples.wanderbricks.payments;