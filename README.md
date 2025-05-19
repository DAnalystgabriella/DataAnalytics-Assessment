## Cowrywise: Data Analyst Technical Assessment

This repository contains SQL queries addressing four core business scenarios, along with explanations of the approach and challenges encountered.

---

### 1. High-Value Customers with Multiple Products

**Objective:** Identify customers with at least one funded savings plan **and** one funded investment plan, sorted by total deposits.

**Approach:**

1. **Aggregate savings inflows:** Use `confirmed_amount` to sum deposits per customer and count funded savings accounts (`confirmed_amount > 0`).
2. **Aggregate investment plans:** Filter `plans_plan` by `is_a_fund = 1` to count active investment plans per customer.
3. **Join with users:** Inner join both aggregates to return customers satisfying both criteria, ordering by total deposit descending.

---

### 2. Transaction Frequency Analysis

**Objective:** Segment customers by their monthly transaction frequency over the past 12 months.

**Approach:**

1. **Monthly counts:** Group savings transactions by `owner_id` and month (`DATE_FORMAT(transaction_date, '%Y-%m')`), counting all transaction events (inflows and withdrawals).
2. **Average per customer:** Compute each user’s average transactions per month over the rolling 12‑month window.
3. **Categorization:** Bucket users into High (≥10), Medium (3–9), and Low (≤2) frequency groups and summarize counts and averages.

**Notes:**

* Both `confirmed_amount` and `amount_withdrawn` rows are included, since frequency concerns any transaction event.

---

### 3. Account Inactivity Alert

**Objective:** Flag active plans (savings or investment) with no inflow transactions in the last 365 days.

**Approach:**

1. **Active plans:** Filter `plans_plan` for `is_archived = 0` and `is_deleted = 0`, preserving flags for savings vs. investment.
2. **Last inflow date:** Use `confirmed_amount > 0` in `savings_savingsaccount` to find the most recent deposit per plan.
3. **Filter inactivity:** Compare the last inflow date against a cutoff (`DATE_SUB(CURDATE(), INTERVAL 365 DAY)`), including plans with `NULL` (never transacted).
4. **Classification:** Label each plan as "Savings" or "Investment" based on flags (`is_regular_savings` vs. `is_a_fund`).

---

### 4. Customer Lifetime Value (CLV) Estimation

**Objective:** Estimate each customer’s lifetime value based on average monthly transaction volume and a profit rate of 0.1% per transaction value.

**Approach:**

1. **Total volume:** Sum `confirmed_amount` per customer in `savings_savingsaccount`.
2. **Tenure calculation:** Compute months since `date_joined`, with a minimum of 1 month to avoid division by zero.
3. **CLV formula:** `CLV = (total_volume / tenure_months) * 12 * 0.001`, rounding to two decimals.
4. **Sorting:** Order customers by descending estimated CLV.

---
---
