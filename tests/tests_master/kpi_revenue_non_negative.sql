SELECT *
FROM {{ ref('kpi_orders') }}
WHERE total_revenue < 0