-- Setup for day 5
-- The input is available as :'input'

CREATE TABLE ingredient_range
(
    id               integer PRIMARY KEY,
    ingredient_range int8multirange NOT NULL
);


CREATE TABLE ingredient
(
    id bigint NOT NULL,
    PRIMARY KEY (id)
);


WITH input AS (SELECT split_part(:'input', E'\n\n', 1) AS ranges),
     ranges AS (SELECT row_number() OVER () AS id,
                       int8multirange(
                               int8range(
                                       split_part(range, '-', 1)::bigint,
                                       split_part(range, '-', 2)::bigint,
                                       '[]'
                               )
                       )                    AS ingredient_range
                FROM input,
                     string_to_table(ranges, E'\n') AS range)
INSERT
INTO ingredient_range (id, ingredient_range)
SELECT id, ingredient_range
FROM ranges;


WITH input AS (SELECT split_part(:'input', E'\n\n', 2) AS ingredients)
INSERT
INTO ingredient (id)
SELECT ingredient::bigint AS id
FROM input,
     string_to_table(ingredients, E'\n') AS ingredient;