# SCD Type 2 Notes

## What Is a Slowly Changing Dimension?

A slowly changing dimension is a dimension table where descriptive attributes can change over time.

Examples:

- product description changes
- product price changes
- customer address changes
- employee title changes

The business may need to know not only the current value, but also what the value used to be.

## What Is SCD Type 2?

SCD Type 2 preserves history.

Instead of overwriting the old row, it keeps the old row and inserts a new version.

## Simple Example

Original product:

```text
Product ID: 123
Model Number: blank
Product Dimensions: blank
```

Changed product:

```text
Product ID: 123
Model Number: BG1782
Product Dimensions: 41" H x 36" W x 24" L
```

With SCD Type 2, both versions exist.

Old version:

```text
Product ID: 123
Model Number: blank
Valid To: timestamp
```

New version:

```text
Product ID: 123
Model Number: BG1782
Valid To: 9999-12-31
```

## Difference Between SCD Type 1 and SCD Type 2

| Type | Behavior | History Kept? |
|---|---|---|
| SCD Type 1 | Overwrite old values | No |
| SCD Type 2 | Insert new version and expire old version | Yes |

## How dbt Snapshots Help

dbt snapshots are built for tracking changes over time.

A snapshot compares current source data to previously captured data.

If a tracked value changes, dbt:

1. marks the old version as no longer current
2. sets an end timestamp
3. inserts a new current version

## Snapshot Strategy Used

This project uses:

```text
strategy = check
```

The `check` strategy means dbt compares selected columns.

If any checked column changes, dbt creates a new version.

## Unique Key Used

This project uses:

```text
PRODUCT_ID
```

as the unique key.

That means dbt tracks product history by product ID.

## Columns Checked for Changes

The snapshot checks product attributes such as:

```text
PRODUCT_NAME
CATEGORY
SELLING_PRICE
MODEL_NUMBER
ABOUT_PRODUCT
PRODUCT_SPECIFICATION
TECHNICAL_DETAILS
SHIPPING_WEIGHT
PRODUCT_DIMENSIONS
```

If any of those values change, dbt captures a new version.

## dbt Snapshot Columns

dbt adds metadata columns to manage history:

```text
DBT_SCD_ID
DBT_UPDATED_AT
DBT_VALID_FROM
DBT_VALID_TO
```

## Gold View Version Columns

The Gold view renames the dbt validity columns:

```text
DBT_VALID_FROM → VRSN_STRT_DTS
DBT_VALID_TO   → VRSN_END_DTS
```

For current rows, the Gold view uses:

```text
9999-12-31
```

as the end date.

## What This Project Validated

The changed product file updated:

```text
MODEL_NUMBER
PRODUCT_DIMENSIONS
```

for product ID:

```text
4c69b61db1fc16e7013b43fc926e502d
```

The final Gold view showed two versions of the same product.

That confirmed SCD Type 2 behavior.