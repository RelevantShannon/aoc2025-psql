-- Setup for day 6
-- The input is available as :'input'

CREATE TABLE numbers
(
    row_num BIGINT,
    col_num BIGINT,
    number  BIGINT
);

CREATE TABLE symbols
(
    col_num BIGINT,
    symbol  TEXT
);

create TABLE raw_input
(
    input TEXT
);

WITH input AS (SELECT ROW_NUMBER() OVER ()                  AS id,
                      TRIM(BOTH E'\n\t\r ' FROM input_line) AS input_line
               FROM REGEXP_SPLIT_TO_TABLE(:'input',
                                          E'\n') AS input_line),
     symbols_arr AS (SELECT input.id,
                            input.input_line AS symbols
                     FROM input
                     ORDER BY input.id DESC
                     LIMIT 1),
     symbols AS (SELECT symbols.col_id AS col_id,
                        symbols.symbol AS symbol
                 FROM symbols_arr,
                      REGEXP_SPLIT_TO_TABLE(symbols_arr.symbols, E' +') WITH ORDINALITY AS symbols(symbol, col_id)),
     numbers AS (SELECT input.id               AS row_id,
                        numbers.col_id         AS col_id,
                        numbers.number::BIGINT AS number
                 FROM INPUT,
                      symbols_arr,
                      REGEXP_SPLIT_TO_TABLE(input.input_line, E' +')
                          WITH ORDINALITY AS numbers(number, col_id)
                 WHERE INPUT.id != symbols_arr.id),
     symbol_insert AS (
         INSERT INTO symbols (col_num, symbol)
             SELECT col_id AS col_num,
                    symbol
             FROM symbols),
     numbers_insert AS (
         INSERT INTO numbers (row_num, col_num, number)
             SELECT row_id AS row_num,
                    col_id AS col_num,
                    number
             FROM numbers)
SELECT 1;

insert into raw_input
values (:'input');