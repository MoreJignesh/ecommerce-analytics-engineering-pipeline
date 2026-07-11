{% macro date_columns(table_name, date_field_name) %}
  
  select
   {{ date_part("week", date_field_name) }} as order_week,
   {{ date_part("month", date_field_name) }} as order_month,
   {{ date_part("year", date_field_name) }} as order_year
from {{ table_name }}

{% endmacro %}