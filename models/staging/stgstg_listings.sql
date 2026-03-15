{{ config(materialized='view') }}

select
    listing_id,
    host_id,
    property_type,
    city,
    price_per_night,
    is_available
from {{ ref('listings') }}

