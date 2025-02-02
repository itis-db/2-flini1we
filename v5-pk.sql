CREATE TABLE temp_shop AS SELECT * FROM shop;
CREATE TABLE temp_supplier AS SELECT * FROM supplier;
CREATE TABLE temp_customer AS SELECT * FROM customer;
CREATE TABLE temp_order_item AS SELECT * FROM order_item;

-- Удаление FK
ALTER TABLE car DROP CONSTRAINT IF EXISTS car_shop_id_fkey;
ALTER TABLE car DROP CONSTRAINT IF EXISTS car_supplier_id_fkey;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_customer_id_fkey;
ALTER TABLE order_item DROP CONSTRAINT IF EXISTS order_item_order_id_fkey;
ALTER TABLE order_item DROP CONSTRAINT IF EXISTS order_item_car_id_fkey;

-- Удаление PK
ALTER TABLE shop DROP CONSTRAINT IF EXISTS shop_pkey;
ALTER TABLE supplier DROP CONSTRAINT IF EXISTS supplier_pkey;
ALTER TABLE car DROP CONSTRAINT IF EXISTS car_pkey;
ALTER TABLE customer DROP CONSTRAINT IF EXISTS customer_pkey;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_pkey;
ALTER TABLE order_item DROP CONSTRAINT IF EXISTS order_item_pkey;

-- Добавление доменных ключей (супереключ)
ALTER TABLE shop ADD PRIMARY KEY (name, phone, address);
ALTER TABLE supplier ADD PRIMARY KEY (name, contact_info);

-- (Car) Для таблицы car используем временные столбцы
ALTER TABLE car ADD COLUMN shop_name VARCHAR(50);
ALTER TABLE car ADD COLUMN shop_phone VARCHAR(20);
ALTER TABLE car ADD COLUMN shop_address VARCHAR(100);
ALTER TABLE car ADD COLUMN supplier_name VARCHAR(50);
ALTER TABLE car ADD COLUMN supplier_contact_info VARCHAR(100);

-- Перенос данных из временной таблицы shop и supplier
UPDATE car c
SET
    shop_name = s.name,
    shop_phone = s.phone,
    shop_address = s.address,
    supplier_name = sup.name,
    supplier_contact_info = sup.contact_info
FROM temp_shop s, temp_supplier sup
WHERE c.shop_id = s.id AND c.supplier_id = sup.id;

-- создаем temp_car (ПОСЛЕ добавления столбцов в car и их заполнения)
CREATE TABLE temp_car AS SELECT * FROM car;
-- Удаление старых столбцов
ALTER TABLE car DROP COLUMN IF EXISTS shop_id;
ALTER TABLE car DROP COLUMN IF EXISTS supplier_id;
ALTER TABLE car DROP COLUMN IF EXISTS id;
-- Добавление доменного ключа
ALTER TABLE car ADD PRIMARY KEY (marka, model, price, count, shop_name, shop_phone, shop_address, supplier_name, supplier_contact_info);

-- (Orders)
ALTER TABLE orders ADD COLUMN customer_name VARCHAR(50);
ALTER TABLE orders ADD COLUMN customer_email VARCHAR(50);
ALTER TABLE orders ADD COLUMN customer_phone VARCHAR(20);
-- Перенос данных из временной таблицы customer
UPDATE orders o
SET
    customer_name = c.name,
    customer_email = c.email,
    customer_phone = c.phone
FROM temp_customer c
WHERE o.customer_id = c.id;

ALTER TABLE orders DROP COLUMN IF EXISTS customer_id;
-- Изменение типа order_date (на TIMESTAMP) для использования в суперключе
ALTER TABLE orders ALTER COLUMN order_date TYPE TIMESTAMP USING order_date::TIMESTAMP;

ALTER TABLE orders DROP COLUMN IF EXISTS id;
-- Добавление доменного ключа (суперключ)
ALTER TABLE orders ADD PRIMARY KEY (customer_email, order_date);
-- создаем temp_orders (ПОСЛЕ изменения структуры orders)
CREATE TABLE temp_orders AS SELECT * FROM orders;

