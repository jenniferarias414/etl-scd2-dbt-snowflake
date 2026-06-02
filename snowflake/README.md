# Snowflake Setup

This folder contains the Snowflake SQL setup files for the SCD Type 2 dbt project.

Snowflake is used for:

- secure access to S3 files
- raw product copy table storage
- Silver transform output
- dbt snapshot history table
- Gold reporting view

## SQL Files

### `01_database_setup.sql`

Creates the main Snowflake database and Bronze schema:

```text
SCD2_DB
SCD2_DB.BRONZE
```

The Bronze schema is used for the raw working table that receives product data copied from the S3 stage.

### `02_storage_integration_stage.sql`

Creates the Snowflake objects needed to read CSV files from S3:

```text
SCD2_INT
SCD2_CSV_FORMAT
SCD2_STAGE
```

## Main Snowflake Objects

### Database

```text
SCD2_DB
```

The project database used for Bronze, Silver, Snapshot, and Gold objects.

### Bronze Schema

```text
SCD2_DB.BRONZE
```

Stores the raw working copy table and stage-related objects.

### Storage Integration

```text
SCD2_INT
```

Allows Snowflake to securely access the S3 bucket through an AWS IAM role.

### External Stage

```text
SCD2_DB.BRONZE.SCD2_STAGE
```

Points Snowflake to the S3 landing folder:

```text
s3://scd2-product-data-jenny/raw_data/
```

### CSV File Format

```text
SCD2_DB.BRONZE.SCD2_CSV_FORMAT
```

Defines how Snowflake reads the product CSV files.

Important settings include:

```text
TYPE = CSV
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
EMPTY_FIELD_AS_NULL = TRUE
```

### Bronze Working Table

```text
SCD2_DB.BRONZE.WORK_PRODUCT_COPY
```

This table stores product rows copied from the staged CSV file.

It is loaded by the dbt macro before the Silver model runs.

## Snowflake + dbt Layer Flow

```text
SCD2_DB.BRONZE.WORK_PRODUCT_COPY
→ SCD2_DB.SILVER.WORK_PRODUCT_TRANSFORM
→ SCD2_DB.SNAPSHOTS.PRODUCT_SNAPSHOT
→ SCD2_DB.GOLD.PRODUCT_VIEW
```

## SCD Type 2 Objects

### Snapshot Table

```text
SCD2_DB.SNAPSHOTS.PRODUCT_SNAPSHOT
```

Created by dbt snapshot logic.

This table stores historical product versions and includes dbt-generated fields:

```text
DBT_SCD_ID
DBT_UPDATED_AT
DBT_VALID_FROM
DBT_VALID_TO
```

### Gold View

```text
SCD2_DB.GOLD.PRODUCT_VIEW
```

Created by the dbt Gold model.

This view exposes product history in a cleaner reporting format.

The view renames validity fields:

```text
DBT_VALID_FROM → VRSN_STRT_DTS
DBT_VALID_TO   → VRSN_END_DTS
```

For current rows, the Gold view replaces null end dates with:

```text
9999-12-31
```

## Validation Queries

Validate the stage can see files in S3:

```sql
LS @SCD2_DB.BRONZE.SCD2_STAGE;
```

Validate the Silver transform table:

```sql
SELECT COUNT(*) AS PRODUCT_TRANSFORM_COUNT
FROM SCD2_DB.SILVER.WORK_PRODUCT_TRANSFORM;

SELECT *
FROM SCD2_DB.SILVER.WORK_PRODUCT_TRANSFORM
LIMIT 20;
```

Validate the snapshot table:

```sql
SELECT *
FROM SCD2_DB.SNAPSHOTS.PRODUCT_SNAPSHOT
LIMIT 20;
```

Validate the Gold view:

```sql
SELECT *
FROM SCD2_DB.GOLD.PRODUCT_VIEW
LIMIT 20;
```

Validate SCD Type 2 versioning for the changed product:

```sql
SELECT
    PRODUCT_ID,
    PRODUCT_NAME,
    MODEL_NUMBER,
    PRODUCT_DIMENSIONS,
    VRSN_STRT_DTS,
    VRSN_END_DTS
FROM SCD2_DB.GOLD.PRODUCT_VIEW
WHERE PRODUCT_ID = '4c69b61db1fc16e7013b43fc926e502d'
ORDER BY VRSN_STRT_DTS;
```

Expected result:

- one old historical version
- one new current version
- old row has an end timestamp
- current row has an open-ended end date