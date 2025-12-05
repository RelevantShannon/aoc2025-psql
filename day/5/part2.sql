-- Part 2 for day 5

WITH RECURSIVE
    full_range(full_range, step)
        AS (SELECT INT8MULTIRANGE() AS full_range,
                   0                AS step

            UNION

            SELECT full_range.full_range + ingredient_range.ingredient_range AS full_range,
                   ingredient_range.id                                       AS step
            FROM full_range
                     LEFT JOIN ingredient_range
                               ON ingredient_range.id = full_range.step + 1),
    final_range AS (SELECT full_range.full_range AS final_range
                    FROM full_range
                    ORDER BY step DESC NULLS LAST
                    LIMIT 1)
SELECT sum(UPPER(inner_range) - LOWER(inner_range))
FROM final_range,
     UNNEST(final_range.final_range) AS inner_range

