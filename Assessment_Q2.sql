-- ============================================================
-- True 12-Month Transaction Frequency Analysis by User
-- ============================================================

-- 1. Generate the last 12 month labels (YYYY-MM)
WITH RECURSIVE months AS (
  SELECT
    DATE_FORMAT(CURDATE(), '%Y-%m')             AS txn_month,
    1                                           AS month_index
  UNION ALL
  SELECT
    DATE_FORMAT(DATE_SUB(CURDATE(),
                INTERVAL month_index MONTH), '%Y-%m'),
    month_index + 1
  FROM months
  WHERE month_index < 11
),

-- 2. List every user + every month (12 rows per user)
users_list AS (
  SELECT id AS owner_id
  FROM users_customuser
),

user_months AS (
  SELECT
    u.owner_id,
    m.txn_month
  FROM users_list AS u
  CROSS JOIN months    AS m
),

-- 3. Count actual transactions by user/month
monthly_txns AS (
  SELECT
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
    COUNT(*)                              AS txns_in_month
  FROM savings_savingsaccount
  WHERE
    transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
  GROUP BY
    owner_id,
    txn_month
),

-- 4. Left-join to zero-fill missing months
user_month_txns AS (
  SELECT
    um.owner_id,
    um.txn_month,
    COALESCE(mt.txns_in_month, 0) AS txns_in_month
  FROM user_months AS um
  LEFT JOIN monthly_txns AS mt
    ON mt.owner_id = um.owner_id
   AND mt.txn_month = um.txn_month
),

-- 5. Compute the true 12-month average per user
avg_monthly AS (
  SELECT
    owner_id,
    ROUND(AVG(txns_in_month), 2) AS avg_txns_per_month
  FROM user_month_txns
  GROUP BY owner_id
)

-- 6. Bucket and summarize
SELECT
  CASE
    WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
    WHEN avg_txns_per_month >= 3  THEN 'Medium Frequency'
    ELSE                            'Low Frequency'
  END                              AS frequency_category,
  COUNT(*)                         AS customer_count,
  ROUND(AVG(avg_txns_per_month),2) AS avg_transactions_per_month
FROM
  avg_monthly
GROUP BY
  frequency_category
ORDER BY
  MIN(
    CASE
      WHEN avg_txns_per_month >= 10 THEN 1
      WHEN avg_txns_per_month >= 3  THEN 2
      ELSE 3
    END
  );
