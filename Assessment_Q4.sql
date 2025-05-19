-- Calculate customer tenure, total transaction volume, and estimated CLV (0.1% profit per transaction)
SELECT
    u.id AS customer_id,  
    -- Combine first and last name into one “name” column
    CONCAT(u.first_name, ' ', u.last_name) AS name,

    -- Tenure in months (at least 1 to avoid divide-by-zero)
    GREATEST(
      TIMESTAMPDIFF(MONTH, u.date_joined, NOW()), 
      1
    ) AS tenure_months,

    -- Sum of all transaction amounts per customer (zero if none)
    IFNULL(SUM(s.amount), 0) AS total_transactions,

    -- Estimated CLV: 
    --   (avg monthly volume) × 12 months × 0.001 (0.1% profit)
    ROUND(
      (
        IFNULL(SUM(s.amount), 0)
        / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, NOW()), 1)
      ) * 12 * 0.001,
      2  -- round to 2 decimal places
    ) AS estimated_clv

FROM 
    users_customuser AS u

    -- Include all users, even those without savings transactions
    LEFT JOIN savings_savingsaccount AS s
      ON u.id = s.owner_id

GROUP BY
    u.id,
    u.first_name,
    u.last_name,
    u.date_joined

-- Rank from highest projected lifetime value down
ORDER BY
    estimated_clv DESC;
