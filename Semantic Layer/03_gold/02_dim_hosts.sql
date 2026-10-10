-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: dim_hosts
-- Conformed host dimension with tier and join year/month
-- Grain: One row per host
-- Source: workspace.wanderbricks_silver.hosts
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.dim_hosts AS
SELECT
    host_id,
    name,
    email,
    phone,
    is_verified,
    is_active,
    rating,
    host_tier,
    country,
    joined_at,
    YEAR(joined_at)  AS join_year,
    MONTH(joined_at) AS join_month
FROM workspace.wanderbricks_silver.hosts;