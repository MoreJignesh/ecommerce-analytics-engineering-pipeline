{% macro mail_notification_macro(mail_id,subject,content) %}
{% set sql_qry %}
  call system$SEND_EMAIL('MY_MAIL_INTEGRATION', '{{mail_id}}','{{subject}}','{{content}}')


  {% endset %}  
  {% do run_query(sql_qry) %}
{% endmacro %}