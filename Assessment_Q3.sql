-- ===================================================================
-- Account Inactivity Alert (no savings transactions in the last 365 days)
-- ===================================================================

-- Pre-compute the cutoff date once
SET @cutoff := DATE_SUB(CURDATE(), INTERVAL 365 DAY);

WITH
  -- A. Only consider currently active, non-deleted plans
  ActivePlans AS (
    SELECT
      id,
      owner_id,
      is_regular_savings,
      is_a_fund
    FROM plans_plan
    WHERE is_archived = 0
      AND is_deleted  = 0
  ),

  -- B. For every plan, find its most recent savings txn date (if any)
  LastTxn AS (
    SELECT
      plan_id,
      MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    where confirmed_amount > 0
    GROUP BY plan_id
  )

SELECT
  p.id AS plan_id,                       -- unique plan identifier
  p.owner_id,                            -- customer who owns it

  -- Classify plan as Savings, Investment, or Unknown
  CASE
    WHEN p.is_regular_savings    = 1
      THEN 'Savings'
    WHEN p.is_a_fund             = 1
      THEN 'Investment'
    ELSE 'Unknown'
  END AS type,

  lt.last_transaction_date,             -- NULL if never transacted

  -- Days since last txn; treat NULL as very large to sort highest first
  COALESCE(
    DATEDIFF(CURDATE(), lt.last_transaction_date),
    9999
  ) AS inactivity_days

FROM ActivePlans AS p

  -- bring in the last txn date per plan
  LEFT JOIN LastTxn AS lt
    ON lt.plan_id = p.id

WHERE
  -- include plans with no txn in the last 365 days (or never)
  (lt.last_transaction_date < @cutoff
   OR lt.last_transaction_date IS NULL)

ORDER BY
  inactivity_days DESC;                  -- most inactive first
