"""Daily refresh: reload IMDb raw files, then build and test the dbt project."""
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_DIR = "/opt/airflow/imdb-content-analytics"

default_args = {
    "owner": "data-eng",
    "retries": 2,
    "retry_delay": timedelta(minutes=10),
}

with DAG(
    dag_id="imdb_content_refresh",
    start_date=datetime(2026, 1, 1),
    schedule="0 6 * * *",  # IMDb refreshes its files daily
    catchup=False,
    default_args=default_args,
    tags=["imdb", "dbt"],
) as dag:
    load_raw = BashOperator(
        task_id="load_raw",
        bash_command=f"cd {PROJECT_DIR} && rm -rf data && python scripts/load_imdb.py",
    )
    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"cd {PROJECT_DIR} && dbt build --profiles-dir .",
    )
    load_raw >> dbt_build
