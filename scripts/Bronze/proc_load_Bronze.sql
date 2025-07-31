-- =============================================
-- Procedure: Bronze.load_Bronze
-- Author: Retro Jbit
-- Date: July 12, 2025
-- Purpose: Load raw CSV data into Bronze layer tables using BULK INSERT
-- Notes: Ensure source CSV paths are accessible by SQL Server.
--        Designed for development environments. Replace file paths accordingly.
-- =============================================

CREATE OR ALTER PROCEDURE Bronze.load_Bronze
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
        PRINT '🚀 Starting Bronze Layer Load Process';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT '📁 Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- ---------------------------
        -- Bronze.crm_cust_info
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [crm_cust_info] Truncating table...';
        TRUNCATE TABLE Bronze.crm_cust_info;

        PRINT '🟢 [crm_cust_info] Inserting data...';
        BULK INSERT Bronze.crm_cust_info
        FROM '/datasets/source_crm/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '⏱️ [crm_cust_info] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Bronze.crm_prd_info
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [crm_prd_info] Truncating table...';
        TRUNCATE TABLE Bronze.crm_prd_info;

        PRINT '🟢 [crm_prd_info] Inserting data...';
        BULK INSERT Bronze.crm_prd_info
        FROM '/datasets/source_crm/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '⏱️ [crm_prd_info] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Bronze.crm_sales_details
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [crm_sales_details] Truncating table...';
        TRUNCATE TABLE Bronze.crm_sales_details;

        PRINT '🟢 [crm_sales_details] Inserting data...';
        BULK INSERT Bronze.crm_sales_details
        FROM '/datasets/source_crm/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '⏱️ [crm_sales_details] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        PRINT '------------------------------------------------';
        PRINT '📦 Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- ---------------------------
        -- Bronze.erp_loc_a101
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [erp_loc_a101] Truncating table...';
        TRUNCATE TABLE Bronze.erp_loc_a101;

        PRINT '🟢 [erp_loc_a101] Inserting data...';
        BULK INSERT Bronze.erp_loc_a101
        FROM '/datasets/source_erp/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '⏱️ [erp_loc_a101] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Bronze.erp_cust_az12
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [erp_cust_az12] Truncating table...';
        TRUNCATE TABLE Bronze.erp_cust_az12;

        PRINT '🟢 [erp_cust_az12] Inserting data...';
        BULK INSERT Bronze.erp_cust_az12
        FROM '/datasets/source_erp/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '⏱️ [erp_cust_az12] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        -- ---------------------------
        -- Bronze.erp_px_cat_g1v2
        -- ---------------------------
        SET @start_time = GETDATE();
        PRINT '🟡 [erp_px_cat_g1v2] Truncating table...';
        TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

        PRINT '🟢 [erp_px_cat_g1v2] Inserting data...';
        BULK INSERT Bronze.erp_px_cat_g1v2
        FROM '/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '⏱️ [erp_px_cat_g1v2] Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' sec';
        PRINT '----------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT '✅ Bronze Layer Load Completed Successfully!';
        PRINT '   - Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10)) + ' seconds';
        PRINT '================================================';

        -- Optional: Log execution result to SchemaVersion or custom log table
        IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NOT NULL
        BEGIN
            INSERT INTO dbo.SchemaVersion (ScriptName)
            VALUES ('Bronze.load_Bronze');
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

        PRINT '🛑 ERROR OCCURRED DURING Bronze LAYER LOAD';
        PRINT '📍 Error Number: ' + CAST(@ErrorNumber AS VARCHAR);
        PRINT '📍 Error Line: ' + CAST(@ErrorLine AS VARCHAR);
        PRINT '💬 Message: ' + @ErrorMessage;
        PRINT '================================================';

        THROW;
    END CATCH
END
