# E-Commerce Decision Intelligence Platform

This project will analyze an e-commerce marketplace using PostgreSQL, SQL, Python, Tableau, and later machine learning.

The project is currently in the setup stage.

## Data Setup

This project uses the **Olist Brazilian E-Commerce Public Dataset**. The raw dataset is intentionally not stored in the repository and can be downloaded reproducibly with KaggleHub.

From the project root, install the dependency and run the download script:

```bash
pip install -r requirements.txt
python scripts/download_data.py
```

The script downloads the source CSV files into `data/raw/`.

Dataset identifier:

```text
olistbr/brazilian-ecommerce
```
