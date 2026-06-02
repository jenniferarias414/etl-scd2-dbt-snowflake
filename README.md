# ETL SCD Type 2 using dbt and Snowflake

## Overview

This project demonstrates an SCD Type 2 product dimension pipeline using **AWS S3**, **Snowflake**, and **dbt Cloud**.

The pipeline uploads product CSV files to S3, loads the data into Snowflake through an external stage, transforms the product data with dbt, captures product changes with a dbt snapshot, and exposes product version history through a Gold view.

This project focuses on **Slowly Changing Dimension Type 2**, where historical versions of records are preserved instead of overwritten.

## Architecture

```text
Local Product CSV files
→ Python upload script
→ Amazon S3 raw_data/ folder
→ Snowflake external stage
→ BRONZE.WORK_PRODUCT_COPY
→ dbt Silver transform model
→ dbt Snapshot
→ dbt Gold PRODUCT_VIEW
```

## What This Project Demonstrates

- Uploading local product CSV files to Amazon S3 with Python and boto3
- Creating an S3 landing folder for raw product files
- Connecting Snowflake to S3 through a storage integration and external stage
- Creating a Snowflake file format for CSV ingestion
- Loading staged CSV data into a Bronze working table with a dbt macro
- Building a Silver dbt model for transformed product data
- Using a dbt snapshot to capture SCD Type 2 record history
- Building a Gold view that exposes version start and end dates
- Validating that a changed product record creates multiple historical versions

## Tech Stack

- AWS S3
- AWS IAM
- Snowflake
- dbt Cloud
- dbt Snapshots
- SQL
- Python
- boto3
- GitHub

## What Is SCD Type 2?

Slowly Changing Dimension Type 2 is a data warehousing pattern used to preserve historical versions of dimension records.

Instead of overwriting old values, SCD Type 2 keeps the old record, expires it with an end date, and creates a new current record.

Example:

```text
Old product version:
Product ID: 123
Model Number: blank
Valid From: 2026-01-01
Valid To: 2026-06-01

New product version:
Product ID: 123
Model Number: BG1782
Valid From: 2026-06-01
Valid To: 9999-12-31
```

The old value remains available for history, while the new row represents the current active version.

## Data Files

This project uses two product CSV files:

```text
Product_Dim.csv
Product_Dim_1.csv
```

`Product_Dim.csv` is the initial product file.

`Product_Dim_1.csv` contains a changed version of one product record.

The changed product used for validation was:

```text
Product ID: 4c69b61db1fc16e7013b43fc926e502d
```

The changed fields were:

```text
MODEL_NUMBER
PRODUCT_DIMENSIONS
```

The raw CSV files are stored locally and excluded from GitHub.

## Repository Structure

```text
.
├── architecture/
│   └── architecture-overview.md
├── data/
│   └── local/                  # gitignored local CSV files
├── dbt/
│   ├── dbt_project.yml
│   ├── macros/
│   │   └── copy_into_snowflake.sql
│   ├── models/
│   │   └── scd2_product/
│   │       ├── silver/
│   │       │   ├── schema.yml
│   │       │   └── transform_product_load.sql
│   │       └── gold/
│   │           ├── schema.yml
│   │           └── product_view.sql
│   ├── snapshots/
│   │   └── scd2_product/
│   │       └── product_snapshot.sql
│   └── README.md
├── docs/
│   ├── project-status.md
│   ├── screenshot-guide.md
│   ├── source-material-handling.md
│   └── troubleshooting.md
├── learning-notes/
├── python/
│   ├── local_to_aws_s3.py
│   └── README.md
├── screenshots/
│   ├── full-walkthrough/
│   ├── selected-for-readme/
│   └── README.md
├── snowflake/
│   ├── 01_database_setup.sql
│   ├── 02_storage_integration_stage.sql
│   └── README.md
├── .gitignore
├── LICENSE
├── README.md
└── requirements.txt
```

## Pipeline Layers

### AWS S3 Landing Layer

Product CSV files are uploaded from the local machine into:

