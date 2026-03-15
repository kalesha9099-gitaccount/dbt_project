{{ config(materialized='view') }}

select
    listing_id,
    host_id,
    property_type,
    city,
    upper(SUBSTRING(city,1,3)) as shorten_city,
    price_per_night,
    is_available
from {{ ref('listings') }}

