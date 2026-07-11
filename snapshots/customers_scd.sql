{% snapshot customers_scd %}

{{    config(target_schema='snapshots',unique_key='customer_id',strategy='timestamp',updated_at='updated_at') }}

SELECT *
FROM (
    SELECT
    customer_id,
    customer_name,
    email,
    city,
    country,
    signup_date,
    updated_at,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) AS rn 
        
        FROM {{ ref('dim_customers') }}
)
WHERE rn = 1

{% endsnapshot %}

