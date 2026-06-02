{{ 
    config(
        materialized='table',
        transient=true,
        database='SCD2_DB',
        schema='SILVER',
        alias='WORK_PRODUCT_TRANSFORM',
        pre_hook=scd2_copy_product_csv('WORK_PRODUCT_COPY')
    )
}}

WITH transform AS (
    SELECT
        PRODUCT_ID,
        PRODUCT_NAME,
        CATEGORY,
        SELLING_PRICE,
        MODEL_NUMBER,
        ABOUT_PRODUCT,
        PRODUCT_SPECIFICATION,
        TECHNICAL_DETAILS,
        SHIPPING_WEIGHT,
        PRODUCT_DIMENSIONS,
        'EST' AS TIME_ZONE,
        'PRODUCT' AS SOURCE_SYS_NAME,
        'STANDARD' AS INSTNC_ST_NM,
        CURRENT_SESSION() AS PROCESS_ID,
        'TRANSFORM_LOAD' AS PROCESS_NAME,
        INSERT_DTS,
        UPDATE_DTS,
        SOURCE_FILE_NAME,
        SOURCE_FILE_ROW_NUMBER
    FROM {{ source('bronze', 'WORK_PRODUCT_COPY') }}
)

SELECT *
FROM transform