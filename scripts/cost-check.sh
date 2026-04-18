#!/usr/bin/env bash
set -euo pipefail

PROFILE="th"
BUDGET=100

START_DATE=$(date -u +"%Y-%m-01")
END_DATE=$(date -u +"%Y-%m-%d")

echo "==> AWS Cost for current month (${START_DATE} to ${END_DATE})"

COST=$(aws ce get-cost-and-usage \
  --time-period "Start=${START_DATE},End=${END_DATE}" \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --profile "${PROFILE}" \
  --output json 2>/dev/null)

AMOUNT=$(echo "${COST}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
total = sum(float(r['Total']['BlendedCost']['Amount']) for r in data['ResultsByTime'])
print(f'{total:.2f}')
")

echo "    Spent: \$${AMOUNT} / \$${BUDGET}"

REMAINING=$(python3 -c "print(f'{${BUDGET} - ${AMOUNT}:.2f}')")
echo "    Remaining: \$${REMAINING}"

if (( $(echo "${AMOUNT} > ${BUDGET} * 0.75" | bc -l) )); then
  echo "    WARNING: Over 75% of budget used!"
elif (( $(echo "${AMOUNT} > ${BUDGET} * 0.50" | bc -l) )); then
  echo "    CAUTION: Over 50% of budget used."
fi
