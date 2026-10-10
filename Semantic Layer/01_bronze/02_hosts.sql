-- ═══════════════════════════════════════════════════════════
-- BRONZE LAYER: hosts
-- 1:1 raw mirror of source with ingestion timestamp
-- Source: samples.wanderbricks.hosts
-- Target: workspace.wanderbricks_bronze.hosts
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_bronze.hosts AS
SELECT
    host_id,
    name,
    email,
    phone,
    is_verified,
    is_active,
    rating,
    country,
    joined_at,
    current_timestamp() AS _ingested_at
FROM samples.wanderbricks.hosts;