{{ config(materialized='table') }}

SELECT *
FROM (
    SELECT
    customer_id,
    customer_name,
    email,
    city,
    country,
    signup_date,
    is_invalid_email,
    date_part('month', signup_date) AS signup_month,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) as rn,
    updated_at

FROM {{ ref('s_customers') }}
)
WHERE rn = 1