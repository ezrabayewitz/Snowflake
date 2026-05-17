# Snowflake Portfolio

![Snowflake](https://img.shields.io/badge/Snowflake-Cloud%20Data%20Platform-29B5E8)
![SQL](https://img.shields.io/badge/SQL-Intermediate-orange)
![Status](https://img.shields.io/badge/SnowPro%20Core-In%20Progress-yellow)

A structured portfolio of hands-on Snowflake quickstarts, SQL exercises, and data projects focused on building practical cloud data warehousing skills in preparation for the SnowPro Core certification.

---

# Projects Overview

## Zero to Snowflake (Core Quickstart Series)

> Guided end-to-end exploration of Snowflake fundamentals — from setup to advanced data features.

| Part | Focus Area | What I Learned |
|------|------------|----------------|
| Part 1 | Setup & Basic Queries | Created, configured, & scaled a Virtual Warehouse; Query Result Cache; Zero-Copy Cloning; Transfored & cleaned data; Recovered dropped table using UNDROP; Created & applied Resource Monitor; Created Budget; Used Universal Search |
| Part 2 | Simple Data Pipeline | Ingested data from an external S3 stage; Queried and transformed semi-structured VARIANT data; Used the FLATTEN function to parse arrays; Created and chained Dynamic Tables; Learned how an ELT pipeline automatically processes new data; Visualized a pipeline using the Directed Acyclic Graph (DAG) |
| Part 3 | Cortex AI | Cortex Playground for AI model testing & optimization; Cortex AI Functions for systematic customer feedback processing; Cortex Search for instant customer feedback discovery & operational intelligence; Cortex Analyst for conversational data exploration |
| Part 4 | Governance with Horizon | Implemented a comprehensive data governance framework using Snowflake Horizon to secure PII, enforce access controls, and monitor data quality across the Tasty Bytes platform. |
| Part 5 | Apps & Collaboration | Leveraged Snowflake Marketplace data shares and Streamlit to enrich Tasty Bytes analytics with third-party weather and geospatial data — uncovering how external factors like wind and precipitation impact food truck sales. |

---

## End-to-End Analytics with Snowflake and Power BI

| Part | Focus Area | What I Learned |
|------|------------|----------------|
| Part 1 | Data Profiling | Designed the foundational data layer and access control framework to serve Tasty Bytes analytics through Power BI, with region-based role segregation.|
| Part 2 | Makretplace Data | Acquired and integrated SafeGraph geospatial data from the Snowflake Marketplace to enrich Tasty Bytes truck locations with point-of-interest metadata. |
| Part 3 | Star Schema with Dynamic Tables | Built a complete star schema data model using Snowflake Dynamic Tables, providing an auto-refreshing analytics layer optimized for Power BI consumption. |
| Part 4 | Data Governance | Protect sensitive data and enforce access controls using **Snowflake Horizon** — Snowflake's built-in data governance framework. |
| Streamlit | Tasty Bytes - Regional Sales Dashboard | An interactive Streamlit dashboard analyzing monthly sales performance across global regions for the Tasty Bytes food truck business, built on Snowflake Dynamic Tables. |

---

# Repository Structure

```
Snowflake/
├── Zero-to-Snowflake/
│   ├── Part-1/   ← setup + basics
│   ├── Part-2/   ← Simple Data Pipeline
│   ├── Part-3/   ← Cortex AI
│   ├── Part-4/   ← Governance with Horizon
│   ├── Part-5/   ← Apps & Collaboration
├── End-to-End Analytics with Snowflake and Power BI/
│   ├── Part-1/   ← Data Profiling
│   ├── Part-2/   ← Makretplace Data
│   ├── Part-3/   ← Star Schema with Dynamic Tables
│   ├── Part-4/   ← Data Governance
│   ├── Streamlit/   ← Tasty Bytes - Regional Sales Dashboard
├── Retail Sales Pipeline/
│   ├── Part 1 - Setup.sql                  # Database, schema, and warehouse setup
│   ├── Part 2 - Staging.sql                # Internal stage and file format creation
│   ├── Part 3 - Loading Raw Data.sql       # Table definitions and COPY INTO commands
│   ├── Part 4 - Snowpark Transformations.py    # Snowpark Python transformation logic
│   ├── Part 5 - Reporting Views.sql        # Business-facing SQL views
│   │
│   └── docs/
│       ├── 01_setup_README.md
│       ├── 02_staging_README.md
│       ├── 03_load_raw_README.md
│       ├── 04_snowpark_transforms_README.md
│       └── 05_reporting_views_README.md
├── notes/        ← SnowPro Core study notes
└── README.md
```

---

# Certification

**SnowPro Core Certification (Snowflake)**  
Status: In Progress  
Candidate: Ezra Bayewitz  

---

# Connect

- 💼 LinkedIn: https://www.linkedin.com/in/ezra-bayewitz  
- 🌐 Portfolio: coming soon
