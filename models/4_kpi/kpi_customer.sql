{{ config(materialized='table') }}

SELECT
    customer_id,
    COUNT(is_invalid_email) AS total_invalid_email,
    COUNT(order_id) AS total_orders,

    SUM(order_amount) AS lifetime_value,

    AVG(order_amount) AS avg_order_value,

    MAX(created_at) AS last_order_date,
    CASE 
    WHEN SUM(order_amount) > 2000 THEN 'HIGH_VALUE'
    WHEN SUM(order_amount) > 1000 THEN 'MEDIUM_VALUE'
    ELSE 'LOW_VALUE' END AS customer_segment

FROM {{ ref('fact_orders') }}

GROUP BY customer_id