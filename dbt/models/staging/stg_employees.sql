{{
    config(
    materialized = 'table',
    tags = ['staging', 'employees'])
}}

select
    "EmployeeID"                    as employee_id
,   "FirstName"                     as first_name
,   "LastName"                      as last_name
,   "EmailAddress"                  as email_address
,   "Department"                    as department
,   "JobTitle"                      as job_title
,   CAST("DateofHire" AS DATE)      as date_of_hire
,   CAST("TerminationDate" AS DATE) as termination_date
,   "Status"                        as employment_status
,   "ReportsTo"                     as reports_to
from {{ source('piwik_source', 'hr_employees_export') }}
