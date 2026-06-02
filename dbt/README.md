# dbt SCD Type 2 Project

This folder contains the dbt portion of the SCD Type 2 Snowflake project.

## What dbt Does Here

dbt is used to:

1. Copy product CSV data from the Snowflake external stage into a bronze working table.
2. Transform the bronze data into a silver product table.
3. Create a dbt snapshot to track product changes over time.
4. Build a gold view that exposes product version history.

## Layer Flow

```text
S3 Product_Dim.csv
→ Snowflake external stage
→ BRONZE.WORK_PRODUCT_COPY
→ SILVER.WORK_PRODUCT_TRANSFORM
→ SNAPSHOTS.PRODUCT_SNAPSHOT
→ GOLD.PRODUCT_VIEW
```

## Important dbt Concepts

### Model

A dbt model is usually a SQL file that creates a table or view.

In this project, these are models:

```text
models/scd2_product/silver/transform_product_load.sql
models/scd2_product/gold/product_view.sql
```

The silver model creates a transformed table.

The gold model creates a reporting-friendly view.

### Macro

A dbt macro is reusable SQL/Jinja logic.

In this project, the macro loads CSV data from the Snowflake external stage into the bronze copy table before the silver model runs.

```text
macros/copy_into_snowflake.sql
```

The macro helps avoid repeating the same `COPY INTO` logic in multiple places.

### Snapshot

A dbt snapshot tracks changes in records over time.

This project uses a snapshot to implement SCD Type 2 behavior for product data.

```text
snapshots/scd2_product/product_snapshot.sql
```

When selected product fields change, dbt creates a new version of the product record.

### Vars

Vars are project-level variables in `dbt_project.yml`.

They make the macro easier to reuse by storing values such as:

- database name
- schema name
- stage name
- file format name
- purge setting

Example:

```yaml
vars:
  wrk_schema: BRONZE
  file_format_name: SCD2_DB.BRONZE.SCD2_CSV_FORMAT
  purge_status: FALSE
  stage_name: SCD2_DB.BRONZE.SCD2_STAGE
  rawhist_db: SCD2_DB
```

## SCD Type 2 Behavior

SCD Type 2 keeps history.

When selected product attributes change, dbt creates a new version of the product record.

The old version receives a `DBT_VALID_TO` timestamp.

The new/current version has a null `DBT_VALID_TO`.

The gold view converts null `DBT_VALID_TO` values into:

```text
9999-12-31
```

That makes it easy to identify the current active version.

## What This Project Validated

The project first loaded the original `Product_Dim.csv` file.

Then a changed file, `Product_Dim_1.csv`, was uploaded.

For the tested product ID, the changed file updated:

- `MODEL_NUMBER`
- `PRODUCT_DIMENSIONS`

After rerunning the dbt transform, snapshot, and gold view, Snowflake showed two versions of the same product:

1. old historical version with an end timestamp
2. new current version with an open-ended end date

That confirmed the SCD Type 2 versioning behavior worked.