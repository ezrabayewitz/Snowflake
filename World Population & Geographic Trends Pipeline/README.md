# World Population & Geographic Trends Pipeline

An end-to-end Snowflake data engineering pipeline built on World Bank public datasets. This project demonstrates automated ingestion via Snowpipe, change data capture using Streams, scheduled transformation using Tasks and Stored Procedures, declarative analytics using Dynamic Tables, and business-facing reporting views.

---

## Project Overview

This pipeline ingests global population, GDP per capita, and urbanization data from the World Bank into Snowflake, transforms it from a wide format into a long analytical format, and maintains a self-updating analytics layer that answers real geographic and economic business questions.

**Datasets**: World Bank Open Data — free, no account required
- `SP.POP.TOTL` — Total population by country (1960–2025)
- `NY.GDP.PCAP.CD` — GDP per capita in USD (1960–2025)
- `SP.URB.TOTL.IN.ZS` — Urban population as % of total (1960–2025)
- Country metadata — region and income group classifications

**Platform**: Snowflake (X-Small warehouse, free trial)

**Estimated credit cost**: < $20

---

## Architecture

```
World Bank CSVs (4 files, free public data)
              │
              │  Snowpipe (AUTO_INGEST = FALSE, manual REFRESH)
              ▼
┌──────────────────────────────────────────┐
│               RAW SCHEMA                 │
│  population_raw   (wide: 1 row/country)  │
│  indicators_raw   (wide: 1 row/country)  │
│  countries_raw    (metadata)             │
└──────────────────────────────────────────┘
              │
              │  Streams (APPEND_ONLY change data capture)
              │  Task (every 5 min, conditional on stream data)
              │  Stored Procedure (UNPIVOT wide → long format)
              ▼
┌──────────────────────────────────────────┐
│            ANALYTICS SCHEMA              │
│  country_year_metrics                    │
│  (long: 1 row per country/year/indicator)│
│                                          │
│  Dynamic Tables (TARGET_LAG = 5 min)     │
│  country_profiles                        │
│  urbanization_growth                     │
│  gdp_population_efficiency               │
│  regional_trends                         │
└──────────────────────────────────────────┘
              │
              │  SQL views
              ▼
┌──────────────────────────────────────────┐
│            REPORTING SCHEMA              │
│  v_top_urbanizing_countries              │
│  v_gdp_leaders_2023                      │
│  v_regional_population_trends            │
│  v_country_snapshot_2023                 │
│  v_urbanization_vs_gdp                   │
└──────────────────────────────────────────┘
```

---

## Key Concepts Demonstrated

| Concept | Where Used |
|---|---|
| Snowpipe (automated ingestion) | Step 2 |
| Named file formats (two formats for different CSV structures) | Step 2 |
| APPEND_ONLY streams (change data capture) | Step 4 |
| Stored procedure (encapsulated transformation logic) | Step 4 |
| Conditional task scheduling (`SYSTEM$STREAM_HAS_DATA`) | Step 4 |
| UNPIVOT (wide-to-long format transformation) | Step 4 |
| Dynamic Tables with dependency chaining | Step 5 |
| Conditional aggregation pivot (`MAX CASE WHEN`) | Step 5 |
| Cost-conscious warehouse configuration | Step 1 |
| Defensive ingestion patterns (`_extra`, `IF NOT EXISTS`, `NULLIF`) | Steps 2–5 |

---

## Business Questions Answered

| View | Question |
|---|---|
| `v_top_urbanizing_countries` | Which countries urbanized fastest between 2000 and 2023? |
| `v_gdp_leaders_2023` | Which countries had the highest GDP per capita in 2023? |
| `v_regional_population_trends` | How have World Bank regions evolved in population, GDP, and urbanization since 1990? |
| `v_country_snapshot_2023` | What does each country look like today across all key metrics? |
| `v_urbanization_vs_gdp` | Does higher urbanization correlate with higher GDP per capita? |

---

## Repository Structure

```
world-population-pipeline/
│
├── 01_setup.sql
├── 02_staging_and_pipe.sql
├── 03_raw_tables.sql
├── 04_streams_and_tasks.sql
├── 05_dynamic_tables.sql
├── 06_reporting_views.sql
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

## How to Run

1. Create a Snowflake trial account at [snowflake.com](https://snowflake.com)
2. Download the four World Bank CSVs (links in each dataset README)
3. Run scripts `01` through `06` in order in Snowsight SQL worksheets
4. Upload CSVs to the internal stage when prompted in Step 2
5. Run `ALTER PIPE ... REFRESH` for all four pipes
6. Run the initial backfill INSERT statements in Step 4
7. Confirm Dynamic Tables and reporting views return data via the verification queries

> **Note**: Tasks are created in a suspended state and must be resumed with `ALTER TASK ... RESUME`. This is done automatically at the end of Step 4.

> **Security**: Never commit credentials to version control.

---
