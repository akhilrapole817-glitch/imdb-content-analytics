{# Explode a comma-separated column into one row per value, portable across DuckDB and Snowflake. #}
{% macro split_to_rows(relation, key_col, list_col, value_alias) %}
  {{ return(adapter.dispatch('split_to_rows')(relation, key_col, list_col, value_alias)) }}
{% endmacro %}

{% macro default__split_to_rows(relation, key_col, list_col, value_alias) %}
    select {{ key_col }}, trim(v) as {{ value_alias }}
    from {{ relation }}, unnest(string_split({{ list_col }}, ',')) as t(v)
    where {{ list_col }} is not null
{% endmacro %}

{% macro snowflake__split_to_rows(relation, key_col, list_col, value_alias) %}
    select {{ key_col }}, trim(f.value::string) as {{ value_alias }}
    from {{ relation }}, lateral flatten(input => split({{ list_col }}, ',')) f
    where {{ list_col }} is not null
{% endmacro %}
