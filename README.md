# E-Commerce Decision Intelligence Platform

This project analyzes an e-commerce marketplace using PostgreSQL, SQL, Python, Tableau, and later machine learning.

**Status: in progress.** The database, the SQL business analysis, and the first Python analysis (delivery performance and customer reviews) are complete. Next: product category analysis, customer segmentation, a Tableau dashboard, and a late-delivery prediction model.

## Data Setup

This project uses the **Olist Brazilian E-Commerce Public Dataset**. The raw dataset is intentionally not stored in the repository and can be downloaded reproducibly with KaggleHub.

From the project root, install the dependencies and run the download script:

```bash
pip install -r requirements.txt
python scripts/download_data.py
```

The script downloads the source CSV files into `data/raw/`.

Dataset identifier:

```text
olistbr/brazilian-ecommerce
```
