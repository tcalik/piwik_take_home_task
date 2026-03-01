import os
import re
import pandas as pd
import adbc_driver_postgresql.dbapi as adbc

DATABASE_URL = os.environ["DATABASE_URL"]


def clean_column_name(col: str) -> str:
    col = col.strip()
    col = re.sub(r'[^a-zA-Z0-9]+', '', col)
    return col

files = {
    "hr_employees_export": "data/hr_employees_export.xlsx",
    "project_assignments_report": "data/project_assignments_report.xlsx",
}

with adbc.connect(DATABASE_URL) as conn:
    with conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS source")
    for table_name, file_path in files.items():
        df = pd.read_excel(file_path, header=3)
        df.columns = [clean_column_name(c) for c in df.columns]
        print(f"Uploading {table_name}")
        df.to_sql(table_name, conn, if_exists="replace", index=False, schema="source")
        print(f"{table_name} done")
