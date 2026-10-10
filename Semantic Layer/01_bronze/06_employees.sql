-- ═══════════════════════════════════════════════════════════
-- BRONZE LAYER: employees
-- 1:1 raw mirror of source with ingestion timestamp
-- Source: samples.wanderbricks.employees
-- Target: workspace.wanderbricks_bronze.employees
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW workspace.wanderbricks_bronze.employees AS
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
    is_currently_employed,
    current_timestamp() AS _ingested_at
FROM samples.wanderbricks.employees;