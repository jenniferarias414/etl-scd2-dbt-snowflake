# Screenshot Guide

This project uses screenshots as validation evidence for the SCD Type 2 dbt + Snowflake pipeline.

Screenshots are organized into:

```text
screenshots/full-walkthrough/
screenshots/selected-for-readme/
```

## Screenshot Folders

### `screenshots/full-walkthrough/`

Contains the full build and validation trail.

### `screenshots/selected-for-readme/`

Contains the strongest screenshots for the README, portfolio card, and case study page.

## Recommended Public Screenshots

| Screenshot | What it proves |
|---|---|
| `01-s3-bucket-raw-data-folder-created.png` | S3 bucket and raw landing folder were created |
| `03-s3-product-file-uploaded.png` | Product CSV file was uploaded to S3 |
| `07-snowflake-stage-list-product-file.png` | Snowflake external stage can see the S3 file |
| `10-dbt-transform-run-success.png` | dbt Silver transform model ran successfully |
| `11-snowflake-silver-transform-validated.png` | Silver transform table was created and populated |
| `12-dbt-snapshot-run-success.png` | dbt snapshot ran successfully |
| `13-snowflake-snapshot-validated.png` | Snapshot table contains dbt SCD2 metadata columns |
| `15-snowflake-gold-view-validated.png` | Gold product history view was created |
| `17-python-product-change-file-upload-success.png` | Changed product file was uploaded to S3 |
| `22-snowflake-scd2-versioning-validated.png` | Same product ID shows historical and current versions |

## Best Screenshots for Portfolio

Use these for the portfolio case study:

```text
diagrams/etl-scd2-dbt-snowflake-architecture.png
screenshots/selected-for-readme/07-snowflake-stage-list-product-file.png
screenshots/selected-for-readme/12-dbt-snapshot-run-success.png
screenshots/selected-for-readme/13-snowflake-snapshot-validated.png
screenshots/selected-for-readme/22-snowflake-scd2-versioning-validated.png
```

## Privacy Review Before Publishing

Before publishing screenshots publicly, review and crop or blur:

- AWS account IDs
- IAM role ARNs
- Snowflake account identifiers
- access key material
- personal email addresses
- browser tabs or bookmarks
- unrelated project details

Never publish screenshots showing access keys or secret keys.

## Screenshot Strategy

The goal is not to prove every click.

The goal is to prove:

- source data landed in S3
- Snowflake could read the staged file
- dbt models ran successfully
- dbt snapshot created historical tracking columns
- the Gold view showed multiple versions for a changed product