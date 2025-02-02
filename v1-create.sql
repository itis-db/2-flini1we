DROP TABLE IF EXISTS shop;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_item;

CREATE TABLE IF NOT EXISTS shop (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS supplier (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    contact_info VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS car (
    id SERIAL PRIMARY KEY,
    marka VARCHAR(10) NOT NULL,
    model VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    count INTEGER CHECK (count > 0),
    shop_id INTEGER NOT NULL,
    supplier_id INTEGER,
    FOREIGN KEY (shop_id) REFERENCES shop(id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(id)
);

CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(id)
);

CREATE TABLE IF NOT EXISTS order_item (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    car_id INTEGER NOT NULL,
    quantity INTEGER CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (car_id) REFERENCES car(id)
);