-- Churn rate by days since last login.
-- Strongest single predictor of churn in the dataset.

select
  case
    when days_since_last_login <= 7 then '0-7 days'
    when days_since_last_login <= 14 then '8-14 days'
    when days_since_last_login <= 30 then '15-30 days'
    else '30+ days'
  end as login_recency_bucket,
  count(*) as total_accounts,
  sum(churn_next_30d) as churned_accounts,
  round(100.0 * sum(churn_next_30d) / count(*), 2) as churn_rate_pct
from b2b_saas_churn_ltv
group by 1
order by min(days_since_last_login);
