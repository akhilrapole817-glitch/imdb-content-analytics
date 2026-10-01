select
    tconst                                   as episode_id,
    parentTconst                             as series_id,
    try_cast(seasonNumber as integer)        as season_number,
    try_cast(episodeNumber as integer)       as episode_number
from {{ source('imdb', 'title_episode') }}
