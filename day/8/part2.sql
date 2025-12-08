-- Part 2 for day 8

SET LOCAL work_mem = '512MB';

WITH RECURSIVE mst(id, network, step)
                   AS (SELECT playground.id::bigint  AS id,
                              -playground.id::bigint AS network,
                              1 ::bigint             AS step
                       FROM playground

                       UNION ALL

                       (WITH rec_mst(id, network, step)
                                 AS (SELECT mst.id      AS id,
                                            mst.network AS network,
                                            mst.step    AS step
                                     FROM mst),
                             current_edge AS (SELECT rec_mst.network AS current_edge
                                              FROM rec_mst
                                              ORDER BY rec_mst.network DESC
                                              LIMIT 1),
                             next_pair_to_merge AS (SELECT point_1.network AS network_1,
                                                           point_2.network AS network_2,
                                                           sorted_edges.id
                                                    FROM sorted_edges
                                                             INNER JOIN rec_mst AS point_1 ON sorted_edges.u = point_1.id
                                                             INNER JOIN rec_mst AS point_2 ON sorted_edges.v = point_2.id,
                                                         current_edge
                                                    WHERE sorted_edges.id > current_edge.current_edge
                                                      AND point_1.network != point_2.network
                                                      AND point_1.id < point_2.id
                                                    ORDER BY sorted_edges.id
                                                    LIMIT 1)
                        SELECT rec_mst.id                   AS id,
                               CASE
                                   WHEN rec_mst.network = next_pair_to_merge.network_1 OR
                                        rec_mst.network = next_pair_to_merge.network_2
                                       THEN next_pair_to_merge.id
                                   ELSE rec_mst.network END AS network,
                               rec_mst.step + 1             AS step
                        FROM rec_mst
                                 INNER JOIN next_pair_to_merge ON TRUE))
SELECT point_1.x * point_2.x
FROM mst
         INNER JOIN sorted_edges ON sorted_edges.id = mst.network
         INNER JOIN playground AS point_1 ON point_1.id = sorted_edges.u
         INNER JOIN playground AS point_2 ON point_2.id = sorted_edges.v
ORDER BY step DESC
LIMIT 1