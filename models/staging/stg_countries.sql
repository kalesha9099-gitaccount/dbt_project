{{
  config(
    materialized = 'view'
    )
}}
select
    country_id,
    country_name,
    region_id
from {{ ref('raw_countries') }}