import os
import re
import pandas as pd
import adbc_driver_postgresql.dbapi as adbc

DATABASE_URL = os.environ["DATABASE_URL"]


def clean_column_name(col: str) -> str:
    col = col.strip()
    col = re.sub(r'[^a-zA-Z0-9]+', '', col)
    return col

files = [
    {"table_name": "hr_employees_export", "file_path": "data/hr_employees_export.xlsx", "header_row": 3},
    {"table_name": "project_assignments_report", "file_path": "data/project_assignments_report.xlsx", "header_row": 3}
]

with adbc.connect(DATABASE_URL) as conn:
    with conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS source")
    conn.commit()
    for i, file in enumerate(files, start=1):
        try:
            df = pd.read_excel(file['file_path'], header=file['header_row'])
            df.columns = [clean_column_name(c) for c in df.columns]
            print(f"Uploading {file['table_name']}")
            df.to_sql(file['table_name'], conn, if_exists="replace", index=False, schema="source")
            print(f"{file['table_name']} done")
        except Exception as e:
            print(f"Failed to upload {file['table_name']}: {e}")
