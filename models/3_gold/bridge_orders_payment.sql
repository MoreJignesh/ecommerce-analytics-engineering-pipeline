{{ config(materialized='table') }}

SELECT
    o.order_id,
    pay.payment_id,

    o.customer_id,
    o.product_id,

    pay.paid_amount,
    o.order_amount,

    pay.processed_at

FROM {{ ref('s_orders') }} o
JOIN {{ ref('s_payments') }} pay
    ON o.order_id = pay.order_id