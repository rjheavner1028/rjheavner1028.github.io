-- ============================================================
--This script can be ran over and over once the DB has been created and will re-create all data after clearing all data
-- ============================================================


-- ============================================================
-- Fully Functional Database for Sales and Returns
--
-- This schema is designed to manage product inventory, sales,
-- customer data, and product returns. It includes full referential 
-- integrity using PRIMARY and FOREIGN KEY constraints, and leverages 
-- ON DELETE CASCADE rules to ensure related records are properly 
-- maintained or removed across tables.
--
-- TABLE STRUCTURE & RELATIONSHIPS:
--
--  products
--   - Stores individual product details, including SKU, name, type, and price.
--   - Primary Key: product_id
--   - Referenced by: sales (via product_id)
--
--  customers
--   - Contains customer data including name, state, and email.
--   - Primary Key: customer_id
--   - Referenced by: sales (via customer_id)
--
--  sales
--   - Represents a sale transaction including product, customer, date, quantity, and total price.
--   - Primary Key: sale_id
--   - Foreign Keys:
--     -- product_id → products(product_id) ON DELETE CASCADE
--     -- customer_id → customers(customer_id) ON DELETE CASCADE
--   - Deleting a product or customer automatically deletes related sales.
--
--  returns
--   - Tracks returns of sold products, including reason, date, and refund amount.
--   - Primary Key: return_id
--   - Foreign Key:
--     -- sale_id → sales(sale_id) ON DELETE CASCADE
--   - Deleting a sale automatically deletes related return records.
--
-- INDEXING:
--   - Indexes are added to foreign key columns to optimize joins and performance:
--     -- sales(product_id), sales(customer_id)
--     -- returns(sale_id)
--     -- products(sku), customers(email)
--
-- STORED PROCEDURES (Known as Functions in PG):
--   - get_return_rate(): Calculates return rate per SKU
--   - get_returns_by_state(): Counts total returns per customer state
--
-- ============================================================

-- ============================================================
-- Clean Slate: Drop All Objects If They Already Exist
-- Ensures the script can be re-run without conflict
-- ============================================================
-- Drop Triggers
DROP TRIGGER IF EXISTS trg_log_return_insert ON returns;

-- Drop Functions
DROP FUNCTION IF EXISTS get_return_rate() CASCADE;
DROP FUNCTION IF EXISTS get_returns_by_state() CASCADE;
DROP FUNCTION IF EXISTS log_return_insert() CASCADE;

-- Drop Views
DROP VIEW IF EXISTS sales_summary CASCADE;
DROP VIEW IF EXISTS return_summary CASCADE;

-- Drop Materialized Views
DROP MATERIALIZED VIEW IF EXISTS mv_return_summary CASCADE;

-- Drop Indexes
DROP INDEX IF EXISTS idx_sales_product_id;
DROP INDEX IF EXISTS idx_sales_customer_id;
DROP INDEX IF EXISTS idx_returns_sale_id;
DROP INDEX IF EXISTS idx_customers_email;
DROP INDEX IF EXISTS idx_products_sku;

-- Drop Tables (in dependency order)
DROP TABLE IF EXISTS return_log CASCADE;
DROP TABLE IF EXISTS returns CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;



-- ============================================================
-- Create the Products Table with Correct SKUs
-- ============================================================
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(20) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_type VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);


-- ============================================================
-- Insert Sample Data for Products (Using Provided SKUs)
-- ============================================================
INSERT INTO products (sku, product_name, product_type, price) VALUES
    ('ADV-24-10C', 'Advanced 24-inch 10C', 'Electronics', 299.99),
    ('ADV-48-10F', 'Advanced 48-inch 10F', 'Electronics', 499.99),
    ('BAS-08-1C', 'Basic 8-inch 1C', 'Electronics', 199.99),
    ('BAS-24-1C', 'Basic 24-inch 1C', 'Electronics', 99.99),
    ('BAS-48-1C', 'Basic 48-inch 1C', 'Electronics', 399.99),
    ('ENT-24-10F', 'Enterprise 24-inch 10F', 'Furniture', 549.99),
    ('ENT-24-40F', 'Enterprise 24-inch 40F', 'Furniture', 449.99),
    ('ENT-48-10F', 'Enterprise 48-inch 10F', 'Furniture', 649.99),
    ('ENT-48-40F', 'Enterprise 48-inch 40F', 'Furniture', 749.99);


