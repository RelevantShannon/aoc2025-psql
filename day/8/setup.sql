-- Setup for day 8
-- The input is available as :'input'

CREATE table playground
(
    id bigint,
    x  bigint,
    y  bigint,
    z  bigint
);

insert into playground (id, x, y, z)
select id,
       coord[1]::bigint as x,
       coord[2]::bigint as y,
       coord[3]::bigint as z
from regexp_split_to_table(:'input', E'\n') with ordinality as line(line, id),
     regexp_split_to_array(line, ',') as coord;

CREATE MATERIALIZED VIEW edges AS
SELECT a.id                                                      AS u,
       b.id                                                      AS v,
       sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2) AS w
FROM playground a
         JOIN playground b ON a.id < b.id;

CREATE MATERIALIZED VIEW sorted_edges AS
SELECT row_number() OVER (ORDER BY edges.w) AS id,
       edges.u,
       edges.v,
       edges.w
FROM edges
ORDER BY w;

CREATE INDEX idx_sorted_edges_id ON sorted_edges (id);

CREATE FUNCTION mul_sfunc(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql AS
'SELECT $1 * coalesce($2, 1)';

CREATE AGGREGATE mul(anyelement) (
    STYPE = anyelement,
    INITCOND = 1,
    SFUNC = mul_sfunc,
    COMBINEFUNC = mul_sfunc,
    PARALLEL = SAFE
    );
