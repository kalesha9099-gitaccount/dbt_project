{{
  config(
    materialized = 'view'
    )
}}




SELECT * FROM airbnb.raw.raw_hosts