-- ============================================================
-- Create the Customers Table
-- ============================================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    state CHAR(2) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);


-- ============================================================
-- Insert Sample Data for Customers
-- ============================================================
INSERT INTO customers (customer_name, state, email) VALUES
    ('Homer Simpson', 'CA', 'homer.simpson@springfield.com'),
    ('Tony Stark', 'NY', 'tony.stark@starkindustries.com'),
    ('Bugs Bunny', 'TX', 'bugs.bunny@looneytunes.com'),
    ('Darth Vader', 'FL', 'darth.vader@empire.com'),
    ('Sherlock Holmes', 'OH', 'sherlock.holmes@bakerstreet.com');


-- ============================================================
-- Create the Sales Table with Integrity and Timestamps
-- ============================================================
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Prevent duplicate sales on the same product/customer/date
    CONSTRAINT unique_sale_entry UNIQUE (product_id, customer_id, sale_date)
);


-- ============================================================
-- Insert Sample Data for Sales
-- ============================================================
INSERT INTO sales (product_id, customer_id, sale_date, quantity, total_price) VALUES
    (1, 1, '2024-01-15', 1, 299.99),
    (2, 2, '2024-01-18', 1, 499.99),
    (3, 3, '2024-02-05', 2, 399.98),
    (4, 4, '2024-02-10', 1, 99.99),
    (5, 5, '2024-02-12', 1, 399.99),
    (6, 1, '2024-02-15', 1, 549.99),
    (7, 2, '2024-02-20', 1, 449.99),
    (8, 3, '2024-02-25', 1, 649.99),
    (9, 4, '2024-03-01', 1, 749.99);


-- ============================================================
-- Create the Returns Table with Validations and Timestamps
-- ============================================================
CREATE TABLE returns (
    return_id SERIAL PRIMARY KEY,
    sale_id INT REFERENCES sales(sale_id) ON DELETE CASCADE,
    return_reason TEXT NOT NULL,
    return_date DATE NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Ensure refund is not negative or nonsensical
    CONSTRAINT chk_refund_amount_valid CHECK (refund_amount >= 0)
);


-- ============================================================
-- Insert Sample Data for Returns
-- ============================================================
INSERT INTO returns (sale_id, return_reason, return_date, refund_amount) VALUES
    (1, 'Defective item', '2024-01-20', 299.99),
    (2, 'Item damaged in shipping', '2024-01-25', 499.99),
    (3, 'Customer changed mind', '2024-02-07', 199.99),
    (4, 'Wrong item received', '2024-02-12', 99.99),
    (5, 'Product not as described', '2024-02-15', 399.99),
    (6, 'Minor damage, but functional', '2024-02-18', 549.99),
    (7, 'Shipping delay, returned after arrival', '2024-02-22', 449.99),
    (8, 'Manufacturing defect', '2024-02-27', 649.99),
    (9, 'Customer dissatisfaction', '2024-03-03', 749.99);
	
	
-- ============================================================
-- CREATE INDEXES
-- ============================================================
CREATE INDEX idx_sales_product_id ON sales(product_id);
CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_returns_sale_id ON returns(sale_id);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_products_sku ON products(sku);


-- ============================================================
-- Stored Procedure to Get Return Rates by SKU
-- ============================================================
CREATE OR REPLACE FUNCTION get_return_rate()
RETURNS TABLE(sku VARCHAR, total_sold INT, total_returns INT, return_rate DECIMAL(5,2)) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.sku,
        COUNT(s.sale_id)::INT AS total_sold,
        COUNT(DISTINCT r.return_id)::INT AS total_returns,
        (COUNT(DISTINCT r.return_id)::DECIMAL / NULLIF(COUNT(s.sale_id), 0) * 100)::DECIMAL(5,2) AS return_rate
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    LEFT JOIN returns r ON s.sale_id = r.sale_id
    GROUP BY p.sku;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Stored Procedure to Get Returns by State
