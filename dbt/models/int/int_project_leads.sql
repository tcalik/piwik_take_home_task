{{
    config(
    materialized = 'table',
    tags = ['int', 'employees'])
}}

with lead_assignments as (
    select
        prj.employee_id as project_lead_id
    ,   prj.project_code
    ,   emp.employment_status
    ,   row_number() over(partition by project_code order by weekly_hours desc) as rn
    from {{ ref("stg_project_assignments") }} prj
    join {{ ref("stg_employees") }} emp
        on prj.employee_id = emp.employee_id
    where assignment_role = 'Lead'
)

select
    project_lead_id
,   project_code
,   employment_status
from lead_assignments
where rn = 1
