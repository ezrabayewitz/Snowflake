# World Population & Geographic Trends Pipeline

An end-to-end Snowflake data engineering pipeline built on World Bank and UN public datasets. This project demonstrates automated ingestion, change data capture, and declarative transformation — three production-grade patterns used in real-world consulting engagements.

---

## Project Overview

This pipeline automatically ingests global population and economic indicator data into Snowflake, detects changes using Streams, triggers transformations on a schedule using Tasks, and maintains a self-updating analytics layer using Dynamic Tables. Once deployed, the pipeline runs itself with no manual intervention.

**Datasets**: World Bank Open Data (population, GDP per capita, urbanization) — free, no account required

**Platform**: Snowflake (X-Small warehouse, free trial)

**Estimated credit cost**: < $20

---

## Architecture

```
World Bank CSVs (free public data)
          │
          │  Snowpipe (event-driven auto-ingestion)
          ▼
┌──────────────────────────────────────┐
│             RAW SCHEMA               │
│  countries_raw                       │
│  population_raw                      │
│  indicators_raw                      │
└──────────────────────────────────────┘
          │
          │  Streams (change data capture)
          │  Tasks (scheduled transformation trigger)
          ▼
┌──────────────────────────────────────┐
│          ANALYTICS SCHEMA            │
│  Dynamic Tables (auto-refreshing)    │
│  COUNTRY_PROFILES                    │
│  GDP_POPULATION_EFFICIENCY           │
│  REGIONAL_TRENDS                     │
│  URBANIZATION_GROWTH                 │
└──────────────────────────────────────┘
          │
          │  SQL views
          ▼
┌──────────────────────────────────────┐
│          REPORTING SCHEMA            │
│  V_COUNTRY_SNAPSHOT_2023             │
│  V_GDP_LEADERS_2023                  │
│  V_REGIONAL_POPULATION_TRENDS        │
│  V_TOP_URBANIZING_COUNTRIES          │
│  V_URBANIZATION_VS_GDP               │
└──────────────────────────────────────┘
```

---

## How This Differs from a Basic Pipeline

| Feature | Basic pipeline | This project |
|---|---|---|
| Ingestion | Manual COPY INTO | Snowpipe (automatic) |
| Transformation trigger | Manual execution | Streams + Tasks (scheduled) |
| Analytics layer | Static tables | Dynamic Tables (self-updating) |
| Change detection | None | Streams (row-level CDC) |

---

## Repository Structure

```
world-population-pipeline/
│
├── 01_setup.sql                    # Database, schemas, warehouse
├── 02_staging_and_pipe.sql         # Stage, file format, Snowpipe definition
├── 03_raw_tables.sql               # Raw table definitions
├── 04_streams_and_tasks.sql        # CDC streams + scheduled task logic
├── 05_dynamic_tables.sql           # Self-updating analytics layer
├── 06_reporting_views.sql          # Business-facing SQL views
│
└── docs/
    ├── 01_setup_README.md
    ├── 02_staging_and_pipe_README.md
    ├── 03_raw_tables_README.md
    ├── 04_streams_and_tasks_README.md
    ├── 05_dynamic_tables_README.md
    └── 06_reporting_views_README.md
```

---

## Key Concepts Demonstrated

| Concept | Where Used |
|---|---|
| Snowpipe (continuous ingestion) | Step 2 |
| Internal stages + named file formats | Step 2 |
| Streams (change data capture) | Step 4 |
| Tasks (scheduled pipeline automation) | Step 4 |
| Dynamic Tables (declarative transforms) | Step 5 |
| Fact and dimension modeling | Steps 4–5 |
| Window functions and aggregations | Step 6 |
| Cost-conscious warehouse configuration | Step 1 |

---

## Business Questions Answered

| View | Question answered |
|---|---|
| `vw_gdp_vs_population` | Which countries punch above their weight economically relative to population size? |
| `vw_urbanization_trends` | Which regions are urbanizing fastest, and how has that shifted over time? |
| `vw_regional_comparisons` | How do continents compare on population growth and economic development? |
| `vw_economic_outliers` | Which countries are statistical outliers in GDP per capita for their region? |

---

## Data Sources

All datasets are freely available from the World Bank Open Data portal (data.worldbank.org):

- `SP.POP.TOTL` — Total population by country and year
- `NY.GDP.PCAP.CD` — GDP per capita (current USD)
- `SP.URB.TOTL.IN.ZS` — Urban population as % of total

---

## How to Run

1. Create a Snowflake trial account at [snowflake.com](https://snowflake.com)
2. Download the three World Bank datasets as CSV files
3. Run each numbered SQL script in order inside Snowsight
4. Upload CSV files to the internal stage when prompted in Step 2
5. Verify Snowpipe loaded the raw tables, then confirm Dynamic Tables are refreshing

> **Security note**: Never commit credentials to version control. If running outside Snowsight, store credentials in environment variables.

---
