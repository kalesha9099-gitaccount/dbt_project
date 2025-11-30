{{
  config(
    materialized = 'view'
    )
}}

with emp as (

    select
        employee_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        department_id
    from {{ ref('stg_employees') }}

),
dept as (

    select
        department_id,
        department_name
    from {{ ref('stg_departments') }}

),
emp_dept as (

    select
        e.employee_id,
        e.first_name,
        e.last_name,
        e.full_name,
        COALESCE(d.department_name, 'Unknown Department') AS department_name
    from emp e
    left join dept d
    on e.department_id = d.department_id

)
select * from emp_dept