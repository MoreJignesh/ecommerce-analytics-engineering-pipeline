
SELECT *
FROM {{ ref('fact_orders') }}
WHERE payment_status_check != 'MATCH'
