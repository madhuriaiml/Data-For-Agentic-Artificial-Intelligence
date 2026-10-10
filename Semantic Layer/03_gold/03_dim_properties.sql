-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: dim_properties
-- Conformed property dimension with price tier and listed year
-- Grain: One row per property
-- Source: workspace.wanderbricks_silver.properties
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.dim_properties AS
SELECT
    property_id,
    host_id,
    destination_id,
    title,
    description,
    base_price,
    price_tier,
    property_type,
    max_guests,
    bedrooms,
    bathrooms,
    property_latitude,
    property_longitude,
    created_at,
    YEAR(created_at) AS listed_year
FROM workspace.wanderbricks_silver.properties;