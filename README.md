# B2B SaaS Churn Risk & Customer Lifetime Value Analysis

SQL analysis of churn risk, revenue at risk, and customer lifetime value (CLV) for a B2B SaaS account dataset.

## Overview

This project analyzes 3,000 SaaS accounts with MRR, subscription tier, tenure, engagement signals, NPS, estimated LTV, and a 30-day churn outcome. The source table is hosted in Supabase/Postgres as `b2b_saas_churn_ltv`.

The analysis is designed to answer four practical questions:

1. Which behavioral signal best identifies near-term churn risk?
2. Which plan tiers account for a disproportionate share of MRR at risk?
3. Is elevated tier-level churn concentrated among new or long-tenured accounts?
4. Does customer engagement explain projected expansion in LTV?

## Key findings

- **Login recency is the strongest single churn signal.** Churn rises as the number of days since the last login increases.
- **Revenue risk is concentrated by plan tier.** Comparing account share, total MRR share, and MRR-at-risk share identifies tiers that are over-indexed on risk.
- **Tier × tenure analysis separates onboarding risk from long-term retention risk.** The included crosstab applies a minimum cell-size threshold of 20 accounts.
- **NPS is not predictive in this dataset.** Its correlation with churn is approximately 0.007 and the score buckets are non-monotonic.
- **Estimated LTV contains target leakage.** For all churned accounts, `Estimated_LTV_USD = MRR_USD * Tenure_Months`. LTV is therefore not modeled as an independent target across the full dataset.
- **Expansion is analyzed only among retained accounts.** The retained-account analysis tests whether the expansion multiplier is explained by engagement features.

## Dataset

- 3,000 accounts across Starter ($49/month), Professional ($199/month), and Enterprise ($999/month)
- 368 churned accounts; overall churn rate: 12.27%
- `NPS_Score` has 592 null values (19.7% of rows)
- Synthetic/Kaggle-style benchmark data; the dataset is not included in this repository

Expected columns:

```text
subscription_plan
mrr_usd
tenure_months
days_since_last_login
active_features_count
support_tickets_last_30d
nps_score
estimated_ltv_usd
churn_next_30d
```

## SQL workflow

| File | Purpose |
| --- | --- |
| [`sql/01_churn_by_login_recency.sql`](sql/01_churn_by_login_recency.sql) | Churn rate by days since last login |
| [`sql/02_revenue_at_risk.sql`](sql/02_revenue_at_risk.sql) | Total revenue concentration and MRR at risk by tier |
| [`sql/03_churn_tier_x_tenure.sql`](sql/03_churn_tier_x_tenure.sql) | Churn rate by plan tier and tenure bucket |
| [`sql/04_ltv_expansion_multiplier_check.sql`](sql/04_ltv_expansion_multiplier_check.sql) | Retained-account expansion analysis and leakage validation |

Run the queries in Supabase SQL Editor or any compatible PostgreSQL client after loading the source table.

## Methodology notes

- Churn is an imbalanced outcome, so predictive modeling should report PR-AUC alongside ROC-AUC and compare PR-AUC with the 12.27% base-rate baseline.
- Crosstab cells with fewer than 20 accounts are excluded from reported rates to avoid unstable estimates.
- For modeling, impute `NPS_Score` with the training-set median and add a missingness indicator.
- Do not use `estimated_ltv_usd` as a churn-model feature or as a full-dataset regression target because it encodes the churn outcome.

## Stack

Supabase, PostgreSQL, and SQL.

## Repository structure

```text
.
├── README.md
└── sql/
    ├── 01_churn_by_login_recency.sql
    ├── 02_revenue_at_risk.sql
    ├── 03_churn_tier_x_tenure.sql
    └── 04_ltv_expansion_multiplier_check.sql
```
