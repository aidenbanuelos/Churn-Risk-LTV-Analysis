-- Churn rate by plan tier and tenure bucket.
-- Cells with fewer than 20 accounts are excluded from the reported crosstab.

select
  subscription_plan,
  case
    when tenure_months <= 3 then '0-3 months'
    when tenure_months <= 12 then '4-12 months'
    when tenure_months <= 24 then '13-24 months'
    else '24+ months'
  end as tenure_bucket,
  count(*) as total_accounts,
  sum(churn_next_30d) as churned_accounts,
  round(100.0 * sum(churn_next_30d) / count(*), 2) as churn_rate_pct
from b2b_saas_churn_ltv
group by 1, 2
having count(*) >= 20
order by subscription_plan, min(tenure_months);
