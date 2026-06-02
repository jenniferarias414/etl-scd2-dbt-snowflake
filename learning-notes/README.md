# Learning Notes

These notes explain the SCD Type 2 dbt + Snowflake project in a slower, more approachable way than the main README.

The main README gives the project overview. This folder explains what each layer does, why dbt snapshots matter, and how the product history validation proves SCD Type 2 behavior.

## Notes Included

- `end-to-end-walkthrough.md` explains the full project flow from local CSV files to the Gold product history view.
- `service-by-service-notes.md` explains the role of each tool and layer.
- `scd2-notes.md` explains Slowly Changing Dimension Type 2 in plain language.
- `how-to-explain-this-project.md` gives a concise explanation for interviews, portfolio reviews, and project walkthroughs.

## Project Flow

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

## Main Concept

This project demonstrates how dbt snapshots can track historical changes in dimension records.

The original product file creates the first product version. The changed product file updates selected attributes for the same product ID. dbt detects the change, expires the old version, and creates a new current version.