{{ config(materialized='view') }}

select
*
from {{ ref('listings') }}

