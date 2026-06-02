{% macro copy_json(table_nm) %}

-- Delete existing rows from the target copy table before reloading staged JSON.
delete from {{ target.database }}.{{ var('target_schema') }}.{{ table_nm }};

-- Copy JSON data from the Snowflake external stage into the target copy table.
COPY INTO {{ target.database }}.{{ var('target_schema') }}.{{ table_nm }}
FROM
(
    SELECT
        $1 AS DATA
    FROM @{{ var('stage_name') }}
)
FILE_FORMAT = (TYPE = JSON)
FORCE = TRUE;

{% endmacro %}


{% macro scd2_copy_product_csv(table_nm) %}

DELETE FROM {{ var('rawhist_db') }}.{{ var('wrk_schema') }}.{{ table_nm }};

COPY INTO {{ var('rawhist_db') }}.{{ var('wrk_schema') }}.{{ table_nm }}
FROM
(
    SELECT
        $1 AS PRODUCT_ID,
        $2 AS PRODUCT_NAME,
        $3 AS CATEGORY,
        $4 AS SELLING_PRICE,
        $5 AS MODEL_NUMBER,
        $6 AS ABOUT_PRODUCT,
        $7 AS PRODUCT_SPECIFICATION,
        $8 AS TECHNICAL_DETAILS,
        $9 AS SHIPPING_WEIGHT,
        $10 AS PRODUCT_DIMENSIONS,
        CURRENT_TIMESTAMP() AS INSERT_DTS,
        CURRENT_TIMESTAMP() AS UPDATE_DTS,
        METADATA$FILENAME AS SOURCE_FILE_NAME,
        METADATA$FILE_ROW_NUMBER AS SOURCE_FILE_ROW_NUMBER
    FROM @{{ var('stage_name') }}
)
FILE_FORMAT = (FORMAT_NAME = '{{ var("file_format_name") }}')
PURGE = {{ var('purge_status') }}
FORCE = TRUE;

{% endmacro %}