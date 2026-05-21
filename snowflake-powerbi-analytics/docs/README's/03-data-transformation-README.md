## Star Schema with Dynamic Tables

Built a complete star schema data model using Snowflake Dynamic Tables, providing an auto-refreshing analytics layer optimized for Power BI consumption.

### What's Covered

1. **Elastic Compute** — Temporarily scaled warehouse to 2X-Large for initial data load, then scaled back down — demonstrating instant, on-demand compute elasticity
2. **Static Dimensions** — Generated `dim_date` (2018–2024) and `dim_time` (86,400 second-level rows) using Snowflake's `GENERATOR` function
3. **Dynamic Table Dimensions** — Created auto-refreshing dimension tables with business logic:
   - `dt_dim_truck` — Truck fleet with brand, make/model, age, EV flag
   - `dt_dim_franchise` — Deduplicated franchise owners using `ROW_NUMBER()`
   - `dt_dim_menu_item` — Menu catalog with health metrics extracted from VARIANT JSON
   - `dt_dim_location` — Locations with derived region (EMEA, NA, APAC)
   - `dt_dim_customer` — Customer demographics from loyalty program
4. **Dynamic Table Facts** — Built a layered fact pipeline:
   - `dt_fact_order_detail` — Line-level transactions joined to all dimensions (enforces DAG dependencies)
   - `dt_fact_order_header` — Order-level aggregation (line count, qty, total)
   - `dt_fact_order_agg` — Daily aggregation per truck/location/customer with 1-hour target lag

### Star Schema Design

```
              dim_date ──┐
              dim_time ──┤
           dt_dim_truck ─┤
       dt_dim_franchise ─┼── dt_fact_order_detail ── dt_fact_order_header ── dt_fact_order_agg
        dt_dim_location ─┤
       dt_dim_menu_item ─┤
        dt_dim_customer ─┘
```

### Key Concepts

- `target_lag = 'DOWNSTREAM'` — Dimensions refresh only when downstream facts need them
- `target_lag = '1 hour'` — The terminal aggregate table drives the refresh cadence for the entire DAG
- Fact table joins to dimensions enforce referential integrity and proper DAG ordering
- Semi-structured JSON extraction (`:` notation) for menu health metrics

### Tech Stack

| Component | Purpose |
|-----------|---------|
| Dynamic Tables | Auto-refreshing star schema pipeline |
| GENERATOR Function | Programmatic date/time dimension creation |
| ROW_NUMBER() | Deduplication of franchise records |
| VARIANT Extraction | JSON health metrics parsing |
| Elastic Warehouses | On-demand scale up/down for bulk loads |
| DAG Orchestration | Declarative refresh dependency management |
