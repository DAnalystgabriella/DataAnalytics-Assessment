-- 1. Determine each plan’s most recent savings transaction date
WITH last_txn AS (
  SELECT
    plan_id,
    MAX(transaction_date) AS last_transaction_date
  FROM savings_savingsaccount
  GROUP BY plan_id
)

-- 2. Select active plans with no inflow in the past year
SELECT
  p.id                           AS plan_id,              -- unique plan identifier
  p.owner_id                     AS owner_id,             -- the customer who owns the plan

  /* Derive a human‑readable “type” label based on plan flags:
     - Savings: regular savings, open savings, emergency plans, personal challenges, donation plans, goals
     - Investment: fixed investments, funds, managed portfolios
     - Unknown: any other combination */
  CASE
    WHEN p.is_regular_savings    = 1
      OR p.open_savings_plan     = 1
      OR p.is_emergency_plan     = 1
      OR p.is_personal_challenge = 1
      OR p.is_donation_plan      = 1
      OR p.is_a_goal             = 1
      THEN 'Savings'
    WHEN p.is_fixed_investment   = 1
      OR p.is_a_fund             = 1
      OR p.is_managed_portfolio  = 1
      THEN 'Investment'
    ELSE 'Unknown'
  END                            AS type,

  lt.last_transaction_date      AS last_transaction_date, -- NULL if never had a savings txn
  DATEDIFF(CURDATE(), lt.last_transaction_date)
    AS inactivity_days           -- number of days since last transaction

FROM plans_plan p
LEFT JOIN last_txn lt
  ON lt.plan_id = p.id

WHERE
  -- Only include plans that are currently active
  p.is_archived = 0
  AND p.is_deleted = 0

  -- Flag plans with no transactions in the past 365 days (or never transacted)
  AND (
    lt.last_transaction_date IS NULL
    OR lt.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 365 DAY)
  )

ORDER BY inactivity_days DESC;  -- show the most inactive accounts first
