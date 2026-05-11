-- Création de la base de données et du schéma RAW
CREATE DATABASE IF NOT EXISTS ECOMMERCE_DB;
USE DATABASE ECOMMERCE_DB;

CREATE SCHEMA IF NOT EXISTS RAW;
USE SCHEMA RAW;

-- Table des commandes
CREATE OR REPLACE TABLE RAW_ORDERS (
    order_id              VARCHAR(50),
    customer_id           VARCHAR(50),
    order_status          VARCHAR(30),
    order_purchase_timestamp  TIMESTAMP_NTZ,
    order_approved_at         TIMESTAMP_NTZ,
    order_delivered_carrier_date TIMESTAMP_NTZ,
    order_delivered_customer_date TIMESTAMP_NTZ,
    order_estimated_delivery_date TIMESTAMP_NTZ
);

-- Table des clients
CREATE OR REPLACE TABLE RAW_CUSTOMERS (
    customer_id           VARCHAR(50),
    customer_unique_id    VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city         VARCHAR(100),
    customer_state        VARCHAR(5)
);

-- Table des produits
CREATE OR REPLACE TABLE RAW_PRODUCTS (
    product_id            VARCHAR(50),
    product_category_name VARCHAR(100),
    product_weight_g      FLOAT,
    product_length_cm     FLOAT,
    product_height_cm     FLOAT,
    product_width_cm      FLOAT
);

-- Table des items de commandes
CREATE OR REPLACE TABLE RAW_ORDER_ITEMS (
    order_id              VARCHAR(50),
    order_item_id         INT,
    product_id            VARCHAR(50),
    seller_id             VARCHAR(50),
    shipping_limit_date   TIMESTAMP_NTZ,
    price                 FLOAT,
    freight_value         FLOAT
);

-- Table des paiements
CREATE OR REPLACE TABLE RAW_ORDER_PAYMENTS (
    order_id              VARCHAR(50),
    payment_sequential    INT,
    payment_type          VARCHAR(30),
    payment_installments  INT,
    payment_value         FLOAT
);

-- Table des avis clients
CREATE OR REPLACE TABLE RAW_ORDER_REVIEWS (
    review_id             VARCHAR(50),
    order_id              VARCHAR(50),
    review_score          INT,
    review_creation_date  TIMESTAMP_NTZ,
    review_answer_timestamp TIMESTAMP_NTZ
);

-- Vérification
SHOW TABLES IN SCHEMA RAW;
