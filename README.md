[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![SQL Server](https://img.shields.io/badge/SQL_Server-2022-brightgreen.svg)](https://www.microsoft.com/sql-server)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](#-run-it-locally-with-docker)

# 🏗️ Medallion-Data-Warehouse

This is a complete, end-to-end **SQL-based data warehouse** built using **Microsoft SQL Server** and Docker. It demonstrates a classic medallion architecture (Bronze, Silver, Gold) for transforming raw data into business-ready insights.

All scripts are version-controlled, documented, and containerized for easy and repeatable deployment.

---

## 🧱 Architecture Overview

The data warehouse follows a layered approach to ensure data quality, traceability, and scalability.

### 🔷 Bronze Layer (Schema: `Bronze`)
- **Purpose**: Ingests raw, unaltered data from various source systems (CRM, ERP).
- **Process**: Data is loaded from CSV files using `BULK INSERT`. Tables in this layer are truncated and reloaded on each run.

### ⚙️ Silver Layer (Schema: `Silver`)
- **Purpose**: Cleanses, standardizes, and integrates data from the Bronze layer.
- **Transformations**:
  - Deduplication of records.
  - Standardization of values (e.g., 'M' -> 'Male').
  - Data type correction (e.g., string dates to `DATE`).
  - Business rule enforcement.

### 💠 Gold Layer (Schema: `Gold`)
- **Purpose**: Provides a business-ready, dimensional model (Star Schema) for reporting and analytics.
- **Structure**:
  - **Dimensions**: `dim_customers`, `dim_products`
  - **Fact Table**: `fact_sales`
- **Implementation**: These are implemented as views on top of the Silver layer, ensuring they always reflect the latest data without physical duplication.

---

## 📂 Project Structure

The repository is organized to separate concerns and make navigation intuitive.

```
.
├── datasets/         # Source CSV files (CRM and ERP)
├── docker/           # Docker configuration
│   └── docker-compose.yaml
├── scripts/          # All SQL scripts, organized by layer
│   ├── Bronze/
│   ├── Silver/
│   ├── Gold/
│   └── init_database.sql
├── tests/            # Data quality check scripts
└── README.md
```

---

## 🐳 Run It Locally With Docker

This project is fully containerized. The `docker-compose.yaml` file automates the entire setup process.

### ✅ Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
- Git (for cloning the repository).

### ⚙️ Setup Instructions

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/DataWareHouseProject.git
    cd DataWareHouseProject
    ```

2.  **Set the Database Password**
    Create a file named `.env` in the project root directory. This file is git-ignored and will store your database password securely. Add the following line to it:
    ```
    MSSQL_SA_PASSWORD=YourStrong@Password123
    ```
    *Note: Replace `YourStrong@Password123` with a strong password of your choice.*

3.  **Build and Run the Container**
    From the **root of the project directory**, run the following command:
    ```bash
    docker-compose -f docker/docker-compose.yaml up --build
    ```
    This command will:
    - Pull the SQL Server 2022 image.
    - Start the container.
    - Automatically run all the initialization scripts located in the `scripts/` directory to create the database, schemas, and tables.

---

## 🔄 Running the ETL Process

After the container is up and running, the database structure will be in place, but the tables will be empty. To populate the data warehouse, you need to execute the loading procedures in the correct order.

You can do this using a SQL client like SSMS, Azure Data Studio, or DBeaver.

1.  **Connect to the Database**
    | Parameter      | Value                     |
    |----------------|---------------------------|
    | **Server**     | `localhost`               |
    | **Port**       | `1433`                    |
    | **Login**      | `sa`                      |
    | **Password**   | The one you set in `.env` |
    | **Database**   | `DataWareHouse`           |

2.  **Execute Loading Procedures**
    Run the following SQL commands in order:
    ```sql
    -- 1. Load raw data into the Bronze layer
    EXEC Bronze.load_Bronze;

    -- 2. Transform and load data into the Silver layer
    EXEC Silver.load_Silver;
    ```
    The Gold layer consists of views, so it updates automatically as the Silver layer is populated.

---

## ✅ Data Quality Checks

The project includes scripts to validate the data in the Silver and Gold layers. You can run these from your SQL client at any time after the ETL process to check for integrity issues.

-   **To check the Silver layer:**
    Execute the contents of `tests/quality_check_Silver.sql`.
-   **To check the Gold layer:**
    Execute the contents of `tests/quality_check_Gold.sql`.

These scripts will print messages and return rows for any data that fails the quality checks (e.g., duplicates, broken referential integrity).

---

## 📊 Ready for Reporting

The Gold layer views are designed for consumption by BI tools. Connect your favorite tool (Power BI, Tableau, Excel) to the database using the connection details above to start building reports and dashboards.

-   `gold.dim_customers`
-   `gold.dim_products`
-   `gold.fact_sales`

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork this repo, add features, and submit a pull request.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
