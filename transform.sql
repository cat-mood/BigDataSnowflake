-- COUNTRY
CREATE TABLE IF NOT EXISTS country (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT UNIQUE NOT NULL
);

-- CITY
CREATE TABLE IF NOT EXISTS city (
    city_id SERIAL PRIMARY KEY,
    city_name TEXT UNIQUE NOT NULL
);

-- PET CATEGORY
CREATE TABLE IF NOT EXISTS pet_category (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL
);

-- PRODUCT CATEGORY
CREATE TABLE IF NOT EXISTS product_category (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL
);

-- PRODUCT BRAND
CREATE TABLE IF NOT EXISTS product_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name TEXT UNIQUE NOT NULL
);

-- SUPPLIER
CREATE TABLE IF NOT EXISTS supplier (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city_id INT REFERENCES city(city_id),
    country_id INT REFERENCES country(country_id)
);

-- PET
CREATE TABLE IF NOT EXISTS pet (
    pet_id SERIAL PRIMARY KEY,
    type TEXT,
    name TEXT,
    breed TEXT,
    category_id INT REFERENCES pet_category(category_id)
);

-- CUSTOMER
CREATE TABLE IF NOT EXISTS customer (
    customer_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INT,
    email TEXT,
    postal_code TEXT,
    country_id INT REFERENCES country(country_id),
    pet_id INT REFERENCES pet(pet_id)
);

-- SELLER
CREATE TABLE IF NOT EXISTS seller (
    seller_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    postal_code TEXT,
    country_id INT REFERENCES country(country_id)
);

-- PRODUCT
CREATE TABLE IF NOT EXISTS product (
    product_id INT PRIMARY KEY,
    name TEXT,
    price NUMERIC,
    weight NUMERIC,
    color TEXT,
    size TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC,
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    category_id INT REFERENCES product_category(category_id),
    brand_id INT REFERENCES product_brand(brand_id),
    supplier_id INT REFERENCES supplier(supplier_id)
);

-- STORE
CREATE TABLE IF NOT EXISTS store (
    store_id SERIAL PRIMARY KEY,
    name TEXT,
    location TEXT,
    state TEXT,
    phone TEXT,
    email TEXT,
    city_id INT REFERENCES city(city_id),
    country_id INT REFERENCES country(country_id)
);

-- SALES FACT
CREATE TABLE IF NOT EXISTS sales_fact (
    sale_id SERIAL PRIMARY KEY,
    sale_date DATE,
    quantity INT,
    total_price NUMERIC,
    customer_id INT REFERENCES customer(customer_id),
    seller_id INT REFERENCES seller(seller_id),
    product_id INT REFERENCES product(product_id),
    store_id INT REFERENCES store(store_id)
);


-- Step 1: Create normalized reference tables (deduplicated)
-- COUNTRY
INSERT INTO country (country_name)
SELECT DISTINCT customer_country FROM raw_data
UNION
SELECT DISTINCT seller_country FROM raw_data
UNION
SELECT DISTINCT store_country FROM raw_data
UNION
SELECT DISTINCT supplier_country FROM raw_data;

-- CITY
INSERT INTO city (city_name)
SELECT DISTINCT store_city FROM raw_data
UNION
SELECT DISTINCT supplier_city FROM raw_data;

-- PET CATEGORY
INSERT INTO pet_category (category_name)
SELECT DISTINCT pet_category FROM raw_data;

-- PRODUCT CATEGORY
INSERT INTO product_category (category_name)
SELECT DISTINCT product_category FROM raw_data;

-- PRODUCT BRAND
INSERT INTO product_brand (brand_name)
SELECT DISTINCT product_brand FROM raw_data;


-- PET
INSERT INTO pet (type, name, breed, category_id)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    pc.category_id
FROM raw_data r
JOIN pet_category pc ON r.pet_category = pc.category_name;

-- CUSTOMER
INSERT INTO customer (customer_id, first_name, last_name, age, email, postal_code, country_id, pet_id)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_postal_code,
    c.country_id,
    p.pet_id
FROM raw_data r
JOIN country c ON r.customer_country = c.country_name
JOIN pet p ON r.customer_pet_name = p.name AND r.customer_pet_type = p.type AND r.customer_pet_breed = p.breed;


INSERT INTO seller (seller_id, first_name, last_name, email, postal_code, country_id)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_postal_code,
    c.country_id
FROM raw_data r
JOIN country c ON r.seller_country = c.country_name;


INSERT INTO supplier (name, contact, email, phone, address, city_id, country_id)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    ci.city_id,
    co.country_id
FROM raw_data r
JOIN city ci ON r.supplier_city = ci.city_name
JOIN country co ON r.supplier_country = co.country_name;


INSERT INTO product (
    product_id, name, price, weight, color, size, material, description, rating, reviews,
    release_date, expiry_date, category_id, brand_id, supplier_id
)
SELECT DISTINCT ON (sale_product_id)
    sale_product_id,
    product_name,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    TO_DATE(product_release_date, 'MM/DD/YYYY'),
    TO_DATE(product_expiry_date, 'MM/DD/YYYY'),
    pc.category_id,
    pb.brand_id,
    s.supplier_id
FROM raw_data r
JOIN product_category pc ON r.product_category = pc.category_name
JOIN product_brand pb ON r.product_brand = pb.brand_name
JOIN supplier s ON r.supplier_name = s.name AND r.supplier_email = s.email;

INSERT INTO store (name, location, state, phone, email, city_id, country_id)
SELECT DISTINCT
    store_name,
    store_location,
    store_state,
    store_phone,
    store_email,
    ci.city_id,
    co.country_id
FROM raw_data r
JOIN city ci ON r.store_city = ci.city_name
JOIN country co ON r.store_country = co.country_name;


INSERT INTO sales_fact (sale_date, quantity, total_price, customer_id, seller_id, product_id, store_id)
SELECT
    TO_DATE(sale_date, 'MM/DD/YYYY'),
    sale_quantity,
    sale_total_price,
    sale_customer_id,
    sale_seller_id,
    sale_product_id,
    s.store_id
FROM raw_data r
JOIN store s ON r.store_name = s.name AND r.store_phone = s.phone;
