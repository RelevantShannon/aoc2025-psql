-- get an initial count of papers for the base case
WITH RECURSIVE
    starting_count AS (SELECT COUNT(*) AS starting_count
                       FROM input),
    acc (
         row_id, col_id, paper_count, step
        ) AS (
        -- base case is just the input with the starting count and a step of 0
        SELECT board_1.row_id                AS row_id,
               board_1.col_id                AS col_id,
               starting_count.starting_count AS paper_count,
               0::bigint                     AS step
        FROM input AS board_1,
             starting_count
        UNION ALL
        (WITH prev AS (
            -- get the previous state from the accumulator
            SELECT *
            FROM acc),
              -- compute the neighbor coordinates for each paper in the previous state
              neighbor_coords AS (SELECT prev.row_id + dr AS n_row_id,
                                         prev.col_id + dc AS n_col_id
                                  FROM prev,
                                       (VALUES (-1),
                                               (0),
                                               (1)) AS vr (dr),
                                       (VALUES (-1), (0), (1)) AS vc (dc)
                                  WHERE NOT (dr = 0
                                      AND dc = 0)),
              -- count the number of neighbors for each cell in the previous state
              neighbor_counts AS (SELECT n_row_id AS row_id,
                                         n_col_id AS col_id,
                                         COUNT(*) AS neighbor_papers
                                  FROM neighbor_coords
                                  GROUP BY n_row_id,
                                           n_col_id),
              -- build the new board state by removing papers with 4 or more neighbors
              new_board AS (SELECT prev.row_id,
                                   prev.col_id,
                                   prev.paper_count AS old_paper_count,
                                   prev.step + 1    AS step
                            FROM prev
                                     -- left join to get neighbor counts
                                     LEFT JOIN neighbor_counts ON neighbor_counts.row_id = prev.row_id
                                AND neighbor_counts.col_id = prev.col_id
                            WHERE COALESCE(neighbor_counts.neighbor_papers, 0) >= 4),
              -- get the new paper count after removals
              paper_stats AS (SELECT COUNT(*) AS paper_count
                              FROM new_board)
         SELECT new_board.row_id        AS row_id,
                new_board.col_id        AS col_id,
                paper_stats.paper_count AS paper_count,
                new_board.step          AS step
         FROM new_board,
              paper_stats
         WHERE paper_stats.paper_count != new_board.old_paper_count))
SELECT DISTINCT (acc.step)
FROM acc
ORDER BY acc.step DESC