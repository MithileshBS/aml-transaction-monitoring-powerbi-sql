# AML Transaction Monitoring & Customer Risk Analytics

**MySQL 8.0 | Power BI Desktop | DAX | Synthetic Banking Data**

A hands-on analytics project demonstrating a rule-based transaction monitoring workflow: generating synthetic banking activity, identifying potentially unusual patterns using SQL, organising investigation cases, assigning illustrative review priorities, and presenting results in Power BI.

> **Scope and disclaimer:** All customers and transactions in this project are fictional and synthetic. Detection thresholds, point weights and review-priority categories are illustrative learning choices, **not** regulatory standards or a production AML model. An alert is **not** evidence of money laundering, and the synthetic dataset cannot establish a real-world false-positive rate or detection accuracy.

## Project objectives

- Build and validate a relational dataset of customer KYC profiles and banking transactions.
- Detect three patterns of potentially unusual activity using MySQL 8.0 SQL.
- Combine monitoring outputs into a reusable SQL view (`vw_aml_alerts`).
- Calculate transparent, customer-level review-priority scores and compare transaction volume with expected monthly activity.
- Create interactive Power BI dashboards and document reconciliation checks.

## Tech stack

- **Database:** MySQL 8.0 / MySQL Workbench 8.0 CE
- **Analysis:** SQL (CTEs, `JOIN`, `GROUP BY`, `CASE`, `LAG`, `TIMESTAMPDIFF`, window functions)
- **Reporting:** Microsoft Power BI Desktop, Power Query, DAX
- **Version control and documentation:** GitHub and Markdown

## Validated dataset & monitoring results

| Metric | Validated result |
|---|---:|
| Fictional KYC customer profiles | 100 |
| Synthetic transactions | 2,000 |
| Customers with transaction activity | 100 |
| Total transaction value | €1,422,538.00 |
| Transfer transactions | 1,604 (€1,162,312.00) |
| Withdrawals | 198 (€132,826.00) |
| Cash deposits | 198 (€127,400.00) |
| AML alert records | 10 |
| Customers triggering alerts | 3 |
| Investigation case records | 3 |
| Defined data-quality audit checks passed | 6 of 6 |

### SQL detection rules

| Rule code | Training rule | Alert records |
|---|---|---:|
| `AML-001` | Outgoing transaction amount greater than €40,000 | 3 |
| `AML-002` | Outgoing transfers occurring within 600 seconds of the previous qualifying transfer by the same customer | 5 |
| `AML-003` | At least five outgoing transfers to the same country other than the customer's recorded home country | 2 grouped alerts |

The ten alert records are **not** ten unique suspicious transactions. Rule `AML-003` generates customer–country grouped results, while other rules generate individual transaction alerts. Different rules can reference overlapping activity.

## Customer investigation findings

| Customer | Existing KYC risk | Alert records | Review-priority score | October actual / expected monthly volume |
|---|---|---:|---:|---:|
| `C0088` | High | 1 | 45 | 1.40× |
| `C0007` | Low | 6 | 40 | 0.42× |
| `C0042` | Low | 3 | 30 | 13.25× |

- **C0042:** Highest activity-to-expected-volume ratio (13.25×); three large outgoing-transfer alerts with combined flagged transaction amount €175,000.
- **C0088:** Highest illustrative review-priority score (45), arising from the existing High KYC rating and a cross-border transfer-pattern flag.
- **C0007:** Five rapid-transaction alerts and one grouped cross-border alert; a relatively low total monthly volume does not by itself rule out noteworthy transaction-frequency patterns.

The priority model is deliberately explainable: baseline KYC points (Low 5 / Medium 15 / High 30; +10 for Pending verification) plus a **one-time per rule per customer** addition (AML-001 +25, AML-002 +20, AML-003 +15). Training priority bands are Low <30, Medium 30–49 and High ≥50. These priorities are for triage, not a statement of verified financial crime risk.

## Power BI report

The Power BI report contains three pages:

1. **AML Overview:** Customer/transaction/case KPI cards, transaction volume by type, incoming vs outgoing volume, and KYC risk distribution.
2. **Transaction Trends:** Daily transaction counts, customer-risk and transaction-direction slicers, a date-range slicer, alerts by rule, case-review status and customers with alerts.
3. **Customer Risk Analysis:** Component rule points, final review priorities, monthly activity-to-expected-volume ratios, conditional formatting and explanatory findings.

