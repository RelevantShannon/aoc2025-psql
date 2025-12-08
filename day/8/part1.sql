-- Part 1 for day 8

SET LOCAL work_mem = '512MB';

WITH RECURSIVE
    mst(id, network, step)
        AS (SELECT playground.id AS id,
                   playground.id AS network,
                   0             AS step
            FROM playground

            UNION ALL

            (WITH rec_mst(id, network, step)
                      AS (SELECT mst.id      AS id,
                                 mst.network AS network,
                                 mst.step    AS step
                          FROM mst),
                  current_step AS (SELECT step AS current_step
                                   FROM rec_mst
                                   LIMIT 1),
                  next_pair_to_merge AS (SELECT point_1.network AS network_1,
                                                point_2.network AS network_2,
                                                sorted_edges.id
                                         FROM sorted_edges
                                                  INNER JOIN rec_mst AS point_1 ON sorted_edges.u = point_1.id
                                                  INNER JOIN rec_mst AS point_2 ON sorted_edges.v = point_2.id,
                                              current_step
                                         WHERE sorted_edges.id = current_step.current_step + 1
                                         ORDER BY sorted_edges.id
                                         LIMIT 1)
             SELECT rec_mst.id                   AS id,
                    CASE
                        WHEN rec_mst.network = next_pair_to_merge.network_2
                            THEN next_pair_to_merge.network_1
                        ELSE rec_mst.network END AS network,
                    rec_mst.step + 1             AS step
             FROM rec_mst
                      INNER JOIN next_pair_to_merge ON TRUE and rec_mst.step < 1001)),
    top_3 AS (SELECT mst.network,
                     COUNT(*) AS network_count
              FROM mst
              WHERE mst.step = 1000
              GROUP BY mst.network
              ORDER BY COUNT(*) DESC
              LIMIT 3)
SELECT mul(top_3.network_count)
FROM top_3