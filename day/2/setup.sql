CREATE TABLE input (
    id integer not null,
    start_id bigint not null,
    end_id bigint not null
);

WITH lines AS (SELECT split_part(line, '-', 1)::bigint AS start_id,
                        split_part(line, '-', 2)::bigint AS end_id,
                      row_number() OVER ()  AS line_number
               FROM REGEXP_SPLIT_TO_TABLE(
                            :'input',
                            E',') AS line
               WHERE line <> '')
INSERT
INTO input(id, start_id, end_id)
SELECT line_number,
       least(start_id, end_id),
       greatest(start_id, end_id)
FROM lines;