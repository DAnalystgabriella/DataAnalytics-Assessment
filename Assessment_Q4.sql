-- =============================================================
-- Customer Lifetime Value (CLV) Calculation – Optimized Version
-- =============================================================

-- 0. Compute “today” once to avoid per-row NOW() calls
SET @today := NOW();

WITH
  -- 1. Pre-aggregate total savings volume per customer
  SavingsAgg AS (
    SELECT
      owner_id,
      SUM(amount) AS total_transactions  -- total transaction volume per user
    FROM
      savings_savingsaccount
    GROUP BY
      owner_id
  )

-- 2. Main query: join users to their aggregated volumes
SELECT
  u.id                                         AS customer_id,
  
  -- full name
  CONCAT(u.first_name, ' ', u.last_name)       AS name,

  -- tenure in months (at least 1 to prevent divide-by-zero)
  GREATEST(
    TIMESTAMPDIFF(MONTH, u.date_joined, @today),
    1
  )                                            AS tenure_months,

  -- pull pre-aggregated total (zero if no savings)
  COALESCE(sa.total_transactions, 0)           AS total_transactions,

  -- CLV = (avg monthly volume) × 12 × 0.001, rounded
  ROUND(
    (
      COALESCE(sa.total_transactions, 0)
      / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, @today), 1)
    ) * 12 * 0.001,
    2
  )                                            AS estimated_clv

FROM
  users_customuser AS u

  -- bring in each user’s total savings amount
  LEFT JOIN SavingsAgg AS sa
    ON sa.owner_id = u.id

-- only group by the primary key (u.id); other columns functionally depend on it
GROUP BY
  u.id

-- list highest CLV first
ORDER BY
  estimated_clv DESC;
