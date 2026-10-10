-- ═══════════════════════════════════════════════════════════
-- BRONZE LAYER: bookings
-- 1:1 raw mirror of source with ingestion timestamp
-- Source: samples.wanderbricks.bookings
-- Target: workspace.wanderbricks_bronze.bookings
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_bronze.bookings AS
SELECT
    booking_id,
    user_id,
    property_id,
    check_in,
    check_out,
    guests_count,
    total_amount,
    status,
    created_at,
    updated_at,
    current_timestamp() AS _ingested_at
FROM samples.wanderbricks.bookings;