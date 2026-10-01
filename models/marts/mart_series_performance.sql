-- Series-level performance: size, average episode rating, and season-over-season trend.
with by_season as (
    select
        series_id,
        series_title,
        season_number,
        count(*)                                            as episodes,
        avg(average_rating)                                 as season_avg_rating
    from {{ ref('fct_episode_ratings') }}
    where season_number is not null
    group by 1, 2, 3
),
bounds as (
    select
        series_id,
        min(season_number)                                  as first_season,
        max(season_number)                                  as last_season
    from by_season
    group by 1
)
select
    s.series_id,
    s.series_title,
    count(*)                                                as season_count,
    sum(s.episodes)                                         as episode_count,
    round(avg(s.season_avg_rating), 2)                      as avg_season_rating,
    round(max(case when s.season_number = b.first_season then s.season_avg_rating end), 2) as first_season_rating,
    round(max(case when s.season_number = b.last_season then s.season_avg_rating end), 2)  as last_season_rating,
    round(
        max(case when s.season_number = b.last_season then s.season_avg_rating end)
        - max(case when s.season_number = b.first_season then s.season_avg_rating end)
    , 2)                                                    as rating_trend
from by_season s
inner join bounds b using (series_id)
group by 1, 2
