[![License](https://img.shields.io/badge/License-MIT-blue.svg )](LICENSE)
[![SQL Server](https://img.shields.io/badge/SQL_Server-2022-brightgreen.svg )](https://www.microsoft.com/sql-server )
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg )](#docker-setup)

# SqlDataWarehouse
# 🏗️ Data Warehouse Project: Bronze → Silver → Gold

This is a complete end-to-end **SQL-based data warehouse** built using **Microsoft SQL Server Express**, designed for learning, development, and reporting purposes.

It follows a layered architecture:
- **Bronze**: Raw data ingestion
- **Silver**: Cleansed, standardized, integrated data
- **Gold**: Business-ready dimensional model (Star Schema)

All scripts are version-controlled, documented, and Docker-ready for easy deployment.

---

## 🧱 Architecture Overview

### 🔷 Bronze Layer
- Purpose: Ingest raw data from source systems
- Tables: CRM & ERP flat files loaded using `BULK INSERT`
- Schema: `Bronze`

### ⚙️ Silver Layer
- Purpose: Clean, standardize, integrate data
- Transformations:
  - Trim spaces
  - Normalize values (gender, marital status)
  - Handle nulls and duplicates
  - Derive missing fields
- Schema: `Silver`

### 💠 Gold Layer
- Purpose: Build dimensional model for reporting
- Includes:
  - Dimensions: `dim_customers`, `dim_products`
  - Fact Table: `fact_sales`
- Schema: `Gold`

---

## 🛠️ Tools Used

- Microsoft SQL Server Express
- SSMS (SQL Server Management Studio)
- Git / GitHub for version control
- Docker for local automation

---

## 🐳 Run It Locally With Docker

This project includes a `docker-compose.yaml` file that lets you spin up a SQL Server instance and automatically deploy your entire data warehouse — no manual setup required!

### ✅ Prerequisites

Make sure you have these installed:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/ )
- Git (optional, for cloning)

---

### Clone the repo
```bash
git clone https://github.com/yourusername/DataWareHouseProject.git 
cd DataWareHouseProject
```

### 🔧 How to Run

From the root of your project:

```bash
# Step 1: Go to docker folder
cd docker

# Step 2: Start the SQL Server container and deploy DWH
docker-compose up
```
---

## 🔒 Set SA Password

Create a .env file at the root to securely store your SQL Server password:
```
MSSQL_SA_PASSWORD=MyP@ssw0rd
```
---
## 💻 Connect via SSMS or Power BI

Once the container is running, connect using:
| Tool | Connection Info |
|------|-----------------|
| SSMS | Server: localhost<br>Login: sa<br>Password: From `.env` |
| Power BI / Excel | Server: localhost<br>Database: DataWareHouse<br>Authentication: SQL Server<br>User: sa<br>Password: From `.env` |
---

## 📊 Ready for Reporting
These views in the Gold schema are ready for visualization:

gold.dim_customers
gold.dim_products
gold.fact_sales
Use any of the following tools:

Power BI Desktop
Tableau
Excel (via ODBC connection)

