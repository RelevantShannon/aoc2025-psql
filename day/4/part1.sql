-- Part 1 for day 4
WITH neighbour_coords AS (
    SELECT
        input.row_id + dr AS n_row_id,
        input.col_id + dc AS n_col_id
    FROM
        input,
        (
            VALUES (-1),
                (0),
                (1)) AS vr (dr),
            (
                VALUES (-1), (0), (1)) AS vc (dc)
            WHERE
                NOT (dr = 0
                    AND dc = 0)
),
neighbour_counts AS (
    SELECT
        n_row_id AS row_id,
        n_col_id AS col_id,
        COUNT(*) AS neighbour_papers
    FROM
        neighbour_coords
    GROUP BY
        n_row_id,
        n_col_id
)
SELECT
    COUNT(*)
FROM
    input
    LEFT JOIN neighbour_counts ON neighbour_counts.row_id = input.row_id
        AND neighbour_counts.col_id = input.col_id
WHERE
    COALESCE(neighbour_counts.neighbour_papers, 0) < 4
