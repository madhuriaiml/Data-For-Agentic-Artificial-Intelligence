-- ═══════════════════════════════════════════════════════════
-- SILVER LAYER: users (cleansed + derived)
-- String normalization, user segment, data quality flags
-- Source: workspace.wanderbricks_bronze.users
-- Target: workspace.wanderbricks_silver.users
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_silver.users AS
SELECT
    user_id,
    TRIM(email)                                            AS email,
    TRIM(name)                                             AS name,
    UPPER(TRIM(country))                                   AS country,
    LOWER(TRIM(user_type))                                 AS user_type,
    created_at,
    is_business,
    TRIM(company_name)                                     AS company_name,
    -- Derived columns
    CASE
        WHEN is_business = true  THEN 'business'
        WHEN is_business = false THEN 'individual'
        ELSE COALESCE(LOWER(TRIM(user_type)), 'unknown')
    END                                                    AS user_segment,
    -- Data quality flags
    CASE WHEN email IS NULL OR email = '' THEN true ELSE false END AS has_null_email
FROM workspace.wanderbricks_bronze.users;