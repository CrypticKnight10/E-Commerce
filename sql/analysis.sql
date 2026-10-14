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

-- Delivery performance vs customer satisfaction
-- CTE means Common Table Expression: a temporary named result that breaks a multi-step analysis into clearer stages.
-- Here, the CTE derives delivery_status first, and the outer query aggregates review scores by that status.
WITH delivery_data AS (
    SELECT
        orders.order_id,
        CASE
            WHEN orders.order_delivered_customer_date IS NOT NULL
                 AND orders.order_delivered_customer_date > orders.order_estimated_delivery_date
                THEN 'Late'
            WHEN orders.order_delivered_customer_date IS NOT NULL
                 AND orders.order_delivered_customer_date <= orders.order_estimated_delivery_date
                THEN 'On Time'
            ELSE 'Not Delivered'
        END AS delivery_status,
        order_reviews.review_score
    FROM orders
    JOIN order_reviews
        ON orders.order_id = order_reviews.order_id
    WHERE orders.order_delivered_customer_date IS NOT NULL
)

-- COUNT(column) ignores NULL values. AVG(column) calculates the arithmetic mean, conceptually equivalent to SUM(column) / COUNT(column) for non-NULL values.
SELECT
    delivery_status,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(review_score) AS review_count
FROM delivery_data
GROUP BY delivery_status
ORDER BY avg_review_score DESC;

-- Payment method analysis
-- COUNT, SUM, and AVG calculate metrics over each GROUP BY group.
-- Aliases created with AS give calculated columns readable names and can be used in ORDER BY.
-- This counts payment records, not unique orders, because order_payments can contain multiple rows for one order.
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    SUM(payment_value) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY avg_payment_value DESC;

-- Repeat customer spending analysis
-- Customer grain matters: the CTE creates one row per customer before comparing customer segments.
-- CASE WHEN turns a numeric condition into a business category such as One-time versus Repeat.
-- A CTE separates customer-level calculations from the final segment-level aggregation.
-- AVG(total_spend) is appropriate for average spend per customer because the CTE contains one row per customer.
WITH customer_value AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT orders.order_id) AS order_count,
        SUM(order_payments.payment_value) AS total_spend
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    JOIN order_payments
        ON orders.order_id = order_payments.order_id
    GROUP BY customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count,
    SUM(total_spend) AS total_spend,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_customer
FROM customer_value
GROUP BY customer_type
ORDER BY avg_spend_per_customer DESC;
