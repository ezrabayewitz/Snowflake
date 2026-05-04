# Part 2 – Simple Data Pipeline

## Overview
This section focuses on building a simple end-to-end data pipeline in Snowflake using external ingestion, semi-structured data processing, and dynamic tables.

The goal is to simulate a real-world data engineering workflow where raw data is ingested, transformed, and aggregated automatically through a governed pipeline.

---

# Objectives

In this project, I worked through:

- Loading external data from Amazon S3 into Snowflake stages
- Ingesting structured data using COPY INTO
- Working with semi-structured JSON data using VARIANT types
- Flattening nested arrays for relational analysis
- Building automated pipelines using Dynamic Tables
- Creating downstream transformations with dependency chains
- Visualizing pipeline flow using DAG (Directed Acyclic Graphs)

---

# Pipeline Architecture

### 1. Data Ingestion
- External stage connected to S3 bucket
- Raw menu data loaded into Snowflake staging table

### 2. Semi-Structured Processing
- JSON-based menu health metrics stored in VARIANT columns
- Extracted nested values using colon syntax and FLATTEN

### 3. Transformation Layer
- Converted raw ingestion into structured ingredient-level dataset
- Built reusable ingredient-to-menu mappings

### 4. Dynamic Tables Pipeline
- Created automated refresh tables with LAG-based scheduling
- Built multi-layer dependency chain:
  - ingredient → ingredient_to_menu_lookup → ingredient_usage_by_truck

### 5. Operational Simulation
- Inserted new menu items and orders
- Verified automatic propagation through dynamic tables

---

# Key Concepts Learned

## External Staging
Snowflake can directly reference external cloud storage (S3) without ingestion until COPY INTO is executed.

## VARIANT Data Type
Enables storage and querying of semi-structured JSON data inside relational tables.

## FLATTEN Function
Used to explode arrays into relational rows for analysis.

## Dynamic Tables
Declarative, automatically refreshed tables that eliminate the need for manual ETL scheduling.

## Pipeline DAG
Snowflake visualizes table dependencies as a Directed Acyclic Graph for monitoring data lineage.

---

# Data Pipeline Flow


```text
S3 External Data
        ↓
Raw Stage (menu_stage)
        ↓
Staging Table (menu_staging)
        ↓
Ingredient Extraction (VARIANT parsing)
        ↓
ingredient table (dynamic)
        ↓
ingredient_to_menu_lookup (dynamic)
        ↓
ingredient_usage_by_truck (dynamic)

---

# Notes

- This lab demonstrates a fully automated transformation pipeline using Snowflake-native features.
- Dynamic Tables handle orchestration without external tools like Airflow or dbt.
- All transformations are declarative and auto-refreshed based on defined lag intervals.
