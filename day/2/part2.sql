SELECT SUM(s)
FROM input,
     LATERAL (
         SELECT COALESCE(SUM(n), 0) AS s
         FROM GENERATE_SERIES(start_id, end_id) AS n
         WHERE n::text ~ '^(\d+)\1+$') AS n
