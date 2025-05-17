-- 1. Build per‑user, per‑month transaction counts
WITH monthly_txns AS (
  SELECT
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m')  AS txn_month,      -- normalize to “YYYY‑MM”
    COUNT(*)                                AS txns_in_month  -- how many txns that user made in that month
  FROM savings_savingsaccount
  GROUP BY
    owner_id,
    txn_month
),

-- 2. Compute each user’s average monthly transactions
avg_monthly AS (
  SELECT
    owner_id,
    AVG(txns_in_month) AS avg_txns_per_month  -- mean txns/month over all months they appear
  FROM monthly_txns
  GROUP BY owner_id
)

-- 3. Bucket and aggregate across users
SELECT
  CASE
    WHEN avg_txns_per_month >= 10 THEN 'High Frequency'    -- 10 or more txns/month
    WHEN avg_txns_per_month BETWEEN 3 AND 9.999 THEN 'Medium Frequency'  -- 3 to 9.999
    ELSE 'Low Frequency'                                   -- below 3
  END                                         AS frequency_category,
  COUNT(*)                                    AS customer_count,               -- how many users in each bucket
  ROUND(AVG(avg_txns_per_month), 2)           AS avg_transactions_per_month    -- average of each user’s own avg, rounded
FROM avg_monthly
GROUP BY
  frequency_category
ORDER BY
  /* ensure ordering High → Medium → Low */
  MIN(
    CASE
      WHEN avg_txns_per_month >= 10 THEN 1
      WHEN avg_txns_per_month >= 3  THEN 2
      ELSE 3
    END
  );
