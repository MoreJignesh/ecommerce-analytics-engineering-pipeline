



{{ config(materialized='incremental',unique_key='order_id') }}

WITH ranked AS (
    SELECT
    payment_id,
    order_id,

    CASE
        WHEN payment_status IS NULL THEN 'unknown'
        ELSE UPPER(TRIM(payment_status))
    END AS payment_status,

    TRY_CAST(NULLIF(REGEXP_REPLACE(REPLACE(paid_amount, ',', '.'),'[^0-9.]',''),'') AS DOUBLE) AS paid_amount,

    processed_at,
           ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY processed_at DESC) AS rn

FROM {{ ref('b_payments') }}
)

SELECT * 

FROM ranked
WHERE rn = 1


{% if is_incremental() %} 
WHERE processed_at > (SELECT MAX(processed_at) FROM {{ this }})
{% endif %}