
{{ config(materialized='table') }}


WITH ranked AS (
    SELECT product_id,
    LOWER(TRIM(product_name)) AS product_name,

    CASE
        WHEN LOWER(category) LIKE '%electr%' THEN 'Electronics'
        WHEN LOWER(category) = 'lifestyle' THEN 'Lifestyle'
        WHEN LOWER(category) = 'fitness' THEN 'Fitness'
        ELSE 'unknown'
    END AS category,
    TRY_CAST(NULLIF(REGEXP_REPLACE(REPLACE(price, ',', '.'),'[^0-9.]',''),'') AS DOUBLE) AS price,

    ROW_NUMBER() OVER (
               PARTITION BY product_id
               ORDER BY updated_at DESC ) AS rn,
    updated_at
    FROM {{ ref('b_products') }}
)

SELECT *

FROM ranked
WHERE rn = 1