-- ===========================================================
-- High-Value Customers with Multiple Products
-- ===========================================================

-- ------------------------------------------------------------
-- 1. Aggregate savings account data per customer
-- ------------------------------------------------------------
WITH SavingsAgg AS (
    SELECT
        owner_id,
        COUNT(*)    AS savings_count,   -- how many savings transactions/accounts
        SUM(confirmed_amount) AS total_deposit    -- total deposited amount
    FROM
        savings_savingsaccount
	WHERE 
		confirmed_amount > 0 						-- ensure at least one funded savings account
    GROUP BY
        owner_id
),

-- ------------------------------------------------------------
-- 2. Aggregate investment plan counts per customer
-- ------------------------------------------------------------
PlanAgg AS (
    SELECT
        owner_id,
        COUNT(*) AS investment_count    -- number of active investment plans
    FROM
        plans_plan
        
	WHERE 
		is_a_fund = 1
    GROUP BY
        owner_id
)

-- ------------------------------------------------------------
-- 3. Combine user info with their savings & plan aggregates
-- ------------------------------------------------------------
SELECT
    u.id                                   AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,              -- full name
    s.savings_count,                                          
    p.investment_count,
    s.total_deposit							AS total_deposits
FROM
    users_customuser AS u

    -- only include customers who actually have savings data
    INNER JOIN SavingsAgg AS s
        ON u.id = s.owner_id

    -- only include customers who actually have investment plans
    INNER JOIN PlanAgg AS p
        ON u.id = p.owner_id

ORDER BY
    s.total_deposit DESC;  -- highest total deposit first
