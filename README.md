# Quick-Bite Food Delivery Platform

A complete **MySQL database design project** for a food-delivery platform (similar to Swiggy/Zomato). It includes schema design, indexes, triggers, views, stored procedures, sample data, and **36 business-oriented SQL queries** with a Python validation script.

## Features

| Component | Details |
|-----------|---------|
| **Tables** | 23 normalized tables (users, restaurants, orders, payments, delivery, wallet, complaints, refunds, etc.) |
| **Indexes** | Performance indexes on high-traffic columns (no redundant UNIQUE indexes) |
| **Triggers** | 5 triggers — auto-update restaurant ratings, wallet credit/debit on refund/payment |
| **Views** | 3 views — order summary, restaurant leaderboard, menu with category |
| **Stored procedure** | `place_order` — transactional cart checkout |
| **Core queries** | 11 fundamental SQL queries (`queries.sql`) |
| **Analytics** | 15 KPI queries — revenue, CLV, retention, delivery ops (`04_analytics_queries.sql`) |
| **Real-world** | 10 audit/reconciliation queries (`05_real_world_questions.sql`) |
| **Sample data** | Realistic Indian city data (Bangalore, Mumbai, Delhi, etc.) |
| **Validation** | `validate_project.py` — automated schema and query checks |

## Project structure

```
├── 01_ddl.sql                  # CREATE TABLE statements (23 tables)
├── 02_indexes.sql              # Index definitions
├── 03_views_triggers.sql       # Views, triggers, stored procedure
├── sample_inserts.sql          # Sample data (~10 rows per table)
├── queries.sql                 # 11 core queries
├── 04_analytics_queries.sql    # 15 business analytics queries
├── 05_real_world_questions.sql # 10 real-world scenario queries
├── validate_project.py         # Automated validation script
└── validate_results.txt        # Last validation run output
```

## Database schema (high level)

```
Users ──┬── User_Address (via User_Has_Address)
        ├── Cart ── Cart_Item ── Menu_Item
        ├── Orders ── Order_Item
        │            ├── Payment
        │            ├── Delivery ── Delivery_Partner
        │            ├── Discount
        │            ├── Complaint ── Refund ── Wallet
        │            └── Cancellation
        └── Wallet ── Wallet_Transaction / Wallet_TopUP

Restaurant ──┬── Restaurant_Address
             ├── Cuisine
             ├── Menu_Category ── Menu_Item
             └── Review
```

## Prerequisites

- **MySQL 8.0+** (recommended — full support for triggers, views, stored procedures)
- **Python 3.8+** (optional, for validation script)
- MySQL client: `mysql` CLI, MySQL Workbench, or DBeaver

## Quick start (MySQL)

### 1. Create database

```sql
CREATE DATABASE quick_bite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quick_bite;
```

### 2. Run scripts in order

```bash
mysql -u root -p quick_bite < 01_ddl.sql
mysql -u root -p quick_bite < 02_indexes.sql
mysql -u root -p quick_bite < 03_views_triggers.sql
mysql -u root -p quick_bite < sample_inserts.sql
```

Or inside the MySQL shell:

```sql
SOURCE 01_ddl.sql;
SOURCE 02_indexes.sql;
SOURCE 03_views_triggers.sql;
SOURCE sample_inserts.sql;
```

### 3. Run queries

```bash
mysql -u root -p quick_bite < queries.sql
mysql -u root -p quick_bite < 04_analytics_queries.sql
mysql -u root -p quick_bite < 05_real_world_questions.sql
```

## Validation script

```bash
python validate_project.py
```

This loads the schema into an in-memory SQLite database, runs inserts and queries, and writes results to `validate_results.txt`.

> **Note:** DDL uses MySQL-specific syntax (`AUTO_INCREMENT`, `ENUM`, `DELIMITER`). For full feature support (triggers, procedures), use MySQL. The validation script skips MySQL-only objects when testing on SQLite.

## Query categories

### Core queries (`queries.sql`)
- Customer lookup and filtering
- Spending analysis and order counts
- Pagination, aggregates, subqueries

### Analytics (`04_analytics_queries.sql`)
- **Revenue & finance** — restaurant leaderboard, CLV, payment mode split
- **Customer behaviour** — new vs returning, repeat customers, abandoned carts
- **Restaurant KPIs** — performance dashboard, top-rated restaurants
- **Delivery ops** — partner scorecard, average delivery duration
- **Menu intelligence** — best sellers, dead stock
- **Wallet & payments** — balance summary
- **Complaints & refunds** — resolution rate, refund impact

### Real-world scenarios (`05_real_world_questions.sql`)
- Hyperlocal marketing (same-city orders)
- Payment reconciliation audits
- Slow delivery detection
- VIP loyalty candidates
- Pending refund alerts

## Tech stack

- **Database:** MySQL 8.0 (InnoDB)
- **Language:** SQL, Python 3
- **Concepts:** Normalization, foreign keys, CHECK constraints, indexes, triggers, views, stored procedures

## Author

**Vivek** — DBMS / SQL portfolio project

## License

This project is open source and available under the [MIT License](LICENSE).
