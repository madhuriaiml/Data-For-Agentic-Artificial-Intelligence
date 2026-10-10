-- ═══════════════════════════════════════════════════════════
-- WANDERBRICKS SEMANTIC LAYER
-- Phase 0: Schema Setup
-- Create the 4 medallion layer schemas
-- ═══════════════════════════════════════════════════════════
-- Target catalog: 'workspace' (requires CREATE_SCHEMA privilege)
-- Source catalog: 'samples.wanderbricks' (read-only)

CREATE SCHEMA IF NOT EXISTS workspace.wanderbricks_bronze;
CREATE SCHEMA IF NOT EXISTS workspace.wanderbricks_silver;
CREATE SCHEMA IF NOT EXISTS workspace.wanderbricks_gold;
CREATE SCHEMA IF NOT EXISTS workspace.wanderbricks_semantic;

-- Verify creation
SHOW SCHEMAS IN workspace;