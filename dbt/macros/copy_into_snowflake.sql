{% macro copy_json(table_nm) %}

-- Delete existing rows from the copy table before reloading the staged JSON file.
delete from {{ var('target_db') }}.{{ var('target_schema') }}.{{ table_nm }};

-- Copy JSON data from the Snowflake external stage into the Snowflake copy table.
COPY INTO {{ var('target_db') }}.{{ var('target_schema') }}.{{ table_nm }}
FROM
(
    SELECT
        $1 AS DATA
    FROM @{{ var('stage_name') }}
)
FILE_FORMAT = (TYPE = JSON)
FORCE = TRUE;

{% endmacro %}