# E-Commerce Database ERD

```mermaid
erDiagram
    customers ||--o{ orders : places
    orders ||--o{ order_items : contains
    products ||--o{ order_items : appears_in
    sellers ||--o{ order_items : supplies
    orders ||--o{ order_payments : has
    orders ||--o{ order_reviews : receives

    customers {
        TEXT customer_id PK
        TEXT customer_unique_id
        TEXT customer_zip_code_prefix
        TEXT customer_city
        TEXT customer_state
    }

    orders {
        TEXT order_id PK
        TEXT customer_id FK
        TEXT order_status
        TIMESTAMP order_purchase_timestamp
        TIMESTAMP order_approved_at
        TIMESTAMP order_delivered_carrier_date
        TIMESTAMP order_delivered_customer_date
        TIMESTAMP order_estimated_delivery_date
    }

    products {
        TEXT product_id PK
        TEXT product_category_name
        INTEGER product_name_lenght
        INTEGER product_description_lenght
        INTEGER product_photos_qty
        NUMERIC product_weight_g
        NUMERIC product_length_cm
        NUMERIC product_height_cm
        NUMERIC product_width_cm
    }

    sellers {
        TEXT seller_id PK
        TEXT seller_zip_code_prefix
        TEXT seller_city
        TEXT seller_state
    }

    order_items {
        TEXT order_id PK, FK
        INTEGER order_item_id PK
        TEXT product_id FK
        TEXT seller_id FK
        TIMESTAMP shipping_limit_date
        NUMERIC price
        NUMERIC freight_value
    }

    order_payments {
        TEXT order_id PK, FK
        INTEGER payment_sequential PK
        TEXT payment_type
        INTEGER payment_installments
        NUMERIC payment_value
    }

    order_reviews {
        TEXT review_id PK
        TEXT order_id PK, FK
        INTEGER review_score
        TEXT review_comment_title
        TEXT review_comment_message
        TIMESTAMP review_creation_date
        TIMESTAMP review_answer_timestamp
    }

    product_category_name_translation {
        TEXT product_category_name PK
        TEXT product_category_name_english
    }

    geolocation {
        TEXT geolocation_zip_code_prefix
        NUMERIC geolocation_lat
        NUMERIC geolocation_lng
        TEXT geolocation_city
        TEXT geolocation_state
    }
```

## Relationship Summary

- One customer can place many orders through `orders.customer_id`.
- One order can contain many order items through `order_items.order_id`.
- One product can appear in many order items through `order_items.product_id`.
- One seller can supply many order items through `order_items.seller_id`.
- One order can have many payment records through `order_payments.order_id`.
- One order can have many review records through `order_reviews.order_id`.

`order_items` uses the composite primary key `(order_id, order_item_id)`. `order_payments` uses `(order_id, payment_sequential)`, and `order_reviews` uses `(review_id, order_id)`.

`product_category_name_translation` and `geolocation` are intentionally shown without relationship lines because the current schema does not declare foreign keys for them. Geolocation is not linked by a foreign key because `geolocation_zip_code_prefix` is not treated as a unique key and can have multiple coordinate observations.
