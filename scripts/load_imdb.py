"""Load IMDb non-commercial TSV files into a DuckDB `raw` schema.

Usage:
  python scripts/load_imdb.py                     # download full files from datasets.imdbws.com
  python scripts/load_imdb.py --source fixtures   # load the small CI fixtures in ./fixtures

IMDb data is for personal and non-commercial use: https://developer.imdb.com/non-commercial-datasets/
"""
import argparse
import os
import urllib.request
from pathlib import Path

import duckdb

FILES = {
    "title_basics": "title.basics.tsv.gz",
    "title_ratings": "title.ratings.tsv.gz",
    "title_principals": "title.principals.tsv.gz",
    "title_episode": "title.episode.tsv.gz",
    "name_basics": "name.basics.tsv.gz",
}
BASE_URL = "https://datasets.imdbws.com/"


def fetch(filename: str, cache: Path) -> Path:
    target = cache / filename
    if not target.exists():
        print(f"downloading {filename} ...")
        urllib.request.urlretrieve(BASE_URL + filename, target)
    return target


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", default="remote", help="'remote' or a local directory of .tsv/.tsv.gz files")
    parser.add_argument("--db", default=os.environ.get("IMDB_DUCKDB_PATH", "imdb.duckdb"))
    args = parser.parse_args()

    con = duckdb.connect(args.db)
    con.execute("create schema if not exists raw")

    cache = Path("data")
    cache.mkdir(exist_ok=True)
    for table, filename in FILES.items():
        if args.source == "remote":
            path = fetch(filename, cache)
        else:
            local = Path(args.source)
            path = local / filename if (local / filename).exists() else local / filename.replace(".gz", "")
        con.execute(
            f"""
            create or replace table raw.{table} as
            select * from read_csv(
                '{path.as_posix()}', delim = '\t', header = true, quote = '',
                nullstr = '\\N', all_varchar = true
            )
            """
        )
        rows = con.execute(f"select count(*) from raw.{table}").fetchone()[0]
        print(f"raw.{table}: {rows:,} rows")
    con.close()


if __name__ == "__main__":
    main()
