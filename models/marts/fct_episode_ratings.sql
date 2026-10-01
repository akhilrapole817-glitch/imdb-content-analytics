select
    e.episode_id,
    e.series_id,
    s.primary_title                                         as series_title,
    e.season_number,
    e.episode_number,
    ep.average_rating,
    ep.num_votes
from {{ ref('stg_episodes') }} e
inner join {{ ref('dim_title') }} s on s.title_id = e.series_id
left join {{ ref('dim_title') }} ep on ep.title_id = e.episode_id
