-- Talent performance by role: credits, average rating, and audience reach (votes).
select
    n.talent_id,
    n.talent_name,
    b.role_category,
    count(distinct b.title_id)                              as credited_titles,
    round(avg(t.average_rating), 2)                         as avg_title_rating,
    sum(t.num_votes)                                        as total_votes
from {{ ref('bridge_title_talent') }} b
inner join {{ ref('dim_talent') }} n using (talent_id)
inner join {{ ref('dim_title') }} t using (title_id)
group by 1, 2, 3
