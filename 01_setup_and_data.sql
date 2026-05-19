----------------------------------------------------------------------
-- Cortex Agent Hands-On Lab: Setup & Sample Data
-- Run this entire file in a SQL Worksheet (Snowsight > + > SQL Worksheet)
----------------------------------------------------------------------

-- 1. Use ACCOUNTADMIN to set up account-level settings and create the role
USE ROLE ACCOUNTADMIN;

-- 2. Enable cross-region inference (required for Cortex AI model access)
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

-- 3. Create custom role and grant it to current user
CREATE ROLE IF NOT EXISTS SANOFI_AGENT;
GRANT ROLE SANOFI_AGENT TO USER <YOUR USERNAME>;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SANOFI_AGENT;

-- 4. Grant the role permissions to create objects
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SANOFI_AGENT;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE SANOFI_AGENT;
GRANT ALL ON DATABASE CORTEX_AGENT_LAB TO ROLE SANOFI_AGENT;
GRANT ALL ON ALL SCHEMAS IN DATABASE CORTEX_AGENT_LAB TO ROLE SANOFI_AGENT;

-- 5. Switch to the custom role for all object creation
USE ROLE SANOFI_AGENT;

-- 6. Create dedicated warehouse
CREATE WAREHOUSE IF NOT EXISTS CORTEX_AGENT_LAB_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE CORTEX_AGENT_LAB_WH;

-- 7. Create database and schema
CREATE DATABASE IF NOT EXISTS CORTEX_AGENT_LAB;
USE DATABASE CORTEX_AGENT_LAB;

CREATE SCHEMA IF NOT EXISTS TUTORIAL;
USE SCHEMA TUTORIAL;

GRANT CREATE AGENT ON SCHEMA CORTEX_AGENT_LAB.TUTORIAL TO ROLE SANOFI_AGENT;

-- 8. Verify Cortex AI access
SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-sonnet-4-5', 'Say hello in one word');

----------------------------------------------------------------------
-- SAMPLE DATA: Products Table (dimension table)
----------------------------------------------------------------------
CREATE OR REPLACE TABLE products (
    product_id NUMBER,
    product_name VARCHAR,
    therapeutic_area VARCHAR,
    formulation VARCHAR,
    approval_year NUMBER,
    manufacturer VARCHAR
);

INSERT INTO products VALUES
    (1, 'Dupixent', 'Immunology', 'Injectable', 2017, 'Sanofi / Regeneron'),
    (2, 'Kevzara', 'Immunology', 'Injectable', 2017, 'Sanofi / Regeneron'),
    (3, 'Aubagio', 'Neurology', 'Oral', 2012, 'Sanofi'),
    (4, 'Lantus', 'Diabetes', 'Injectable', 2000, 'Sanofi'),
    (5, 'Toujeo', 'Diabetes', 'Injectable', 2015, 'Sanofi'),
    (6, 'Praluent', 'Cardiovascular', 'Injectable', 2015, 'Sanofi / Regeneron'),
    (7, 'Multaq', 'Cardiovascular', 'Oral', 2009, 'Sanofi'),
    (8, 'Admelog', 'Diabetes', 'Injectable', 2017, 'Sanofi');

----------------------------------------------------------------------
-- SAMPLE DATA: Sales Table (fact table)
----------------------------------------------------------------------
CREATE OR REPLACE TABLE sales (
    sale_id NUMBER AUTOINCREMENT,
    sale_date DATE,
    product_id NUMBER,
    region VARCHAR,
    channel VARCHAR,
    units_sold NUMBER,
    revenue_usd NUMBER(12,2)
);

INSERT INTO sales (sale_date, product_id, region, channel, units_sold, revenue_usd)
VALUES
    ('2024-01-10', 1, 'North America', 'Specialty Pharmacy', 1200, 4800000.00),
    ('2024-01-12', 1, 'Europe', 'Hospital', 800, 3040000.00),
    ('2024-01-15', 2, 'North America', 'Specialty Pharmacy', 300, 750000.00),
    ('2024-01-18', 4, 'North America', 'Retail Pharmacy', 5000, 1500000.00),
    ('2024-01-20', 4, 'Asia Pacific', 'Retail Pharmacy', 3500, 980000.00),
    ('2024-01-25', 5, 'Europe', 'Hospital', 2000, 1200000.00),
    ('2024-02-01', 1, 'North America', 'Specialty Pharmacy', 1350, 5400000.00),
    ('2024-02-05', 3, 'North America', 'Retail Pharmacy', 900, 2700000.00),
    ('2024-02-10', 6, 'Europe', 'Specialty Pharmacy', 450, 1350000.00),
    ('2024-02-15', 1, 'Asia Pacific', 'Hospital', 600, 2280000.00),
    ('2024-02-20', 7, 'North America', 'Retail Pharmacy', 1500, 900000.00),
    ('2024-02-25', 4, 'Europe', 'Retail Pharmacy', 4200, 1260000.00),
    ('2024-03-01', 1, 'Europe', 'Specialty Pharmacy', 950, 3800000.00),
    ('2024-03-05', 8, 'North America', 'Retail Pharmacy', 2800, 840000.00),
    ('2024-03-10', 5, 'North America', 'Hospital', 1800, 1080000.00),
    ('2024-03-15', 2, 'Europe', 'Hospital', 400, 1000000.00),
    ('2024-03-20', 3, 'Europe', 'Retail Pharmacy', 700, 2100000.00),
    ('2024-03-25', 6, 'North America', 'Specialty Pharmacy', 500, 1500000.00);

----------------------------------------------------------------------
-- VERIFY: Confirm all tables loaded correctly
----------------------------------------------------------------------
SELECT 'products' AS table_name, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'sales', COUNT(*) FROM sales;
