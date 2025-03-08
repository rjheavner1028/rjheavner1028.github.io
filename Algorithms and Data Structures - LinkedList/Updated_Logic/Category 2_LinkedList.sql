-- ============================================================
-- Create the database (Most of the time you will already have your Database, this is just used as an exmaple for the assignment)
-- CREATE DATABASE eBid_Database;
-- ============================================================

-- Drop the table if it exists, then create it.
DROP TABLE IF EXISTS eBid_Monthly_Sales;
CREATE TABLE eBid_Monthly_Sales (
    auction_title         TEXT,
    auction_id            INTEGER,
    department            TEXT,
    close_date            DATE,
    winning_bid           NUMERIC,
    cc_fee                NUMERIC,
    fee_percent           NUMERIC,
    auction_fee_subtotal  NUMERIC,
    auction_fee_total     NUMERIC,
    pay_status            TEXT,
    paid_date             DATE DEFAULT NULL,
    asset_number          TEXT,
    inventory_id          TEXT,
    decal_vehicle_id      TEXT,
    vtr_number            TEXT,
    receipt_number        TEXT,
    cap                   INTEGER,
    expenses              NUMERIC,
    net_sales             NUMERIC,
    fund                  TEXT,
    business_unit         INTEGER
);

-- ============================================================
-- Create a staging table for CSV import.
-- The staging table uses an integer column (close_date_xl) to store the Excel serial date.
DROP TABLE IF EXISTS eBid_Monthly_Sales_Staging;
CREATE TABLE eBid_Monthly_Sales_Staging (
    auction_title         TEXT,
    auction_id            INTEGER,
    department            TEXT,
    close_date_xl         INTEGER,  -- Excel serial date
    winning_bid           NUMERIC,
    cc_fee                NUMERIC,
    fee_percent           NUMERIC,
    auction_fee_subtotal  NUMERIC,
    auction_fee_total     NUMERIC,
    pay_status            TEXT,
    asset_number          TEXT,
    inventory_id          TEXT,
    decal_vehicle_id      TEXT,
    vtr_number            TEXT,
    receipt_number        TEXT,
    cap                   INTEGER,
    expenses              NUMERIC,
    net_sales             NUMERIC,
    fund                  TEXT,
    business_unit         INTEGER
);

-- ============================================================
-- Create a function to import CSV data.
-- This function:
--  1. Clears the staging table.
--  2. Copies the CSV data into the staging table.
--  3. Inserts data into the final table converting the Excel serial date.
--
-- Note: Adjust the conversion formula if the Excel uses the 1904 date system like this one does

CREATE OR REPLACE FUNCTION import_auction_data_csv(file_path TEXT)
RETURNS VOID AS
$$
BEGIN
    -- Clear staging table to ensure no leftover data
    TRUNCATE eBid_Monthly_Sales_Staging;
    
    -- Import CSV data into the staging table.
    -- The CSV file is assumed to have a header and columns ordered exactly as listed.
    EXECUTE FORMAT(
        $f$
        COPY eBid_Monthly_Sales_Staging (
            auction_title,
            auction_id,
            department,
            close_date_xl,
            winning_bid,
            cc_fee,
            fee_percent,
            auction_fee_subtotal,
            auction_fee_total,
            pay_status,
            asset_number,
            inventory_id,
            decal_vehicle_id,
            vtr_number,
            receipt_number,
            cap,
            expenses,
            net_sales,
            fund,
            business_unit
        )
        FROM %L
        WITH (
            FORMAT CSV,
            HEADER,
            DELIMITER ','
        )
        $f$,
        file_path
    );
    
    -- Insert data from the staging table into the final table,
    -- converting the Excel serial date (close_date_xl) to a proper DATE.
    -- For Excel's 1900 date system, the conversion is:
    --   DATE '1900-01-01' + (excel_serial - 2)
    INSERT INTO eBid_Monthly_Sales (
        auction_title,
        auction_id,
        department,
        close_date,
        winning_bid,
        cc_fee,
        fee_percent,
        auction_fee_subtotal,
        auction_fee_total,
        pay_status,
        asset_number,
        inventory_id,
        decal_vehicle_id,
        vtr_number,
        receipt_number,
        cap,
        expenses,
        net_sales,
        fund,
        business_unit
    )
    SELECT
        auction_title,
        auction_id,
        department,
        DATE '1900-01-01' + (close_date_xl - 2) AS close_date,
        winning_bid,
        cc_fee,
        fee_percent,
        auction_fee_subtotal,
        auction_fee_total,
        pay_status,
        asset_number,
        inventory_id,
        decal_vehicle_id,
        vtr_number,
        receipt_number,
        cap,
        expenses,
        net_sales,
        fund,
        business_unit
    FROM eBid_Monthly_Sales_Staging;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Create a function to print all data from the final table.
