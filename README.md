# Zero to Snowflake

A structured, hands-on walkthrough of Snowflake's key fundamentals, following the official Zero to Snowflake quickstart series. This project documents my learning process as I build practical skills in cloud data warehousing using Snowflake.

Concepts applied using a sample dataset called Tasty Bytes.



---

# Objective

To gain practical experience with core Snowflake concepts including:
- Data loading and transformation
- Virtual warehouse management
- Querying structured and semi-structured data
- Time Travel and data recovery features
- Building foundational SQL fluency in a cloud environment

To gain hands-on experience in the following areas:
- A comprehensive understanding of the core Snowflake platform.
- Configured Virtual Warehouses.
- An automated ELT pipeline with Dynamic Tables.
- A complete intelligence customer analytics platform leveraging Snowflake AI.
- A robust data governance framework with roles and policies.
- Enriched analytical views combining first- and third-party data.

---

# Project Structure

```
Zero-to-Snowflake/
├── README.md
├── Part-1/
│   ├── README.md
│   └── queries.sql
├── Part-2/
│   ├── README.md
│   └── queries.sql
├── Part-3/
│   ├── README.md
│   └── queries.sql
├── Part-4/
│   ├── README.md
│   └── queries.sql
├── Part-5/
│   ├── README.md
│   └── queries.sql

```


---

# Learning Progress

## Part 1 – Getting Started with Snowflake

Learned about core Snowflake concepts by exploring Virtual Warehouses, using the query results cache, performing basic data transformations, leveraging data recovery with Time Travel, and monitoring account with Resource Monitors and Budgets

## Part 2 – Data Pipeline

Learned how to build a simple, automated data pipeline in Snowflake. Started by ingesting raw, semi-structured data from an external stage, and then used the power of Snowflake's Dynamic Tables to transform and enrich that data, creating a pipeline that automatically stays up-to-date as new data arrives.

## Part 3 – Cortex AI

Explored Snowflake's complete AI platform through a progressive journey from experimentation into unified business intelligence. Learned AI capabilities by building a comprehensive customer intelligence system using Cortex Playground for AI experimentation, Cortex AI Functions for production-scale analysis, Cortex Search for semantic text searching, and Cortex Analyst for natural language analytics.

## Part 4 – Governance with Horizon

This section covers Snowflake's Horizon governance framework across 6 areas: Roles & Access Control -Creating custom roles with granular privileges; Auto Classification — Automatically detecting and tagging PII columns using classification profiles; Column-Level Masking — Tag-based dynamic masking policies that hide sensitive string/date data for non-admin roles; Row-Level Security — Row access policies that filter rows by role; Data Quality (DMFs) — System and custom Data Metric Functions to monitor nulls, duplicates, and business rule violations; Trust Center — Security scanner packages for continuous account risk monitoring


## Part 5 – 


---

# Notes

This repository is actively updated as I progress through each quickstart module and expand into more advanced Snowflake use cases.
