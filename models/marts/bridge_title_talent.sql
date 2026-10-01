select
    p.title_id,
    p.talent_id,
    p.billing_order,
    p.role_category,
    p.job
from {{ ref('stg_principals') }} p
inner join {{ ref('dim_title') }} t using (title_id)
inner join {{ ref('dim_talent') }} n using (talent_id)
