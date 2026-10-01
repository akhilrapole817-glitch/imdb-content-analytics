-- Content performance by genre, format, and decade.
select
    g.genre,
    t.content_format,
    t.start_decade,
    count(*)                                                as title_count,
    count(t.average_rating)                                 as rated_title_count,
    round(avg(t.average_rating), 2)                         as avg_rating,
    round(avg(t.weighted_rating), 2)                        as avg_weighted_rating,
    sum(t.num_votes)                                        as total_votes
from {{ ref('bridge_title_genre') }} g
inner join {{ ref('dim_title') }} t using (title_id)
where t.content_format in ('Film', 'Series') and not t.is_adult
group by 1, 2, 3
