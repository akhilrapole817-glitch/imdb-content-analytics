select
    nconst                                   as talent_id,
    primaryName                              as talent_name,
    try_cast(birthYear as integer)           as birth_year,
    try_cast(deathYear as integer)           as death_year,
    primaryProfession                        as professions_raw
from {{ source('imdb', 'name_basics') }}