### Dashboard previews

**AML Overview** — transaction KPIs, volume breakdowns and KYC-risk distribution.

![AML Overview dashboard](screenshots/01_aml_overview.png)

**Transaction Trends** — daily trends, detection-rule counts and case monitoring.

![Transaction Trends dashboard](screenshots/02_transaction_trends.png)

**Customer Risk Analysis** — investigation priorities and activity-versus-expected-volume analysis.

![Customer Risk Analysis dashboard](screenshots/03_customer_risk_analysis.png)

[Open the Power BI report](powerbi/AML_Transaction_Monitoring_Dashboard.pbix) to explore the interactive version. The images are derived from screenshots taken during project development; they are not live report embeds.

## Repository structure

```text
aml-transaction-monitoring-portfolio/
├── README.md
├── .gitignore
├── sql/
│   ├── 01_schema.sql
│   ├── 02_synthetic_data.sql
│   ├── 03_detection_and_alert_view.sql
│   ├── 04_case_reviews.sql
│   └── 05_validation.sql
├── powerbi/
│   └── AML_Transaction_Monitoring_Dashboard.pbix
├── screenshots/
│   ├── 01_aml_overview.png
│   ├── 02_transaction_trends.png
│   └── 03_customer_risk_analysis.png
└── docs/
    └── validation_summary.md
```

**Repository files:** This version contains the original synthetic customer and transaction records exported from the local MySQL database and converted to `02_synthetic_data.sql`, the SQL logic and validation queries, the Power BI `.pbix` report, dashboard screenshots, and a validation summary. The original Day 6 data-generation algorithms are not included; instead, a snapshot of the synthetic rows is supplied.

## How to reproduce

1. Install MySQL Server 8.x and MySQL Workbench, and connect to your own local MySQL instance.
2. On a **new, empty** `aml_project` database, run the scripts in this order:
   1. `sql/01_schema.sql` — create database and the customers/transactions tables.
   2. `sql/02_synthetic_data.sql` — load the 100 customers and 2,000 transactions.
   3. `sql/03_detection_and_alert_view.sql` — create the alert view.
   4. `sql/04_case_reviews.sql` — create the case-review table and example cases.
   5. `sql/05_validation.sql` — calculate control totals and run audit checks.
3. Open [`powerbi/AML_Transaction_Monitoring_Dashboard.pbix`](powerbi/AML_Transaction_Monitoring_Dashboard.pbix) in Power BI Desktop. To refresh the imported tables, update the MySQL connection settings to point to your local server and use your own credentials.
4. Check the results against [`docs/validation_summary.md`](docs/validation_summary.md) and the screenshot previews above.

**Important:** Do not run the data-insertion script against already-populated tables because duplicate-key errors can occur. The SQL and report have been assembled with the validated project data, but a clean-machine, end-to-end rebuild has **not been independently tested**. Do not publish passwords, connection secrets or real customer data.

## Validation and limitations

- Reconciled 2,000 transaction records and €1,422,538 total volume between MySQL and Power BI.
- Reconciled all rule-level alert counts (3 + 5 + 2 = 10), customer-level alert totals (6 + 3 + 1 = 10), customer scores (45, 40, 30) and October actual/expected volume ratios.
- Passed six specified quality checks covering duplicate transaction IDs, non-positive/missing amounts, missing timestamps, unmatched customer references and unexpected case-review statuses.
- Primary-key duplicate checks do not detect two different transaction IDs representing the same real-world event. Foreign-country comparison uses the recorded customer home country as a simplified proxy. No independently verified labels or investigation evidence were supplied, so alert precision, recall and false-positive rate cannot be estimated.
- Customer case-review records were created for demonstration and do not represent live compliance investigations.

See [`docs/validation_summary.md`](docs/validation_summary.md) for the validated control totals and scope.

## Portfolio skills demonstrated

SQL analytics · database design and validation · AML/KYC domain concepts · rule-based monitoring · window functions · DAX measures and calculated columns · Power Query · Power BI data modelling · dashboard design · data reconciliation · technical documentation.
