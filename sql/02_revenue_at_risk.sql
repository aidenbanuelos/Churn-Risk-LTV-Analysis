-- Revenue concentration across all accounts.
select
  subscription_plan,
  count(*) as accounts,
  sum(mrr_usd) as total_mrr,
  round(100.0 * count(*) / sum(count(*)) over (), 1) as pct_of_accounts,
  round(100.0 * sum(mrr_usd) / sum(sum(mrr_usd)) over (), 1) as pct_of_mrr
from b2b_saas_churn_ltv
group by subscription_plan
order by total_mrr desc;

-- MRR at risk from accounts churning this cycle.
select
  subscription_plan,
  count(*) as churning_accounts,
  sum(mrr_usd) as mrr_at_risk,
  round(
    100.0 * sum(mrr_usd)
    / (select sum(mrr_usd) from b2b_saas_churn_ltv),
    1
  ) as pct_of_total_mrr_at_risk
from b2b_saas_churn_ltv
where churn_next_30d = 1
group by subscription_plan
order by mrr_at_risk desc;
