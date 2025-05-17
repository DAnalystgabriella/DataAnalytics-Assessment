-- Common Table Expression (CTE) to aggregate savings account data
WITH SavingsAgg AS (
    SELECT
        owner_id,
        COUNT(*)    AS savings_count,   -- Number of savings accounts per customer
        SUM(amount) AS total_deposit    -- Total amount deposited per customer
    FROM
        savings_savingsaccount
    GROUP BY
        owner_id
),
-- CTE to aggregate investment plan data
PlanAgg AS (
    SELECT
        owner_id,
        COUNT(*) AS investment_count    -- Number of investment plans per customer
    FROM
        plans_plan
    GROUP BY
        owner_id
)
-- Main query to combine user information with aggregated savings and investment data
SELECT
    u.id                                   AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    s.savings_count,
    p.investment_count,
    s.total_deposit
FROM
    users_customuser u
    INNER JOIN SavingsAgg s
        ON u.id = s.owner_id
    INNER JOIN PlanAgg p
        ON u.id = p.owner_id
WHERE
    s.total_deposit > 0    -- Ensures the customer has at least one funded savings account
ORDER BY
    s.total_deposit DESC;  -- Sorts the results by total deposit in descending order
