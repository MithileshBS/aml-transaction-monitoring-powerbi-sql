-- Day 13 validation queries. Run after loading data, creating the alert view,
-- and creating the case-review table. Counts below describe the user's dataset.
USE aml_project;

-- 1. Control totals
SELECT
    (SELECT COUNT(*) FROM aml_customers_v2) AS customers,
    (SELECT COUNT(*) FROM aml_transactions_v2) AS transactions,
    (SELECT COUNT(*) FROM vw_aml_alerts) AS alerts,
    (SELECT COUNT(*) FROM aml_case_reviews_v2) AS cases;
-- Expected: 100, 2000, 10, 3

-- 2. Transaction-value reconciliation
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(SUM(amount_eur), 2) AS total_volume_eur
FROM aml_transactions_v2;
-- Expected: 2000, 100, 1422538.00

SELECT transaction_type,
       COUNT(*) AS transaction_count,
       ROUND(SUM(amount_eur), 2) AS total_volume_eur
FROM aml_transactions_v2
GROUP BY transaction_type
ORDER BY total_volume_eur DESC;
-- Expected: Transfer 1604 / 1162312.00; Withdrawal 198 / 132826.00;
-- Cash Deposit 198 / 127400.00

-- 3. Rule-level and customer-level alert counts
SELECT rule_code, customer_id, COUNT(*) AS alert_count,
       ROUND(SUM(flagged_amount_eur), 2) AS flagged_amount_eur
FROM vw_aml_alerts
GROUP BY rule_code, customer_id
ORDER BY rule_code, customer_id;
-- Expected: AML-001/C0042=3; AML-002/C0007=5;
-- AML-003/C0007=1; AML-003/C0088=1

-- 4. Reconcile customer scoring (one set of rule points per customer)
WITH customer_scores AS (
    SELECT
        c.customer_id,
        CASE c.customer_risk_rating
            WHEN 'High' THEN 30
            WHEN 'Medium' THEN 15
            WHEN 'Low' THEN 5
            ELSE 0
        END + CASE WHEN c.kyc_status = 'Pending' THEN 10 ELSE 0 END
            AS baseline_points,
        25 * MAX(CASE WHEN a.rule_code = 'AML-001' THEN 1 ELSE 0 END)
            AS aml_001_points,
        20 * MAX(CASE WHEN a.rule_code = 'AML-002' THEN 1 ELSE 0 END)
            AS aml_002_points,
        15 * MAX(CASE WHEN a.rule_code = 'AML-003' THEN 1 ELSE 0 END)
            AS aml_003_points
    FROM aml_customers_v2 AS c
    INNER JOIN vw_aml_alerts AS a ON c.customer_id = a.customer_id
    GROUP BY c.customer_id, c.customer_risk_rating, c.kyc_status
)
SELECT *,
       baseline_points + aml_001_points + aml_002_points + aml_003_points
           AS final_priority_score
FROM customer_scores
ORDER BY final_priority_score DESC;
-- Expected: C0088 45; C0007 40; C0042 30

-- 5. Actual October volume vs. expected volume
SELECT c.customer_id, c.expected_monthly_volume_eur,
       ROUND(SUM(t.amount_eur), 2) AS actual_october_volume_eur,
       ROUND(SUM(t.amount_eur) /
             NULLIF(c.expected_monthly_volume_eur, 0), 2) AS volume_ratio
FROM aml_customers_v2 AS c
INNER JOIN aml_transactions_v2 AS t ON c.customer_id = t.customer_id
WHERE c.customer_id IN ('C0007', 'C0042', 'C0088')
  AND t.transaction_time >= '2026-10-01'
  AND t.transaction_time < '2026-11-01'
GROUP BY c.customer_id, c.expected_monthly_volume_eur
ORDER BY volume_ratio DESC;
-- Expected: C0042 185548.00 / 13.25; C0088 12600.00 / 1.40;
-- C0007 11260.00 / 0.42

-- 6. Six data-quality checks (all expected 0)
SELECT 'Duplicate Transaction IDs' AS check_name,
       COUNT(*) - COUNT(DISTINCT transaction_id) AS issues
FROM aml_transactions_v2
UNION ALL
SELECT 'Invalid Transaction Amounts', COUNT(*)
FROM aml_transactions_v2 WHERE amount_eur IS NULL OR amount_eur <= 0
UNION ALL
SELECT 'Missing Transaction Timestamps', COUNT(*)
FROM aml_transactions_v2 WHERE transaction_time IS NULL
UNION ALL
SELECT 'Unmatched Transaction Customers', COUNT(*)
FROM aml_transactions_v2 t
LEFT JOIN aml_customers_v2 c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Unmatched AML Alert Customers', COUNT(*)
FROM vw_aml_alerts a
LEFT JOIN aml_customers_v2 c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Invalid Case Review Statuses', COUNT(*)
FROM aml_case_reviews_v2
WHERE review_status NOT IN (
    'Pending Review', 'Under Review', 'Explained - Legitimate', 'Escalated'
);
