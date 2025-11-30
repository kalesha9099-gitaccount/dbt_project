-- ...existing code...
-- Strategy: Filter incoming data based on the hire_date 
 -- to only process new/updated employees.

{{
    config(
        materialized = 'incremental',
        unique_key = 'employee_id',
        incremental_strategy = 'merge',
        on_schema_change = 'append_new_columns'
    )
}}


-- 1. BASE_JOIN CTE: Joins all staging models and applies basic transformations
WITH base_join AS (
    SELECT 
        e.employee_id,
        e.first_name,
        e.salary,
        e.hire_date, -- Required for incremental filter

        -- keep commission_pct numeric and replace NULLs with 0 for output
        COALESCE(e.commission_pct, 0)::double precision AS commission_pct,

        -- separate text hash to mark rows that originally had NULL commission_pct
        CASE
          WHEN e.commission_pct IS NULL THEN md5(e.employee_id::text)
          ELSE NULL
        END AS commission_pct_hash,

        d.department_name,
        d.department_id,
        l.postal_code,
        l.city,
        
        -- Case Statement for Country Name transformation
        CASE
            WHEN c.country_name = 'United States of America' THEN 'USA'
            WHEN c.country_name = 'United Kingdom' THEN 'UK'
            ELSE UPPER(SUBSTR(c.country_name, 1, 3))
        END AS c_name,
        
        r.region_name,
        j.job_title,
        j.min_salary,
        j.max_salary,

        -- max hire date for each department
        MAX(e.hire_date) OVER (PARTITION BY d.department_id) AS dept_max_hire_date
        
    FROM {{ ref('stg_employees') }} e
    
    -- Using LEFT JOINs to maintain all employees, even if department/job is missing (best practice)
    LEFT JOIN {{ ref('stg_departments') }} d ON e.department_id = d.department_id
    LEFT JOIN {{ ref('stg_locations') }} l ON d.location_id = l.location_id
    LEFT JOIN {{ ref('stg_countries') }} c ON l.country_id = c.country_id
    LEFT JOIN {{ ref('stg_regions') }} r ON c.region_id = r.region_id
    LEFT JOIN {{ ref('stg_jobs') }} j ON e.job_id = j.job_id
),

-- 2. FINAL_RANKING CTE: Applies the window function
final_ranking AS (
    SELECT
        *, -- Select all columns from the base_join CTE
        DENSE_RANK() OVER (
            PARTITION BY department_id 
            ORDER BY salary DESC
        ) AS rnk
    FROM base_join
)

-- 3. FINAL SELECT: Applies incremental filtering and the specific department filter
SELECT 
    * FROM final_ranking


WHERE department_id between 60 and 90
  AND hire_date = dept_max_hire_date

-- DBT Incremental Logic: Only process rows where hire_date is newer than the latest date 
-- already in the target table (this). Detect whether commission_pct_hash exists on the target
{% set _cols = adapter.get_columns_in_relation(this) %}
{% set _col_names = _cols | map(attribute='name') | list %}
{% set has_hash = 'commission_pct_hash' in _col_names %}

{% if is_incremental() %}
   AND (
    hire_date > (SELECT COALESCE(MAX(hire_date), '1900-01-01') FROM {{ this }})
    OR EXISTS (
      SELECT 1
      FROM {{ this }} t
      WHERE t.employee_id = employee_id
         AND (
           t.commission_pct IS NULL
           {% if has_hash %}
             OR t.commission_pct_hash IS NULL
           {% endif %}
         )
    )
  )
{% endif %}
-- ...existing code...