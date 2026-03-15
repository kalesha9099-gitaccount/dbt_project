{{
  config(
    materialized = 'view',
    )
}}

select
    booking_id,
    listing_id,
    guest_id,
    checkin_date,
    checkout_date,
    total_amount
from {{ ref('bookings') }}