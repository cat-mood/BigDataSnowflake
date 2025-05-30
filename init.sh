#!/bin/bash
user=admin
db=lab01

psql -U ${user} -d ${db} -c "
CREATE TABLE raw_data (
	id int4 NULL,
	customer_first_name varchar(50) NULL,
	customer_last_name varchar(50) NULL,
	customer_age int4 NULL,
	customer_email varchar(50) NULL,
	customer_country varchar(50) NULL,
	customer_postal_code varchar(50) NULL,
	customer_pet_type varchar(50) NULL,
	customer_pet_name varchar(50) NULL,
	customer_pet_breed varchar(50) NULL,
	seller_first_name varchar(50) NULL,
	seller_last_name varchar(50) NULL,
	seller_email varchar(50) NULL,
	seller_country varchar(50) NULL,
	seller_postal_code varchar(50) NULL,
	product_name varchar(50) NULL,
	product_category varchar(50) NULL,
	product_price float4 NULL,
	product_quantity int4 NULL,
	sale_date varchar(50) NULL,
	sale_customer_id int4 NULL,
	sale_seller_id int4 NULL,
	sale_product_id int4 NULL,
	sale_quantity int4 NULL,
	sale_total_price float4 NULL,
	store_name varchar(50) NULL,
	store_location varchar(50) NULL,
	store_city varchar(50) NULL,
	store_state varchar(50) NULL,
	store_country varchar(50) NULL,
	store_phone varchar(50) NULL,
	store_email varchar(50) NULL,
	pet_category varchar(50) NULL,
	product_weight float4 NULL,
	product_color varchar(50) NULL,
	product_size varchar(50) NULL,
	product_brand varchar(50) NULL,
	product_material varchar(50) NULL,
	product_description varchar(1024) NULL,
	product_rating float4 NULL,
	product_reviews int4 NULL,
	product_release_date varchar(50) NULL,
	product_expiry_date varchar(50) NULL,
	supplier_name varchar(50) NULL,
	supplier_contact varchar(50) NULL,
	supplier_email varchar(50) NULL,
	supplier_phone varchar(50) NULL,
	supplier_address varchar(50) NULL,
	supplier_city varchar(50) NULL,
	supplier_country varchar(50) NULL
);"

for file in /docker-entrypoint-initdb.d/data/MOCK_DATA*.csv; do
    echo "Importing $file..."
    psql -U ${user} -d ${db} -c "\COPY raw_data(id,customer_first_name,customer_last_name,customer_age,customer_email,customer_country,customer_postal_code,customer_pet_type,customer_pet_name,customer_pet_breed,seller_first_name,seller_last_name,seller_email,seller_country,seller_postal_code,product_name,product_category,product_price,product_quantity,sale_date,sale_customer_id,sale_seller_id,sale_product_id,sale_quantity,sale_total_price,store_name,store_location,store_city,store_state,store_country,store_phone,store_email,pet_category,product_weight,product_color,product_size,product_brand,product_material,product_description,product_rating,product_reviews,product_release_date,product_expiry_date,supplier_name,supplier_contact,supplier_email,supplier_phone,supplier_address,supplier_city,supplier_country) FROM '$file' DELIMITER ',' CSV HEADER;"
done