-- Обработка таблицы order_item
ALTER TABLE order_item ADD COLUMN order_customer_name VARCHAR(50);
ALTER TABLE order_item ADD COLUMN order_customer_email VARCHAR(50);
ALTER TABLE order_item ADD COLUMN order_customer_phone VARCHAR(20);
ALTER TABLE order_item ADD COLUMN order_order_date TIMESTAMP;
ALTER TABLE order_item ADD COLUMN car_marka VARCHAR(10);
ALTER TABLE order_item ADD COLUMN car_model VARCHAR(50);
ALTER TABLE order_item ADD COLUMN car_price NUMERIC(10, 2);
ALTER TABLE order_item ADD COLUMN car_count INTEGER;
ALTER TABLE order_item ADD COLUMN shop_name VARCHAR(50);
ALTER TABLE order_item ADD COLUMN shop_phone VARCHAR(20);
ALTER TABLE order_item ADD COLUMN shop_address VARCHAR(100);
ALTER TABLE order_item ADD COLUMN supplier_name VARCHAR(50);
ALTER TABLE order_item ADD COLUMN supplier_contact_info VARCHAR(100);
-- Перенос данных из временных таблиц (orders и car)
UPDATE order_item oi
SET
    order_customer_name = o.customer_name,
    order_customer_email = o.customer_email,
    order_customer_phone = o.customer_phone,
    order_order_date = o.order_date,
    car_marka = c.marka,
    car_model = c.model,
    car_price = c.price,
    car_count = c.count,
    shop_name = c.shop_name,
    shop_phone = c.shop_phone,
    shop_address = c.shop_address,
    supplier_name = c.supplier_name,
    supplier_contact_info = c.supplier_contact_info
FROM temp_orders o, temp_car c
WHERE (oi.order_customer_email, oi.order_order_date) = (o.customer_email, o.order_date)
  AND (c.marka, c.model, c.price, c.count, c.shop_name, c.shop_phone, c.shop_address, c.supplier_name, c.supplier_contact_info) = 
      (oi.car_marka, oi.car_model, oi.car_price, oi.car_count, oi.shop_name, oi.shop_phone, oi.shop_address, oi.supplier_name, oi.supplier_contact_info);
-- Удаление старых столбцов (order_id и car_id)
ALTER TABLE order_item DROP COLUMN IF EXISTS order_id;
ALTER TABLE order_item DROP COLUMN IF EXISTS car_id;
ALTER TABLE order_item DROP COLUMN IF EXISTS id;
-- Добавление доменного ключа (суперключ)
ALTER TABLE order_item ADD PRIMARY KEY (order_customer_email, order_order_date, car_marka, car_model);
-- FK
ALTER TABLE car ADD FOREIGN KEY (shop_name, shop_phone, shop_address) REFERENCES shop(name, phone, address);
ALTER TABLE car ADD FOREIGN KEY (supplier_name, supplier_contact_info) REFERENCES supplier(name, contact_info);
ALTER TABLE orders ADD FOREIGN KEY (customer_email) REFERENCES customer(email);
ALTER TABLE order_item ADD FOREIGN KEY (order_customer_email, order_order_date) REFERENCES orders(customer_email, order_date);
ALTER TABLE order_item ADD FOREIGN KEY (car_marka, car_model, car_price, car_count, shop_name, shop_phone, shop_address, supplier_name, supplier_contact_info) REFERENCES car(marka, model, price, count, shop_name, shop_phone, shop_address, supplier_name, supplier_contact_info);

-- Rollback
ALTER TABLE shop DROP COLUMN IF EXISTS id;
ALTER TABLE supplier DROP COLUMN IF EXISTS id;
ALTER TABLE customer DROP COLUMN IF EXISTS id;

ALTER TABLE car DROP CONSTRAINT IF EXISTS car_shop_name_fkey CASCADE;
ALTER TABLE car DROP CONSTRAINT IF EXISTS car_supplier_name_fkey CASCADE;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_customer_email_fkey CASCADE;
ALTER TABLE order_item DROP CONSTRAINT IF EXISTS order_item_order_customer_email_fkey CASCADE;
ALTER TABLE order_item DROP CONSTRAINT IF EXISTS order_item_car_marka_fkey CASCADE;

ALTER TABLE shop DROP CONSTRAINT IF EXISTS shop_pkey CASCADE;
ALTER TABLE supplier DROP CONSTRAINT IF EXISTS supplier_pkey CASCADE;
ALTER TABLE car DROP CONSTRAINT IF EXISTS car_pkey CASCADE;
ALTER TABLE customer DROP CONSTRAINT IF EXISTS customer_pkey CASCADE;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_pkey CASCADE;
ALTER TABLE order_item DROP CONSTRAINT IF EXISTS order_item_pkey CASCADE;

