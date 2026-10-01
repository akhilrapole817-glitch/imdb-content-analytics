select
    tconst                                   as title_id,
    try_cast(averageRating as decimal(3,1))  as average_rating,
    try_cast(numVotes as integer)            as num_votes
from {{ source('imdb', 'title_ratings') }}
