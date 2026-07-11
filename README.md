
# E-commerce Analytics Engineering Pipeline

# Business Problem

E-commerce businesses generate data from multiple operational systems such as orders, customers, products, and payments.

However, raw transactional data often contains:

- inconsistent formatting
- duplicate records
- missing values
- payment inconsistencies
- non-standardized business attributes

This project builds an analytics engineering pipeline that transforms raw operational data into trusted analytical datasets for reporting, KPI tracking, and self-service BI analytics.

# Project Goals

The main objectives of this project are:

- Build an end-to-end ELT pipeline using dbt and Databricks
- Implement medallion architecture for scalable transformations
- Apply dimensional modeling principles
- Create reusable analytics models
- Implement automated data quality checks
- Generate BI-ready datasets

## Project Overview

This project demonstrates an end-to-end analytics engineering pipeline built using **Databricks and dbt**.

The objective of this project is to transform raw e-commerce transactional data into clean, reliable, and business-ready datasets that can be consumed by analytics and BI tools.

The pipeline follows a **Medallion Architecture** approach:

* Raw Layer
* Bronze Layer
* Silver Layer
* Gold Layer
* KPI Layer
* BI Consumption Layer

The project uses dbt for:

* Data transformation
* Data modeling
* Data quality testing
* Documentation generation
* Dependency management

---

# Data Architecture

The project follows a **Medallion Architecture** pattern using dbt and Databricks.

```text
                         Databricks Platform
                                |
                                |
                         RAW Source Tables
                                |
          -----------------------------------------------
          |              |              |               |
      customers       orders        products       payments
          |
          v

                  dbt Source Layer
                     (0_source)

              source('raw', table_name)

                                |
                                v

                    Bronze Layer (Views)
                     models/1_bronze

          -----------------------------------------------
          |              |              |               |
    b_customers     b_orders     b_products      b_payments

          Purpose:
          - Preserve source structure
          - Apply light transformations
          - Prepare data for cleansing


                                |
                                v

                    Silver Layer (Tables)
                     models/2_silver

          -----------------------------------------------
          |              |              |               |
    s_customers     s_orders     s_products      s_payments

          Purpose:
          - Data cleaning
          - Standardization
          - Business rules
          - Data quality improvements


                                |
                                v

                     Gold Layer (Tables)
                      models/3_gold

          -------------------------------------------------
          |              |              |                 |
   dim_customers   dim_products    dim_date        fact_orders
                                                     |
                                                     |
                                              fact_payments
                                                     |
                                                     |
                                          bridge_orders_payment

          Purpose:
          - Dimensional modeling
          - Fact and dimension tables
          - Analytics-ready datasets


                                |
                                v

                     KPI Layer (Tables)
                      models/4_kpi

          -------------------------------------------------
          |              |              |                 |
    kpi_customer   kpi_orders   kpi_payment   kpi_data_quality

                                |
                                v

                         OBT Layer

                       obt_orders

                                |
                                v

                    BI Consumption Layer

                 Power BI / Looker Studio
```

# dbt Model Structure

## Source Layer

Location:

```
models/0_source
```

Source definitions are maintained in:

```
sources.yml
```

Raw source tables:

| Source Table |
| ------------ |
| customers    |
| orders       |
| products     |
| payments     |

The source layer provides:

* Metadata management
* Source documentation
* Freshness monitoring
* Data lineage tracking

---

# Bronze Layer

Location:

```
models/1_bronze
```

Materialization:

```
View
```

Models:

| Bronze Model | Description                      |
| ------------ | -------------------------------- |
| b_customers  | Raw customer data representation |
| b_orders     | Raw order transaction data       |
| b_products   | Raw product information          |
| b_payments   | Raw payment transaction data     |

Responsibilities:

* Minimal transformation
* Preserve source structure
* Prepare raw data for cleaning

---

# Silver Layer

Location:

```
models/2_silver
```

Materialization:

```
Table
```

Models:

| Silver Model | Purpose                         |
| ------------ | ------------------------------- |
| s_customers  | Cleaned customer information    |
| s_orders     | Standardized order transactions |
| s_products   | Cleaned product attributes      |
| s_payments   | Standardized payment records    |

Responsibilities:

* Remove inconsistencies
* Standardize formats
* Apply business rules
* Improve data quality

---

# Gold Layer

Location:

```
models/3_gold
```

Materialization:

```
Table
```

Models:

| Model                 | Type      | Purpose                    |
| --------------------- | --------- | -------------------------- |
| dim_customers         | Dimension | Customer analytics         |
| dim_products          | Dimension | Product analytics          |
| dim_date              | Dimension | Date-based analysis        |
| fact_orders           | Fact      | Order-level metrics        |
| fact_payments         | Fact      | Payment-level metrics      |
| bridge_orders_payment | Bridge    | Order-payment relationship |

The Gold layer follows dimensional modeling principles and provides analytics-ready datasets.

---

# KPI Layer

Location:

```
models/4_kpi
```

Models:

| Model            | Purpose                            |
| ---------------- | ---------------------------------- |
| kpi_customer     | Customer metrics                   |
| kpi_orders       | Order metrics                      |
| kpi_payment      | Payment metrics                    |
| kpi_data_quality | Data quality monitoring            |
| obt_orders       | Dashboard-ready denormalized table |

The KPI layer is optimized for BI tools and self-service analytics.


# Key Data Models

## Order Processing Pipeline

The order lifecycle flows through multiple layers:

