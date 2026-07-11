{{ config(materialized='table') }}

WITH base AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.product_id,
        o.order_status,
        o.order_amount,
        o.created_at,

        p.payment_status,
        p.paid_amount,

        c.email,

        -- flags
        CASE WHEN o.order_id IS NULL THEN 1 ELSE 0 END AS null_order_id,
        CASE WHEN o.customer_id IS NULL THEN 1 ELSE 0 END AS null_customer_id,
        CASE WHEN o.product_id IS NULL THEN 1 ELSE 0 END AS null_product_id,
        CASE WHEN o.order_status IS NULL OR TRIM(o.order_status) = '' THEN 1 ELSE 0 END AS null_order_status,
        CASE WHEN o.order_amount IS NULL THEN 1 ELSE 0 END AS null_order_amount,

        CASE WHEN p.payment_status IS NULL OR TRIM(p.payment_status) = '' THEN 1 ELSE 0 END AS null_payment_status,
        CASE WHEN p.paid_amount IS NULL THEN 1 ELSE 0 END AS null_paid_amount,

        CASE WHEN c.email IS NULL OR TRIM(c.email) = '' THEN 1 ELSE 0 END AS null_email,

        -- invalid email
        CASE 
            WHEN c.email IS NULL THEN 1
            WHEN c.email NOT LIKE '%@%.%' THEN 1
            ELSE 0
        END AS invalid_email,

        -- payment issues
        CASE 
            WHEN UPPER(TRIM(p.payment_status)) IN ('FAILED','UNKNOWN') THEN 1
            ELSE 0
        END AS invalid_payment,

        -- mismatch
        CASE 
            WHEN p.paid_amount IS NOT NULL 
             AND o.order_amount IS NOT NULL
             AND p.paid_amount != o.order_amount THEN 1
            ELSE 0
        END AS mismatch_flag

    FROM {{ ref('s_orders') }} o
    LEFT JOIN {{ ref('s_payments') }} p
        ON o.order_id = p.order_id
    LEFT JOIN {{ ref('s_customers') }} c
        ON o.customer_id = c.customer_id
),

agg AS (

    SELECT
        COUNT(*) AS total_records,

        -- NULL COUNTS
        SUM(null_order_id) AS null_order_id,
        SUM(null_customer_id) AS null_customer_id,
        SUM(null_product_id) AS null_product_id,
        SUM(null_order_status) AS null_order_status,
        SUM(null_order_amount) AS null_order_amount,
        SUM(null_payment_status) AS null_payment_status,
        SUM(null_paid_amount) AS null_paid_amount,
        SUM(null_email) AS null_email,

        -- INVALIDS
        SUM(invalid_email) AS invalid_email_count,
        SUM(invalid_payment) AS invalid_payment_count,

        -- MISMATCH
        SUM(mismatch_flag) AS mismatch_count

    FROM base
)

SELECT
    *,

    -- PERCENTAGES
    null_order_id * 1.0 / total_records AS null_order_id_pct,
    null_customer_id * 1.0 / total_records AS null_customer_id_pct,
    null_product_id * 1.0 / total_records AS null_product_id_pct,
    null_order_status * 1.0 / total_records AS null_order_status_pct,
    null_order_amount * 1.0 / total_records AS null_order_amount_pct,
    null_payment_status * 1.0 / total_records AS null_payment_status_pct,
    null_paid_amount * 1.0 / total_records AS null_paid_amount_pct,
    null_email * 1.0 / total_records AS null_email_pct,

    invalid_email_count * 1.0 / total_records AS invalid_email_pct,
    invalid_payment_count * 1.0 / total_records AS invalid_payment_pct,
    mismatch_count * 1.0 / total_records AS mismatch_pct,

    -- DATA QUALITY SCORE
    1 - (
        (mismatch_count * 1.0 / total_records) * 0.5 +
        (invalid_payment_count * 1.0 / total_records) * 0.3 +
        (invalid_email_count * 1.0 / total_records) * 0.2
    ) AS data_quality_score

FROM agg