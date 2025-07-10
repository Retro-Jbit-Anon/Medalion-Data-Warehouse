-- =============================================
-- Procedure: Silver.load_Silver
-- Author: Your Name
-- Date: July 14, 2025
-- Purpose: Load and transform data from Bronze to Silver layer
-- Notes:
--   - Cleanses, deduplicates, and standardizes data
--   - Truncates target tables before insert (full refresh)
--   - Designed for development environments
-- =============================================

CREATE OR ALTER PROCEDURE Silver.load_Silver
AS
BEGIN
    SET NOCOUNT ON;

    -- Timing variables
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT '🚀 Starting Silver Layer Transformation Process';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT '📁 Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- ---------------------------
        -- Silver.crm_cust_info
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [crm_cust_info] Truncating table...';
        TRUNCATE TABLE Silver.crm_cust_info;

        PRINT '🟢 [crm_cust_info] Inserting transformed data...';
        INSERT INTO Silver.crm_cust_info (
            cst_id, 
            cst_key, 
            cst_firstname, 
            cst_lastname, 
            cst_marital_status, 
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        PRINT '⏱️ [crm_cust_info] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Silver.crm_prd_info
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [crm_prd_info] Truncating table...';
        TRUNCATE TABLE Silver.crm_prd_info;

        PRINT '🟢 [crm_prd_info] Inserting transformed data...';
        INSERT INTO Silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE
            )
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '⏱️ [crm_prd_info] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Silver.crm_sales_details
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [crm_sales_details] Truncating table...';
        TRUNCATE TABLE Silver.crm_sales_details;

        PRINT '🟢 [crm_sales_details] Inserting transformed data...';
        INSERT INTO Silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '⏱️ [crm_sales_details] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        PRINT '------------------------------------------------';
        PRINT '📦 Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- ---------------------------
        -- Silver.erp_cust_az12
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [erp_cust_az12] Truncating table...';
        TRUNCATE TABLE Silver.erp_cust_az12;

        PRINT '🟢 [erp_cust_az12] Inserting transformed data...';
        INSERT INTO Silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '⏱️ [erp_cust_az12] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Silver.erp_loc_a101
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [erp_loc_a101] Truncating table...';
        TRUNCATE TABLE Silver.erp_loc_a101;

        PRINT '🟢 [erp_loc_a101] Inserting transformed data...';
        INSERT INTO Silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', ''),
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '⏱️ [erp_loc_a101] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Silver.erp_px_cat_g1v2
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [erp_px_cat_g1v2] Truncating table...';
        TRUNCATE TABLE Silver.erp_px_cat_g1v2;

        PRINT '🟢 [erp_px_cat_g1v2] Inserting raw data...';
        INSERT INTO Silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '⏱️ [erp_px_cat_g1v2] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT '✅ Silver Layer Load Completed Successfully!';
        PRINT '   - Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10)) + ' seconds';
        PRINT '================================================';

        -- Optional: Log execution result in SchemaVersion
        IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NOT NULL
        BEGIN
            INSERT INTO dbo.SchemaVersion (ScriptName)
            VALUES ('Silver.load_Silver');
        END

    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorNumber INT,
            @ErrorSeverity INT,
            @ErrorState INT,
            @ErrorLine INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorNumber = ERROR_NUMBER(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorLine = ERROR_LINE();

        PRINT '🛑 ERROR OCCURRED DURING Silver LAYER LOAD';
        PRINT '📍 Error Number: ' + CAST(@ErrorNumber AS VARCHAR);
        PRINT '📍 Error Line: ' + CAST(@ErrorLine AS VARCHAR);
        PRINT '💬 Message: ' + @ErrorMessage;
        PRINT '================================================';

        THROW;
    END CATCH
END