```text
raw.orders
    |
    v
b_orders
(Bronze - raw representation)
    |
    v
s_orders
(Silver - cleaned and deduplicated)
    |
    v
fact_orders
(Gold - business transaction model)
    |
    +----------------+
    |                |
    v                v
kpi_orders       obt_orders
(Business       (BI-ready
 metrics)       dataset)
```

---

## Silver Transformation Logic

The `s_orders` model performs:

* Order status standardization
* Amount field cleansing
* Duplicate removal
* Incremental processing using `updated_at`
* Latest record selection using window functions

---

## Gold Business Logic

The `fact_orders` model creates:

* Payment validation checks
* Payment variance calculations
* Order severity classification
* Customer order ranking
* Repeat customer identification
* Customer purchase intervals

---

## BI Consumption

The `obt_orders` model provides a flattened analytics table containing:

* Customer attributes
* Product attributes
* Order details
* Payment information
* Date attributes
* Customer behavior metrics

This model is designed for self-service analytics tools such as Power BI and Looker Studio.

---

## Materialization Strategy

| Layer | Materialization | Reason |
|---|---|---|
| Bronze | View | Lightweight representation of source data |
| Silver | Incremental Table | Process only new/updated records |
| Gold | Incremental Table | Optimize large analytical models |
| KPI | Table | Optimized for reporting |

---

# Technology Stack

| Technology               | Purpose                               |
| ------------------------ | ------------------------------------- |
| Databricks               | Cloud data platform and SQL warehouse |
| dbt Core                 | Data transformation framework         |
| dbt Databricks Adapter   | Databricks connectivity               |
| Apache Iceberg           | Managed table format                  |
| Python                   | Project environment management        |
| uv                       | Dependency management                 |
| Jinja                    | Dynamic SQL generation                |
| Power BI / Looker Studio | Data visualization                    |


---

## Quality Checks Implemented

### 1. Payment Mismatch Detection

Test:

```
payment_mismatch_anomaly.sql
```

Purpose:

Identifies individual orders where payment amounts do not match order amounts.

The test detects:

* Underpayments
* Overpayments
* Missing payment values
* Payment processing inconsistencies

The validation is performed against the Gold layer:

```
fact_orders
```

---

### 2. Payment Mismatch Threshold Monitoring

Test:

```
payment_mismatch_threshold.sql
```

Purpose:

Monitors overall payment quality across the dataset.

Business rule:

```
Payment mismatches should be below 30% of total orders
```

If mismatches exceed the threshold, the dbt test fails and indicates a potential upstream data issue.

---

### 3. Revenue Validation

Test:

```
kpi_revenue_non_negative.sql
```

Purpose:

Ensures revenue metrics remain valid.

Rule:

```
total_revenue >= 0
```

This protects downstream dashboards from displaying incorrect financial metrics.

# Engineering Decisions

## Incremental Processing

Large transactional tables are implemented using dbt incremental models.

Example:

- s_orders
- fact_orders

Incremental loading uses updated timestamps to process only changed records.

Benefits:

- Reduced compute cost
- Faster execution
- Scalable processing


## Deduplication Strategy

The pipeline uses window functions:

ROW_NUMBER()

to identify the latest version of records based on updated timestamps.


## Dimensional Modeling

The Gold layer follows a star schema approach:

Fact Tables:

- fact_orders
- fact_payments


Dimension Tables:

- dim_customers
- dim_products
- dim_date

---

## Data Quality Flow

```
Raw Data
   |
   v
Bronze
   |
   v
Silver
   |
   v
Gold
   |
   v
Data Quality Tests
   |
   v
KPI / BI Reporting
```

```
dbt build
    |
    +-- Models
    |
    +-- Tests
    |
    +-- Documentation
```

This ensures only validated data reaches analytics consumers.

---

# Project Structure

```
.
├── analyses/
├── macros/
├── models/
│   ├── 0_source/
│   ├── 1_bronze/
│   ├── 2_silver/
│   ├── 3_gold/
│   └── 4_kpi/
│
├── seeds/
├── snapshots/
├── tests/
│
├── dbt_project.yml
└── README.md
```

---

# dbt Commands

Initialize dependencies:

```bash
uv sync
```

Activate environment:

```powershell
.\.venv\Scripts\activate.ps1
```

Install dbt packages:

```bash
uv add dbt-core dbt-databricks
```

---

## Validate Connection

```bash
dbt debug
```

---

## Run Models

Run all models:

```bash
dbt run
```

Run specific models:

```bash
dbt run --select model_name
```

---

## Testing

Run all tests:

```bash
dbt test
```

Run complete pipeline:

```bash
dbt build
```

---

## Documentation

Generate documentation:

```bash
dbt docs generate
```

View documentation:

```bash
dbt docs serve
```

---

# Data Quality

The project includes dbt tests such as:

* not_null checks
* relationship validation
* custom anomaly tests

Examples:

* Ensuring IDs are present
* Validating relationships between tables
* Detecting payment inconsistencies

---

# Future Improvements

Potential enhancements:

* Add CI/CD pipeline using GitHub Actions
* Add automated deployment workflow
* Add incremental models for large datasets
* Add more comprehensive data quality monitoring
* Add dashboard screenshots

# Current Limitations

- Pipeline currently runs locally using dbt Core
- Deployment automation is not implemented
- Source ingestion is simulated using Databricks raw tables
- Monitoring is implemented through dbt tests but not external alerting