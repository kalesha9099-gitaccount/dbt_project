{{
  config(
    materialized = 'view'
    )
}}

select
    location_id,
    street_address,
    postal_code,
    city,
    state_province,
    country_id
from {{ ref('raw_locations') }}