{{ config(materialized='table') }}

SELECT
    f.order_id,
    f.customer_id,
    c.customer_name,
    c.city,
    c.country,

    f.product_id,
    p.product_name,
    p.category,

    f.order_status,
    f.order_amount,
    f.paid_amount,
    f.payment_status,
    f.payment_status_check,
    f.payment_variance,
    f.payment_severity,

    f.order_value_bucket,
    f.is_repeat_customer repeat_customer_flag,
    f.order_rank customer_order_rank,
    CASE WHEN f.order_rank = 1 THEN 1 ELSE 0 END AS is_new_customer,
    CASE WHEN f.order_rank > 1 THEN 1 ELSE 0 END AS is_repeat_customer,

    CASE WHEN f.payment_status_check != 'MATCH' THEN 1 ELSE 0 END AS mismatch_flag,

    f.created_at as order_date,
    d.year,
    d.month,
    d.day

FROM {{ ref('fact_orders') }} f

LEFT JOIN {{ ref('dim_customers') }} c
    ON f.customer_id = c.customer_id

LEFT JOIN {{ ref('dim_products') }} p
    ON f.product_id = p.product_id

LEFT JOIN {{ ref('dim_date') }} d
    ON DATE(f.created_at) = DATE(d.date_day)
