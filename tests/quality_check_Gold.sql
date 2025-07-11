-- =============================================
-- File: quality_check_Gold.sql
-- Author: Retro Jbit
-- Date: July 17, 2025
-- Purpose: Perform data quality checks on Gold layer views
-- Notes:
--   - Run after Gold layer views are created.
--   - Investigate any returned rows to ensure referential integrity.
-- =============================================

PRINT '================================================';
PRINT '🔍 Starting Data Quality Checks (Gold Layer)';
PRINT '================================================';

-- ====================================================================
-- 🧾 Checking 'gold.dim_customers'
-- ====================================================================

-- 🔍 Check for duplicate surrogate keys in customer dimension
-- Expected: No results
PRINT '🟡 [dim_customers] Checking for duplicate customer_key...';
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- 🧾 Checking 'gold.dim_products'
-- ====================================================================

-- 🔍 Check for duplicate surrogate keys in product dimension
-- Expected: No results
PRINT '🟡 [dim_products] Checking for duplicate product_key...';
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- 🧾 Checking 'gold.fact_sales'
-- ====================================================================

-- 🔍 Validate referential integrity with dimensions
-- Expected: No orphaned records
PRINT '🟡 [fact_sales] Checking for missing foreign key references...';
SELECT 
    f.order_number,
    CASE WHEN c.customer_key IS NULL THEN 'Missing Customer' END AS customer_issue,
    CASE WHEN p.product_key IS NULL THEN 'Missing Product' END AS product_issue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

-- Track execution in SchemaVersion table
IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NOT NULL
BEGIN
    INSERT INTO dbo.SchemaVersion (ScriptName)
    VALUES ('quality_check_Gold.sql');
END
GO

-- Output success message
PRINT '================================================';
PRINT '✅ All Gold layer quality checks completed.';
PRINT '📌 Investigate any returned rows to resolve inconsistencies.';
PRINT '================================================';