-- Заолнение псевдо-случайными данными
INSERT INTO shop (name, phone, address)
VALUES 
('Shop A', '123-456-7890', '123 Main St'),
('Shop B', '234-567-8901', '456 Elm St'),
('Shop C', '345-678-9012', '789 Oak St');

INSERT INTO supplier (name, contact_info)
VALUES 
('Supplier 1', 'supplier1@example.com'),
('Supplier 2', 'supplier2@example.com'),
('Supplier 3', 'supplier3@example.com');

INSERT INTO car (marka, model, price, count, shop_id, supplier_id)
VALUES 
('Toyota', 'Corolla', 20000.00, 10, 1, 1),
('Honda', 'Civic', 22000.00, 5, 1, 2),
('Ford', 'Focus', 18000.00, 8, 2, 1),
('BMW', '3 Series', 35000.00, 3, 2, 3),
('Audi', 'A4', 33000.00, 4, 3, 2);

INSERT INTO customer (name, email, phone)
VALUES 
('John Doe', 'john.doe@example.com', '555-1234'),
('Jane Smith', 'jane.smith@example.com', '555-5678'),
('Alice Johnson', 'alice.johnson@example.com', '555-8765'),
('Bob Brown', 'bob.brown@example.com', '555-4321');

INSERT INTO orders (customer_id, order_date)
VALUES 
(1, '2025-01-01 10:00:00'),
(2, '2025-01-02 11:00:00'),
(3, '2025-01-03 12:00:00'),
(4, '2025-01-04 13:00:00');

INSERT INTO order_item (order_id, car_id, quantity)
VALUES 
(1, 1, 1),
(2, 2, 2),
(3, 3, 1),
(4, 4, 1),
(4, 5, 1);

-- INNER JOIN with CTE
WITH CustomerOrders AS (
    SELECT 
        orders.id AS order_id,
        customer.name AS customer_name,
        customer.email AS customer_email,
        orders.order_date
    FROM orders
    INNER JOIN customer ON orders.customer_id = customer.id
)
SELECT 
    CustomerOrders.order_id,
    CustomerOrders.customer_name,
    CustomerOrders.customer_email,
    CustomerOrders.order_date
FROM CustomerOrders;

-- LEFT JOIN with CTE
WITH CarSuppliers AS (
    SELECT 
        car.id AS car_id,
        car.marka,
        car.model,
        car.price,
        supplier.name AS supplier_name,
        supplier.contact_info
    FROM car
    LEFT JOIN supplier ON car.supplier_id = supplier.id
)
SELECT 
    CarSuppliers.car_id,
    CarSuppliers.marka,
    CarSuppliers.model,
    CarSuppliers.price,
    CarSuppliers.supplier_name,
    CarSuppliers.contact_info
FROM CarSuppliers;

-- RIGHT JOIN with CTE
WITH SupplierCars AS (
    SELECT 
        supplier.id AS supplier_id,
        supplier.name AS supplier_name,
        supplier.contact_info,
        car.marka,
        car.model,
        car.price
    FROM car
    RIGHT JOIN supplier ON car.supplier_id = supplier.id
)
SELECT 
    SupplierCars.supplier_id,
    SupplierCars.supplier_name,
    SupplierCars.contact_info,
    SupplierCars.marka,
    SupplierCars.model,
    SupplierCars.price
FROM SupplierCars;

-- CROSS JOIN with CTE
WITH CustomerCars AS (
    SELECT 
        customer.name AS customer_name,
        car.marka,
        car.model
    FROM customer
    CROSS JOIN car
)
SELECT 
    CustomerCars.customer_name,
    CustomerCars.marka,
    CustomerCars.model
FROM CustomerCars;

-- UNION with CTE
WITH AllNames AS (
    SELECT name AS person_name FROM customer
    UNION
    SELECT name AS person_name FROM supplier
)
SELECT AllNames.person_name FROM AllNames;

-- UNION ALL with CTE
WITH AllNames AS (
    SELECT name AS person_name FROM customer
    UNION ALL
    SELECT name AS person_name FROM supplier
)
SELECT AllNames.person_name FROM AllNames;