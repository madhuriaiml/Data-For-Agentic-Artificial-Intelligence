-- ═══════════════════════════════════════════════════════════
-- SILVER LAYER: bookings (cleansed + derived)
-- Status normalization, stay duration, date truncation, DQ flags
-- Source: workspace.wanderbricks_bronze.bookings
-- Target: workspace.wanderbricks_silver.bookings
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_silver.bookings AS
SELECT
    booking_id,
    user_id,
    property_id,
    check_in,
    check_out,
    guests_count,
    total_amount,
    LOWER(TRIM(status))                                   AS status,
    created_at,
    updated_at,
    -- Derived columns
    DATEDIFF(check_out, check_in)                          AS stay_duration_days,
    DATE_TRUNC('month', check_in)                          AS booking_month,
    YEAR(check_in)                                         AS booking_year,
    -- Data quality flags
    CASE WHEN check_out <= check_in THEN true ELSE false END AS has_invalid_dates,
    CASE WHEN guests_count IS NULL OR guests_count <= 0 THEN true ELSE false END AS has_invalid_guest_count
FROM workspace.wanderbricks_bronze.bookings;