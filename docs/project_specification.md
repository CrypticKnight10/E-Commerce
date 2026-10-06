# Project Specification

## Project Title

**E-Commerce Decision Intelligence Platform**

The project will use PostgreSQL, SQL, Python, Tableau, and later machine learning to analyze an e-commerce marketplace and support business decision-making.

## Business Problem

An e-commerce marketplace collects data about orders, customers, products, sellers, payments, deliveries, and customer reviews.

The purpose of this project is to use that data to understand overall business performance, customer behavior, product and seller performance, delivery operations, and customer satisfaction.

The analysis should help identify areas of strong performance, operational problems, and opportunities for improvement.

The project should investigate business questions using the data rather than assume conclusions in advance.

## Stakeholders

### Executive / Marketplace Management

Interested in overall marketplace performance, revenue, growth, major problems, and opportunities.

### Operations / Customer Experience

Interested in delivery performance, late orders, shipping behavior, and customer satisfaction.

### Seller Management

Interested in seller performance, revenue contribution, delivery issues, and customer reviews.

### Marketing / Customer Analytics

Interested in customer behavior, repeat purchases, customer value, segmentation, and retention.

## Dataset

The primary dataset will be the **Olist Brazilian E-Commerce Public Dataset**.

It contains roughly 100,000 anonymized marketplace orders distributed across several related tables, including:

- customers
- orders
- order items
- payments
- reviews
- products
- sellers
- geolocation

The multi-table structure will be used to practice relational database design, primary and foreign keys, joins, and ER diagrams.

The raw Olist CSV files will be downloaded reproducibly into `data/raw/` and will not be committed to the repository.

A separate Olist marketing-funnel dataset may be considered later if it supports a useful business question, but it is not part of the initial scope.

## Tools

Planned tools and technologies:

- PostgreSQL
- SQL
- Python
- pandas
- NumPy when needed
- Tableau / Tableau Public
- scikit-learn later in the project
- Git
- GitHub
- VS Code
- Jupyter Notebook

SQL, PostgreSQL, relational database design, business analytics, and Tableau are major learning goals of this project.

Machine learning will come later rather than being the starting point.

## Deliverables

The completed project should include:

1. A clean GitHub repository and project structure
2. A PostgreSQL relational database
3. An ER diagram
4. A documented SQL schema with keys and relationships
5. SQL-based business analysis covering approximately 15–20 meaningful business questions
6. Python-based customer and business analysis
7. RFM/customer segmentation
8. Delivery and customer satisfaction analysis
9. A Tableau executive dashboard
10. A classification model predicting whether an order will arrive late
11. Business findings and recommendations
12. A polished GitHub README
13. Resume-ready project bullets or summary

## Folder Structure

```text
ecommerce/
├── data/
│   └── raw/
├── sql/
│   ├── schema.sql
│   ├── load_data.sql
│   └── analysis.sql
├── notebooks/
│   ├── 01_business_analysis.ipynb
│   ├── 02_customer_analysis.ipynb
│   └── 03_delivery_prediction.ipynb
├── scripts/
│   └── download_data.py
├── dashboard/
├── images/
├── docs/
│   └── project_specification.md
├── README.md
├── requirements.txt
└── .gitignore
```

Additional files or folders should only be added when the project genuinely needs them.

## Definition of Finished

The project will be considered finished when:

1. The Olist data has been modeled and loaded into a functioning PostgreSQL relational database.
2. The database structure, table relationships, primary keys, and foreign keys can be clearly explained.
3. Approximately 15–20 meaningful business questions have been answered primarily using SQL.
4. Deeper customer and operational analysis has been completed in Python.
5. Customer segmentation or RFM analysis has been completed and interpreted.
6. A polished Tableau dashboard communicates the most important KPIs and findings.
7. A classification model has been built and appropriately evaluated for predicting late deliveries.
8. The analysis has been translated into defensible business findings and recommendations.
9. The GitHub repository contains clean code, documentation, SQL files, notebooks, dashboard material, and reproducible setup information.
10. The README clearly explains the business problem, approach, analysis, findings, and recommendations.
11. I can personally explain and defend the major technical and analytical decisions in the project during an internship interview.

Do not add analysis results, SQL code, database implementation, machine learning code, or assumptions about what the dataset will show.
