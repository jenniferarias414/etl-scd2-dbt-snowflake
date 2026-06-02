# Troubleshooting Notes

This document captures issues and checks for the SCD Type 2 dbt + Snowflake project.

## Python Cannot Import boto3

### Issue

The Python upload script fails with:

```text
ModuleNotFoundError: No module named 'boto3'
```

### Resolution

Create and activate a virtual environment, then install `boto3`:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install boto3
pip freeze > requirements.txt
```

## AWS Profile Not Found

### Issue

The upload script cannot find the AWS profile.

### Resolution

Confirm the profile exists:

```bash
aws configure list-profiles
```

The script uses:

```text
scd1-lab
```

Test S3 access:

```bash
aws s3 ls s3://scd2-product-data-jenny/raw_data/ --profile scd1-lab
```

## Snowflake Stage Cannot See Files

### Issue

`LS @SCD2_DB.BRONZE.SCD2_STAGE;` does not show the expected file.

### Checks

Confirm the file exists in S3:

```bash
aws s3 ls s3://scd2-product-data-jenny/raw_data/ --profile scd1-lab
```

Confirm the stage points to the correct path:

```sql
DESC STAGE SCD2_DB.BRONZE.SCD2_STAGE;
```

Confirm the storage integration was created:

```sql
DESC INTEGRATION SCD2_INT;
```

## Storage Integration Permission Error

### Issue

Snowflake cannot access the S3 bucket.

### Common Causes

- AWS IAM role trust policy still has dummy external ID
- Snowflake-generated external ID was not copied into AWS
- Snowflake-generated IAM user ARN was not copied into AWS
- IAM policy points to the wrong bucket or prefix
- Stage URL does not match the allowed storage location

### Useful Snowflake Command

```sql
DESC INTEGRATION SCD2_INT;
```

Use these values to update the AWS trust policy:

```text
STORAGE_AWS_IAM_USER_ARN
STORAGE_AWS_EXTERNAL_ID
```

## dbt Fails with Duplicate vars

### Issue

dbt fails with an error like:

```text
Duplicate key `vars`
```

### Cause

`dbt_project.yml` can only have one top-level `vars:` section.

### Resolution

Combine all variables under one `vars:` block.

## dbt Transform Does Not Load Data

### Checks

Confirm the file exists in the Snowflake stage:

```sql
LS @SCD2_DB.BRONZE.SCD2_STAGE;
```

Confirm the Bronze table exists:

```sql
SELECT COUNT(*)
FROM SCD2_DB.BRONZE.WORK_PRODUCT_COPY;
```

Run the dbt transform:

```bash
dbt run --select transform_product_load
```

The transform model uses a `pre_hook` to call the macro that loads data into the Bronze table.

## Snapshot Does Not Create a New Version

### Issue

The snapshot runs, but no new product version appears.

### Common Causes

- changed file was not uploaded
- stage still points to old file only
- transform was not rerun after uploading the changed file
- changed columns are not included in `check_cols`
- the changed product ID does not match the existing product ID
- snapshot was run before the Silver table refreshed

### Correct Order

```text
Upload changed file
→ dbt run --select transform_product_load
→ dbt snapshot --select product_snapshot
→ dbt run --select product_view
→ validate in Snowflake
```

## Useful SCD2 Validation Query

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

- two rows for the same product ID
- old row has blank values for changed fields
- old row has an end timestamp
- new row has updated values
- new row has open-ended end date

## Cleanup Reminder

After project validation, suspend the Snowflake warehouse:

```sql
ALTER WAREHOUSE COMPUTE_WH SUSPEND;
```

Optional cleanup:

```sql
DROP DATABASE SCD2_DB;
```

Only drop the database after screenshots, documentation, and validation are complete.