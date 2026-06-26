{{
  config(
    materialized = 'view',
    )
}}

select
    booking_id,
    listing_id
from {{ ref('bookings') }}