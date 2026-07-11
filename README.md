
# E-commerce Analytics Engineering Pipeline

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

# Architecture

```
Raw Databricks Tables
          |
          v
     Source Layer
          |
          v
       Bronze
 (Light transformations)
          |
          v
       Silver
(Cleansing and standardization)
          |
          v
        Gold
(Dimension and Fact Models)
          |
          v
        KPI
(Business Metrics Layer)
          |
          v
Power BI / Looker Studio
```

---

# Technology Stack

| Technology               | Purpose                               |
| ------------------------ | ------------------------------------- |
| Databricks               | Cloud data platform and SQL warehouse |
| dbt Core                 | Data transformation framework         |
| dbt Databricks Adapter   | Databricks connectivity               |
| Apache Iceberg           | Table format                          |
| Python                   | Project environment management        |
| uv                       | Dependency management                 |
| Jinja                    | Dynamic SQL generation                |
| Power BI / Looker Studio | Data visualization                    |

---

# Data Flow

## Source Layer

The source layer defines raw Databricks tables using dbt sources.

Source tables:

* customers
* products
* orders
* payments

The source layer provides:

* Metadata management
* Data lineage
* Freshness monitoring

---

## Bronze Layer

Purpose:

Create a lightly transformed representation of raw data.

Responsibilities:

* Read raw source tables
* Preserve source structure
* Apply minimal transformations
* Prepare data for downstream processing

Models:

* b_customers
* b_products
* b_orders
* b_payments

Materialization:

```
Views
```

---

## Silver Layer

Purpose:

Clean and standardize data.

Responsibilities:

* Remove duplicates
* Handle missing values
* Standardize formats
* Apply business rules
* Prepare analytics-ready datasets

Materialization:

```
Tables
```

---

## Gold Layer

Purpose:

Create business-oriented analytical models.

Responsibilities:

* Build fact tables
* Build dimension tables
* Apply business logic
* Optimize reporting queries

Materialization:

```
Tables
```

---

## KPI Layer

Purpose:

Create aggregated business metrics.

Examples:

* Revenue metrics
* Customer metrics
* Sales performance
* Order analysis

These models are designed for dashboard consumption.

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

