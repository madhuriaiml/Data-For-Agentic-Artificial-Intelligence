-- ═══════════════════════════════════════════════════════════
-- SILVER LAYER: employees (cleansed + derived)
-- Employment status derivation, string normalization, DQ flag
-- Source: workspace.wanderbricks_bronze.employees
-- Target: workspace.wanderbricks_silver.employees
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_silver.employees AS
SELECT
    employee_id,
    host_id,
    TRIM(name)                                             AS name,
    LOWER(TRIM(role))                                     AS role,
    TRIM(email)                                           AS email,
    TRIM(phone)                                          AS phone,
    UPPER(TRIM(country))                                  AS country,
    joined_at,
    end_service_date,
    is_currently_employed,
    -- Derived: employment status from boolean + dates
    CASE
        WHEN is_currently_employed = false THEN 'inactive'
        WHEN end_service_date IS NOT NULL THEN 'inactive'
        ELSE 'active'
    END                                                    AS employment_status,
    -- Data quality flags
    CASE WHEN email IS NULL OR email = '' THEN true ELSE false END AS has_null_email
FROM workspace.wanderbricks_bronze.employees;