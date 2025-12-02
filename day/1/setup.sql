CREATE TABLE input (
    id integer not null,
    rotation bigint NOT NULL
);

WITH lines AS (SELECT SUBSTRING(line, 1, 1)   AS rotation,
                      SUBSTRING(line, 2)::int AS quantity,
                      row_number() OVER ()  AS line_number
               FROM REGEXP_SPLIT_TO_TABLE(
                            :'input',
                            E'\n') AS line
               WHERE line <> '')
INSERT
INTO input(id, rotation)
SELECT line_number,
       CASE
           WHEN rotation = 'R' THEN quantity
           WHEN rotation = 'L' THEN -quantity
           END AS rotation
FROM lines