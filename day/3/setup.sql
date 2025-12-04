-- Setup for day 3
-- The input is available as :'input'
CREATE TABLE input
(
    bank_id    integer NOT NULL,
    battery_id integer NOT NULL,
    joltage    integer NOT NULL,
    PRIMARY KEY (bank_id, battery_id)
);

WITH lines AS (SELECT line,
                      ROW_NUMBER() OVER () AS bank_id
               FROM REGEXP_SPLIT_TO_TABLE(:'input', E'\n') AS line)
INSERT
INTO input (bank_id, battery_id, joltage)
SELECT bank_id,
       battery_id,
       joltage::integer
FROM lines,
     LATERAL (
              SELECT ROW_NUMBER() OVER () AS battery_id,
                     joltage::integer
              FROM REGEXP_SPLIT_TO_TABLE(line, E'') AS joltage)
