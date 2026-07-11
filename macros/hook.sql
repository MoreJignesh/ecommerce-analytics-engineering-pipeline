{% macro log_pre_hook(table_name) %}
  
  insert into hook_log (hook_type, table_name, executed_at)
  values('pre-hook','{{table_name}}',current_timestamp)

{% endmacro %}

{% macro log_post_hook(table_name) %}
  
  insert into hook_log (hook_type, table_name, executed_at)
  values('post-hook','{{table_name}}',current_timestamp)

{% endmacro %}

