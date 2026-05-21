-- ============================================================
-- SCHEMA & DATA — Dùng chung cho tất cả các phase
-- ============================================================
CREATE DATABASE IF NOT EXISTS subquery_cte;

USE subquery_cte;

CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2),
    category VARCHAR(50)
);

INSERT INTO
    products
VALUES
    (1, 'Laptop A', 1200.00, 'Electronics'),
    (2, 'Mouse', 25.00, 'Electronics'),
    (3, 'Desk Chair', 350.00, 'Furniture'),
    (4, 'Monitor', 450.00, 'Electronics'),
    (5, 'Keyboard', 75.00, 'Electronics'),
    (6, 'Bookshelf', 200.00, 'Furniture'),
    (7, 'Webcam', 89.00, 'Electronics'),
    (8, 'Standing Desk', 780.00, 'Furniture'),
    (9, 'Headphones', 149.00, 'Electronics'),
    (10, 'Lamp', 45.00, 'Furniture');

CREATE TABLE orders (
    id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    order_date DATE
);

INSERT INTO
    orders
VALUES
    (1, 1, 2, '2024-01-05'),
    (2, 4, 1, '2024-01-10'),
    (3, 9, 3, '2024-02-01'),
    (4, 3, 1, '2024-02-14'),
    (5, 1, 1, '2024-03-01'),
    (6, 7, 2, '2024-03-15'),
    (7, 5, 4, '2024-04-01');