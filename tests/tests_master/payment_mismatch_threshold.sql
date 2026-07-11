
WITH stats AS (
    SELECT
        COUNT(*) AS total_orders,
        COUNT_IF(payment_status_check != 'MATCH') AS mismatches
    FROM {{ ref('fact_orders') }}
)

SELECT *, CASE WHEN  mismatches / total_orders > 0.3 THEN 'FAILED' ELSE 'PASSED' END AS STATUS
FROM stats
WHERE mismatches / total_orders > 0.3   -- 30% threshold