-- Active: 1778116211273@@127.0.0.1@3306@mysql
-- ============================================================
-- SCHEMA & DATA — UNION practice
-- ============================================================
CREATE DATABASE IF NOT EXISTS union_practice;

USE union_practice;

-- Khách hàng mua online
CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    join_date DATE
);

-- Đối tác / nhà cung cấp
CREATE TABLE vendors (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    partner_since DATE
);

-- Nhân viên đang làm việc
CREATE TABLE current_employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(12, 0),
    hire_date DATE
);

-- Nhân viên đã nghỉ việc
CREATE TABLE former_employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(12, 0),
    hire_date DATE,
    leave_date DATE
);

-- Đơn hàng online
CREATE TABLE online_orders (
    id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    product VARCHAR(100),
    amount DECIMAL(12, 0),
    order_date DATE
);

-- Đơn hàng mua tại cửa hàng
CREATE TABLE instore_orders (
    id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    product VARCHAR(100),
    amount DECIMAL(12, 0),
    order_date DATE
);

-- ------------------------------------------------------------

INSERT INTO customers VALUES
    (1, 'Nguyen Van An',   'an@email.com',   'Hanoi',   '2023-01-15'),
    (2, 'Tran Thi Bich',   'bich@email.com', 'HCMC',    '2023-03-20'),
    (3, 'Le Van Cuong',    'cuong@email.com','Danang',   '2023-06-10'),
    (4, 'Pham Thi Dung',   'dung@email.com', 'Hanoi',   '2024-01-05'),
    (5, 'Hoang Van Em',    'em@email.com',   'Hue',     '2024-02-14');

INSERT INTO vendors VALUES
    (1, 'ABC Electronics', 'abc@vendor.com',  'Hanoi',   '2022-05-01'),
    (2, 'XYZ Furniture',   'xyz@vendor.com',  'HCMC',    '2021-11-15'),
    (3, 'Fast Delivery',   'fast@vendor.com', 'Danang',  '2023-01-10'),
    (4, 'Tech Supplies',   'tech@vendor.com', 'Hanoi',   '2022-08-20'),
    (5, 'Green Products',  'green@vendor.com','Can Tho', '2023-09-01');

INSERT INTO current_employees VALUES
    (1, 'Nguyen Minh Duc',  'IT',      15000000, '2021-03-01'),
    (2, 'Tran Thi Lan',     'HR',      12000000, '2020-06-15'),
    (3, 'Le Quang Vinh',    'IT',      18000000, '2019-01-10'),
    (4, 'Pham Thi Thu',     'Finance', 14000000, '2022-04-20'),
    (5, 'Hoang Van Khanh',  'IT',      16000000, '2021-09-01'),
    (6, 'Nguyen Thu Huong', 'HR',      11000000, '2023-01-15');

INSERT INTO former_employees VALUES
    (1, 'Do Van Nam',       'IT',      13000000, '2018-05-01', '2022-12-31'),
    (2, 'Nguyen Thi Mai',   'Finance', 13500000, '2019-08-15', '2023-06-30'),
    (3, 'Tran Van Long',    'HR',      11000000, '2020-01-20', '2022-03-31'),
    (4, 'Le Thi Yen',       'IT',      14000000, '2017-11-10', '2021-07-15');

INSERT INTO online_orders VALUES
    (1, 'Nguyen Van An',  'Laptop',     15000000, '2024-01-10'),
    (2, 'Tran Thi Bich',  'Phone',       8000000, '2024-01-15'),
    (3, 'Le Van Cuong',   'Tablet',      6000000, '2024-02-01'),
    (4, 'Nguyen Van An',  'Headphones',  1500000, '2024-02-20'),
    (5, 'Pham Thi Dung',  'Laptop',     14000000, '2024-03-05');

INSERT INTO instore_orders VALUES
    (1, 'Nguyen Van An',  'Mouse',       500000, '2024-01-20'),
    (2, 'Hoang Van Em',   'Keyboard',    800000, '2024-02-10'),
    (3, 'Nguyen Van An',  'Laptop',     15000000,'2024-02-25'),
    (4, 'Tran Thi Bich',  'Monitor',     5000000, '2024-03-01'),
    (5, 'Le Van Cuong',   'Webcam',      1200000, '2024-03-15');
