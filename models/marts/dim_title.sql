-- One row per title, with format, decade, and a vote-weighted rating
-- (Bayesian average) so low-vote titles do not dominate performance rankings.
with titles as (
    select * from {{ ref('stg_titles') }}
),
ratings as (
    select * from {{ ref('stg_ratings') }}
),
global as (
    select avg(average_rating) as mean_rating from ratings
)
select
    t.title_id,
    t.primary_title,
    t.original_title,
    t.title_type,
    case
        when t.title_type in ('movie', 'tvMovie', 'short') then 'Film'
        when t.title_type in ('tvSeries', 'tvMiniSeries') then 'Series'
        when t.title_type = 'tvEpisode' then 'Episode'
        else 'Other'
    end                                                     as content_format,
    t.is_adult,
    t.start_year,
    (t.start_year // 10) * 10                               as start_decade,
    t.end_year,
    t.runtime_minutes,
    t.genres_raw,
    r.average_rating,
    coalesce(r.num_votes, 0)                                as num_votes,
    case when r.average_rating is not null then round(
        (r.num_votes * 1.0 / (r.num_votes + {{ var('min_votes', 1000) }})) * r.average_rating
        + ({{ var('min_votes', 1000) }} * 1.0 / (r.num_votes + {{ var('min_votes', 1000) }})) * g.mean_rating
    , 3) end                                                as weighted_rating
from titles t
left join ratings r using (title_id)
cross join global g
