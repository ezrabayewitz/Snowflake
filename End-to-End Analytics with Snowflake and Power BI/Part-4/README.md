## Part 4: Data Governance

Protect sensitive data and enforce access controls using **Snowflake Horizon** — Snowflake's built-in data governance framework.

### What's Covered

#### Object Tagging & Classification
- Run Snowflake's built-in `SYSTEM$CLASSIFY` procedure to automatically detect and tag PII columns (names, emails, phone numbers, dates of birth)
- Create custom tags (`pii_name_tag`, `pii_phone_number_tag`, `pii_email_tag`, `pii_dob_tag`) for fine-grained classification
- Apply custom tags to specific columns on `DT_DIM_CUSTOMER`

#### Dynamic Data Masking (Tag-Based)
- **Name mask** — returns `**~MASKED~**` for unauthorized roles
- **Phone mask** — partially masks phone numbers (e.g., `555-***-****`)
- **Email mask** — hides username portion (e.g., `******@provider.com`)
- **Date of Birth mask** — truncates to the first of the month

Masking policies are attached directly to tags, so any column with the tag is automatically protected — no per-column assignment needed.

| Role | Access Level |
|------|-------------|
| `SYSADMIN` / `ACCOUNTADMIN` | Full unmasked access |
| `TB_BI_ANALYST_GLOBAL` | Unmasked (except email) |
| Regional analyst roles | Masked PII |

#### Row Access Policies
- Create a mapping table (`ROW_POLICY_MAP`) linking analyst roles to permitted `LOCATION_ID` values
- Define a row access policy (`RAP_DIM_LOCATION_POLICY`) that filters fact table rows based on the current role
