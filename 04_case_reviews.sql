-- Educational case-management records. No real investigation outcomes.
-- Prerequisite: 01_schema.sql and synthetic customer rows loaded.
USE aml_project;

CREATE TABLE IF NOT EXISTS aml_case_reviews_v2 (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    rule_code VARCHAR(10) NOT NULL,
    review_status VARCHAR(30) NOT NULL DEFAULT 'Pending Review',
    review_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_customer_rule (customer_id, rule_code),
    FOREIGN KEY (customer_id) REFERENCES aml_customers_v2(customer_id)
);

-- Initial demonstration outcomes. Re-running leaves existing cases untouched.
INSERT INTO aml_case_reviews_v2
    (customer_id, rule_code, review_status, review_notes)
VALUES
    ('C0042', 'AML-001', 'Under Review',
     'Three large outgoing transfers detected; supporting documentation not verified.'),
    ('C0007', 'AML-002', 'Pending Review',
     'Rapid outgoing transaction pattern detected.'),
    ('C0088', 'AML-003', 'Pending Review',
     'Repeated cross-border transfer pattern detected.')
ON DUPLICATE KEY UPDATE case_id = case_id;

SELECT rule_code, review_status, COUNT(*) AS case_count
FROM aml_case_reviews_v2
GROUP BY rule_code, review_status
ORDER BY rule_code;
