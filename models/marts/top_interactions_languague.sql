with tmp_query_clean as (
        select *
        from
            (
                select
                    post_id,
                    extract(year from created_at) year,
                    split(tags, '|') tags, -- Pasa a formato array las filas que tengan por ejemplo "a|b|c" las convierte en ["a","b","c"]
                    accepted_answer_id,
                    created_at
                from {{ ref("stg_posts_questions") }}
            ),
            unnest(tags) tag -- Crea una fila por cada tag, fila 1 --> a , fila 2 --> b...
        where accepted_answer_id is not null
    )

select
    tag,
    count(*) c,
    count(distinct b.owner_user_id) answerers,
    avg(timestamp_diff(b.created_at, a.created_at, minute)) time_to_answer
from tmp_query_clean a
left join {{ ref("stg_posts_answers") }} b on a.accepted_answer_id = b.post_id
group by 1
having c > 300
order by 2 desc
limit 1000
