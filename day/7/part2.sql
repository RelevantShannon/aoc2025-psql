-- Part 2 for day 7

WITH RECURSIVE beam (row_num, col_num, path_count)
                   AS (SELECT board.row_num AS row_num,
                              board.col_num AS col_num,
                              1::bigint     AS path_count
                       FROM board
                       WHERE board.symbol = 'S'

                       UNION

                       (WITH new_beam(row_num, col_num, path_count) AS
                                 (SELECT beam.row_num + 1 AS row_num,
                                         beam.col_num     AS col_num,
                                         beam.path_count  AS path_count
                                  FROM beam),
                             new_beams(row_num, col_num, path_count)
                                 AS (SELECT new_beam.row_num    AS row_num,
                                            new_beam.col_num    AS col_num,
                                            new_beam.path_count AS path_count
                                     FROM new_beam
                                              INNER JOIN board
                                                         ON board.row_num =
                                                            new_beam.row_num
                                                             AND board.col_num =
                                                                 new_beam.col_num
                                     WHERE board.symbol = '.'

                                     UNION ALL

                                     SELECT new_beam.row_num   AS row_num,
                                            split_beam.col_num AS col_num,
                                            path_count         AS path_count
                                     FROM new_beam
                                              INNER JOIN board
                                                         ON board.row_num =
                                                            new_beam.row_num
                                                             AND board.col_num =
                                                                 new_beam.col_num,
                                          LATERAL (VALUES (new_beam.col_num - 1),
                                                          (new_beam.col_num + 1)) AS split_beam(col_num)
                                     WHERE board.symbol = '^')
                        SELECT new_beams.row_num                 AS row_num,
                               new_beams.col_num                 AS col_num,
                               SUM(new_beams.path_count)::bigint AS path_count
                        FROM new_beams
                        GROUP BY new_beams.row_num, new_beams.col_num))
SELECT beam.row_num, SUM(beam.path_count)
FROM beam
GROUP BY beam.row_num
ORDER BY beam.row_num DESC
LIMIT 1;