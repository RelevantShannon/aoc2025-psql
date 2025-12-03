WITH banks AS (
    -- Get distinct bank IDs
    SELECT DISTINCT
        input.bank_id
    FROM
        input
),
max_batteries AS (
    SELECT
        ( WITH RECURSIVE bank AS (
                -- for each bank, perform a reduce operation to get the max 12-battery combination
                -- This is a greedy algorithm that runs in O(n * 12) time
                -- First get all batteries for the bank
                SELECT
                    input.bank_id,
                    input.battery_id,
                    input.joltage
                FROM
                    input
                WHERE
                    input.bank_id = banks.bank_id),
                -- Get the length of the bank
                params AS (
                    SELECT
                        COUNT(*) AS length
                    FROM
                        bank),
                    -- Recursive pick of batteries
                    pick (min, step, acc)
                    AS (
                    -- base case
                    -- we start with min battery_id of 0, step 1, and empty accumulator
                    SELECT
                        0,
                        1,
                        ARRAY[]::int[]
                    UNION
                    -- recursive case
                    -- at each step, pick the max joltage battery available after the last picked battery
                    -- and append it to the accumulator, increment the step, and update min to the picked battery_id
                    SELECT
                        max_row.battery_id,
                        pick.step + 1,
                        pick.acc || max_row.joltage
                    FROM
                        pick
                        JOIN LATERAL (
                        -- select the max joltage battery available after the last picked battery
                        SELECT
                            bank.battery_id,
                            bank.joltage
                        FROM
                            bank,
                            params
                        WHERE
                            -- only consider batteries after the last picked battery
                            -- if we are at step N, we need to leave room for (12 - N) more batteries
                            -- from the end to guarantee we can pick 12 batteries total
                            bank.battery_id > pick.min AND bank.battery_id <= params.length - (12 - pick.step)
                        ORDER BY
                            bank.joltage DESC,
                            bank.battery_id
                        LIMIT 1) AS max_row ON TRUE
                    WHERE
                        -- stop after picking 12 batteries
                        pick.step <= 12
)
                    -- select the max batteries combination after 12 picks
                    -- concatenate the joltage values into a string
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
