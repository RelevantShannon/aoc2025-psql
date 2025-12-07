-- Part 1 for day 7

WITH RECURSIVE beam (row_num, col_num)
                   AS (SELECT board.row_num AS row_num,
                              board.col_num AS col_num
                       FROM board
                       WHERE board.symbol = 'S'

                       UNION

                       (WITH new_beam AS (SELECT beam.row_num + 1 AS row_num,
                                                 beam.col_num     AS col_num
                                          FROM beam)


                        SELECT new_beam.row_num AS row_num,
                               new_beam.col_num AS col_num
                        FROM new_beam
                                 INNER JOIN board
                                            ON board.row_num = new_beam.row_num
                                                AND board.col_num = new_beam.col_num
                        WHERE board.symbol = '.'

                        UNION

                        SELECT new_beam.row_num   AS row_num,
                               split_beam.col_num AS col_num
                        FROM new_beam
                                 INNER JOIN board
                                            ON board.row_num = new_beam.row_num
                                                AND board.col_num = new_beam.col_num,
                             LATERAL (VALUES (new_beam.col_num - 1),
                                             (new_beam.col_num + 1)) AS split_beam(col_num)
                        WHERE board.symbol = '^'))
SELECT COUNT(*)
FROM beam
         INNER JOIN board
                    ON board.row_num = beam.row_num + 1
                        AND board.col_num = beam.col_num
WHERE board.symbol = '^'
