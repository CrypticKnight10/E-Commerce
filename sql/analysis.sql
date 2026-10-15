-- Overall Business Performance

-- What is the distribution of orders by order status?
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- What is the total payment value contributed by customers?
SELECT
    SUM(payment_value) AS total_payment_value
FROM order_payments;

-- What is the overall average order value?
-- AOV uses customer payment value divided by distinct orders.
SELECT
    ROUND(
        SUM(payment_value)
        / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS avg_order_value
FROM order_payments;

-- Monthly Performance

-- How do order volume, payment value, and AOV change by month?
-- COUNT(DISTINCT order_id) prevents multiple payment rows from inflating order counts.
SELECT
    TO_CHAR(DATE_TRUNC('month', orders.order_purchase_timestamp), 'YYYY-MM') AS month,
    COUNT(DISTINCT orders.order_id) AS order_count,
    SUM(order_payments.payment_value) AS monthly_payment_value,
    ROUND(
        SUM(order_payments.payment_value)
        / NULLIF(COUNT(DISTINCT orders.order_id), 0),
        2
    ) AS avg_order_value
FROM orders
JOIN order_payments
    ON orders.order_id = order_payments.order_id
GROUP BY month
ORDER BY month;

-- Product / Category Performance

-- Which product categories generate the most product sales value?
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

-- Geographic Performance

-- Which customer states generate the most orders and payment value?
SELECT
    customer_state,
    COUNT(DISTINCT orders.order_id) AS order_count,
    SUM(order_payments.payment_value) AS total_payment_value,
    ROUND(
        SUM(order_payments.payment_value)
        / NULLIF(COUNT(DISTINCT orders.order_id), 0),
        2
    ) AS avg_order_value
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_payments
    ON orders.order_id = order_payments.order_id
GROUP BY customer_state
ORDER BY total_payment_value DESC;

-- Seller Performance

-- Which sellers generate the most product sales value?
SELECT
    sellers.seller_id,
    sellers.seller_city,
    sellers.seller_state,
    SUM(order_items.price) AS total_sales,
    COUNT(DISTINCT order_items.order_id) AS order_count,
    ROUND(
        SUM(order_items.price)
        / NULLIF(COUNT(DISTINCT order_items.order_id), 0),
        2
    ) AS avg_sales_per_order
FROM order_items
JOIN sellers
    ON order_items.seller_id = sellers.seller_id
GROUP BY
    sellers.seller_id,
    sellers.seller_city,
    sellers.seller_state
ORDER BY total_sales DESC;

-- Which sellers have the highest late-delivery rates among sellers with at least 50 delivered orders?
-- Minimum 50 delivered orders reduces misleading rate rankings from very small seller samples.
WITH seller_delivery AS (
    SELECT
        sellers.seller_id,
        sellers.seller_city,
        sellers.seller_state,
        COUNT(
            DISTINCT CASE
                WHEN orders.order_delivered_customer_date IS NOT NULL
                THEN orders.order_id
            END
        ) AS delivered_orders,
        COUNT(
            DISTINCT CASE
                WHEN orders.order_delivered_customer_date IS NOT NULL
                     AND orders.order_delivered_customer_date > orders.order_estimated_delivery_date
                THEN orders.order_id
            END
        ) AS late_orders
    FROM orders
    JOIN order_items
        ON orders.order_id = order_items.order_id
    JOIN sellers
        ON order_items.seller_id = sellers.seller_id
    GROUP BY
        sellers.seller_id,
        sellers.seller_city,
        sellers.seller_state
)

SELECT
    seller_id,
    seller_city,
    seller_state,
    delivered_orders,
    late_orders,
    ROUND(
        late_orders * 100.0 / NULLIF(delivered_orders, 0),
        2
    ) AS late_delivery_rate
FROM seller_delivery
WHERE delivered_orders >= 50
ORDER BY late_delivery_rate DESC NULLS LAST;

-- Delivery & Customer Satisfaction

-- What percentage of delivered orders are late?
-- Orders without a recorded customer delivery date are excluded from the denominator.
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
        / NULLIF(COUNT(order_delivered_customer_date), 0) * 100,
        2
    ) AS late_delivery_rate
FROM orders;

-- Do late deliveries correspond to lower customer review scores?
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

SELECT
    delivery_status,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(review_score) AS review_count
FROM delivery_data
GROUP BY delivery_status
ORDER BY avg_review_score DESC;

-- Payment Behavior

-- How do payment methods differ in usage and payment value?
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    SUM(payment_value) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY avg_payment_value DESC;

-- Customer Behavior

-- What percentage of customers are repeat purchasers?
-- customer_unique_id represents the underlying customer across orders.
WITH customer_orders AS (
    SELECT
        customers.customer_unique_id,
        COUNT(DISTINCT orders.order_id) AS order_count
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    GROUP BY customers.customer_unique_id
)

SELECT
    COUNT(
        CASE
            WHEN order_count >= 2 THEN 1
        END
    ) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(
            CASE
                WHEN order_count >= 2 THEN 1
            END
        )::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS repeat_customer_rate
FROM customer_orders;

-- Do repeat customers spend more per customer than one-time customers?
WITH customer_value AS (
    SELECT
        customers.customer_unique_id,
        COUNT(DISTINCT orders.order_id) AS order_count,
        SUM(order_payments.payment_value) AS total_spend
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    JOIN order_payments
        ON orders.order_id = order_payments.order_id
    GROUP BY customers.customer_unique_id
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
