-- Part 1 for day 3
WITH max_by_bank AS (
    SELECT
        input.bank_id,
        MAX(input.joltage * 10 + sub_input.joltage) AS max
    FROM
        input
        CROSS JOIN input AS sub_input
    WHERE
        sub_input.bank_id = input.bank_id
        AND sub_input.battery_id > input.battery_id
    GROUP BY
        input.bank_id
)
SELECT
    SUM(max_by_bank.max)
FROM
    max_by_bank
