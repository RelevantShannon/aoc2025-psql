-- Setup for day 7
-- The input is available as :'input'

CREATE TABLE board
(
    row_num integer,
    col_num integer,
    symbol  CHAR(1)
);

INSERT INTO board (row_num, col_num, symbol)
SELECT row_num, col_num, symbol
FROM REGEXP_SPLIT_TO_TABLE(:'input', E'\n') WITH ORDINALITY AS symbol(line, row_num),
     REGEXP_SPLIT_TO_TABLE(line, '') WITH ORDINALITY AS symbol_char(symbol, col_num);