
{% macro log_on_run_start() %}
  
  insert into run_log (run_phase, executed_at)
  values('on-run-start',current_timestamp)

{% endmacro %}

{% macro log_on_run_end() %}
  
  insert into run_log (run_phase, executed_at)
  values('on-run-end',current_timestamp)

{% endmacro %}