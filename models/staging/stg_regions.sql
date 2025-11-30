{{
  config(
    materialized = 'view'
    )
}}

select
    region_id,
    region_name
from {{ ref('raw_regions') }}