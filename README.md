# Data Analytics Engineer Task
Solution by Tomasz Calik

## Requirements
The only requirement to run this project is `Docker`, but running the project is the simplest with `make` also available.

## Running the project
The quickest way to start this project is running
``` bash
make run
```
at the root of this project. 
This command will build the image, upload the data into the psql database and run `dbt build`.

Run
``` bash
make down
```
to tear down the project.

If you want to run the project step by step:
``` bash
make build
# to build the image
make ingest
# to upload the data into the psql db
make dbt
# to run dbt build - runs models and tests
```

### Runnning without make
``` bash
docker compose build
# to build the image
docker compose up -d db
# to start the db container
docker compose run --rm runner uv run scripts/load_data.py
# to upload the data into the psql db
docker compose run --rm runner uv run dbt build --project-dir dbt --profiles-dir .
# to run dbt build - runs models and tests
docker compose down -v
# to tear down the project
```

### Accessing the db manually
You can access the db manually by attaching a terminal to the container:
``` bash
docker ps
# find the container id of the postgress instance
docker exec -it {container_id} bash
# attach a terminal to the container
psql piwik -U dbt_user
# log into the psql db. You should see data in the "source", "dev_staging", "dev_int" and "dev_marts" schemas
```

## Asumptions
The following decisions were made in order to solve edge cases and conflicts:
  1. Project leads: in `int_project_leads` a single lead is selected based on the employee with most hours in a lead role. This is done to achieve one lead per role and a single output row in the final mart. The main drawback of this approach is loss of detail at the project level(no visibility of the second lead in `PROJ-2024-004`) Alternatives considered: 
  - array of employee_id - some BI tools don't handle arrays well
  - concatenated string - complete loss of filtering functionality on employee_id
  2. `int_project_leads` still outputs an inactive employee in the lead role of a project. Thanks to this approach we can also test if all project leads are active. In this case, the test `asser_active_leads` returns a `warn`.
  3. The `Billable? / is_billable` flag is ignored for all functional purposes. This has been decided since there was no clear correlation between employee status, weekly hours and the is_billable flag.
  ```sql
select 
    e.employee_id
,   employment_status
,   sum(case when is_billable then weekly_hours else 0 end) as billable_hours
,   sum(case when not is_billable then weekly_hours else 0 end) as not_billable_hours
from dev_staging.stg_project_assignments pa
join dev_staging.stg_employees e
    on e.employee_id = pa.employee_id
group by 1, 2
order by 1;
  ```
  4. Denormalized values: Some values that could have been denormalized have not been - notably `project_code`/`project_name`. This is to both avoid increasing the complexity of this project and lack of a reasonable assumption for deduplication. However, it doesn't seem to be a problem in this dataset.
  5. Client secrets are committed to this repository for ease of use. Since this is an isolated project with no security concerns, the `.env` and `profiles.yml` are part of the repository.

## Result 
Column names `team_count` and `total_weekly_hours` abbreviated to fit table format
```
select * from dev_marts.project_staffing ;

 project_code  |        project_name         | project_lead_id | t_c | t_w_h
---------------+-----------------------------+-----------------+-----+-------
 PROJ-2024-002 | Mobile App Redesign         | EMP-1004        |   4 |    84
 PROJ-2024-004 | Data Pipeline Modernization | EMP-1024        |   3 |    88
 PROJ-2024-005 | Customer Portal             | EMP-1013        |   2 |    40
 PROJ-2024-001 | Platform Migration          | EMP-1016        |   3 |    68
 PROJ-2024-007 | Security Audit Remediation  |                 |   6 |   104
 PROJ-2024-003 | Q1 Marketing Campaign       | EMP-1023        |   6 |   124
 PROJ-2024-006 | Internal Tools Refresh      |                 |   0 |     0
```
