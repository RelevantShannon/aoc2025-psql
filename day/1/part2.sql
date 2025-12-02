WITH position AS (SELECT (COALESCE(
                                          SUM(rotation)
                                          OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
                                          0
                          ) + 50)::BIGINT AS old_position,
                         rotation::BIGINT AS rotation
                  FROM INPUT)
SELECT SUM(
               FLOOR(GREATEST(old_position, old_position + rotation)::numeric / 100) -
               CEIL(LEAST(old_position, old_position + rotation)::numeric / 100) +
               CASE WHEN (old_position + rotation) % 100 != 0 THEN 1 ELSE 0 END
       )
FROM position;