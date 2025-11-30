{{
  config(
    materialized = 'view'
    )
}}

select
    job_id,
    job_title,
    min_salary,
    max_salary
from {{ ref('raw_jobs') }}