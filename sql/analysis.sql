-- Calculates monthly unique order count, monthly total payment value, and monthly average order value.
SELECT
    TO_CHAR(DATE_TRUNC('month', orders.order_purchase_timestamp), 'YYYY-MM') AS month,
    COUNT(DISTINCT orders.order_id) AS order_count,
    SUM(order_payments.payment_value) AS monthly_payment_value,
    ROUND(
        SUM(order_payments.payment_value)
        / COUNT(DISTINCT orders.order_id),
        2
    ) AS avg_order_value
FROM orders
JOIN order_payments
    ON orders.order_id = order_payments.order_id
GROUP BY month
ORDER BY month;

-- Identifies product categories with the highest product sales value.
SELECT
    product_category_name_translation.product_category_name_english AS category,
    SUM(order_items.price) AS category_sales,
    COUNT(*) AS items_sold,
    ROUND(AVG(order_items.price), 2) AS avg_item_price
FROM order_items
JOIN products
    ON order_items.product_id = products.product_id
JOIN product_category_name_translation
    ON products.product_category_name =
       product_category_name_translation.product_category_name
GROUP BY product_category_name_translation.product_category_name_english
ORDER BY category_sales DESC;

-- State-level customer payment and order analysis
SELECT
    customer_state,
    COUNT(DISTINCT orders.order_id) AS order_count,
    SUM(order_payments.payment_value) AS total_payment_value,
    ROUND(
        SUM(order_payments.payment_value)
        / COUNT(DISTINCT orders.order_id),
        2
    ) AS avg_order_value
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_payments
    ON orders.order_id = order_payments.order_id
GROUP BY customer_state
ORDER BY total_payment_value DESC;

-- Seller performance by sales, order volume, AOV, and location
SELECT
    sellers.seller_id,
    sellers.seller_city,
    sellers.seller_state,
    SUM(order_items.price) AS total_sales,
    COUNT(DISTINCT order_items.order_id) AS order_count,
    ROUND(
        SUM(order_items.price)
        / COUNT(DISTINCT order_items.order_id),
        2
    ) AS avg_order_value
FROM order_items
JOIN sellers
    ON order_items.seller_id = sellers.seller_id
GROUP BY
    sellers.seller_id,
    sellers.seller_city,
    sellers.seller_state
ORDER BY total_sales DESC;

-- Overall delivery performance
SELECT
    SUM(
        CASE
            WHEN order_delivered_customer_date IS NOT NULL
                 AND order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    COUNT(order_delivered_customer_date) AS delivered_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date IS NOT NULL
                     AND order_delivered_customer_date > order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        )::NUMERIC
        / COUNT(order_delivered_customer_date) * 100,
        2
    ) AS late_delivery_rate

FROM orders;
