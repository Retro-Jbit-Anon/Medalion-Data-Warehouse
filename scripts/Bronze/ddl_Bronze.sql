-- =============================================
-- File: ddl_Bronze.sql
-- Author: Retro Jbit
-- Date: July 10, 2025
-- Purpose: Create Bronze layer tables for raw data ingestion from source systems
-- Version: 1.0
-- Notes: Drops existing tables if they exist. For development use only.
-- =============================================

-- Ensure Bronze schema exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Bronze')
    EXEC('CREATE SCHEMA Bronze');
GO

-- Drop tables if they already exist
IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_cust_info;

IF OBJECT_ID('Bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_prd_info;

IF OBJECT_ID('Bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_sales_details;

IF OBJECT_ID('Bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_loc_a101;

IF OBJECT_ID('Bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_cust_az12;

IF OBJECT_ID('Bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_px_cat_g1v2;
GO

-- Create Tables in Bronze Schema
-- ----------------------------------

-- Customer Info
CREATE TABLE Bronze.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE
);
GO

-- Product Info
CREATE TABLE Bronze.crm_prd_info (
    prd_id        INT,
    prd_key       NVARCHAR(50),
    prd_nm        NVARCHAR(50),
    prd_cost      INT,
    prd_line      NVARCHAR(50),
    prd_start_dt  DATETIME,
    prd_end_dt    DATETIME
);
GO

-- Sales Details
CREATE TABLE Bronze.crm_sales_details (
    sls_ord_num   NVARCHAR(50),
    sls_prd_key   NVARCHAR(50),
    sls_cust_id   INT,
    sls_order_dt  INT,
    sls_ship_dt   INT,
    sls_due_dt    INT,
    sls_sales     INT,
    sls_quantity  INT,
    sls_price     INT
);
GO

-- Location Data
CREATE TABLE Bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

-- Customer Additional Info
CREATE TABLE Bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

-- Product Category Mapping
CREATE TABLE Bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO

-- Add Extended Properties (Descriptions)
-- ---------------------------------------

-- crm_cust_info
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Raw customer data from CRM system',
    @level0type = N'Schema', @level0name = 'Bronze',
    @level1type = N'Table',  @level1name = 'crm_cust_info';
GO

-- crm_prd_info
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Raw product information including cost and lifecycle dates',
    @level0type = N'Schema', @level0name = 'Bronze',
    @level1type = N'Table',  @level1name = 'crm_prd_info';
GO

-- crm_sales_details
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Raw sales transactions with order and delivery dates',
    @level0type = N'Schema', @level0name = 'Bronze',
    @level1type = N'Table',  @level1name = 'crm_sales_details';
GO

-- erp_loc_a101
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'ERP location mapping table (country by ID)',
    @level0type = N'Schema', @level0name = 'Bronze',
    @level1type = N'Table',  @level1name = 'erp_loc_a101';
GO

-- erp_cust_az12
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Additional customer metadata like birth date and gender',
    @level0type = N'Schema', @level0name = 'Bronze',
    @level1type = N'Table',  @level1name = 'erp_cust_az12';
GO

-- erp_px_cat_g1v2
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Product category and subcategory mapping table',
    @level0type = N'Schema', @level0name = 'Bronze',
    @level1type = N'Table',  @level1name = 'erp_px_cat_g1v2';
GO

-- Track deployment in SchemaVersion table
-- ---------------------------------------

-- Create SchemaVersion table if not exists
IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchemaVersion (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ScriptName VARCHAR(255) NOT NULL,
        AppliedOn DATETIME DEFAULT GETDATE()
    );
END
GO

-- Insert current script into version tracker
INSERT INTO dbo.SchemaVersion (ScriptName)
VALUES ('ddl_Bronze.sql');
GO

-- Output success message
PRINT '✅ All Bronze layer tables created successfully.';
PRINT '✅ Descriptions added via extended properties.';
PRINT '✅ Script version recorded in SchemaVersion table.';