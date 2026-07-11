
SELECT *
FROM {{ source('raw', 'orders') }}
WHERE LEN(order_id) < 6 OR  LEN(customer_id) < 4 OR LEN(product_id) < 4