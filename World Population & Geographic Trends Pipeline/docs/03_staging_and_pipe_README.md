# 03 — Staging and Snowpipe

This script creates two named file formats, an internal stage, and four Snowpipe definitions that form the automated ingestion layer of the pipeline.

---

## What This Script Does

- Creates two file formats tailored to the two distinct World Bank CSV structures
- Creates an internal stage (`world_stage`) for uploading source files
- Defines four Snowpipe objects that load files into raw tables automatically when refreshed
- Verifies stage contents and triggers all four pipes
- Confirms both indicators loaded correctly by checking distinct `indicator_code` values

---

## File Formats

Two separate file formats are needed because World Bank data CSVs and metadata CSVs have different structures:

### world_bank_csv
Used for the main data files (population, GDP, urbanization). These files include a 5-line header block containing dataset metadata before the actual column headers begin, so `SKIP_HEADER = 5` is required to land on the correct row.

### world_bank_metadata_csv
Used for the country metadata file, which has a standard single header row. Uses `SKIP_HEADER = 1`.

Using named file formats rather than inline format options is best practice — format settings are defined once, reused across all pipes, and easy to update in one place if the source structure changes.

---

## Snowpipe Definitions

### pop_pipe
Loads total population data from `API_SP.POP.TOTL_DS2_en_csv_v2_127039.csv` into `RAW.POPULATION_RAW`.

### indicators_pipe
Loads GDP per capita data from `API_NY.GDP.PCAP.CD_DS2_en_csv_v2_121663.csv` into `RAW.INDICATORS_RAW`.

### urban_pipe
Loads urbanization rate data from `API_SP.URB.TOTL.IN.ZS_DS2_en_csv_v2_121583.csv` into `RAW.INDICATORS_RAW`.

Note that both `indicators_pipe` and `urban_pipe` load into the same target table (`INDICATORS_RAW`). This is intentional — both datasets share the same wide column structure and are distinguished downstream by their `indicator_code` column (`NY.GDP.PCAP.CD` vs `SP.URB.TOTL.IN.ZS`).

### countries_pipe
Loads country metadata from the World Bank metadata CSV into `RAW.COUNTRIES_RAW` using the separate `world_bank_metadata_csv` format.

---

## Design Decisions

### AUTO_INGEST = FALSE
True auto-ingest requires configuring cloud storage event notifications (S3, Azure, GCS) to notify Snowflake when new files arrive. In this project, `AUTO_INGEST = FALSE` is used and pipes are triggered manually via `ALTER PIPE ... REFRESH`. This keeps the project within free trial constraints while still demonstrating the full Snowpipe pattern.

In a production client environment, `AUTO_INGEST = TRUE` would be enabled with the appropriate cloud event notification, making the pipeline fully event-driven with no manual intervention required.

### ON_ERROR = 'CONTINUE'
Rather than aborting the entire load when a malformed row is encountered, `ON_ERROR = 'CONTINUE'` skips the bad row and continues loading. This is appropriate for raw ingestion where maximizing data capture is the priority. Errors are tracked in Snowflake's `COPY_HISTORY` and can be investigated separately.

### COMPRESSION = 'AUTO'
Snowflake automatically detects and decompresses files regardless of whether they are zipped or unzipped. This makes the pipeline resilient to changes in how source files are delivered.

### Two indicators in one table
GDP per capita and urbanization rate are stored in the same `INDICATORS_RAW` table rather than separate tables. Since both share an identical column structure, combining them reduces redundancy and keeps the raw layer simpler. The `indicator_code` column cleanly separates them for any downstream filtering.

---

