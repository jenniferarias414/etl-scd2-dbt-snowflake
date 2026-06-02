{% snapshot product_snapshot %}

{{
    config(
        target_database='SCD2_DB',
        target_schema='SNAPSHOTS',
        unique_key='PRODUCT_ID',
        strategy='check',
        check_cols=[
            'PRODUCT_NAME',
            'CATEGORY',
            'SELLING_PRICE',
            'MODEL_NUMBER',
            'ABOUT_PRODUCT',
            'PRODUCT_SPECIFICATION',
            'TECHNICAL_DETAILS',
            'SHIPPING_WEIGHT',
            'PRODUCT_DIMENSIONS'
        ]
    )
}}

SELECT *
FROM {{ ref('transform_product_load') }}

{% endsnapshot %}