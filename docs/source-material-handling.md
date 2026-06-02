# Source Material Handling

This project was completed as a guided data engineering lab and organized into a portfolio-ready GitHub repository.

## Public Repo Content

The public repo includes:

- project overview
- architecture documentation
- Python upload script
- Snowflake setup SQL
- dbt macro, models, and snapshot
- validation screenshots
- troubleshooting notes
- learning notes

## Private / Excluded Content

The following should not be committed:

- raw course instructions
- course-provided CSV files
- access key files
- credentials
- `.env` files
- local dbt profile files
- personal notes
- unblurred screenshots with sensitive details

## Local Data Files

The project uses two course-provided product files:

```text
Product_Dim.csv
Product_Dim_1.csv
```

These are stored locally under:

```text
data/local/
```

They are intentionally excluded from GitHub.

## Credential Handling

The Python script does not hardcode AWS credentials.

It uses a local AWS CLI profile:

```text
scd1-lab
```

The profile exists only on the local machine.

## dbt Profile Handling

The public repo does not include `profiles.yml`.

dbt Cloud manages the project connection separately through the dbt Cloud UI.

For a local dbt setup, a user would need to create their own profile with the correct Snowflake account, role, warehouse, database, and schema settings.

## Guided Project Disclosure

This repo is written as a professional learning project.

The implementation follows a guided lab scenario, but the repo adds:

- organized project structure
- explanatory comments
- architecture documentation
- validation evidence
- troubleshooting notes
- public learning notes
- portfolio-ready presentation