select
    project_lead_id
,   employment_status
from {{ ref('int_project_leads') }}
where employment_status <> 'Active'
