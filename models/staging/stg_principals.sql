select
    tconst                                   as title_id,
    try_cast(ordering as integer)            as billing_order,
    nconst                                   as talent_id,
    category                                 as role_category,
    job,
    characters                               as characters_raw
from {{ source('imdb', 'title_principals') }}
