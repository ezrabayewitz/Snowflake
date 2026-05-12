# 01 — Setup

This script establishes the foundational Snowflake objects for the pipeline: the database, schema layers, and virtual warehouse.

---

## What This Script Does

- Creates the `RETAIL_PIPELINE` database
- Creates three schemas representing the pipeline's data layers: `RAW`, `ANALYTICS`, and `REPORTING`
- Creates an `X-SMALL` virtual warehouse configured for cost efficiency

---

## Design Decisions

### Three-schema medallion architecture
Rather than dumping all tables into a single schema, this pipeline separates data by its stage of transformation. This mirrors how professional data teams at consulting firms like Squadron Data structure client environments:

- `RAW` — data exactly as it arrived from the source, never modified
- `ANALYTICS` — cleaned, joined, and modeled tables ready for analysis
- `REPORTING` — business-facing views that answer specific questions

This separation means that if a transformation breaks, the raw source data is always preserved and the pipeline can be re-run from any layer.

### X-SMALL warehouse
An X-SMALL warehouse is sufficient for this dataset (~100,000 rows). Using a larger warehouse would provide no performance benefit and would burn credits unnecessarily. In a client engagement, right-sizing warehouses is one of the first cost optimizations a data engineer performs.

### AUTO_SUSPEND = 60
The warehouse automatically suspends after 60 seconds of inactivity. A suspended warehouse costs zero credits. This is a critical setting to enable on any warehouse — forgetting to set it is a common source of unexpected Snowflake spend.

### AUTO_RESUME = TRUE
The warehouse resumes automatically when a query is submitted. This means users never need to manually start it, which is the expected behavior in a production environment.

---

## Key SQL

```sql
CREATE WAREHOUSE IF NOT EXISTS RETAIL_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;
```

---

## What to Verify

After running this script, confirm the following exist in your Snowflake account:

- Database: `RETAIL_PIPELINE`
- Schemas: `RAW`, `ANALYTICS`, `REPORTING`
- Warehouse: `RETAIL_WH`
