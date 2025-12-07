-- Part 1 for day 7

WITH RECURSIVE beam (row_num, col_num)
                   AS (SELECT board.row_num AS row_num,
                              board.col_num AS col_num
                       FROM board
                       WHERE board.symbol = 'S'

                       UNION

                       SELECT beam.row_num + 1   AS row_num,
                              split_beam.col_num AS col_num
                       FROM beam
                                JOIN board
                                     ON board.row_num = beam.row_num + 1
                                         AND board.col_num = beam.col_num
                                CROSS JOIN LATERAL (
                           VALUES (CASE WHEN board.symbol = '.' THEN beam.col_num END),
                                  (CASE WHEN board.symbol = '^' THEN beam.col_num - 1 END),
                                  (CASE WHEN board.symbol = '^' THEN beam.col_num + 1 END)
                           ) AS split_beam(col_num)
                       WHERE split_beam.col_num IS NOT NULL)
SELECT COUNT(*)
FROM beam
         INNER JOIN board
                    ON board.row_num = beam.row_num + 1
                        AND board.col_num = beam.col_num
WHERE board.symbol = '^'
