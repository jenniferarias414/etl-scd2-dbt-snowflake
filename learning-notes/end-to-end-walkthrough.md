# End-to-End Walkthrough

This project built an SCD Type 2 product dimension pipeline using AWS S3, Snowflake, dbt models, and dbt snapshots.

## Big Picture

The pipeline works like this:

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

## Step 1: Local Product Files

The project starts with two product CSV files:

```text
Product_Dim.csv
Product_Dim_1.csv
```

`Product_Dim.csv` is the original product file.

`Product_Dim_1.csv` is the changed product file used to demonstrate SCD Type 2 behavior.

The changed product file contains one product record with updated values.

The changed product ID is:

```text
4c69b61db1fc16e7013b43fc926e502d
```

The changed fields are:

```text
MODEL_NUMBER
PRODUCT_DIMENSIONS
```

## Step 2: Python Uploads Files to S3

A Python script uploads the local CSV files to Amazon S3.

Script:

```text
python/local_to_aws_s3.py
```

Target S3 location:

```text
s3://scd2-product-data-jenny/raw_data/
```

The script uses `boto3` and a local AWS CLI profile instead of hardcoded credentials.

## Step 3: S3 Stores Raw Product Files

S3 acts as the raw landing zone.

It stores the CSV files before Snowflake reads them.

S3 does not transform the data. It only provides a durable cloud location for the source files.

## Step 4: Snowflake Reads from S3

Snowflake reads the S3 files through:

- storage integration
- external stage
- CSV file format

The stage is:

```text
SCD2_DB.BRONZE.SCD2_STAGE
```

The file format is:

```text
SCD2_DB.BRONZE.SCD2_CSV_FORMAT
```

A successful `LS` command against the stage proves Snowflake can see the product file in S3.

## Step 5: dbt Macro Loads Bronze Table

The dbt macro runs a Snowflake `COPY INTO` command.

Macro:

```text
scd2_copy_product_csv
```

File:

```text
dbt/macros/copy_into_snowflake.sql
```

The macro loads staged CSV data into:

```text
SCD2_DB.BRONZE.WORK_PRODUCT_COPY
```

This macro is called as a `pre_hook` before the Silver model runs.

That means the Bronze copy step happens automatically before the Silver transform model is built.

## Step 6: dbt Silver Model Transforms Product Data

The Silver model reads from the Bronze table and creates a transformed product table.

Model:

```text
dbt/models/scd2_product/silver/transform_product_load.sql
```

Output:

```text
SCD2_DB.SILVER.WORK_PRODUCT_TRANSFORM
```

The Silver layer keeps product attributes and adds processing metadata.

## Step 7: dbt Snapshot Tracks Product Changes

The dbt snapshot tracks changes to product records over time.

Snapshot:

```text
dbt/snapshots/scd2_product/product_snapshot.sql
```

Output:

```text
SCD2_DB.SNAPSHOTS.PRODUCT_SNAPSHOT
```

The snapshot uses:

```text
unique_key = PRODUCT_ID
strategy = check
```

The `check` strategy compares selected columns. If one of those columns changes for the same `PRODUCT_ID`, dbt creates a new version of the row.

## Step 8: Gold View Exposes Product History

The Gold view reads from the snapshot table and exposes version history in a cleaner format.

Model:

```text
dbt/models/scd2_product/gold/product_view.sql
```

Output:

```text
SCD2_DB.GOLD.PRODUCT_VIEW
```

The Gold view renames dbt validity fields:

```text
DBT_VALID_FROM → VRSN_STRT_DTS
DBT_VALID_TO   → VRSN_END_DTS
```

It also uses an open-ended date for current rows:

```text
9999-12-31
```

## Step 9: Initial Load Validation

The initial `Product_Dim.csv` file was uploaded to S3.

Then dbt ran:

```bash
dbt run --select transform_product_load
dbt snapshot --select product_snapshot
dbt run --select product_view
```

This created the Silver table, Snapshot table, and Gold view.

## Step 10: Change Load Validation

The changed file `Product_Dim_1.csv` was uploaded to S3.

Then dbt ran again:

```bash
dbt run --select transform_product_load
dbt snapshot --select product_snapshot
dbt run --select product_view
```

The snapshot detected changes for the same `PRODUCT_ID`.

The Gold view showed two versions:

1. old historical version
2. new current version

## Final Result

The final result confirmed SCD Type 2 behavior.

The old product version was retained and given an end timestamp.

The new product version was inserted as the current version.

That means the project preserved product history instead of overwriting the old values.