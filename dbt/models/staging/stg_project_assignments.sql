{{
    config(
    materialized = 'table',
    tags = ['staging', 'projects'])
}}

select
    "AssignmentID"                                 as assignment_id
,   "EmpID"                                        as employee_id
,   "ProjectCode"                                  as project_code
,   "ProjectName"                                  as project_name
,   "AssignmentRole"                               as assignment_role
,   CAST("StartDate" AS DATE)                      as start_date
,   "WeeklyHours"                                  as weekly_hours
,   COALESCE("Billable" IN ('Y', 'Yes'), FALSE)    as is_billable
from {{ source("piwik_source", "project_assignments_report") }}
