{{
    config(
        materialized='view',
        database='SCD2_DB',
        schema='GOLD',
        alias='PRODUCT_VIEW'
    )
}}

WITH product_history AS (
    SELECT
        PRODUCT_ID,
        DBT_VALID_FROM AS VRSN_STRT_DTS,
        COALESCE(DBT_VALID_TO, '9999-12-31 00:00:00.000') AS VRSN_END_DTS,
        PRODUCT_NAME,
        CATEGORY,
        SELLING_PRICE,
        MODEL_NUMBER,
        ABOUT_PRODUCT,
        PRODUCT_SPECIFICATION,
        TECHNICAL_DETAILS,
        SHIPPING_WEIGHT,
        PRODUCT_DIMENSIONS,
        TIME_ZONE,
        SOURCE_SYS_NAME,
        INSTNC_ST_NM,
        PROCESS_ID,
        PROCESS_NAME,
        INSERT_DTS,
        UPDATE_DTS
    FROM {{ ref('product_snapshot') }}
)

SELECT *
FROM product_history