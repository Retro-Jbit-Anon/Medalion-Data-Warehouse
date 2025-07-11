-- =============================================
-- File: quality_checks_Silver.sql
-- Author: Retro Jbit
-- Date: July 11, 2025
-- Purpose: Perform data quality checks on Silver layer tables
-- Notes:
--   - Run after Silver.load_Silver completes successfully
--   - Investigate any returned rows to ensure data integrity
-- =============================================

PRINT '================================================';
PRINT '🔍 Starting Data Quality Checks (Silver Layer)';
PRINT '================================================';

-- ====================================================================
-- 🧾 Checking 'Silver.crm_cust_info'
-- ====================================================================

-- 🔍 Check for NULLs or Duplicates in cst_id
-- Expected: No results
PRINT '🟡 [crm_cust_info] Checking for NULL or duplicate cst_id...';
SELECT 
    cst_id,
    COUNT(*) AS DuplicateCount
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- 🔍 Check for unwanted spaces in cst_key
-- Expected: No results
PRINT '🟡 [crm_cust_info] Checking for unwanted spaces in cst_key...';
SELECT 
    cst_key 
FROM Silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- 📊 Show distinct marital status values
PRINT '🟢 [crm_cust_info] Distinct marital status values:';
SELECT DISTINCT 
    cst_marital_status 
FROM Silver.crm_cust_info;

-- 📊 Show gender normalization
PRINT '🟢 [crm_cust_info] Distinct gender values:';
SELECT DISTINCT 
    cst_gndr 
FROM Silver.crm_cust_info;

-- ====================================================================
-- 🧾 Checking 'Silver.crm_prd_info'
-- ====================================================================

-- 🔍 Check for NULLs or Duplicates in prd_id
-- Expected: No results
PRINT '🟡 [crm_prd_info] Checking for NULL or duplicate prd_id...';
SELECT 
    prd_id,
    COUNT(*) AS DuplicateCount
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- 🔍 Check for unwanted spaces in prd_nm
-- Expected: No results
PRINT '🟡 [crm_prd_info] Checking for unwanted spaces in prd_nm...';
SELECT 
    prd_nm 
FROM Silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- 🔍 Check for negative or NULL product cost
-- Expected: No results
PRINT '🟡 [crm_prd_info] Checking for invalid product cost...';
SELECT 
    prd_cost 
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 📊 Show distinct product lines
PRINT '🟢 [crm_prd_info] Distinct product line values:';
SELECT DISTINCT 
    prd_line 
FROM Silver.crm_prd_info;

-- 🔍 Check for invalid date ranges
-- Expected: No results
PRINT '🟡 [crm_prd_info] Checking for end date before start date...';
SELECT 
    * 
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- 🧾 Checking 'Silver.crm_sales_details'
-- ====================================================================

-- 🔍 Check for invalid order dates
-- Expected: No invalid dates
PRINT '🟡 [crm_sales_details] Checking for invalid order/ship/due dates...';
SELECT 
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt 
FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- 🔍 Validate Sales = Quantity × Price
-- Expected: All valid
PRINT '🟡 [crm_sales_details] Checking sales = quantity × price...';
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM Silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- 🧾 Checking 'Silver.erp_cust_az12'
-- ====================================================================

-- 🔍 Identify out-of-range birthdates
-- Expected: Birthdates between 1924-01-01 and today
PRINT '🟡 [erp_cust_az12] Checking for invalid birthdates...';
SELECT DISTINCT 
    bdate 
FROM Silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- 📊 Show distinct gender values
PRINT '🟢 [erp_cust_az12] Distinct gender values:';
SELECT DISTINCT 
    gen 
FROM Silver.erp_cust_az12;

-- ====================================================================
-- 🧾 Checking 'Silver.erp_loc_a101'
-- ====================================================================

-- 📊 Show country mapping values
PRINT '🟢 [erp_loc_a101] Distinct country names:';
SELECT DISTINCT 
    cntry 
FROM Silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- 🧾 Checking 'Silver.erp_px_cat_g1v2'
-- ====================================================================

-- 🔍 Check for unwanted spaces in string fields
-- Expected: No results
PRINT '🟡 [erp_px_cat_g1v2] Checking for unwanted spaces in category fields...';
SELECT 
    cat,
    subcat,
    maintenance
FROM Silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- 📊 Show maintenance flag values
PRINT '🟢 [erp_px_cat_g1v2] Distinct maintenance flags:';
SELECT DISTINCT 
    maintenance 
FROM Silver.erp_px_cat_g1v2;

-- Track execution in SchemaVersion table
IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NOT NULL
BEGIN
    INSERT INTO dbo.SchemaVersion (ScriptName)
    VALUES ('quality_checks_Silver.sql');
END
GO

-- Output success message
PRINT '================================================';
PRINT '✅ All Silver layer quality checks completed.';
PRINT '📌 Investigate any returned rows to resolve inconsistencies.';
PRINT '================================================';
