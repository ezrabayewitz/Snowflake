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
| [Part 1](Zero-to-Snowflake/Part-1/) | Setup & Basic Queries | Created, configured, & scaled a Virtual Warehouse; Query Result Cache; Zero-Copy Cloning; Transfored & cleaned data; Recovered dropped table using UNDROP; Created & applied Resource Monitor; Created Budget; Used Universal Search |
| [Part 2](Zero-to-Snowflake/Part-2/) | Simple Data Pipeline | Ingested data from an external S3 stage; Queried and transformed semi-structured VARIANT data; Used the FLATTEN function to parse arrays; Created and chained Dynamic Tables; Learned how an ELT pipeline automatically processes new data; Visualized a pipeline using the Directed Acyclic Graph (DAG) |
| [Part 3](Zero-to-Snowflake/Part-3/) | Cortex AI | Cortex Playground for AI model testing & optimization; Cortex AI Functions for systematic customer feedback processing; Cortex Search for instant customer feedback discovery & operational intelligence; Cortex Analyst for conversational data exploration |
| [Part 4](Zero-to-Snowflake/Part-4/) | Governance Features in Snowflake Horizon | Compute scaling, performance tuning, concurrency |
| [Part 5](Zero-to-Snowflake/Part-5/) | Apps & Collaboration | Time Travel, data recovery, dynamic tables |

---

## Additional Quickstarts (In Progress)

| Project | Description | Status |
|----------|-------------|------|
| Coming soon | Extended SQL practice and applied analytics labs | ⏳ Planned |

---

# Repository Structure

```
Snowflake/
├── Zero-to-Snowflake/
│   ├── Part-1/   ← setup + basics
│   ├── Part-2/   ← Simple Data Pipeline
│   ├── Part-3/   ← Cortex AI
│   ├── Part-4/   ← Governance Features in Snowflake Horizon
│   ├── Part-5/   ← Apps & Collaboration
├── quickstarts/  ← additional quickstarts (coming soon)
├── queries/      ← standalone SQL exercises
├── notes/        ← SnowPro Core study notes
└── README.md
```

---

# What I Built & Learned

## Loading & Transforming Data
- Built pipelines using COPY INTO
- Transformed raw data into analytics-ready tables
- Worked with JSON and semi-structured formats

## Compute & Performance
- Configured virtual warehouses for workload optimization
- Tested auto-suspend and auto-resume behavior
- Explored scaling and concurrency concepts

## Data Reliability
- Used Time Travel for historical queries and recovery
- Practiced rollback and data restoration strategies

## Modern Data Pipelines
- Explored dynamic tables for automated transformations
- Understood lightweight orchestration inside Snowflake

---

# Tech Stack

| Category | Tools |
|----------|------|
| Platform | Snowflake |
| Language | SQL |
| Data Formats | CSV, JSON, Parquet |
| Interface | Snowflake UI, SnowSQL |

---

# Certification

**SnowPro Core Certification (Snowflake)**  
Status: In Progress  
Candidate: Ezra Bayewitz  

---

# Connect

- 💼 LinkedIn: https://www.linkedin.com/in/ezra-bayewitz  
- 🌐 Portfolio: coming soon
