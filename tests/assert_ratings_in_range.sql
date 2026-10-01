-- IMDb ratings must fall between 1.0 and 10.0.
select title_id, average_rating
from {{ ref('dim_title') }}
where average_rating is not null and (average_rating < 1 or average_rating > 10)
