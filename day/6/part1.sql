-- Part 1 for day 6

WITH RECURSIVE
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
         SELECT numbers.col_num AS col_num,
                numbers.row_num AS row_num,
                CASE
                    WHEN symbols.symbol = '+' THEN
                        acc.number + numbers.number
                    ELSE
                        acc.number * numbers.number
                    END         AS num
         FROM acc
                  INNER JOIN numbers ON
             acc.row_num + 1 = numbers.row_num AND
             acc.col_num = numbers.col_num
                  INNER JOIN symbols ON
             symbols.col_num = numbers.col_num),
    acc_numbers AS (SELECT DISTINCT ON (acc.col_num) acc.number AS number
                    FROM acc
                    ORDER BY acc.col_num, acc.row_num DESC)
SELECT SUM(acc_numbers.number)
FROM acc_numbers