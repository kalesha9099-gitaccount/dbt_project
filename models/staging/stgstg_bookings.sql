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
    total_amount,
    checkout_date - checkin_date as nights_stayed
from {{ ref('bookings') }}