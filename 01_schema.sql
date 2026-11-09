-- AML/KYC training project: MySQL 8.x schema.
-- Uses synthetic data only. Safe to re-run: never drops an existing table.
CREATE DATABASE IF NOT EXISTS aml_project;
USE aml_project;

CREATE TABLE IF NOT EXISTS aml_customers_v2 (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_type VARCHAR(20) NOT NULL,
    home_country VARCHAR(50),
    occupation_sector VARCHAR(80),
    expected_monthly_volume_eur DECIMAL(14,2),
    kyc_status VARCHAR(20),
    customer_risk_rating VARCHAR(10),
    onboarding_date DATE
);

CREATE TABLE IF NOT EXISTS aml_transactions_v2 (
    transaction_id INT PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    transaction_time DATETIME NOT NULL,
    amount_eur DECIMAL(14,2) NOT NULL,
    transaction_type VARCHAR(30),
    direction VARCHAR(10),
    counterparty_country VARCHAR(50),
    channel VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES aml_customers_v2(customer_id)
);
