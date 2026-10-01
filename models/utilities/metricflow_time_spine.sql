{{ config(materialized='table') }}
{% if target.type == 'snowflake' %}
select dateadd(day, seq4(), '1900-01-01'::date) as date_day
from table(generator(rowcount => 49674))
{% else %}
select cast(d as date) as date_day
from generate_series(date '1900-01-01', date '2035-12-31', interval 1 day) as t(d)
{% endif %}
