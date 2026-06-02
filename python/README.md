# Python Upload Script

This folder contains the Python script used to upload local product CSV files to Amazon S3 for the SCD Type 2 project.

## Script

```text
local_to_aws_s3.py
```

## Purpose

The Python script uploads product CSV files from the local machine into the S3 landing folder used by Snowflake.

Target S3 location:

```text
s3://scd2-product-data-jenny/raw_data/
```

## Files Uploaded

This project uses two product files:

```text
Product_Dim.csv
Product_Dim_1.csv
```

`Product_Dim.csv` is the initial full product file.

`Product_Dim_1.csv` is the changed product file used to demonstrate SCD Type 2 versioning.

## Credential Handling

AWS credentials are not hardcoded in the script.

The script uses a local AWS CLI profile:

```text
scd1-lab
```

This profile was already configured locally and has access to upload files to the S3 bucket.

## How to Run

From the project root, activate the virtual environment:

```bash
source .venv/bin/activate
```

Upload the initial product file:

```bash
python python/local_to_aws_s3.py data/local/Product_Dim.csv
```

Upload the changed product file:

```bash
python python/local_to_aws_s3.py data/local/Product_Dim_1.csv
```

## Expected Output

Example successful output:

```text
Product_Dim.csv uploaded successfully
s3://scd2-product-data-jenny/raw_data/Product_Dim.csv
```

## Role in the Pipeline

The Python script is responsible for the first movement of data:

```text
Local CSV file
→ Python upload script
→ Amazon S3 raw_data/ folder
```

After the file is in S3, Snowflake reads it through the external stage.

## Notes

The CSV files are stored locally under:

```text
data/local/
```

They are intentionally excluded from GitHub because they are course-provided local data files.

The Python script is included because it documents how files were moved from the local machine into the S3 landing zone.