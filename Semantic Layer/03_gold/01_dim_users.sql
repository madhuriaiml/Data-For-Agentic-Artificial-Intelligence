-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: dim_users
-- Conformed user dimension with signup year/month
-- Grain: One row per user
-- Source: workspace.wanderbricks_silver.users
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.dim_users AS
SELECT
    user_id,
    email,
    name,
    country,
    user_type,
    user_segment,
    is_business,
    company_name,
    created_at,
    YEAR(created_at)  AS signup_year,
    MONTH(created_at) AS signup_month
FROM workspace.wanderbricks_silver.users;