-- Part 2 for day 7

WITH RECURSIVE beam (row_num, col_num, path_count)
                   AS (SELECT board.row_num AS row_num,
                              board.col_num AS col_num,
                              1::bigint     AS path_count
                       FROM board
                       WHERE board.symbol = 'S'

                       UNION

                       (WITH split_beams(row_num, col_num, path_count)
                                 AS (SELECT beam.row_num + 1   AS row_num,
                                            split_beam.col_num AS col_num,
                                            beam.path_count    AS path_count
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
                        SELECT split_beams.row_num                 AS row_num,
                               split_beams.col_num                 AS col_num,
                               SUM(split_beams.path_count)::bigint AS path_count
                        FROM split_beams
                        GROUP BY split_beams.row_num, split_beams.col_num))
SELECT beam.row_num, SUM(beam.path_count)
FROM beam
GROUP BY beam.row_num
ORDER BY beam.row_num DESC
LIMIT 1;