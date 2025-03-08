-- ============================================================
-- Fully functional Database for Sales and Returns
-- ============================================================


-- Drop existing tables to avoid conflicts
DROP TABLE IF EXISTS returns CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- Create the Products Table with Correct SKUs
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(20) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_type VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Insert Sample Data for Products (Using Provided SKUs)
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

-- Create the Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    state CHAR(2) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- Insert Sample Data for Customers
INSERT INTO customers (customer_name, state, email) VALUES
    ('Homer Simpson', 'CA', 'homer.simpson@springfield.com'),
    ('Tony Stark', 'NY', 'tony.stark@starkindustries.com'),
    ('Bugs Bunny', 'TX', 'bugs.bunny@looneytunes.com'),
    ('Darth Vader', 'FL', 'darth.vader@empire.com'),
    ('Sherlock Holmes', 'OH', 'sherlock.holmes@bakerstreet.com');


-- Create the Sales Table
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price DECIMAL(10,2) NOT NULL
);

-- Insert Sample Data for Sales
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

-- Create the Returns Table
CREATE TABLE returns (
    return_id SERIAL PRIMARY KEY,
    sale_id INT REFERENCES sales(sale_id) ON DELETE CASCADE,
    return_reason TEXT NOT NULL,
    return_date DATE NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL
);

-- Insert Sample Data for Returns
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

-- Stored Procedure to Get Return Rates by SKU
CREATE OR REPLACE FUNCTION get_return_rate()
RETURNS TABLE(sku VARCHAR, total_sold INT, total_returns INT, return_rate DECIMAL(5,2)) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.sku,
        COUNT(s.sale_id) AS total_sold,
        COUNT(r.return_id) AS total_returns,
        (COUNT(r.return_id)::DECIMAL / COUNT(s.sale_id) * 100) AS return_rate
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    LEFT JOIN returns r ON s.sale_id = r.sale_id
    GROUP BY p.sku;
END; $$ LANGUAGE plpgsql;

-- Stored Procedure to Get Returns by State
CREATE OR REPLACE FUNCTION get_returns_by_state()
RETURNS TABLE(state CHAR(2), total_returns INT) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.state,
        COUNT(r.return_id) AS total_returns
    FROM returns r
    JOIN sales s ON r.sale_id = s.sale_id
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.state;
END; $$ LANGUAGE plpgsql;

-- Query to Test Return Rate Function
SELECT * FROM get_return_rate();

-- Query to Test Returns by State Function
SELECT * FROM get_returns_by_state();
