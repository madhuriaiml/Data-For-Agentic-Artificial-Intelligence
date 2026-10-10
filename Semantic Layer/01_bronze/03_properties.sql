-- ═══════════════════════════════════════════════════════════
-- BRONZE LAYER: properties
-- 1:1 raw mirror of source with ingestion timestamp
-- Source: samples.wanderbricks.properties
-- Target: workspace.wanderbricks_bronze.properties
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_bronze.properties AS
SELECT
    property_id,
    host_id,
    destination_id,
    title,
    description,
    base_price,
    property_type,
    max_guests,
    bedrooms,
    bathrooms,
    property_latitude,
    property_longitude,
    created_at,
    current_timestamp() AS _ingested_at
FROM samples.wanderbricks.properties;