-- ============================================================
CREATE OR REPLACE FUNCTION print_auction_data()
RETURNS TABLE (
    auction_title TEXT,
    auction_id INTEGER,
    department TEXT,
    close_date DATE,
    winning_bid NUMERIC,
    cc_fee NUMERIC,
    fee_percent NUMERIC,
    auction_fee_subtotal NUMERIC,
    auction_fee_total NUMERIC,
    pay_status TEXT,
    paid_date DATE,
    asset_number TEXT,
    inventory_id TEXT,
    decal_vehicle_id TEXT,
    vtr_number TEXT,
    receipt_number TEXT,
    cap INTEGER,
    expenses NUMERIC,
    net_sales NUMERIC,
    fund TEXT,
    business_unit INTEGER
) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM eBid_Monthly_Sales;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Import Data - Update File Path as needed || File path must be within \\PostgreSQL\17\data\ for PG to accept file
-- ============================================================
COPY eBid_Monthly_Sales_Staging (
    auction_title,
    auction_id,
    department,
    close_date_xl,         -- numeric date from Excel
    winning_bid,
    cc_fee,
    fee_percent,
    auction_fee_subtotal,
    auction_fee_total,
    pay_status,
    asset_number,
    inventory_id,
    decal_vehicle_id,
    vtr_number,
    receipt_number,
    cap,
    expenses,
    net_sales,
    fund,
    business_unit
)
FROM 'C:\Program Files\PostgreSQL\17\data\eBid_Monthly_Sales.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');


-- ============================================================
-- Insert from staging into the base table, converting the numeric date to a real date
-- ============================================================

INSERT INTO eBid_Monthly_Sales (
    auction_title,
    auction_id,
    department,
    close_date,
    winning_bid,
    cc_fee,
    fee_percent,
    auction_fee_subtotal,
    auction_fee_total,
    pay_status,
    -- paid_date is omitted or defaults to NULL
    asset_number,
    inventory_id,
    decal_vehicle_id,
    vtr_number,
    receipt_number,
    cap,
    expenses,
    net_sales,
    fund,
    business_unit
)
SELECT
    auction_title,
    auction_id,
    department,
    DATE '1900-01-01' + (close_date_xl - 2), -- Adjust for Excel
    winning_bid,
    cc_fee,
    fee_percent,
    auction_fee_subtotal,
    auction_fee_total,
    pay_status,
    asset_number,
    inventory_id,
    decal_vehicle_id,
    vtr_number,
    receipt_number,
    cap,
    expenses,
    net_sales,
    fund,
    business_unit
FROM eBid_Monthly_Sales_Staging;



-- ============================================================
-- ============================================================
-- Create functions to showcase data that was just imported along with showing the SELECT for the function as an example
-- ============================================================
-- ============================================================




-- ============================================================
-- Get All Auctions Between Two Dates
-- ============================================================

CREATE OR REPLACE FUNCTION get_auctions_between_dates(start_date DATE, end_date DATE)
RETURNS TABLE (
    auction_title TEXT,
    auction_id INTEGER,
    department TEXT,
    close_date DATE,
    winning_bid NUMERIC,
    pay_status TEXT,
    net_sales NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.auction_title, e.auction_id, e.department, e.close_date, 
           e.winning_bid, e.pay_status, e.net_sales
    FROM eBid_Monthly_Sales e
    WHERE e.close_date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;



--Example Call
SELECT * FROM get_auctions_between_dates('2013-01-01', '2014-06-30');



-- ============================================================
-- Get Auctions Above a Certain Winning Bid
-- ============================================================

CREATE OR REPLACE FUNCTION get_auctions_above_bid(min_bid NUMERIC)
RETURNS TABLE (
    auction_title TEXT,
    auction_id INTEGER,
    department TEXT,
    close_date DATE,
    winning_bid NUMERIC,
    pay_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.auction_title, e.auction_id, e.department, e.close_date, 
           e.winning_bid, e.pay_status
    FROM eBid_Monthly_Sales e
    WHERE e.winning_bid >= min_bid;
END;
$$ LANGUAGE plpgsql;

--Example Call
SELECT * FROM get_auctions_above_bid(500);


-- ============================================================
-- Get Auctions By Pay Status
-- ============================================================

CREATE OR REPLACE FUNCTION get_auctions_by_pay_status(status_filter TEXT)
RETURNS TABLE (
    auction_title TEXT,
    auction_id INTEGER,
    department TEXT,
    close_date DATE,
    winning_bid NUMERIC,
    pay_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.auction_title, e.auction_id, e.department, e.close_date, 
           e.winning_bid, e.pay_status
    FROM eBid_Monthly_Sales e
    WHERE e.pay_status = status_filter;
END;
$$ LANGUAGE plpgsql;


--Example Call
SELECT * FROM get_auctions_by_pay_status('Successful');


-- ============================================================
-- Get Net Sales Sum Between Dates
-- ============================================================

CREATE OR REPLACE FUNCTION get_total_net_sales(start_date DATE, end_date DATE)
RETURNS NUMERIC AS $$
DECLARE
    total_sales NUMERIC;
BEGIN
    SELECT SUM(net_sales) INTO total_sales
    FROM eBid_Monthly_Sales
    WHERE close_date BETWEEN start_date AND end_date;
    
    RETURN total_sales;
END;
$$ LANGUAGE plpgsql;

--Example Call
SELECT get_total_net_sales('2013-01-01', '2014-06-30');

-- ============================================================
-- Get Top 5 Most Profitable Auctions
-- ============================================================

CREATE OR REPLACE FUNCTION get_top_profitable_auctions()
RETURNS TABLE (
    auction_title TEXT,
    auction_id INTEGER,
    department TEXT,
    close_date DATE,
    net_sales NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.auction_title, 
           e.auction_id, 
           e.department, 
           e.close_date, 
           e.net_sales
    FROM eBid_Monthly_Sales e
    ORDER BY e.net_sales DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

--Example Call
SELECT * FROM get_top_profitable_auctions();


-- ============================================================
-- Example queries in Database without calling a function
SELECT public.print_auction_data();
SELECT * FROM eBid_Monthly_Sales;
