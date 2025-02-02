CREATE TABLE accounts (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    signup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dishes (
    dish_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    dish_title VARCHAR(255) NOT NULL,
    dish_description TEXT NOT NULL,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE components (
    component_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dish_id UUID NOT NULL,
    component_name VARCHAR(100) NOT NULL,
    component_quantity VARCHAR(50) NOT NULL,
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id)
);

INSERT INTO accounts (user_name, user_email, signup_date)
SELECT 
    CONCAT('cook_', i) AS user_name,
    CONCAT('cook_', i, '@example.com') AS user_email,
    NOW() - (RANDOM() * INTERVAL '365 days') AS signup_date
FROM generate_series(1, 50) AS s(i);

INSERT INTO dishes (account_id, dish_title, dish_description, creation_date)
SELECT 
    a.account_id AS account_id,
    CONCAT('Dish Title ', s.i) AS dish_title,
    CONCAT('This is the description of dish number ', s.i, '.') AS dish_description,
    NOW() - (RANDOM() * INTERVAL '30 days') AS creation_date
FROM generate_series(1, 150) AS s(i),
     (SELECT account_id FROM accounts ORDER BY RANDOM() LIMIT 50) AS a;

INSERT INTO components (dish_id, component_name, component_quantity)
SELECT 
    d.dish_id AS dish_id,
    CONCAT('Component_', s.i) AS component_name,
    CONCAT(FLOOR(RANDOM() * 500 + 1), ' grams') AS component_quantity
FROM generate_series(1, 300) AS s(i),
     (SELECT dish_id FROM dishes ORDER BY RANDOM() LIMIT 100) AS d;

SELECT * FROM accounts;

SELECT d.*, a.user_name
FROM dishes d
JOIN accounts a ON d.account_id = a.account_id;

SELECT c.*, d.dish_title
FROM components c
JOIN dishes d ON c.dish_id = d.dish_id;