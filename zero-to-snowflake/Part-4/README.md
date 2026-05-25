## Governance with Horizon

Implemented a comprehensive data governance framework using Snowflake Horizon to secure PII, enforce access controls, and monitor data quality across the Tasty Bytes platform.

### What's Covered

1. **Role-Based Access Control (RBAC)** — Created a custom `tb_data_steward` role with granular privileges (warehouse usage, schema access, table-level SELECT) following Snowflake's hierarchical role model
2. **Auto Classification & Tagging** — Configured a classification profile to automatically detect and tag sensitive columns (names, emails, phone numbers, DOB) with a custom `PII` tag based on semantic categories
3. **Column-Level Security (Masking Policies)** — Created tag-based dynamic masking policies that obfuscate string and date PII for non-admin roles at query time
4. **Row-Level Security (Row Access Policies)** — Restricted row visibility by role using a policy map table — e.g., `tb_data_engineer` only sees US customer records
5. **Data Quality Monitoring (DMFs)** — Used system DMFs (`NULL_PERCENT`, `DUPLICATE_COUNT`, `AVG`) and built a custom DMF to detect order total calculation errors, scheduled to trigger on table changes
6. **Trust Center** — Enabled CIS Benchmarks and Threat Intelligence scanner packages to continuously monitor account-level security risks and surface remediation recommendations

### Key Concepts

- Tag-based masking — policies automatically apply to any column tagged as PII, no per-column attachment needed
- Declarative row access — a mapping table drives which roles see which countries, easily extensible
- Custom DMFs — business logic encoded as reusable, schedulable data quality checks
- Defense in depth — classification, masking, row access, and security scanning work as complementary layers

### Tech Stack

| Component | Purpose |
|-----------|---------|
| RBAC & Custom Roles | Granular privilege management |
| Classification Profiles | Automatic PII detection & tagging |
| Dynamic Data Masking | Column-level security at query time |
| Row Access Policies | Row-level filtering by role |
| Data Metric Functions | Automated data quality monitoring |
| Trust Center | Account security scanning & remediation |
