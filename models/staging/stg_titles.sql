select
    tconst                                   as title_id,
    titleType                                as title_type,
    primaryTitle                             as primary_title,
    originalTitle                            as original_title,
    isAdult = '1'                            as is_adult,
    try_cast(startYear as integer)           as start_year,
    try_cast(endYear as integer)             as end_year,
    try_cast(runtimeMinutes as integer)      as runtime_minutes,
    genres                                   as genres_raw
from {{ source('imdb', 'title_basics') }}
