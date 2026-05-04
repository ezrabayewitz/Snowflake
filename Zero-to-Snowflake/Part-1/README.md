## Getting Started with Snowflake

Explored Snowflake's core platform capabilities through hands-on configuration and data operations using the Tasty Bytes food truck dataset.

### What's Covered

1. **Virtual Warehouses** — Created and configured compute warehouses with auto-suspend, auto-resume, and elastic scaling (XSmall → XLarge on the fly)
2. **Query Result Cache** — Demonstrated Snowflake's persisted query results, reducing repeat query execution from seconds to milliseconds with zero compute cost
3. **Data Transformation** — Extracted structured columns from semi-structured VARIANT/JSON data using colon notation and casting, then cleaned data quality issues (e.g., `Ford_` → `Ford`)
4. **Zero Copy Cloning** — Created instant, storage-free dev copies of production tables for safe transformation work, then atomically swapped into production
5. **Data Recovery (UNDROP)** — Restored accidentally dropped tables using Snowflake's Time Travel feature
6. **Resource Monitors** — Set credit quotas with threshold-based actions (notify at 75%, suspend at 90%, kill at 100%)
7. **Budgets** — Created spending limits across any Snowflake object or service with email notifications
8. **Universal Search** — Used natural language search to discover relevant tables, views, Marketplace listings, and documentation

### Tech Stack

| Component | Purpose |
|-----------|---------|
| Virtual Warehouses | Elastic, scalable compute resources |
| Zero Copy Cloning | Instant dev/test copies without storage cost |
| Time Travel & UNDROP | Data recovery and versioning |
| VARIANT Data Type | Semi-structured JSON storage and querying |
| Resource Monitors | Warehouse credit usage controls |
| Budgets | Holistic cost management across services |
| Universal Search | Natural language object discovery |
