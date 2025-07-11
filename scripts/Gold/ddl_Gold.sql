-- =============================================
-- File: ddl_Gold.sql
-- Author: Retro Jbit
-- Date: July 11    , 2025
-- Purpose: Create Gold layer views (Star Schema) for reporting and analytics
-- Notes:
--   - Views are built on top of the Silver layer.
--   - Includes dimensions and fact views.
-- =============================================

-- Ensure 'Gold' schema exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Gold')
    EXEC('CREATE SCHEMA Gold');
GO

-- Add schema description
EXEC sp_addextendedproperty 
    @name = N'Description', 
    @value = 'Curated business-ready data (Star Schema)',
    @level0type = N'Schema', @level0name = 'Gold';
GO

-- =============================================================================
-- Create Dimension: Gold.dim_customers
-- =============================================================================

IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW Gold.dim_customers;
GO

CREATE VIEW Gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- Surrogate key
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is primary source
        ELSE COALESCE(ca.gen, 'n/a')               -- Fallback to ERP
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

-- Add view description
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Customer dimension with demographic and location details',
    @level0type = N'Schema', @level0name = 'Gold',
    @level1type = N'View',   @level1name = 'dim_customers';
GO

-- =============================================================================
-- Create Dimension: Gold.dim_products
-- =============================================================================

IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
    DROP VIEW Gold.dim_products;
GO

CREATE VIEW Gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Current active products only
GO

-- Add view description
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Product dimension including current product attributes and categories',
    @level0type = N'Schema', @level0name = 'Gold',
    @level1type = N'View',   @level1name = 'dim_products';
GO

-- =============================================================================
-- Create Fact Table: Gold.fact_sales
-- =============================================================================

IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.fact_sales;
GO

CREATE VIEW Gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN Gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN Gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO

-- Add view description
EXEC sp_addextendedproperty 
    @name = N'Description',
    @value = 'Fact table containing sales transactions linked to product and customer dimensions',
    @level0type = N'Schema', @level0name = 'Gold',
    @level1type = N'View',   @level1name = 'fact_sales';
GO

-- Track execution in SchemaVersion table
IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NOT NULL
BEGIN
    INSERT INTO dbo.SchemaVersion (ScriptName)
    VALUES ('ddl_Gold.sql');
END
GO

-- Output success message
PRINT '================================================';
PRINT '✅ Gold layer views created successfully.';
PRINT '📌 Ready for reporting and analytics.';
PRINT '================================================';