-- Part 1 for day 3
WITH max_by_bank AS (
    -- For each bank create a cartesian product of all batteries in that bank
    -- then filter out to only pairs where battery 2 is after battery 1
    -- then get the max joltage combination for each bank
    SELECT
        bank_1.bank_id,
        MAX(bank_1.joltage * 10 + bank_2.joltage) AS max
    FROM
        input AS bank_1,
        input AS bank_2
    WHERE
        bank_1.bank_id = bank_2.bank_id
        AND bank_2.battery_id > bank_1.battery_id
    GROUP BY
        bank_1.bank_id
)
SELECT
    -- Sum the max joltage combinations across all banks
    SUM(max_by_bank.max)
FROM
    max_by_bank
