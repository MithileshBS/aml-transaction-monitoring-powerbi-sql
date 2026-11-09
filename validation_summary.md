# Data validation summary

**Dataset:** synthetic banking activity; MySQL `aml_project`.

## Reconciled totals

| Metric | Value |
|---|---:|
| Customers | 100 |
| Transactions | 2,000 |
| Active customers | 100 |
| Transaction volume | €1,422,538.00 |
| Transfer (count / volume) | 1,604 / €1,162,312.00 |
| Withdrawal (count / volume) | 198 / €132,826.00 |
| Cash Deposit (count / volume) | 198 / €127,400.00 |
| AML alert records | 10 |
| Cases under review / pending | 1 / 2 |

## Monitoring alert counts

| Rule | Customer | Alert count | Flagged amount (not unique funds) |
|---|---|---:|---:|
| AML-001 | C0042 | 3 | €175,000.00 |
| AML-002 | C0007 | 5 | €2,400.00 |
| AML-003 | C0007 | 1 grouped alert | €3,528.00 |
| AML-003 | C0088 | 1 grouped alert | €5,874.00 |

## Scoring reconciliation

| Customer | Baseline | AML-001 | AML-002 | AML-003 | Final | Expected October / Actual October | Actual/Expected |
|---|---:|---:|---:|---:|---:|---|---:|
| C0088 | 30 | 0 | 0 | 15 | 45 | €9,000 / €12,600 | 1.40× |
| C0007 | 5 | 0 | 20 | 15 | 40 | €26,500 / €11,260 | 0.42× |
| C0042 | 5 | 25 | 0 | 0 | 30 | €14,000 / €185,548 | 13.25× |

## Data-quality checks (6 of 6 passed; zero issues)

1. Duplicate transaction IDs.
2. Missing or non-positive transaction amounts.
3. Missing transaction timestamps.
4. Transactions with unmatched customers.
5. AML alerts with unmatched customers.
6. Unexpected case-review statuses.

## Limitations

This is synthetic test data. Rule weights, thresholds and scenarios were designed for learning. Neither a compliance conclusion nor a quantitative real-world detection performance claim can be derived from these checks. All tables and results should be treated as demonstration material, not as evidence of actual suspicious transactions.
