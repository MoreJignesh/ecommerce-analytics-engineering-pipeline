{{ config(materialized='table') }}

WITH customer_base AS (
SELECT
        customer_id,
        INITCAP(TRIM(customer_name)) AS customer_name,
        LOWER(TRIM(email)) AS email,
        CASE WHEN o.city IS NULL THEN 'Null'
            ELSE INITCAP(TRIM(o.city)) END AS city,
        UPPER(TRIM(m.country)) AS country,
        signup_date,
        updated_at,
        CASE WHEN email IS NULL OR email NOT LIKE '%@%.%' THEN 1  ELSE 0 END AS is_invalid_email,
        CASE WHEN customer_name IS NULL OR TRIM(customer_name) = '' THEN 1 ELSE 0 END AS is_invalid_name
    FROM {{ ref("b_customers") }} o
    
    LEFT JOIN {{ ref('city_country_lookup') }} m
    ON INITCAP(TRIM(o.city)) = m.standardized_city ),

deduped AS (SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY 
                    COALESCE(email, CAST(customer_id AS STRING))   
                ORDER BY updated_at DESC
            ) AS rn
        FROM customer_base
    )
    WHERE rn = 1 )

SELECT
    customer_id,
    customer_name,
    email,
    city,
    country,
    signup_date,
    updated_at,
    is_invalid_email,
    is_invalid_name

FROM deduped