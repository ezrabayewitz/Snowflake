## Data Pipeline

Built an end-to-end data pipeline in Snowflake to ingest, transform, and track ingredient usage across Tasty Bytes food truck operations.

### Pipeline Architecture

1. **Ingestion** — Loaded raw menu CSV data from an Amazon S3 external stage into a staging table using `COPY INTO`
2. **Semi-Structured Parsing** — Extracted nested JSON health metrics and ingredient arrays from VARIANT columns using colon notation, bracket indexing, and `LATERAL FLATTEN`
3. **Dynamic Table Pipeline** — Created a chain of auto-refreshing Dynamic Tables that declaratively transform raw data into analytics-ready views:
   - `INGREDIENT` — Distinct ingredients with associated menu IDs
   - `INGREDIENT_TO_MENU_LOOKUP` — Maps ingredients to individual menu items
   - `INGREDIENT_USAGE_BY_TRUCK` — Monthly ingredient consumption per truck (US only)
4. **DAG Visualization** — Monitored pipeline dependencies and refresh status via Snowflake's built-in Directed Acyclic Graph

### Key Concepts

- Automatic downstream refresh — inserting a new menu item (e.g., Banh Mi) propagates through the entire pipeline without manual intervention
- Declarative transformations — Dynamic Tables define *what* the data should look like, not *how* to update it
- Target lag configuration — each table specifies its freshness SLA (1–2 minutes)

### Tech Stack

| Component | Purpose |
|-----------|---------|
| External Stages (S3) | Cloud data ingestion from Amazon S3 |
| VARIANT Data Type | Semi-structured JSON parsing & querying |
| LATERAL FLATTEN | Unnesting nested arrays and JSON objects |
| Dynamic Tables | Declarative, auto-refreshing transformation pipeline |
| DAG Visualization | Pipeline orchestration & monitoring |
| COPY INTO | Bulk data loading from stage to table | dbt.
- All transformations are declarative and auto-refreshed based on defined lag intervals.
