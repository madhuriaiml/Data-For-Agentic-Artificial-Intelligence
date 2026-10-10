-- ═══════════════════════════════════════════════════════════
-- SILVER LAYER: properties (cleansed + derived)
-- String normalization, price tier, GPS validation flags
-- Source: workspace.wanderbricks_bronze.properties
-- Target: workspace.wanderbricks_silver.properties
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_silver.properties AS
SELECT
    property_id,
    host_id,
    destination_id,
    TRIM(title)                                            AS title,
    TRIM(description)                                     AS description,
    base_price,
    LOWER(TRIM(property_type))                            AS property_type,
    max_guests,
    bedrooms,
    bathrooms,
    property_latitude,
    property_longitude,
    created_at,
    -- Derived: price tier
    CASE
        WHEN base_price >= 500 THEN 'Premium'
        WHEN base_price >= 200 THEN 'Luxury'
        WHEN base_price >= 100 THEN 'Mid'
        WHEN base_price >= 0  THEN 'Budget'
        ELSE 'Unknown'
    END                                                    AS price_tier,
    -- Data quality flags
    CASE WHEN property_latitude IS NULL
          OR property_latitude < -90 OR property_latitude > 90 THEN true ELSE false END AS has_invalid_lat,
    CASE WHEN property_longitude IS NULL
          OR property_longitude < -180 OR property_longitude > 180 THEN true ELSE false END AS has_invalid_long
FROM workspace.wanderbricks_bronze.properties;