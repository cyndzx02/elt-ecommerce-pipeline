-- ============================================================
-- Schéma en étoile : couche ANALYTICS
-- ============================================================

USE DATABASE ECOMMERCE_DB;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;
USE SCHEMA ANALYTICS;

-- ── Dimension Clients ────────────────────────────────────────
CREATE OR REPLACE VIEW DIM_CUSTOMERS AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
FROM RAW.RAW_CUSTOMERS;

-- ── Dimension Produits ───────────────────────────────────────
CREATE OR REPLACE VIEW DIM_PRODUCTS AS
SELECT
    product_id,
    COALESCE(product_category_name, 'non_renseigné') AS product_category,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM RAW.RAW_PRODUCTS;

-- ── Dimension Temps ─────────────────────────────────────────
CREATE OR REPLACE VIEW DIM_DATE AS
SELECT DISTINCT
    DATE(order_purchase_timestamp)           AS date_day,
    YEAR(order_purchase_timestamp)           AS year,
    MONTH(order_purchase_timestamp)          AS month,
    DAY(order_purchase_timestamp)            AS day,
    DAYOFWEEK(order_purchase_timestamp)      AS day_of_week,
    QUARTER(order_purchase_timestamp)        AS quarter,
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS year_month
FROM RAW.RAW_ORDERS
WHERE order_purchase_timestamp IS NOT NULL;

-- ── Fait Commandes (table centrale) ─────────────────────────
CREATE OR REPLACE VIEW FCT_ORDERS AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    DATE(o.order_purchase_timestamp)             AS order_date,
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS order_month,

    -- Délai de livraison en jours
    DATEDIFF('day',
        o.order_purchase_timestamp,
        o.order_delivered_customer_date
    ) AS delivery_days,

    -- Livré dans les délais ?
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN TRUE ELSE FALSE
    END AS on_time_delivery,

    -- Montants agrégés depuis les items
    SUM(i.price)          AS total_revenue,
    SUM(i.freight_value)  AS total_freight,
    COUNT(i.order_item_id) AS total_items,

    -- Score moyen avis
    AVG(r.review_score)   AS avg_review_score

FROM RAW.RAW_ORDERS o
LEFT JOIN RAW.RAW_ORDER_ITEMS i    ON o.order_id = i.order_id
LEFT JOIN RAW.RAW_ORDER_REVIEWS r  ON o.order_id = r.order_id
GROUP BY
    o.order_id, o.customer_id, o.order_status,
    o.order_purchase_timestamp, o.order_delivered_customer_date,
    o.order_estimated_delivery_date;

-- ── Quelques requêtes de vérification ───────────────────────

-- Top 10 mois par chiffre d'affaires
SELECT
    order_month,
    COUNT(order_id)        AS nb_commandes,
    ROUND(SUM(total_revenue), 2) AS ca_total
FROM FCT_ORDERS
GROUP BY order_month
ORDER BY order_month;

-- Taux de livraison dans les délais
SELECT
    ROUND(100.0 * SUM(CASE WHEN on_time_delivery THEN 1 END) / COUNT(*), 1) AS pct_on_time
FROM FCT_ORDERS
WHERE order_status = 'delivered';