ALTER TABLE shop ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE supplier ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE car ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE customer ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE orders ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE order_item ADD COLUMN id SERIAL PRIMARY KEY;

-- Восстановление связей для car
ALTER TABLE car ADD COLUMN shop_id INTEGER;
ALTER TABLE car ADD COLUMN supplier_id INTEGER;

UPDATE car c
SET shop_id = s.id, supplier_id = sup.id
FROM temp_shop s, temp_supplier sup
WHERE c.marka = ANY (ARRAY(SELECT marka FROM temp_car tc WHERE tc.shop_name = s.name))
  AND c.model = ANY (ARRAY(SELECT model FROM temp_car tc WHERE tc.supplier_name = sup.name));

ALTER TABLE car DROP COLUMN IF EXISTS shop_name;
ALTER TABLE car DROP COLUMN IF EXISTS shop_phone;
ALTER TABLE car DROP COLUMN IF EXISTS shop_address;
ALTER TABLE car DROP COLUMN IF EXISTS supplier_name;
ALTER TABLE car DROP COLUMN IF EXISTS supplier_contact_info;

-- Восстановление связей для orders
ALTER TABLE orders ADD COLUMN customer_id INTEGER;

UPDATE orders o
SET customer_id = c.id
FROM temp_customer c
WHERE o.customer_email = c.email;

ALTER TABLE orders DROP COLUMN IF EXISTS customer_name;
ALTER TABLE orders DROP COLUMN IF EXISTS customer_email;
ALTER TABLE orders DROP COLUMN IF EXISTS customer_phone;
-- Временные уникальные identifiers
ALTER TABLE temp_orders ADD COLUMN temp_order_id SERIAL;
ALTER TABLE temp_car ADD COLUMN temp_car_id SERIAL;

-- Восстановление связей для order_item
ALTER TABLE order_item ADD COLUMN order_id INTEGER;
ALTER TABLE order_item ADD COLUMN car_id INTEGER;

-- Обновление order_id в order_item
UPDATE order_item oi
SET order_id = o.temp_order_id
FROM temp_orders o
WHERE oi.order_customer_email = o.customer_email AND oi.order_order_date = o.order_date;

-- Обновление car_id в order_item
UPDATE order_item oi
SET car_id = c.temp_car_id
FROM temp_car c
WHERE oi.car_marka = c.marka AND oi.car_model = c.model;

ALTER TABLE order_item DROP COLUMN IF EXISTS order_customer_name;
ALTER TABLE order_item DROP COLUMN IF EXISTS order_customer_email;
ALTER TABLE order_item DROP COLUMN IF EXISTS order_customer_phone;
ALTER TABLE order_item DROP COLUMN IF EXISTS order_order_date;
ALTER TABLE order_item DROP COLUMN IF EXISTS car_marka;
ALTER TABLE order_item DROP COLUMN IF EXISTS car_model;
ALTER TABLE order_item DROP COLUMN IF EXISTS car_price;
ALTER TABLE order_item DROP COLUMN IF EXISTS car_count;
ALTER TABLE order_item DROP COLUMN IF EXISTS shop_name;
ALTER TABLE order_item DROP COLUMN IF EXISTS shop_phone;
ALTER TABLE order_item DROP COLUMN IF EXISTS shop_address;
ALTER TABLE order_item DROP COLUMN IF EXISTS supplier_name;
ALTER TABLE order_item DROP COLUMN IF EXISTS supplier_contact_info;
ALTER TABLE temp_orders DROP COLUMN IF EXISTS temp_order_id;
ALTER TABLE temp_car DROP COLUMN IF EXISTS temp_car_id;

-- Добавление FK
ALTER TABLE car ADD FOREIGN KEY (shop_id) REFERENCES shop(id);
ALTER TABLE car ADD FOREIGN KEY (supplier_id) REFERENCES supplier(id);
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customer(id);
ALTER TABLE order_item ADD FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE order_item ADD FOREIGN KEY (car_id) REFERENCES car(id);

-- Удаление временных таблиц
DROP TABLE IF EXISTS temp_shop;
DROP TABLE IF EXISTS temp_supplier;
DROP TABLE IF EXISTS temp_customer;
DROP TABLE IF EXISTS temp_car;
DROP TABLE IF EXISTS temp_orders;
DROP TABLE IF EXISTS temp_order_item;