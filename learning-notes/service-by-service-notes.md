# Service-by-Service Notes

This project uses Python, AWS S3, Snowflake, and dbt Cloud.

Each component has a specific role in the SCD Type 2 pipeline.

## Python

Python uploads local product CSV files to S3.

The script uses:

```text
boto3
AWS CLI profile
```

Python is only responsible for moving files from the local machine into the S3 landing folder.

## Amazon S3

S3 stores the raw product CSV files.

Bucket:

```text
scd2-product-data-jenny
```

Folder:

```text
raw_data/
```

S3 acts as the raw landing zone for Snowflake ingestion.

## AWS IAM

IAM controls access between AWS and Snowflake.

This project uses IAM for two main purposes:

1. local Python upload access to S3
2. Snowflake read access to S3 through a storage integration

For production, permissions should be narrowed to the exact bucket and prefix needed.

## Snowflake Storage Integration

The storage integration allows Snowflake to securely read from S3.

Integration:

```text
SCD2_INT
```

Snowflake generates trust values that are used in the AWS IAM role trust policy.

## Snowflake External Stage

The external stage points Snowflake to the S3 folder.

Stage:

```text
SCD2_DB.BRONZE.SCD2_STAGE
```

S3 path:

```text
s3://scd2-product-data-jenny/raw_data/
```

The stage is how Snowflake knows where to find the CSV files.

## Snowflake File Format

The file format tells Snowflake how to interpret the CSV file.

File format:

```text
SCD2_DB.BRONZE.SCD2_CSV_FORMAT
```

Important behavior:

- skip header row
- comma delimiter
- quoted values allowed
- empty fields treated as null

## Bronze Layer

Bronze table:

```text
SCD2_DB.BRONZE.WORK_PRODUCT_COPY
```

This is the raw working copy table.

It receives rows from the staged CSV file.

## dbt Macro

A macro is reusable dbt SQL/Jinja logic.

This project uses a macro to run the staged file load into the Bronze table.

Macro:

```text
scd2_copy_product_csv
```

The macro is called before the Silver model runs.

## Silver Layer

Silver output:

```text
SCD2_DB.SILVER.WORK_PRODUCT_TRANSFORM
```

The Silver model creates a transformed product table.

It keeps the product data and adds processing metadata.

## dbt Snapshot

The snapshot is the main SCD Type 2 component.

Snapshot output:

```text
SCD2_DB.SNAPSHOTS.PRODUCT_SNAPSHOT
```

The snapshot tracks changes to selected product fields.

If a tracked field changes for the same product ID, dbt creates a new product version.

## Gold Layer

Gold output:

```text
SCD2_DB.GOLD.PRODUCT_VIEW
```

The Gold view presents product history in a cleaner reporting format.

It includes version start and end dates.

## Main Responsibility Split

```text
Python = uploads files
S3 = stores files
Snowflake stage = exposes files to Snowflake
Bronze = raw working copy
Silver = transformed product data
Snapshot = historical version tracking
Gold = reporting-friendly product history
```