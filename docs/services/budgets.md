# AWS Budgets

## What It Is

Cost management tool that lets you set custom budgets and receive alerts when costs or usage exceed thresholds. Integrates with SNS for notifications and supports automated actions (stop EC2, apply SCPs).

## What We Deployed

```
Budget:     monthly-account-budget
Type:       COST
Limit:      $100/month
Alerts at:  25%, 50%, 75%, 100% of actual spend
SNS Topic:  arn:aws:sns:us-east-1:<ACCOUNT_ID>:budget-alerts
Email:      <YOUR_EMAIL>
```

**Why:**
- Safety net for the $100 credits — get early warnings before overspending
- Good practice: always set budget alarms before deploying infrastructure
- SNS allows extending to Slack, Lambda, or other targets later

## Budget Types

| Type | What It Tracks |
|------|---------------|
| **Cost** (what we use) | Dollar spend against a limit |
| **Usage** | Service usage (hours, GB, requests) against a limit |
| **Savings Plans** | Utilization or coverage of Savings Plans |
| **Reservation** | Utilization or coverage of Reserved Instances |

## Alert Types

| Type | When It Fires |
|------|--------------|
| **Actual** (what we use) | When actual spend crosses the threshold |
| **Forecasted** | When AWS predicts you'll exceed the threshold by end of period |

We use `ACTUAL` — fires when real spend hits each threshold. For production, you'd add `FORECASTED` alerts too.

## Budget Actions (Advanced)

Budgets can trigger automated responses:

| Action | What It Does |
|--------|-------------|
| Apply IAM policy | Restrict permissions when budget exceeded |
| Apply SCP | Organization-level restriction |
| Stop EC2 instances | Target specific instances by tag |

**SAA-Pro scenario:** "How to automatically prevent overspend?" → Budget action that applies a deny SCP when 90% threshold is hit.

## Cost

- First 2 budgets: **free**
- Additional budgets: $0.02/day each
- Budget actions: $0.10/day per action-enabled budget

We use 1 budget → **$0/month**.

## SAA-Pro Exam Tips

- Budgets vs Cost Explorer: Budgets is for alerts/actions, Cost Explorer is for analysis/visualization
- Budgets can apply SCPs via budget actions — powerful for org-level cost governance
- Forecasted alerts use ML to predict end-of-period spend
- Cost Anomaly Detection is a separate service for unexpected spikes (complements Budgets)
- Budgets updates ~3x/day (not real-time) — there can be a delay of up to 24 hours
