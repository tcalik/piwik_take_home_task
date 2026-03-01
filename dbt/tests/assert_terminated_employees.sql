select
    employee_id
from {{ ref ('stg_employees') }}
where termination_date is not null
    and employment_status = 'Active'
