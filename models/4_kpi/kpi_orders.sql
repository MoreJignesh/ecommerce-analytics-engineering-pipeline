{{ config(materialized='table') }}

    SELECT
    DATE(d.date_day) order_date,
    COUNT(f.order_id) AS total_orders,
    SUM(f.order_amount) AS total_revenue

FROM {{ ref('fact_orders') }} f
JOIN {{ ref('dim_date') }} d
    ON DATE(f.created_at) = DATE(d.date_day)

GROUP BY DATE(d.date_day)
