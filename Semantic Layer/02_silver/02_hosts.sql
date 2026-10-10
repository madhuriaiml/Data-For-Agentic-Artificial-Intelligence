-- ═══════════════════════════════════════════════════════════
-- SILVER LAYER: hosts (cleansed + derived)
-- String normalization, host tier from rating, data quality flags
-- Source: workspace.wanderbricks_bronze.hosts
-- Target: workspace.wanderbricks_silver.hosts
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_silver.hosts AS
SELECT
    host_id,
    TRIM(name)                                             AS name,
    TRIM(email)                                            AS email,
    TRIM(phone)                                           AS phone,
    is_verified,
    is_active,
    rating,
    UPPER(TRIM(country))                                   AS country,
    joined_at,
    -- Derived: host tier from rating
    CASE
        WHEN rating >= 4.5 THEN 'Platinum'
        WHEN rating >= 4.0 THEN 'Gold'
        WHEN rating >= 3.0 THEN 'Silver'
        WHEN rating >= 1.0 THEN 'Bronze'
        ELSE 'Unrated'
    END                                                    AS host_tier,
    -- Data quality flags
    CASE WHEN email IS NULL OR email = '' THEN true ELSE false END AS has_null_email,
    CASE WHEN phone IS NULL OR phone = '' THEN true ELSE false END AS has_null_phone
FROM workspace.wanderbricks_bronze.hosts;