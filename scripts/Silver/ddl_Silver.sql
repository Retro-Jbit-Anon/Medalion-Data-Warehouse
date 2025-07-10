-- =============================================
-- File: ddl_Silver.sql
-- Author: Retro Jbit
-- Date: July 10, 2025
-- Purpose: Create tables in the Silver layer for cleansed and integrated data
-- Version: 1.0
-- =============================================

-- Ensure 'Silver' schema exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Silver')
    EXEC('CREATE SCHEMA Silver');
GO

-- Drop existing tables if they exist
IF OBJECT_ID('Silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE Silver.crm_cust_info;

IF OBJECT_ID('Silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE Silver.crm_prd_info;

IF OBJECT_ID('Silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE Silver.crm_sales_details;

IF OBJECT_ID('Silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE Silver.erp_loc_a101;

IF OBJECT_ID('Silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE Silver.erp_cust_az12;

IF OBJECT_ID('Silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE Silver.erp_px_cat_g1v2;
GO

-- Create Tables in Silver Schema
-- ----------------------------------

-- Customer Info
CREATE TABLE Silver.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Product Info
CREATE TABLE Silver.crm_prd_info (
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Sales Details
CREATE TABLE Silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Location Data
CREATE TABLE Silver.erp_loc_a101 (
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Customer Additional Info
CREATE TABLE Silver.erp_cust_az12 (
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Product Category Mapping
CREATE TABLE Silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Add Extended Properties (Descriptions)
-- ---------------------------------------

-- crm_cust_info
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Cleansed customer data from CRM system',
    @level0type = N'Schema', @level0name = 'Silver',
    @level1type = N'Table',  @level1name = 'crm_cust_info';
GO

-- crm_prd_info
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Integrated product information with category and lifecycle dates',
    @level0type = N'Schema', @level0name = 'Silver',
    @level1type = N'Table',  @level1name = 'crm_prd_info';
GO

-- crm_sales_details
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Cleaned and validated sales transactions with proper date types',
    @level0type = N'Schema', @level0name = 'Silver',
    @level1type = N'Table',  @level1name = 'crm_sales_details';
GO

-- erp_loc_a101
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'ERP location mapping table with country by ID',
    @level0type = N'Schema', @level0name = 'Silver',
    @level1type = N'Table',  @level1name = 'erp_loc_a101';
GO

-- erp_cust_az12
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Additional cleansed customer metadata like birth date and gender',
    @level0type = N'Schema', @level0name = 'Silver',
    @level1type = N'Table',  @level1name = 'erp_cust_az12';
GO

-- erp_px_cat_g1v2
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Product category and subcategory mapping with maintenance flag',
    @level0type = N'Schema', @level0name = 'Silver',
    @level1type = N'Table',  @level1name = 'erp_px_cat_g1v2';
GO

-- Track deployment in SchemaVersion table
-- ---------------------------------------
IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NOT NULL
BEGIN
    INSERT INTO dbo.SchemaVersion (ScriptName)
    VALUES ('ddl_Silver.sql');
END
GO

-- Output success message
PRINT '✅ All Silver layer tables created successfully.';
PRINT '✅ Descriptions added via extended properties.';
PRINT '✅ Script version recorded in SchemaVersion table.';