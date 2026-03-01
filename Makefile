.PHONY: build up ingest dbt run down

build:
	docker compose build

up:
	docker compose up -d db

ingest: up
	docker compose run --rm runner uv run scripts/load_data.py

dbt: up
	docker compose run --rm runner uv run dbt build --project-dir dbt --profiles-dir .

run: build ingest dbt

down:
	docker compose down -v
