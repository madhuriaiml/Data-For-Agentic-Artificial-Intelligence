-- ═══════════════════════════════════════════════════════════
-- GOLD LAYER: dim_employees
-- Conformed employee dimension with employment status
-- Grain: One row per employee
-- Source: workspace.wanderbricks_silver.employees
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_gold.dim_employees AS
SELECT
    employee_id,
    host_id,
    name,
    role,
    email,
    phone,
    country,
    joined_at,
    end_service_date,
    employment_status,
    is_currently_employed
FROM workspace.wanderbricks_silver.employees;