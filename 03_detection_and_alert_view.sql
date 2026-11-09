-- Verified Day 7/10 rule logic, assembled into a MySQL view.
-- Prerequisites: 01_schema.sql and your actual synthetic customer/transaction data.
-- Rule thresholds are illustrative teaching rules, not regulatory requirements.
USE aml_project;

CREATE OR REPLACE VIEW vw_aml_alerts AS
WITH large_alerts AS (
    SELECT
        'AML-001' AS rule_code,
        customer_id,
        transaction_id,
        transaction_time AS alert_time,
        amount_eur AS flagged_amount_eur
    FROM aml_transactions_v2
    WHERE amount_eur > 40000
      AND direction = 'Outgoing'
),
outgoing_history AS (
    SELECT
        customer_id,
        transaction_id,
        transaction_time,
        amount_eur,
        LAG(transaction_time) OVER (
            PARTITION BY customer_id
            ORDER BY transaction_time, transaction_id
        ) AS previous_time
    FROM aml_transactions_v2
    WHERE direction = 'Outgoing'
      AND transaction_type = 'Transfer'
),
rapid_alerts AS (
    SELECT
        'AML-002' AS rule_code,
        customer_id,
        transaction_id,
        transaction_time AS alert_time,
        amount_eur AS flagged_amount_eur
    FROM outgoing_history
    WHERE TIMESTAMPDIFF(
        SECOND, previous_time, transaction_time
    ) BETWEEN 0 AND 600
),
cross_border_alerts AS (
    SELECT
        'AML-003' AS rule_code,
        t.customer_id,
        CAST(NULL AS SIGNED) AS transaction_id,
        MAX(t.transaction_time) AS alert_time,
        SUM(t.amount_eur) AS flagged_amount_eur
    FROM aml_transactions_v2 AS t
    INNER JOIN aml_customers_v2 AS c
        ON t.customer_id = c.customer_id
    WHERE t.direction = 'Outgoing'
      AND t.transaction_type = 'Transfer'
      AND t.counterparty_country IS NOT NULL
      AND t.counterparty_country <> c.home_country
    GROUP BY t.customer_id, t.counterparty_country
    HAVING COUNT(*) >= 5
)
SELECT * FROM large_alerts
UNION ALL
SELECT * FROM rapid_alerts
UNION ALL
SELECT * FROM cross_border_alerts;

-- Expected on the user's validated synthetic dataset: 3, 5, and 2 alert records.
SELECT rule_code, COUNT(*) AS total_alerts
FROM vw_aml_alerts
GROUP BY rule_code
ORDER BY rule_code;
