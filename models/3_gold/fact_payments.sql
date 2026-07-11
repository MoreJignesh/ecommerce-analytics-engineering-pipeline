{{ config(materialized='incremental', on_schema_change='sync_all_columns', unique_key='payment_id') }}

SELECT
    pay.payment_id,
    pay.order_id,

    o.customer_id,
    o.product_id,

    pay.payment_status,
    pay.paid_amount,
    o.order_amount,

    CASE
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount IS NULL THEN 'PAID_AMOUNT_MISSING'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND o.order_amount IS NULL THEN 'ORDER_AMOUNT_MISSING'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount = o.order_amount THEN 'MATCH'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount < o.order_amount THEN 'UNDERPAID'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount > o.order_amount THEN 'OVERPAID'
        WHEN UPPER(TRIM(payment_status)) = 'PENDING'  THEN 'PENDING'
        WHEN UPPER(TRIM(payment_status)) = 'FAILED'  THEN 'FAILED'
        ELSE 'UNKNOWN' 
    END AS payment_comparison,
    CASE 
    WHEN (pay.paid_amount - o.order_amount) != 0 THEN 1
    ELSE 0
    END AS has_revenue_impact,

    pay.processed_at

FROM {{ ref('s_payments') }} pay

LEFT JOIN {{ ref('s_orders') }} o
    ON pay.order_id = o.order_id

{% if is_incremental() %}
WHERE pay.processed_at > (SELECT COALESCE(MAX(processed_at), '1900-01-01') FROM {{ this }})
{% endif %}