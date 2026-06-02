# Project Status

## Status

Completed.

This project was built and validated end-to-end using AWS S3, Snowflake, dbt models, and dbt snapshots to demonstrate SCD Type 2 product history tracking.

## Completed Work

### AWS

- Created S3 bucket for product CSV files
- Created `raw_data/` folder for source files
- Uploaded initial product file to S3
- Uploaded changed product file to S3
- Created IAM policy for Snowflake S3 access
- Created IAM role for Snowflake storage integration

### Python

- Created Python script using `boto3`
- Used local AWS CLI profile for credentials
- Uploaded `Product_Dim.csv`
- Uploaded `Product_Dim_1.csv`

### Snowflake

- Created `SCD2_DB`
- Created `BRONZE`, `SILVER`, `SNAPSHOTS`, and `GOLD` schemas
- Created Snowflake storage integration
- Created external stage pointing to S3
- Created CSV file format
- Created Bronze working table

### dbt

- Created dbt macro to load staged CSV data into the Bronze table
- Created Silver transform model
- Created dbt snapshot using `PRODUCT_ID` as the unique key
- Used the dbt snapshot `check` strategy to detect changes in selected product columns
- Created Gold view to expose versioned product history
- Validated SCD Type 2 behavior after a changed product file was processed

## Final Data Flow

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

## Final Validation

The project validated that the changed product record created historical versioning.

Changed product:

```text
PRODUCT_ID = 4c69b61db1fc16e7013b43fc926e502d
```

Changed fields:

```text
MODEL_NUMBER: blank → BG1782
PRODUCT_DIMENSIONS: blank → 41" H x 36" W x 24" L
```

Expected SCD Type 2 result:

- old product version retained
- old version received an end timestamp
- new product version inserted
- new version remains current/open-ended

## Project Outcome

The final Gold view confirmed that dbt snapshots successfully tracked product changes over time and exposed product history through a reporting-friendly view.