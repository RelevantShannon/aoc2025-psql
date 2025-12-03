WITH banks AS (
    SELECT DISTINCT
        input.bank_id
    FROM
        input
),
max_batteries AS (
    SELECT
        ( WITH RECURSIVE bank AS (
                SELECT
                    input.bank_id,
                    input.battery_id,
                    input.joltage
                FROM
                    input
                WHERE
                    input.bank_id = banks.bank_id),
                params AS (
                    SELECT
                        COUNT(*) AS length
                    FROM
                        bank),
                    pick (min, step, acc)
                    AS (
                    SELECT
                        0,
                        1,
                        ARRAY[]::int[]
                    UNION
                    SELECT
                        max_row.battery_id,
                        pick.step + 1,
                        pick.acc || max_row.joltage
                    FROM
                        pick
                        JOIN LATERAL (
                        SELECT
                            bank.battery_id,
                            bank.joltage
                        FROM
                            bank,
                            params
                        WHERE
                            bank.battery_id > pick.min AND bank.battery_id <= params.length - (12 - pick.step)
                        ORDER BY
                            bank.joltage DESC,
                            bank.battery_id
                        LIMIT 1) AS max_row ON TRUE
                    WHERE
                        pick.step <= 12
)
                    SELECT
                        ARRAY_TO_STRING(pick.acc, '') AS max_batteries
                    FROM
                        pick
                    ORDER BY
                        step DESC
                    LIMIT 1)::bigint AS max_batteries
            FROM
                banks
)
    SELECT
        SUM(max_batteries.max_batteries)
FROM
    max_batteries
