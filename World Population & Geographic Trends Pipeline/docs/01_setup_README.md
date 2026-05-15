# 01 — Setup

This script establishes the foundational Snowflake objects for the World Population Pipeline: the database, three schema layers, and a cost-optimized virtual warehouse.

---

## What This Script Does

- Creates the `WORLD_POPULATION` database
- Creates three schemas representing the pipeline's data layers: `RAW`, `ANALYTICS`, and `REPORTING`
- Creates an `X-SMALL` virtual warehouse configured for cost efficiency

---

## Design Decisions

### Three-schema medallion architecture

This pipeline separates data into three layers, each serving a distinct purpose:

- `RAW` — data exactly as it arrived from the World Bank, never modified. If anything breaks downstream, this is the source of truth to re-run from.
- `ANALYTICS` — cleaned, modeled, and enriched tables maintained automatically by Dynamic Tables.
- `REPORTING` — business-facing SQL views that answer specific geographic and economic questions.

This separation is a professional standard in data engineering. It makes pipelines auditable, testable, and easier to debug — qualities that matter in a consulting context where a client's data is on the line.

### X-SMALL warehouse with AUTO_SUSPEND

An X-SMALL warehouse is more than sufficient for this dataset. Snowflake bills per second, and a warehouse costs nothing when suspended. Setting `AUTO_SUSPEND = 60` means the warehouse shuts off after 60 seconds of inactivity — keeping credit costs close to zero during development.

In production, right-sizing warehouses is one of the first cost optimizations a data engineer performs for a client. Documenting this decision explicitly shows awareness of real-world cost management.

---

## Key SQL

```sql
CREATE WAREHOUSE IF NOT EXISTS WORLD_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;
```

---

## What to Verify

After running this script, confirm the following exist in your Snowflake account:

- Database: `WORLD_POPULATION`
- Schemas: `RAW`, `ANALYTICS`, `REPORTING`
- Warehouse: `WORLD_WH` (status: suspended)
