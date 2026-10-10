-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: fact_bookings
-- Booking fact enriched with host_id via property join
-- Grain: One row per booking
-- Sources: workspace.wanderbricks_silver.bookings, .properties
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.fact_bookings AS
SELECT
    b.booking_id,
    b.user_id,
    b.property_id,
    p.host_id,
    b.check_in,
    b.check_out,
    b.stay_duration_days,
    b.guests_count,
    CAST(b.total_amount AS DECIMAL(15,4))                   AS total_amount,
    b.status,
    b.booking_month,
    b.booking_year,
    b.created_at,
    b.updated_at,
    -- Data quality flags carried through
    b.has_invalid_dates,
    b.has_invalid_guest_count
FROM workspace.wanderbricks_silver.bookings b
LEFT JOIN workspace.wanderbricks_silver.properties p
    ON b.property_id = p.property_id;