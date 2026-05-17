# 04 — Streams, Tasks, and Transformation

This script is the most technically sophisticated part of the pipeline. It implements change data capture using Snowflake Streams, automates transformation using a Task, and unpivots the wide raw data into a clean long-format analytics table using a Stored Procedure.

---

## What This Script Does

- Creates `ANALYTICS.country_year_metrics` — the central analytics table in long format (one row per country per year per indicator)
- Creates two Streams on the raw tables to detect new incoming rows
- Creates a Stored Procedure that reads from the streams and unpivots data into the analytics table
- Creates a Task that runs the procedure every 5 minutes when new stream data is detected
- Performs an initial backfill of all existing raw data since streams only capture future inserts

---

## Key Concepts

### Streams (Change Data Capture)
A Snowflake Stream is an object that tracks row-level changes to a table. When new rows are inserted into `POPULATION_RAW` or `INDICATORS_RAW` — for example by a future Snowpipe refresh — the streams capture those changes automatically.

`APPEND_ONLY = TRUE` is used here because raw tables are insert-only by design. This is more efficient than a standard stream, which also tracks updates and deletes.

The `METADATA$ACTION = 'INSERT'` filter in the stored procedure ensures only new inserts are processed, not any other change types.

```sql
CREATE OR REPLACE STREAM RAW.population_stream
    ON TABLE RAW.POPULATION_RAW
    APPEND_ONLY = TRUE;
```

### UNPIVOT — wide to long transformation
The raw tables store data in a wide format — one column per year (e.g. `year_1960`, `year_1961`, ..., `year_2025`). This is how the World Bank distributes the data but it is difficult to query analytically. A query like "show me population for Brazil from 1990 to 2020" requires referencing 31 separate columns.

UNPIVOT reshapes the data into a long format — one row per country per year — which is the standard structure for time-series analysis. The `TO_NUMBER(REPLACE(year_col, 'YEAR_', ''))` expression strips the `YEAR_` prefix from the column name and converts it to a numeric year value.

**Before UNPIVOT (wide format):**
| country_name | year_1990 | year_1991 | year_1992 |
|---|---|---|---|
| Brazil | 149,469,867 | 151,889,530 | 154,344,338 |

**After UNPIVOT (long format):**
| country_name | year | value |
|---|---|---|
| Brazil | 1990 | 149,469,867 |
| Brazil | 1991 | 151,889,530 |
| Brazil | 1992 | 154,344,338 |

### Stored Procedure
The transformation logic is encapsulated in a stored procedure (`transform_raw_to_analytics`) rather than a standalone SQL statement. This makes it callable from a Task, testable in isolation, and reusable. The procedure processes both the population stream and the indicators stream in a single call and returns a status string on completion.

### Task
The Task runs the stored procedure automatically on a schedule:

```sql
SCHEDULE  = '5 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('RAW.population_stream')
  OR SYSTEM$STREAM_HAS_DATA('RAW.indicators_stream')
```

The `WHEN` clause is a conditional check — if neither stream has new data, the Task skips execution entirely and no warehouse credits are consumed. This is a critical cost-saving pattern in production pipelines.

`ALTER TASK ... RESUME` is required because Tasks are created in a suspended state by default and must be explicitly started.

### Initial backfill
Streams only capture changes that occur after the stream is created — they do not see data that already existed in the table. The two `INSERT INTO ... UNPIVOT` statements at the bottom of the script manually backfill all existing raw data into the analytics table on first run. This is a standard pattern when introducing streams to a table that already contains data.

---

## Analytics Table Structure

### country_year_metrics
| Column | Type | Description |
|---|---|---|
| country_name | VARCHAR | Full country name |
| country_code | VARCHAR | ISO 3-letter country code |
| indicator_name | VARCHAR | Human-readable indicator description |
| indicator_code | VARCHAR | World Bank indicator code |
| year | NUMBER | 4-digit year (1960–2025) |
| value | FLOAT | Indicator value for that country and year |
| loaded_at | TIMESTAMP | When the row was inserted into the analytics table |

---

## Design Decisions

### One analytics table for all indicators
All three indicators (population, GDP per capita, urbanization) land in the same `country_year_metrics` table, distinguished by `indicator_code`. This makes cross-indicator analysis straightforward — joining population to GDP for the same country and year is a simple self-join or pivot on this single table.

### loaded_at timestamp
The `loaded_at` column defaults to `CURRENT_TIMESTAMP` on insert. This provides a lightweight audit trail — you can always see when a row entered the analytics layer, which is useful for debugging pipeline timing issues.

### Streams on raw tables, not the stage
Streams are placed on the raw tables rather than monitoring the stage directly. This means the pipeline responds to data landing in the database, not just files arriving in storage — a more robust and Snowflake-native approach.

---

