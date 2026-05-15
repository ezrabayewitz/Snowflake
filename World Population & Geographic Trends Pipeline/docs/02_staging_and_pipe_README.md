# 02 — Staging and Snowpipe

This script creates the internal stage, named file format, and three Snowpipe definitions that form the ingestion layer of the pipeline.

---

## What This Script Does

- Creates a named file format (`world_bank_csv`) configured for World Bank CSV structure
- Creates an internal stage (`world_stage`) for uploading source files
- Defines three Snowpipe objects that automatically load files into raw tables as they arrive

---

## What is Snowpipe?

Snowpipe is Snowflake's continuous data ingestion service. Rather than running a manual `COPY INTO` command on a schedule, Snowpipe watches a stage for new files and loads them automatically — either triggered by cloud storage events (`AUTO_INGEST = TRUE`) or called via the Snowpipe REST API.

In this pipeline, `AUTO_INGEST = FALSE` is used and the pipes are triggered manually. This avoids the need to configure cloud storage event notifications, keeping the project within the free trial budget while still demonstrating the full Snowpipe pattern.

In a production environment at a client site, `AUTO_INGEST = TRUE` would be enabled with an S3/Azure/GCS event notification, making the pipeline fully event-driven with no manual intervention required.

---

## Design Decisions

### Named file format
Rather than defining format options inline in each pipe, a single named file format object (`world_bank_csv`) is reused across all three pipes. This is best practice in production because:
- Format settings are defined once and version-controlled in one place
- Any change to the format (e.g. adding a new null value pattern) applies to all pipes automatically
- It makes `COPY INTO` commands cleaner and easier to read

### Separate stage subdirectories
Files are uploaded into subdirectories (`population/`, `indicators/`, `countries/`) within the same stage. Each Snowpipe points to its own subdirectory, so files are routed to the correct table automatically. This mirrors how a real data landing zone is organised — one stage, multiple logical partitions.

### NULL handling
World Bank CSVs use `..` as a null indicator for missing data. The `NULL_IF = ('NULL', 'null', '', 'NA', '..')` setting handles all common null patterns so the raw tables don't contain literal string dots where numeric values are expected.

### TRIM_SPACE = TRUE
Some World Bank CSVs include leading/trailing whitespace in string fields. This setting strips it automatically during ingestion, preventing subtle join failures downstream (e.g. `'Brazil '` not matching `'Brazil'`).

---

## Snowpipe vs COPY INTO

| Feature | COPY INTO | Snowpipe |
|---|---|---|
| Trigger | Manual or scheduled | Event-driven or API call |
| Latency | Batch (minutes to hours) | Near real-time (seconds) |
| Cost model | Warehouse credits | Serverless compute credits |
| Best for | Large batch loads | Continuous / streaming files |

---
