
{{ config(materialized='incremental',unique_key='order_id') }}

WITH ranked AS (
SELECT
    order_id,
    customer_id,
    product_id,

    CASE
        WHEN order_status IS NULL OR TRIM(order_status) = '' THEN 'unknown'
        ELSE UPPER(TRIM(order_status))
    END AS order_status,

    TRY_CAST(NULLIF(REGEXP_REPLACE(REPLACE(order_amount, ',', '.'),'[^0-9.]',''),'') AS DOUBLE)  AS order_amount,

    created_at,
    updated_at,
           ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) AS rn

FROM {{ ref('b_orders') }}
)

SELECT * 
FROM ranked
WHERE rn = 1

{% if is_incremental() %} 
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}