
{{ config(materialized='table') }}

SELECT
    product_id,
    product_name,
    category,
    price,
    updated_at
FROM {{ ref('s_products') }}