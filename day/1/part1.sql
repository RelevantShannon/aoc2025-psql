WITH position AS (SELECT (SUM(rotation) OVER
    (ORDER BY id)) + 50 AS position
                  FROM INPUT)
SELECT COUNT(*)
FROM position
WHERE position % 100 = 0;