
{{ config(materialized='table') }}

SELECT *
FROM
(SELECT DISTINCT

    pay.payment_status,
    pay.paid_amount,
    
    o.order_amount,

    CASE
        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount IS NULL 
            THEN 'PAID_AMOUNT_MISSING'

        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND o.order_amount IS NULL 
            THEN 'ORDER_AMOUNT_MISSING'

        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount = o.order_amount 
            THEN 'MATCH'

        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount < o.order_amount 
            THEN 'UNDERPAID'

        WHEN UPPER(TRIM(payment_status)) = 'SUCCESS' AND pay.paid_amount > o.order_amount 
            THEN 'OVERPAID'

        WHEN UPPER(TRIM(payment_status)) = 'PENDING'  
            THEN 'PENDING'

        WHEN UPPER(TRIM(payment_status)) = 'FAILED'  
            THEN 'FAILED'

        ELSE 'UNKNOWN'
    END AS payment_status_check

FROM {{ ref('s_orders') }} o
LEFT JOIN {{ ref('s_products') }} p
    ON o.product_id = p.product_id
LEFT JOIN {{ ref('s_payments') }} pay
    ON o.order_id = pay.order_id)temp
    ORDER BY 1,2,3