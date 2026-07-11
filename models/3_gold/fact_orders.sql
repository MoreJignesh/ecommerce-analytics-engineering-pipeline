
{{  config(materialized='incremental', on_schema_change='sync_all_columns',unique_key='order_id') }}

SELECT
    o.order_id,
    o.customer_id,
    o.product_id,
    p.category,
    o.order_status,
    p.price AS product_price,
    pay.payment_status,
    o.order_amount,
    pay.paid_amount,
    CASE
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount IS NULL THEN 'PAID_AMOUNT_MISSING'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND o.order_amount IS NULL THEN 'ORDER_AMOUNT_MISSING'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount = o.order_amount THEN 'MATCH'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount < o.order_amount THEN 'UNDERPAID'
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount > o.order_amount THEN 'OVERPAID'
        WHEN UPPER(TRIM(payment_status)) = 'PENDING'  THEN 'PENDING'
        WHEN UPPER(TRIM(payment_status)) = 'FAILED'  THEN 'FAILED'
        ELSE 'UNKNOWN' END AS payment_status_check,
    pay.paid_amount - o.order_amount AS payment_variance,
    (pay.paid_amount - o.order_amount) / (CASE WHEN o.order_amount IS NULL OR o.order_amount = 0 THEN 1 ELSE o.order_amount END) AS variance_pct,
    CASE WHEN payment_status = 'SUCCESS' AND payment_status_check = 'MATCH' THEN 'COMPLETED'
    WHEN payment_status = 'SUCCESS' AND payment_status_check IN ('UNDERPAID','OVERPAID') THEN 'COMPLETED_WITH_ISSUE' 
    WHEN payment_status = 'PENDING' THEN 'PENDING'
    WHEN payment_status = 'FAILED' THEN 'FAILED'
    WHEN order_status = 'CANCELLED' THEN 'CANCELLED'
    ELSE 'UNKNOWN' END AS final_order_status,
    CASE  WHEN ABS(pay.paid_amount - o.order_amount) = 0 THEN 0
    WHEN ABS(pay.paid_amount - o.order_amount) < 50 THEN 1
    WHEN ABS(pay.paid_amount - o.order_amount) < 100 THEN 2
    ELSE 3     END AS payment_severity ,
    CASE WHEN order_amount < 50 THEN 'LOW'
    WHEN order_amount BETWEEN 50 AND 150 THEN 'MEDIUM'
    ELSE 'HIGH' END AS order_value_bucket,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at) AS order_rank,
    CASE  WHEN ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at) > 1 THEN 1 ELSE 0 END AS is_repeat_customer,
    DATEDIFF(created_at, LAG(created_at) OVER (PARTITION BY customer_id ORDER BY created_at) ) AS days_between_orders,
    o.created_at,
    o.updated_at

FROM {{ ref('s_orders') }} o
LEFT JOIN {{ ref('s_products') }} p
    ON o.product_id = p.product_id
LEFT JOIN {{ ref('s_payments') }} pay
    ON o.order_id = pay.order_id


{% if is_incremental() %} 
WHERE o.updated_at > (SELECT COALESCE(MAX(created_at), '1900-01-01') FROM {{ this }})
{% endif %}