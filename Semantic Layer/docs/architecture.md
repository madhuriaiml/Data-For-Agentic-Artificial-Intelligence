# Architecture

## Overview

This project implements a **Medallion Architecture** with four layers, progressing from raw data to business-ready metrics. Each layer is implemented as SQL Views in Unity Catalog, ensuring zero storage cost and idempotent re-runs.

## Layer Details

### Source Layer — `samples.wanderbricks`

Read-only sample data provided by Databricks. 6 tables representing a vacation rental platform:

| Table | Rows | Grain | Key Columns |
| --- | --- | --- | --- |
| `users` | ~7,938 | One row per user | `user_id` (PK) |
| `hosts` | ~4,728 | One row per host | `host_id` (PK) |
| `properties` | ~12,725 | One row per property | `property_id` (PK), `host_id` (FK) |
| `bookings` | ~47,477 | One row per booking | `booking_id` (PK), `user_id` (FK), `property_id` (FK) |
| `payments` | ~49,638 | One row per payment | `payment_id` (PK), `booking_id` (FK) |
| `employees` | ~10,634 | One row per employee | `employee_id` (PK), `host_id` (FK) |

### Bronze Layer — `workspace.wanderbricks_bronze`

**Purpose:** 1:1 mirror of source tables with an `_ingested_at` timestamp for auditability.

**Design principles:**
- Isolates downstream layers from changes to the `samples` catalog
- No transformations — raw passthrough only
- Adds `current_timestamp() AS _ingested_at` for load tracking

### Silver Layer — `workspace.wanderbricks_silver`

**Purpose:** Cleaned, typed, conformed data with derived business columns and data quality flags.

**Transformations applied:**
- String normalization: `TRIM()`, `UPPER()`, `LOWER()` on text fields
- Derived columns: `user_segment`, `host_tier`, `price_tier`, `stay_duration_days`, `employment_status`
- Data quality flags: `has_null_email`, `has_invalid_dates`, `has_invalid_amount`, etc.
- Date truncation: `booking_month`, `payment_month` for downstream grouping

### Gold Layer — `workspace.wanderbricks_gold`

**Purpose:** Star schema with conformed dimensions and fact tables for analytics.

**Dimension tables:**
- `dim_users` — user attributes + signup year/month
- `dim_hosts` — host attributes + tier + join year/month
- `dim_properties` — property attributes + price tier + listed year
- `dim_employees` — employee attributes + employment status
- `dim_date` — generated calendar from min to max booking date (season, quarter, year-quarter)

**Fact tables:**
- `fact_bookings` — one row per booking, enriched with `host_id` via property join
- `fact_payments` — one row per payment, enriched with booking/user/property/host FKs

### Semantic Layer — `workspace.wanderbricks_semantic`

**Purpose:** Business-ready metrics using Unity Catalog Metric Views.

**Metric Views (use `MEASURE()` syntax):**
- `mv_revenue_metrics` — revenue & payment KPIs (dimensions: payment year, month, method)
- `mv_booking_metrics` — booking analytics (dimensions: booking year, month, status, property type, price tier)
- `mv_host_performance` — host KPIs with pre-aggregated SQL source (dimensions: host name, tier, verified, active, country, rating)
- `mv_user_analytics` — user/guest analytics with pre-aggregated SQL source (dimensions: signup year, month, segment, country, business, repeat user)

**Standard SQL View:**
- `vw_executive_dashboard` — monthly cross-domain summary combining revenue, bookings, users, and active hosts

## Data Flow

```
samples.wanderbricks.*
    │
    ├──→ bronze.users      ──→ silver.users      ──→ gold.dim_users      ──→ semantic.mv_user_analytics
    ├──→ bronze.hosts       ──→ silver.hosts       ──→ gold.dim_hosts      ──┐
    ├──→ bronze.properties  ──→ silver.properties  ──→ gold.dim_properties──→ semantic.mv_host_performance
    ├──→ bronze.bookings    ──→ silver.bookings    ──→ gold.fact_bookings  ──→ semantic.mv_booking_metrics
    │                                              ──→ gold.dim_date            │
    ├──→ bronze.payments    ──→ silver.payments    ──→ gold.fact_payments  ──→ semantic.mv_revenue_metrics
    └──→ bronze.employees   ──→ silver.employees   ──→ gold.dim_employees   ──┘
                                                                         ──→ semantic.vw_executive_dashboard
```

## Why Views Instead of Tables?

1. **Zero storage cost** — views compute on-demand, no materialized data
2. **Always fresh** — no ETL scheduling needed; queries always see latest source data
3. **Idempotent** — `CREATE OR REPLACE VIEW` makes re-runs safe
4. **Free-tier friendly** — only compute cost when actively queried
5. **Simple to maintain** — SQL-only, no pipeline infrastructure

For production, consider migrating to Lakeflow Spark Declarative Pipelines for incremental processing and materialization.