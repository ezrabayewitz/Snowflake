# ❄️ Snowflake Data Engineering Portfolio
### Ezra Bayewitz

[![Snowflake](https://img.shields.io/badge/Snowflake-Cloud%20Data%20Platform-29B5E8?logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![SQL](https://img.shields.io/badge/SQL-Intermediate-orange?logo=postgresql&logoColor=white)]()
[![Python](https://img.shields.io/badge/Python-Snowpark-3776AB?logo=python&logoColor=white)]()
[![Power BI](https://img.shields.io/badge/Power%20BI-Analytics-F2C811?logo=powerbi&logoColor=black)]()
[![Streamlit](https://img.shields.io/badge/Streamlit-Dashboard-FF4B4B?logo=streamlit&logoColor=white)]()
[![SnowPro Core](https://img.shields.io/badge/SnowPro%20Core-In%20Progress-yellow)]()

---

## 📌 Overview

This repository documents a structured, end-to-end journey through **Snowflake's core data engineering capabilities** — from cloud warehouse fundamentals to production-grade analytics pipelines. Projects span data ingestion, transformation, governance, AI, and business intelligence — including a self-built **World Population & Geographic Trends Pipeline** using real World Bank data, a **Retail Sales Pipeline**, and an **interactive Power BI + Streamlit analytics layer**.

> **Business focus:** Every project here maps to real-world data engineering tasks — building scalable pipelines, enforcing governance, enabling self-service analytics, and extracting insights from raw data.

---

## 🗂️ Table of Contents

- [Tech Stack](#-tech-stack)
- [Key Skills Demonstrated](#-key-skills-demonstrated)
- [Project Architecture](#-project-architecture)
- [Projects](#-projects)
  - [World Population & Geographic Trends Pipeline](#1--world-population--geographic-trends-pipeline--flagship-project)
  - [Retail Sales Pipeline](#2--retail-sales-pipeline)
  - [End-to-End Analytics with Snowflake & Power BI](#3--end-to-end-analytics-with-snowflake--power-bi)
  - [Zero to Snowflake (Core Quickstart Series)](#4--zero-to-snowflake-core-quickstart-series)
- [Repository Structure](#-repository-structure)
- [Certification](#-certification)
- [Connect](#-connect)

---

## 🛠️ Tech Stack

| Category | Tools |
|---|---|
| **Cloud Data Platform** | Snowflake (Virtual Warehouses, Stages, Dynamic Tables, Cortex AI, Horizon) |
| **Languages** | SQL, Python (Snowpark) |
| **Data Transformation** | Snowpark Python, Dynamic Tables, SQL Views |
| **Business Intelligence** | Power BI, Streamlit |
| **Data Governance** | Snowflake Horizon (RBAC, PII masking, data quality) |
| **AI / ML** | Snowflake Cortex (LLM functions, Cortex Search, Cortex Analyst) |
| **Data Sources** | Internal staging, AWS S3, Snowflake Marketplace (SafeGraph) |
| **Architecture Patterns** | ELT, Star Schema, DAG Pipelines, Role-Based Access Control, Change Data Capture (CDC), Wide-to-Long UNPIVOT |

---

## 💡 Key Skills Demonstrated

- **Pipeline Engineering** — Built end-to-end ELT pipelines from raw ingestion through staging, transformation, and business-facing reporting views
- **Automated Ingestion** — Implemented Snowpipe for continuous data loading and APPEND_ONLY Streams for change data capture
- **Scheduled Orchestration** — Designed conditional Task scheduling using `SYSTEM$STREAM_HAS_DATA` to trigger transformations only when new data arrives
- **Data Modeling** — Designed star schema data models and long-format analytical tables with automated refresh via Dynamic Tables
- **Cloud Infrastructure** — Configured and scaled Virtual Warehouses; implemented Resource Monitors and Budgets
- **Data Governance** — Applied role-based access control, PII masking policies, and data quality monitoring using Snowflake Horizon
- **Semi-Structured Data** — Parsed and flattened JSON/VARIANT data using `FLATTEN` and lateral joins
- **AI Integration** — Used Snowflake Cortex AI for LLM-powered feedback analysis and conversational analytics
- **Third-Party Data Enrichment** — Integrated Snowflake Marketplace datasets (SafeGraph geospatial) to enrich internal analytics
- **BI & Visualization** — Delivered insights via Power BI connected to Snowflake and an interactive Streamlit dashboard
- **Python in Snowflake** — Wrote Snowpark transformations executed natively within the Snowflake environment

---

## 🏗️ Project Architecture

```
Raw Data Sources
(CSV files, S3, Marketplace)
          │
          ▼
┌─────────────────────┐
│   Snowflake Stages  │  ← Internal & External Stages, File Formats
│   (Ingestion Layer) │
└─────────┬───────────┘
          │  COPY INTO
          ▼
┌─────────────────────┐
│    Raw / Bronze     │  ← Unprocessed source tables
│       Tables        │
└─────────┬───────────┘
          │  Snowpark Python + SQL
          ▼
┌─────────────────────┐
│   Silver / Curated  │  ← Cleaned, typed, transformed data
│       Tables        │     Dynamic Tables (auto-refresh)
└─────────┬───────────┘
          │  Star Schema modeling
          ▼
┌─────────────────────┐
│  Gold / Analytics   │  ← Fact + Dimension tables, Reporting Views
│       Layer         │     Role-Based Access Control (Horizon)
└─────────┬───────────┘
          │
    ┌─────┴──────┐
    ▼            ▼
 Power BI     Streamlit
(Dashboards) (Web App)
```

---

## 📁 Projects

---

### 1. 🌍 World Population & Geographic Trends Pipeline — *Flagship Project*

**[View Project →](<./World Population & Geographic Trends Pipeline/>)**

**Business Problem:** Global organizations and analysts need to understand long-term demographic and economic trends across countries — but World Bank data arrives as wide, country-per-row CSVs spanning 60+ years. This project builds a fully automated pipeline that ingests, reshapes, and continuously refreshes that data into a queryable analytics layer, answering real geographic and economic questions.

**What I Built:**
- Ingested 4 World Bank public datasets (population, GDP per capita, urbanization, country metadata) via **Snowpipe**
- Implemented **APPEND_ONLY Streams** for change data capture on raw tables
- Designed a **Stored Procedure** to UNPIVOT wide-format data into a long analytical format (1 row per country/year/indicator)
- Scheduled **conditional Task execution** using `SYSTEM$STREAM_HAS_DATA` — transforms only fire when new data arrives
- Built a **Dynamic Table dependency chain** (5-minute lag) for country profiles, urbanization growth, GDP efficiency, and regional trends
- Delivered 5 business-facing **reporting views** answering real geographic and economic questions

**Pipeline Architecture:**

```
World Bank CSVs (4 files — free public data)
              │
              │  Snowpipe (AUTO_INGEST, manual REFRESH)
              ▼
        RAW SCHEMA
  population_raw / indicators_raw / countries_raw
  (wide format: 1 row per country, 60+ year columns)
              │
              │  Streams (CDC) → Task (conditional, every 5 min)
              │  Stored Procedure (UNPIVOT wide → long)
              ▼
        ANALYTICS SCHEMA
  country_year_metrics (long: 1 row per country/year/indicator)
  Dynamic Tables: country_profiles, urbanization_growth,
                  gdp_population_efficiency, regional_trends
              │
              │  SQL Views
              ▼
        REPORTING SCHEMA
  v_top_urbanizing_countries  |  v_gdp_leaders_2023
  v_regional_population_trends  |  v_country_snapshot_2023
  v_urbanization_vs_gdp
```

**Business Questions Answered:**

| Reporting View | Question Answered |
|---|---|
| `v_top_urbanizing_countries` | Which countries urbanized fastest between 2000–2023? |
| `v_gdp_leaders_2023` | Which countries had the highest GDP per capita in 2023? |
| `v_regional_population_trends` | How have World Bank regions evolved since 1990? |
| `v_country_snapshot_2023` | What does each country look like across all metrics today? |
| `v_urbanization_vs_gdp` | Does higher urbanization correlate with higher GDP per capita? |

**Tech Used:** Snowpipe, Streams (CDC), Tasks, Stored Procedures, UNPIVOT, Dynamic Tables, SQL Views, Snowflake SQL

| File | Purpose |
|------|---------|
| `01_setup.sql` | Database, schema, warehouse provisioning |
| `02_staging_and_pipe.sql` | Internal stages, file formats, Snowpipe definitions |
| `03_raw_tables.sql` | Raw table definitions |
| `04_streams_and_tasks.sql` | Streams, Stored Procedure, Task scheduling |
| `05_dynamic_tables.sql` | Analytics layer with Dynamic Table dependency chain |
| `06_reporting_views.sql` | Business-facing reporting views |

---

### 2. 🏪 Retail Sales Pipeline

**[View Project →](./Retail%20Sales%20Pipeline/)**

**Business Problem:** Retail organizations accumulate raw sales data across regions and product lines, but raw files alone can't drive decisions. This project builds a structured analytics pipeline — from raw CSV ingestion to clean, query-ready reporting views — simulating the work of a data engineer supporting a retail analytics team.

**What I Built:**
- Designed and provisioned the full Snowflake environment (database, schemas, warehouse)
- Created internal stages and file formats for structured CSV ingestion
- Defined raw tables and loaded data using `COPY INTO`
- Wrote Snowpark Python transformations executed natively in Snowflake
- Delivered business-facing SQL reporting views consumed downstream

**Pipeline Workflow:**

```
CSV Source Files
      │
      ▼
Internal Stage + File Format
      │  COPY INTO
      ▼
Raw Tables (Bronze)
      │  Snowpark Python
      ▼
Transformed Tables (Silver)
      │  SQL
      ▼
Reporting Views (Gold)
```

**Tech Used:** Snowflake SQL, Snowpark Python, Virtual Warehouses, Internal Stages, COPY INTO, SQL Views

| File | Purpose |
|------|---------|
| `Part 1 - Setup.sql` | Database, schema, and warehouse provisioning |
| `Part 2 - Staging.sql` | Internal stage and file format creation |
| `Part 3 - Loading Raw Data.sql` | Table definitions and COPY INTO commands |
| `Part 4 - Snowpark Transformations.py` | Snowpark Python transformation logic |
| `Part 5 - Reporting Views.sql` | Business-facing SQL views |

---

### 3. 📊 End-to-End Analytics with Snowflake & Power BI

**[View Project →](./End-to-End%20Analytics%20with%20Snowflake%20and%20Power%20BI/)**

**Business Problem:** A food truck company (Tasty Bytes) needs a scalable analytics layer that non-technical stakeholders can consume through Power BI — with proper governance, third-party data enrichment, and an auto-refreshing data model. This project builds that full stack.

**What I Built:**
- Designed the foundational data access layer with region-based role segregation
- Integrated **SafeGraph geospatial data** from the Snowflake Marketplace to enrich truck location data
- Built a complete **star schema** using Snowflake Dynamic Tables (auto-refreshing on new data)
- Applied **Snowflake Horizon** governance: PII masking, access policies, data quality monitoring
- Delivered a **Streamlit dashboard** for regional sales analysis — deployed natively in Snowflake

**Architecture:**

```
Tasty Bytes Raw Data + SafeGraph Marketplace
              │
              ▼
     Snowflake Dynamic Tables
     (Star Schema: Fact + Dims)
       Auto-refreshing via DAG
              │
     ┌────────┴────────┐
     ▼                 ▼
  Power BI         Streamlit App
(Regional KPIs)  (Interactive Dashboard)
```

**Tech Used:** Snowflake Dynamic Tables, Star Schema, Snowflake Marketplace, Snowflake Horizon, Power BI, Streamlit, RBAC

| Part | Focus |
|------|-------|
| Part 1 — Data Profiling | Data layer design + role-based access control |
| Part 2 — Marketplace Data | SafeGraph geospatial enrichment |
| Part 3 — Star Schema | Dynamic Tables for auto-refreshing analytics model |
| Part 4 — Data Governance | Horizon: PII masking, access policies |
| Streamlit App | Regional Sales Dashboard — interactive, live |

---

### 4. 📚 Zero to Snowflake — *Core Quickstart Series*

**[View Project →](./Zero-to-Snowflake/)**

A structured five-part series covering Snowflake fundamentals through hands-on labs. Designed to build both certification readiness and practical intuition for cloud data warehousing.

| Part | Focus | Skills Gained |
|------|-------|--------------|
| **Part 1** | Setup & Fundamentals | Virtual Warehouse scaling, Query Result Cache, Zero-Copy Cloning, UNDROP, Resource Monitors |
| **Part 2** | Simple Data Pipeline | S3 external stage ingestion, VARIANT/semi-structured data, FLATTEN, Dynamic Tables, DAG visualization |
| **Part 3** | Cortex AI | LLM model playground, Cortex AI Functions, Cortex Search, Cortex Analyst (conversational queries) |
| **Part 4** | Governance with Horizon | PII classification, dynamic data masking, access control policies, data quality monitoring |
| **Part 5** | Apps & Collaboration | Snowflake Marketplace, Streamlit in Snowflake, weather + geospatial data enrichment |

---

## 📂 Repository Structure

```
Snowflake/
│
├── world-population-pipeline/          ← 🌍 Flagship independent project
│   ├── 01_setup.sql
│   ├── 02_staging_and_pipe.sql
│   ├── 03_raw_tables.sql
│   ├── 04_streams_and_tasks.sql
│   ├── 05_dynamic_tables.sql
│   ├── 06_reporting_views.sql
│   └── docs/
│       ├── 01_setup_README.md
│       ├── 02_staging_and_pipe_README.md
│       ├── 03_raw_tables_README.md
│       ├── 04_streams_and_tasks_README.md
│       ├── 05_dynamic_tables_README.md
│       └── 06_reporting_views_README.md
│
├── Retail Sales Pipeline/              ← 🏪 Independent pipeline project
│   ├── Part 1 - Setup.sql
│   ├── Part 2 - Staging.sql
│   ├── Part 3 - Loading Raw Data.sql
│   ├── Part 4 - Snowpark Transformations.py
│   ├── Part 5 - Reporting Views.sql
│   └── docs/
│       ├── 01_setup_README.md
│       ├── 02_staging_README.md
│       ├── 03_load_raw_README.md
│       ├── 04_snowpark_transforms_README.md
│       └── 05_reporting_views_README.md
│
├── End-to-End Analytics with Snowflake and Power BI/   ← 📊 Full analytics stack
│   ├── Part-1/   ← Data Profiling + Access Control
│   ├── Part-2/   ← Marketplace Data (SafeGraph)
│   ├── Part-3/   ← Star Schema with Dynamic Tables
│   ├── Part-4/   ← Data Governance (Horizon)
│   └── Streamlit/   ← Regional Sales Dashboard
│
├── Zero-to-Snowflake/                  ← 📚 Core quickstart labs
│   ├── Part-1/   ← Setup & Fundamentals
│   ├── Part-2/   ← Simple Data Pipeline
│   ├── Part-3/   ← Cortex AI
│   ├── Part-4/   ← Governance with Horizon
│   └── Part-5/   ← Apps & Collaboration
│
├── notes/                              ← 📝 SnowPro Core study notes
└── README.md
```

---

## 🎓 Certification

**SnowPro Core Certification — Snowflake**
- Status: 🟡 In Progress
- Candidate: Ezra Bayewitz
- Covers: Virtual Warehouses, Data Sharing, Performance Tuning, Security, Semi-Structured Data, Cortex AI, Data Governance

---

## 🔮 What's Next

- [ ] Complete SnowPro Core Certification
- [ ] Add query result screenshots to World Population Pipeline reporting views
- [ ] Add Power BI screenshots and dashboard walkthrough to End-to-End Analytics project
- [ ] Add Streamlit app screenshots to Regional Sales Dashboard
- [ ] Add schema diagrams for Retail Sales Pipeline
- [ ] Expand World Population Pipeline with additional indicators (literacy, life expectancy)
- [ ] Explore Snowflake Data Clean Rooms

---

## 🤝 Connect

- 💼 **LinkedIn:** [linkedin.com/in/ezra-bayewitz](https://www.linkedin.com/in/ezra-bayewitz)
- 🌐 **Portfolio:** Coming soon

---

*Built while preparing for SnowPro Core certification and developing practical cloud data engineering skills.*
