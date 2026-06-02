# How to Explain This Project

## Short Version

This project is an SCD Type 2 product dimension pipeline built with AWS S3, Snowflake, and dbt.

A Python script uploads product CSV files to S3. Snowflake reads the files through an external stage. dbt loads and transforms the data, then uses a snapshot to track historical product changes. A Gold view exposes product version history for validation and reporting.

## Slightly More Detailed Version

I built a guided data engineering project that demonstrates how dbt snapshots can preserve historical changes in product dimension data.

The original product CSV file is uploaded to S3 and loaded into Snowflake. dbt transforms the product data into a Silver model and creates a snapshot table that tracks selected product attributes by `PRODUCT_ID`.

Then a changed product file is uploaded. After rerunning the transform, snapshot, and Gold view, dbt detects that tracked fields changed for the same product ID. The old version is expired and a new current version is inserted.

## Technical Walkthrough

The pipeline starts with local product CSV files.

Python uploads the files to S3.

Snowflake uses a storage integration and external stage to read the S3 files.

A dbt macro loads the staged CSV data into a Bronze working table.

A Silver dbt model transforms the Bronze table.

A dbt snapshot tracks changes to selected product columns.

A Gold dbt view exposes the version history with version start and end dates.

The final validation query shows two versions of the same product ID, proving SCD Type 2 versioning worked.

## What This Shows

This project demonstrates:

- Python-to-S3 file upload
- Snowflake external stage setup
- Snowflake CSV file format
- dbt macro usage
- dbt model layering
- dbt snapshot configuration
- SCD Type 2 historical tracking
- Gold view creation
- Snowflake validation queries
- product dimension versioning

## Key Talking Points

The most important part of this project is the dbt snapshot.

The snapshot allows the warehouse to preserve product history instead of overwriting old values.

The project shows the difference between simply loading a changed file and actually tracking the history of that change.

## One-Sentence Summary

Built an SCD Type 2 product dimension pipeline using AWS S3, Snowflake, and dbt snapshots to preserve historical product changes and expose versioned product records through a Gold view.