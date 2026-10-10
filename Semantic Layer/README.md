# Wanderbricks Semantic Layer

> A complete Medallion Architecture + Semantic Layer for vacation rental business operations, built entirely with **Databricks SQL Views** and **Unity Catalog Metric Views**.

## Project Overview

Wanderbricks is an Airbnb-style vacation rental platform with 6 source tables: users, hosts, properties, bookings, payments, and employees. This project transforms that raw operational data into a **business-ready semantic layer** that any stakeholder can query without writing complex SQL.

The semantic layer follows a **Medallion Architecture** (Bronze → Silver → Gold → Semantic) implemented with SQL Views on Databricks, culminating in an AI/BI Dashboard and a SQL Playbook for stakeholder self-service.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  SOURCE (Read-Only)                                            │
│  samples.wanderbricks.{users, hosts, properties,               │
│                         bookings, payments, employees}        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  BRONZE LAYER — Raw Mirror (6 views)                           │
│  workspace.wanderbricks_bronze                                  │
│  1:1 copies with ingestion timestamps                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  SILVER LAYER — Cleaned & Conformed (6 views)                  │
│  workspace.wanderbricks_silver                                  │
│  Type enforcement, string normalization, derived columns,      │
│  data quality flags                                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  GOLD LAYER — Star Schema (7 views)                            │
│  workspace.wanderbricks_gold                                    │
│  dim_users, dim_hosts, dim_properties, dim_employees,          │
│  dim_date, fact_bookings, fact_payments                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  SEMANTIC LAYER — Business Metric Views (6 assets)             │
│  workspace.wanderbricks_semantic                                │
│  4 Unity Catalog Metric Views (MEASURE() syntax) +             │
│  1 Executive Dashboard SQL View                                │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                             │
│  AI/BI Dashboard · SQL Playbook · This GitHub Repo              │
└─────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Technology | Usage |
| --- | --- |
| Databricks SQL Views | Bronze, Silver, Gold layer views |
| Unity Catalog Metric Views | Semantic layer with `MEASURE()` syntax |
| Unity Catalog | Schema governance, column comments, tags |
| AI/BI Lakeview Dashboards | Executive visualization layer |
| Serverless SQL Compute | Zero-maintenance, auto-scaling compute |

## Repository Structure

```
wanderbricks-semantic-layer/
├── README.md                          # This file
├── .gitignore                         # Databricks-specific ignores
├── docs/
│   ├── architecture.md               # Architecture deep-dive
│   ├── data_dictionary.md            # All tables, views, and columns
│   └── kpi_catalog.md                 # Every KPI with formula and source
├── 00_setup/
│   └── 01_create_schemas.sql          # CREATE SCHEMA for all 4 layers
├── 01_bronze/
│   ├── 01_users.sql                  # Raw mirror: users
│   ├── 02_hosts.sql                  # Raw mirror: hosts
│   ├── 03_properties.sql             # Raw mirror: properties
│   ├── 04_bookings.sql               # Raw mirror: bookings
│   ├── 05_payments.sql               # Raw mirror: payments
│   └── 06_employees.sql              # Raw mirror: employees
├── 02_silver/
│   ├── 01_users.sql                  # Cleaned + derived: users
│   ├── 02_hosts.sql                  # Cleaned + derived: hosts
│   ├── 03_properties.sql             # Cleaned + derived: properties
│   ├── 04_bookings.sql               # Cleaned + derived: bookings
│   ├── 05_payments.sql               # Cleaned + derived: payments
│   └── 06_employees.sql              # Cleaned + derived: employees
├── 03_gold/
│   ├── 01_dim_users.sql              # Dimension: users
│   ├── 02_dim_hosts.sql              # Dimension: hosts
│   ├── 03_dim_properties.sql         # Dimension: properties
│   ├── 04_dim_employees.sql          # Dimension: employees
│   ├── 05_dim_date.sql               # Dimension: generated calendar
│   ├── 06_fact_bookings.sql          # Fact table: bookings
│   └── 07_fact_payments.sql          # Fact table: payments
├── 04_semantic/
│   ├── 01_mv_revenue_metrics.sql     # Metric View: revenue & payments
│   ├── 02_mv_booking_metrics.sql     # Metric View: booking analytics
│   ├── 03_mv_host_performance.sql    # Metric View: host performance
│   ├── 04_mv_user_analytics.sql      # Metric View: user/guest analytics
│   └── 05_vw_executive_dashboard.sql  # SQL View: executive summary
└── sql_playbook/
    └── wanderbricks_sql_playbook.sql   # 10 documented business queries
```

## Setup Instructions

### Prerequisites
- Databricks workspace with Unity Catalog enabled
- Access to `samples.wanderbricks` schema (read-only sample data)
- `CREATE SCHEMA` privilege on a catalog (e.g., `workspace`)
- Serverless SQL compute (auto-provisions on query execution)

### Steps

1. **Create schemas** — Run `00_setup/01_create_schemas.sql`
2. **Build Bronze layer** — Run files in `01_bronze/` sequentially
3. **Build Silver layer** — Run files in `02_silver/` sequentially
4. **Build Gold layer** — Run files in `03_gold/` sequentially (dimensions before facts)
5. **Build Semantic layer** — Run files in `04_semantic/` sequentially
6. **Explore** — Run queries from `sql_playbook/wanderbricks_sql_playbook.sql`

> **Note:** All SQL uses `CREATE OR REPLACE VIEW` so files are idempotent and can be re-run safely.

## KPI Summary

| Domain | Key Metrics |
| --- | --- |
| Revenue & Payments | Total Revenue, Total Payments, Avg Payment Amount, Payment Success Rate |
| Booking Analytics | Total Bookings, Avg Stay Duration, Total Booking Value, Avg Booking Value |
| Host Performance | Total Properties, Total Employees, Total Booking Revenue, Avg Booking Value |
| User Analytics | New Users, Business %, Repeat Booking Rate, Users With Bookings |

See [`docs/kpi_catalog.md`](docs/kpi_catalog.md) for full metric definitions with formulas.

## Querying the Semantic Layer

Metric views use Databricks' `MEASURE()` syntax:

```sql
-- Total revenue by payment method
SELECT `payment_method`, MEASURE(`total_revenue`) AS `total_revenue`
FROM workspace.wanderbricks_semantic.mv_revenue_metrics
GROUP BY ALL
ORDER BY `total_revenue` DESC;
```

The standard SQL view (`vw_executive_dashboard`) queries normally:

```sql
SELECT * FROM workspace.wanderbricks_semantic.vw_executive_dashboard
ORDER BY year DESC, month DESC LIMIT 1;
```

## Free-Tier Considerations

- All views are **virtual** (no storage cost) — compute is only used when queried
- Serverless SQL auto-starts/stops — no idle cluster costs
- No pipelines or scheduled jobs required for this project
- For production, consider migrating views to a Lakeflow Spark Declarative Pipeline for incremental processing

## Future Enhancements

- Migrate Bronze → Silver to a Lakeflow Spark Declarative Pipeline for incremental updates
- Add data quality alerts (e.g., payment success rate drop)
- Implement row-level security on Gold views (e.g., employees see only their region)
- Add a Genie Space for natural-language querying of the semantic layer
- Real-time streaming for bookings and payments via Auto Loader

## License

This project uses the `samples.wanderbricks` sample dataset provided by Databricks for educational/portfolio purposes.