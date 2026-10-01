select
    talent_id,
    talent_name,
    birth_year,
    death_year,
    professions_raw
from {{ ref('stg_talent') }}
