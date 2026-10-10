-- ═══════════════════════════════════════════════════════════
-- BRONZE LAYER: users
-- 1:1 raw mirror of source with ingestion timestamp
-- Source: samples.wanderbricks.users
-- Target: workspace.wanderbricks_bronze.users
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_bronze.users AS
SELECT
    user_id,
    email,
    name,
    country,
    user_type,
    created_at,
    is_business,
    company_name,
    current_timestamp() AS _ingested_at
FROM samples.wanderbricks.users;