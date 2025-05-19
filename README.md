# 📊 Cowrywise: Data Analyst Technical Assessment

This repository contains SQL queries that analyze customer behavior and product engagement. Each query addresses a key business scenario using a well-defined schema and optimized logic.

---

## 1. 🏦 High-Value Customers with Multiple Products

**Objective**: Identify customers who have both funded savings accounts and active investment plans, ranked by total deposits.

**Highlights**:
- Uses `confirmed_amount > 0` to ensure actual savings inflows.
- Filters plans where `is_a_fund = 1` to get investment plan.
- Returns full name, count of savings/investment products, and total deposits.
- Sorted by descending total deposit.

---

## 2. 🔁 12-Month Transaction Frequency Analysis

**Objective**: Categorize users based on their average monthly transaction activity over the past year.

**Method**:
- Dynamically generates the last 12 months using a recursive CTE.
- Cross joins users with months to ensure 0-activity months are included.
- Aggregates monthly transaction counts (savings inflows and withdrawals).
- Buckets users as:
  - **High Frequency**: ≥10 transactions/month
  - **Medium Frequency**: 3–9 transactions/month
  - **Low Frequency**: <3 transactions/month

**Output**: Frequency category, user count per bucket, and average transactions per user.

---

## 3. ⛔ Account Inactivity Alert (No Inflows in 12 Months)

**Objective**: Flag savings and investment plans with no inflow in the past 365 days.

**Logic**:
- Filters for active (non-archived, non-deleted) plans.
- Finds the most recent `confirmed_amount > 0` per plan.
- Returns plans with no deposit activity since cutoff or never funded.

**Output**: Plan ID, owner, type (Savings/Investment), last inflow date, and inactivity duration (days).

---

## 4. 💰 Customer Lifetime Value (CLV) Estimation

**Objective**: Estimate lifetime value based on average monthly deposit volume and a 0.1% margin.

**Formula**:
*CLV = (Total Deposits / Tenure in Months) × 12 × 0.001*

**Assumptions**:
- Only `confirmed_amount` used to measure actual inflows.
- Tenure is at least 1 month (using `GREATEST(..., 1)`) to avoid division by zero.

**Output**: Customer ID, name, tenure (months), total inflows, and estimated CLV (2 decimal precision), sorted descending.

---

## ✅ Schema Notes & Clarifications

- **Savings inflows**: Tracked via `savings_savingsaccount.confirmed_amount`.
- **Withdrawals**: Excluded unless analyzing frequency.
- **Plan types**:
  - `is_a_fund = 1`: Investment plan
  - `is_regular_savings = 1`: Savings plan
- **Null handling**: All averages safely zero-filled to avoid skew.

---

## 📁 Folder Structure

```bash
DataAnalytics-Assessment/
├── 01_high_value_customers.sql
├── 02_transaction_frequency.sql
├── 03_inactive_plans.sql
└── 04_customer_lifetime_value.sql

