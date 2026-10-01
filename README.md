# IMDb Content Analytics

An analytics engineering project that turns the public IMDb datasets into tested, documented dbt models for
**title metadata, talent, ratings, and content performance**: the core entities of a TV and film studio's
analytics stack.

## What it does

| Layer | Models | Purpose |
|---|---|---|
| Raw | `raw.title_basics`, `title_ratings`, `title_principals`, `title_episode`, `name_basics` | IMDb TSVs loaded as-is by `scripts/load_imdb.py` |
| Staging | `stg_titles`, `stg_ratings`, `stg_principals`, `stg_episodes`, `stg_talent` | Renaming, typing, IMDb `\N` null handling |
| Marts | `dim_title`, `dim_talent`, `bridge_title_genre`, `bridge_title_talent`, `fct_episode_ratings` | Star schema for titles, talent, genres, and episodes |
| Analytics | `mart_genre_performance`, `mart_series_performance`, `mart_talent_performance` | Content performance by genre, format, and decade; season-over-season series trends; talent reach |
| Semantic layer | `titles` semantic model; `titles_released`, `audience_votes`, `avg_rating` metrics | Governed metric definitions (dbt Semantic Layer / MetricFlow) |

Design choices worth noting:

- **Vote-weighted rating** (`dim_title.weighted_rating`): a Bayesian average so a 9.5 rating with 40 votes does not
  outrank an 8.6 with 200,000. The vote threshold is the `min_votes` dbt var (default 1,000).
- **Portable SQL**: genre explosion and the date spine use `adapter.dispatch` / target checks so the same project runs on
  **DuckDB locally and Snowflake** in production.
- **Tests on every key**: `unique`, `not_null`, `relationships`, `accepted_values`, plus a singular test that ratings
  stay within 1 to 10. CI runs the full `dbt build` on synthetic fixtures for every pull request.

## Run it

```bash
pip install -r requirements.txt
python scripts/load_imdb.py            # downloads the IMDb files (about 1.5 GB uncompressed) into imdb.duckdb
dbt build --profiles-dir .             # builds all models and runs all tests
```

Snowflake: install `dbt-snowflake`, set the `SNOWFLAKE_*` environment variables, load the raw tables, then
`dbt build --profiles-dir . --target snowflake`.

Orchestration: `airflow/dags/imdb_refresh.py` reloads the raw files daily and runs `dbt build`, with retries.

## Data

Information courtesy of IMDb (https://www.imdb.com). Used with permission under the IMDb non-commercial dataset terms
(https://developer.imdb.com/non-commercial-datasets/). The files in `fixtures/` are small **synthetic** rows in the
IMDb column layout, used only for CI.
