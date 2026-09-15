-- Retained-account analysis:
-- the expansion multiplier is not explained by engagement features.

select
  corr(
    estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0),
    tenure_months
  ) as corr_tenure,
  corr(
    estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0),
    active_features_count
  ) as corr_features,
  corr(
    estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0),
    support_tickets_last_30d
  ) as corr_tickets,
  corr(
    estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0),
    days_since_last_login
  ) as corr_recency,
  corr(
    estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0),
    nps_score
  ) as corr_nps,
  count(*) as retained_accounts
from b2b_saas_churn_ltv
where churn_next_30d = 0;

-- Supporting proof of target leakage. Run separately.
select
  churn_next_30d,
  count(*) as accounts,
  min(estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0)) as min_ratio,
  max(estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0)) as max_ratio,
  stddev(
    estimated_ltv_usd::numeric / nullif(mrr_usd * tenure_months, 0)
  ) as ratio_stddev
from b2b_saas_churn_ltv
group by churn_next_30d;