-- ============================================================
CREATE OR REPLACE FUNCTION get_returns_by_state()
RETURNS TABLE(state CHAR(2), total_returns INT) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.state,
        COUNT(r.return_id)::INT AS total_returns
    FROM returns r
    JOIN sales s ON r.sale_id = s.sale_id
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.state;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Create Views for Easy Reporting
-- ============================================================

-- View: Summary of sales by product
CREATE OR REPLACE VIEW sales_summary AS
SELECT 
    p.sku,
    p.product_name,
    COUNT(s.sale_id) AS total_sales,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.total_price) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.sku, p.product_name;

-- View: Summary of returns by product
CREATE OR REPLACE VIEW return_summary AS
SELECT 
    p.sku,
    p.product_name,
    COUNT(r.return_id) AS total_returns,
    SUM(r.refund_amount) AS total_refunds
FROM returns r
JOIN sales s ON r.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
GROUP BY p.sku, p.product_name;


-- ============================================================
-- Simple Trigger for Return Logs
-- ============================================================

CREATE TABLE return_log (
    log_id SERIAL PRIMARY KEY,
    return_id INT,
    action VARCHAR(10),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to insert into log
CREATE OR REPLACE FUNCTION log_return_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO return_log (return_id, action)
    VALUES (NEW.return_id, 'INSERT');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on insert
CREATE TRIGGER trg_log_return_insert
AFTER INSERT ON returns
FOR EACH ROW
EXECUTE FUNCTION log_return_insert();

-- ============================================================
-- Creates a snapshot of the return summary for performance
-- ============================================================

CREATE MATERIALIZED VIEW mv_return_summary AS
SELECT 
    p.sku,
    COUNT(r.return_id) AS total_returns
FROM returns r
JOIN sales s ON r.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
GROUP BY p.sku;

-- Refresh manually when needed
REFRESH MATERIALIZED VIEW mv_return_summary;


-- ============================================================
-- Queries to showcase how quering this database can be done and what can be viewed, any of these can become a FUNCTION, but showcasing these as queries only
-- ============================================================
-- Query to Test Return Rate Function
SELECT * FROM get_return_rate();

-- Query to Test Returns by State Function
SELECT * FROM get_returns_by_state();

--Top 3 Products with the Highest Return Rate
SELECT 
    p.sku,
    p.product_name,
    COUNT(s.sale_id) AS total_sales,
    COUNT(r.return_id) AS total_returns,
    ROUND(COUNT(r.return_id)::DECIMAL / NULLIF(COUNT(s.sale_id), 0) * 100, 2) AS return_rate
FROM sales s
JOIN products p ON s.product_id = p.product_id
LEFT JOIN returns r ON s.sale_id = r.sale_id
GROUP BY p.sku, p.product_name
ORDER BY return_rate DESC
LIMIT 3;

--Total Revenue by Product Type
SELECT 
    product_type,
    SUM(total_price) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY product_type
ORDER BY total_revenue DESC;

--Customers Who Made Multiple Purchases
SELECT 
    c.customer_name,
    COUNT(s.sale_id) AS num_purchases
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_name
HAVING COUNT(s.sale_id) > 1
ORDER BY num_purchases DESC;

--Ranking Products by Total Revenue
SELECT 
    p.sku,
    p.product_name,
    SUM(s.total_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(s.total_price) DESC) AS revenue_rank
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.sku, p.product_name;

--Monthly Sales Summary
SELECT 
    DATE_TRUNC('month', sale_date) AS month,
    COUNT(*) AS total_sales,
    SUM(total_price) AS revenue
FROM sales
GROUP BY month
ORDER BY month;
