{{ config(materialized='table') }}

SELECT
    payment_status_check,

    COUNT(order_id) AS total_transactions,

    SUM(paid_amount) AS total_paid,

    AVG(paid_amount) AS avg_payment,

    COUNT_IF(payment_status_check = 'UNDERPAID') AS underpaid_count,

    COUNT_IF(payment_status_check = 'OVERPAID') AS overpaid_count,
    SUM(CASE WHEN payment_status_check= 'UNDERPAID' THEN payment_variance ELSE 0 END) AS revenue_loss,
    SUM(CASE WHEN payment_status_check= 'OVERPAID' THEN payment_variance ELSE 0 END) AS overpayment_risk

FROM {{ ref('fact_orders') }}

GROUP BY payment_status_check