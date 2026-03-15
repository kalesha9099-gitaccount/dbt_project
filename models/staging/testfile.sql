{{
  config(
    materialized = 'view',
    )
}}

select * from {{ ref('largetext')}}