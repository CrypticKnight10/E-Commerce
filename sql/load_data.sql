-- Load customers first because orders references customers.
\copy customers FROM 'data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load orders after customers so the foreign key can be satisfied.
\copy orders FROM 'data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load products before order items because order items reference products.
\copy products FROM 'data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load sellers before order items because order items reference sellers.
\copy sellers FROM 'data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load order items after their orders, products, and sellers exist.
\copy order_items FROM 'data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load payment records after their referenced orders exist.
\copy order_payments FROM 'data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load reviews after their referenced orders exist.
\copy order_reviews FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true);

-- Load the product category translations.
\copy product_category_name_translation FROM 'data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true);

-- Load geographic observations without assuming unique zip prefixes.
\copy geolocation FROM 'data/raw/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true);
