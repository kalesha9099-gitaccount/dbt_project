{{
  config(
    materialized = 'view')
}}

--Postgres compatible version
select
  curr_axis_values,
  to_jsonb(string_to_array(curr_axis_values, ' '))::text as curr_axis_values_super
from {{ ref('measureunits') }}