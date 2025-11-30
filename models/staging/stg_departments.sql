{{
  config(
    materialized = 'view'
    )
}}

select
    department_id,
    department_name,
    manager_id,
    location_id

from {{ ref('raw_departments') }}