```text
s3://scd2-product-data-jenny/raw_data/
```

This acts as the raw file landing location.

### Snowflake Bronze Layer

Snowflake reads the staged CSV files from S3 through:

- storage integration
- external stage
- CSV file format

The Bronze working table is:

```text
SCD2_DB.BRONZE.WORK_PRODUCT_COPY
```

### dbt Silver Layer

The Silver model transforms the copied product data and adds processing metadata.

Output:

```text
SCD2_DB.SILVER.WORK_PRODUCT_TRANSFORM
```

### dbt Snapshot Layer

The dbt snapshot tracks changes to selected product fields.

Snapshot table:

```text
SCD2_DB.SNAPSHOTS.PRODUCT_SNAPSHOT
```

The snapshot adds dbt-generated SCD2 columns such as:

```text
DBT_SCD_ID
DBT_UPDATED_AT
DBT_VALID_FROM
DBT_VALID_TO
```

### dbt Gold Layer

The Gold view exposes versioned product history in a reporting-friendly structure.

Output:

```text
SCD2_DB.GOLD.PRODUCT_VIEW
```

The view renames dbt validity columns into:

```text
VRSN_STRT_DTS
VRSN_END_DTS
```

## Validation

The project was validated in two stages.

### Initial Load

The initial `Product_Dim.csv` file was uploaded to S3 and processed through the dbt transform, snapshot, and Gold view.

Validation confirmed:

- product data loaded into the Silver transform table
- dbt snapshot created SCD2 tracking columns
- Gold view exposed product version data

### Change Load

The changed `Product_Dim_1.csv` file was uploaded to S3.

The dbt transform, snapshot, and Gold view were rerun.

Validation confirmed that the same product ID had two versions:

- old version with blank `MODEL_NUMBER` and blank `PRODUCT_DIMENSIONS`
- new version with `MODEL_NUMBER = BG1782`
- new version with `PRODUCT_DIMENSIONS = 41" H x 36" W x 24" L`

This confirmed SCD Type 2 behavior.

## Selected Validation Screenshots

| Step | Screenshot |
|---|---|
| S3 bucket and raw folder created | `screenshots/selected-for-readme/01-s3-bucket-raw-data-folder-created.png` |
| Product file uploaded to S3 | `screenshots/selected-for-readme/03-s3-product-file-uploaded.png` |
| Snowflake stage listed product file | `screenshots/selected-for-readme/07-snowflake-stage-list-product-file.png` |
| dbt transform ran successfully | `screenshots/selected-for-readme/10-dbt-transform-run-success.png` |
| Silver transform table validated | `screenshots/selected-for-readme/11-snowflake-silver-transform-validated.png` |
| dbt snapshot ran successfully | `screenshots/selected-for-readme/12-dbt-snapshot-run-success.png` |
| Snapshot table validated | `screenshots/selected-for-readme/13-snowflake-snapshot-validated.png` |
| Gold view validated | `screenshots/selected-for-readme/15-snowflake-gold-view-validated.png` |
| Product change file uploaded | `screenshots/selected-for-readme/17-python-product-change-file-upload-success.png` |
| SCD2 versioning validated | `screenshots/selected-for-readme/22-snowflake-scd2-versioning-validated.png` |

## Notes About Scope

This is a guided learning project and not a production deployment.

For a production implementation, improvements would include:

- least-privilege IAM policies
- secure secret management
- infrastructure as code
- automated dbt jobs
- stronger data quality tests
- source freshness checks
- error handling for rejected files
- monitoring and alerting
- CI/CD for dbt deployment
- a stronger product source system and change-feed strategy

## Project Status

Completed:

- S3 bucket and `raw_data/` folder
- Python upload script
- Snowflake storage integration and stage
- Snowflake CSV file format
- Bronze working table
- dbt macro for staged CSV loading
- Silver transform model
- dbt snapshot for SCD Type 2 versioning
- Gold product history view
- Initial load validation
- Change load validation
- SCD2 historical version validation