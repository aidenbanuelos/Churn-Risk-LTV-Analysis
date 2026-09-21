# B2B SaaS Churn Risk & LTV Analysis

For this project I looked at a B2B SaaS dataset (3,000 accounts) to figure out what's actually driving churn and how much revenue is at risk because of it. All the analysis is SQL against a Supabase (Postgres) database.

## The Data

- Dataset: a B2B SaaS churn/LTV dataset I found (synthetic, not real company data)
- 3,000 accounts across three plans: Starter ($49/mo), Professional ($199/mo), Enterprise ($999/mo)
- Overall churn rate: 12.27% (368 out of 3,000 accounts churned)
- `NPS_Score` is missing for about 20% of accounts (592 nulls)
- I loaded it into Supabase as a table called `b2b_saas_churn_ltv`

## A problem I found in the data (and why I'm calling it out instead of hiding it)

Before I started building anything, I checked whether the columns actually meant what they said, and I found something important: `Estimated_LTV_USD` isn't really an independent number. For every single account that churned, LTV = MRR × Tenure_Months, exactly, no exceptions. For accounts that didn't churn, LTV is that same formula times some extra multiplier that doesn't seem tied to anything meaningful, like feature usage or support tickets, it's basically random.

Basically what that means: if I'd just thrown `Estimated_LTV_USD` into a regression model, I'd either be re-deriving a formula the dataset creator used (not a real insight) or accidentally leaking the churn answer into my LTV predictions. So instead of ignoring this, here's what I did:

- I'm not treating LTV as something to predict for the whole dataset.
- Where I do look at LTV, I only look at retained (non-churned) accounts, and I'm looking at the "extra multiplier" part instead of raw LTV.
- The fact that this multiplier isn't explained by any behavior data is actually one of my findings, not just a technical footnote. See `sql/04_ltv_expansion_multiplier_check.sql`.

I think catching this before building on top of it matters more than the modeling itself, honestly.

## What I Found

1. **How recently someone logged in is the biggest churn signal.** Out of everything I checked, days since last login had the strongest relationship with churn (r = 0.39, everything else was way weaker). I bucketed it into ranges to see where churn risk actually jumps — see `sql/01_churn_by_login_recency.sql`.
2. **Revenue at risk isn't spread out evenly.** I compared how much of the total accounts vs. how much of the total MRR each plan tier represents, then compared that to how much MRR is walking out the door from churning accounts. See `sql/02_revenue_at_risk.sql`.
3. **Enterprise churns more, but I still need to figure out why.** I built a crosstab of plan tier x tenure to see if Enterprise churn is mostly new accounts (onboarding issue) or accounts that have been around a while (long-term retention issue). [I haven't filled this part in yet — need to actually run `sql/03_churn_tier_x_tenure.sql` and look at the result before I can say which one it is.]
4. **NPS doesn't actually predict churn here**, even though you'd expect it to. The correlation was basically zero (0.007) and didn't even move in a consistent direction across score buckets. I'm including this because I think it's more honest to show a finding that didn't confirm my assumption than to just leave it out.
5. **The LTV "extra multiplier" isn't explained by anything I measured.** Tenure has some relationship to it, but engagement stuff (features used, tickets, login recency) basically doesn't. Details in the leakage section above.

## Some Notes on How I Did This

- Since only 12.27% of accounts churned, I know I can't just look at raw accuracy if I build a classifier later — I'd want to use PR-AUC and compare it against the baseline rate, not just ROC-AUC.
- For the tier x tenure crosstab, I only trust groups with at least 20 accounts in them. Anything smaller and the churn rate percentage doesn't really mean anything (like if 1 out of 3 accounts churned, that's not a real "33% churn rate").
- For the missing NPS values, I'm filling them with the median instead of anything fancier, since NPS barely correlates with churn anyway — didn't seem worth the extra complexity.

## Repo Structure

```
sql/
  01_churn_by_login_recency.sql
  02_revenue_at_risk.sql
  03_churn_tier_x_tenure.sql
  04_ltv_expansion_multiplier_check.sql
README.md
```

## Tools I Used

Supabase (Postgres), SQL 
