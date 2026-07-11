
{% snapshot orders_status_scd %}
{{
  config(target_schema='snapshots',unique_key='order_id',strategy='timestamp',updated_at='updated_at')
}}

SELECT order_id, order_status, updated_at
FROM {{ ref('s_orders') }}

{% endsnapshot %}

