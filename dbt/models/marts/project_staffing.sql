{{
    config(
    materialized = 'table',
    tags = ['marts', 'projects'])
}}

with projects as(
    select distinct
        project_code
    ,   project_name
from {{ ref('stg_project_assignments') }}
)

, active_assignments as(
    select
        pas.assignment_id
    ,   pas.employee_id
    ,   pas.project_code
    ,   pas.weekly_hours
    from {{ ref('stg_project_assignments') }} pas
    join {{ ref('stg_employees') }} emp
        on pas.employee_id = emp.employee_id
    where emp.employment_status = 'Active'
)

, project_leads as(
    select
        project_lead_id
    ,   project_code
    from {{ ref("int_project_leads") }}
    where employment_status = 'Active'
)

select
    prj.project_code
,   prj.project_name
,   pl.project_lead_id
,   coalesce(count(aa.employee_id), 0) as team_count
,   coalesce(sum(aa.weekly_hours), 0) as total_weekly_hours
from projects prj
left join active_assignments aa
    on aa.project_code = prj.project_code
left join project_leads pl
    on prj.project_code = pl.project_code
group by 1, 2, 3
