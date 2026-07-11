

SELECT DISTINCT
    DATE(created_at) AS date_day,
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    DAY(created_at) AS day,
    DAYOFWEEK(created_at) AS day_of_week

FROM {{ ref('s_orders') }}