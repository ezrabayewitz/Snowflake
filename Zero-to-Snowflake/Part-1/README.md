# Part 1 – Getting Started with Snowflake

## Overview
This project is a structured implementation of Snowflake’s official “Getting Started with Snowflake” quickstart lab. It demonstrates foundational concepts in cloud data warehousing, SQL execution, and Snowflake’s core platform architecture.

All work was executed in a Snowflake worksheet environment and documented for learning and portfolio purposes.

---

# Objectives

This lab focuses on understanding:

- Virtual warehouse creation and compute scaling
- Query execution and result caching
- Semi-structured data transformation (VARIANT types)
- Zero-copy cloning for safe development workflows
- Data recovery using Time Travel (UNDROP)
- Resource monitoring and cost management
- Budget tracking for cloud spend control
- Universal search for data discovery

---

# Workflow Summary

### 1. Virtual Warehouses
- Created and configured `my_wh`
- Adjusted warehouse size and auto-suspend settings
- Executed queries using dedicated compute resources

### 2. Query Execution & Caching
- Ran analytical queries on sample datasets
- Observed query result caching behavior
- Compared execution times between cold and cached runs

### 3. Data Transformation
- Extracted structured fields from VARIANT data type
- Converted semi-structured data into relational columns
- Performed aggregation and grouping on cleaned data

### 4. Zero-Copy Cloning
- Created development copy of production table
- Modified schema safely without impacting original data
- Demonstrated Snowflake’s storage-efficient cloning system

### 5. Data Cleaning & SWAP Operations
- Standardized inconsistent values in dataset
- Used table SWAP for atomic production updates

### 6. Data Recovery (Time Travel)
- Dropped production table accidentally
- Restored it using UNDROP
- Verified data integrity after recovery

### 7. Resource Monitoring
- Created credit-based resource monitor
- Assigned monitor to warehouse
- Configured alerts and automatic suspension rules

### 8. Budgets
- Created cost-tracking budget object
- Linked database and warehouse resources
- Enabled spend visibility and alerts

### 9. Universal Search
- Explored metadata discovery tools
- Located objects and documentation using search interface

---

# Key Concepts Learned

## Virtual Warehouses
Compute and storage are decoupled. Warehouses can be scaled independently based on workload demand.

## Query Result Caching
Snowflake automatically caches query results, significantly improving performance for repeated queries.

## Zero-Copy Cloning
Instant duplication of database objects without additional storage cost.

## Time Travel
Ability to restore dropped or modified objects within a retention period.

## Cost Governance
Resource Monitors and Budgets provide granular control over compute spend.

---

# Tech Stack

- Snowflake Cloud Data Platform
- SQL (ANSI-style)
- Semi-structured data (VARIANT, JSON)
- Snowflake UI Worksheets

---

# Notes

This lab is based on Snowflake’s official “Getting Started” quickstart and has been reorganized and documented to reflect practical understanding and learning outcomes.
