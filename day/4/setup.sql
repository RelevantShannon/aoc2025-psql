-- Setup for day 4
-- The input is available as :'input'
CREATE TABLE input (
    row_id integer NOT NULL,
    col_id integer NOT NULL,
    PRIMARY KEY (row_id, col_id)
);

WITH lines AS (
    SELECT
        line,
        ROW_NUMBER() OVER () AS row_id
    FROM
        REGEXP_SPLIT_TO_TABLE(:'input', E'\n') AS line)
INSERT INTO input (row_id, col_id)
SELECT
    row_id,
    col_id
FROM
    lines,
    LATERAL (
        SELECT
            ROW_NUMBER() OVER () AS col_id,
            char_line = '@' AS is_paper
        FROM
            REGEXP_SPLIT_TO_TABLE(line, E'') AS char_line)
WHERE
    is_paper;

