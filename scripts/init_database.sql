-- =============================================
-- File: init_database.sql
-- Author: Jidaar
-- Date: July 10, 2025
-- Purpose: Creates the DataWareHouse database and core layer schemas:
--          Bronze (raw), Silver (cleaned), Gold (curated)
-- Version: 1.0
-- =============================================

-- Ensure we're in master context
USE master;
GO

-- Drop database if it exists (development only - use with caution in prod)
IF DB_ID('DataWareHouse') IS NOT NULL
BEGIN
    ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWareHouse;
END
GO

-- Create the data warehouse database
CREATE DATABASE DataWareHouse;
GO

-- Switch to the new database
USE DataWareHouse;
GO

-- Drop schemas if they exist (optional for dev reproducibility)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Bronze')
    EXEC('CREATE SCHEMA Bronze');

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Silver')
    EXEC('CREATE SCHEMA Silver');

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Gold')
    EXEC('CREATE SCHEMA Gold');
GO

-- Add schema descriptions via extended properties
EXEC sp_addextendedproperty 
    @name = N'Description', 
    @value = 'Raw/staging layer - unprocessed data',
    @level0type = N'Schema', @level0name = 'Bronze';

EXEC sp_addextendedproperty 
    @name = N'Description', 
    @value = 'Cleansed and integrated data',
    @level0type = N'Schema', @level0name = 'Silver';

EXEC sp_addextendedproperty 
    @name = N'Description', 
    @value = 'Curated business-ready data',
    @level0type = N'Schema', @level0name = 'Gold';
GO

-- Optional: Create a SchemaVersion table for migration tracking
IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchemaVersion (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ScriptName VARCHAR(255) NOT NULL,
        AppliedOn DATETIME DEFAULT GETDATE()
    );
END
GO

-- Insert this script into the version tracker
INSERT INTO dbo.SchemaVersion (ScriptName)
VALUES ('init_database.sql');
GO

-- Output success message
PRINT '✅ Database "DataWareHouse" created successfully.';
PRINT '✅ Schemas: Bronze, Silver, Gold created and documented.';
