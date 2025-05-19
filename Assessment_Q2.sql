-- ============================================================
-- Rolling 12-Month Transaction Frequency Analysis by User
-- ============================================================

-- 1. Build per-user, per-month transaction counts for the last year
WITH monthly_txns AS (
  SELECT
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,   -- Normalize to “YYYY-MM”
    COUNT(*)                              AS txns_in_month -- How many transactions in that month
  FROM
    savings_savingsaccount
  WHERE
    transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)  
    -- Only include transactions from the past 12 months
  GROUP BY
    owner_id,
    txn_month
),

-- 2. Compute each user’s average monthly transaction count
avg_monthly AS (
  SELECT
    owner_id,
    AVG(txns_in_month) AS avg_txns_per_month  -- Mean transactions per month over the rolling window
  FROM
    monthly_txns
  GROUP BY
    owner_id
)

-- 3. Bucket users by frequency and produce summary statistics
SELECT
  CASE
    WHEN avg_txns_per_month >= 10 THEN 'High Frequency'    -- Power users with 10+ txns/mo
    WHEN avg_txns_per_month >= 3  THEN 'Medium Frequency'  -- Regular users with 3–9 txns/mo
    ELSE                            'Low Frequency'       -- Occasional users with <3 txns/mo
  END                            AS frequency_category,

  COUNT(*)                       AS customer_count,              -- Number of users in each bucket

  ROUND(
    AVG(avg_txns_per_month), 2
  )                               AS avg_transactions_per_month  -- Bucket’s average of users’ own averages

FROM
  avg_monthly

GROUP BY
  frequency_category

ORDER BY
  -- Force the order High → Medium → Low
  MIN(
    CASE
      WHEN avg_txns_per_month >= 10 THEN 1
      WHEN avg_txns_per_month >= 3  THEN 2
      ELSE 3
    END
  );
