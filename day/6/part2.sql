-- Part 2 for day 6

WITH RECURSIVE
    lines(line, row_num) AS
        (SELECT line,
                row_num
         FROM raw_input,
              REGEXP_SPLIT_TO_TABLE(raw_input.input, E'\n') WITH ORDINALITY AS a(line, row_num)),
    symbols_line(line, row_num) AS
        (SELECT lines.line    AS line,
                lines.row_num AS row_num
         FROM lines
         ORDER BY lines.row_num DESC
         LIMIT 1),
    symbols(symbol, col_num, length) AS
        (SELECT TRIM(symbol)   AS symbol,
                col_num        AS col_num,
                LENGTH(symbol) AS length
         FROM symbols_line,
              REGEXP_SPLIT_TO_TABLE(symbols_line.line, E'\\s(?=\\S)') WITH ORDINALITY AS a(symbol, col_num)),
    numbers_line(line, row_num) AS
        (SELECT lines.line    AS line,
                lines.row_num AS row_num
         FROM lines,
              symbols_line
         WHERE lines.row_num != symbols_line.row_num),
    numbers_acc(line, acc, row_num, step) AS
        (SELECT numbers_line.line    AS line,
                ARRAY []::text[]     AS acc,
                numbers_line.row_num AS row_num,
                0::bigint            AS step
         FROM numbers_line

         UNION

         SELECT SUBSTRING(numbers_acc.line FROM (symbols.length + 2))               AS line,
                numbers_acc.acc || SUBSTRING(numbers_acc.line FOR (symbols.length)) AS acc,
                numbers_acc.row_num                                                 AS row_num,
                numbers_acc.step + 1                                                AS step
         FROM numbers_acc
                  INNER JOIN symbols ON symbols.col_num = numbers_acc.step + 1),
    col_numbers AS (SELECT number.col_num, ARRAY_AGG(number.number) AS number
                    FROM numbers_acc,
                         UNNEST(numbers_acc.acc) WITH ORDINALITY AS number(number, col_num)
                    WHERE line = ''
                    GROUP BY number.col_num),
    transposed AS (SELECT col_numbers.col_num, trans_num.row_num, trans_num.number
                   FROM col_numbers,
                        LATERAL (SELECT x AS row_num, TRIM(STRING_AGG(CHAR, '' ORDER BY y))::BIGINT AS number
                                 FROM UNNEST(col_numbers.number) WITH ORDINALITY AS num(str, y),
                                      REGEXP_SPLIT_TO_TABLE(str, '') WITH ORDINALITY AS digit(CHAR, x)
                                 GROUP BY x) AS trans_num),
    acc (col_num, row_num, number) AS
        (SELECT symbols.col_num AS col_num,
                0::bigint       AS row_num,
                CASE
                    WHEN symbols.symbol = '+' THEN
                        0::bigint
                    ELSE
                        1::bigint
                    END         AS number
         FROM symbols

         UNION ALL
         SELECT transposed.col_num AS col_num,
                transposed.row_num AS row_num,
                CASE
                    WHEN symbols.symbol = '+' THEN
                        acc.number + transposed.number
                    ELSE
                        acc.number * transposed.number
                    END            AS num
         FROM acc
                  INNER JOIN transposed ON
             acc.row_num + 1 = transposed.row_num AND
             acc.col_num = transposed.col_num
                  INNER JOIN symbols ON
             symbols.col_num = transposed.col_num),
    acc_numbers AS (SELECT DISTINCT ON (acc.col_num) acc.number AS number
                    FROM acc
                    ORDER BY acc.col_num, acc.row_num DESC)
SELECT SUM(acc_numbers.number)
FROM acc_numbers