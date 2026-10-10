-- ============================================================
-- SCHEMA & DATA — Dùng chung cho tất cả các phase
-- ============================================================
-- DISTINCT là chủ đề về ĐỊNH NGHĨA "THẾ NÀO LÀ TRÙNG NHAU", không
-- phải về tốc độ. Nên dữ liệu phải NHỎ và ĐẾM ĐƯỢC BẰNG MẮT — bạn
-- phải tự đếm ra đáp án rồi mới hỏi MySQL, để biết ai đúng ai sai.
--   customers   :  8 dòng
--   products    :  8 dòng
--   orders      : 12 dòng
--   order_items : 26 dòng
--   page_views  : 20 dòng
--
-- Dữ liệu được cài CỐ Ý những cái bẫy sau — mọi bài học đều xoay
-- quanh chúng:
--   - customers.city : 'Ha Noi' / 'ha noi' / 'Ha Noi ' (có DẤU CÁCH
--     CUỐI). Mắt người thấy 3 thành phố. MySQL trả lời 5, 4, hay 3
--     tuỳ bạn hỏi kiểu gì.
--   - customers.city : 2 dòng NULL  -> DISTINCT gom NULL thành MỘT,
--     nhưng COUNT(DISTINCT) lại VỨT nó đi.
--   - 'Nguyen Van An' : 2 người khác nhau (id 1 và id 8) trùng tên.
--   - Vu Van Giang (id 6)  : có xem web nhưng KHÔNG hề mua hàng.
--   - orders.channel : có 1 dòng NULL.
--   - products.category : 'Gift Card' có category = NULL.
--   - Mouse & Keyboard cùng giá 25, Notebook & Pen cùng giá 5
--     -> để thấy SUM(DISTINCT price) ăn mất tiền.
--   - Laptop Pro (id 1) và Gift Card (id 8) : CHƯA AI mua.
--   - order 1 và order 12 : cùng khách, cùng tiền, cùng hàng hoá —
--     chỉ khác ngày. Trùng hay không trùng? Tuỳ bạn chọn cột nào.
--   - page_views : có dòng trùng HỆT nhau (id 1 và 2), và có
--     customer_id = NULL (khách vãng lai chưa đăng nhập).
--
-- Chạy file này 1 lần:  mysql -u root < schema.sql
-- ============================================================
DROP DATABASE IF EXISTS distinct_lab;

CREATE DATABASE distinct_lab;

USE distinct_lab;

-- ------------------------------------------------------------
-- BẢNG customers — khách hàng
-- city cố ý bẩn: hoa/thường lẫn lộn, có dấu cách cuối, có NULL.
-- Đây là dữ liệu THẬT trông như thế nào khi nhập tay.
-- ------------------------------------------------------------
CREATE TABLE customers (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    city VARCHAR(30) NULL,
    country CHAR(2) NOT NULL,
    signup_on DATE NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    customers (id, full_name, city, country, signup_on)
VALUES
    (1, 'Nguyen Van An',  'Ha Noi',      'VN', '2023-01-05'),
    (2, 'Tran Thi Binh',  'ha noi',      'VN', '2023-02-11'), -- <- chữ thường
    (3, 'Le Minh Cuong',  'Ho Chi Minh', 'VN', '2023-05-20'),
    (4, 'Pham Quoc Dung', 'Da Nang',     'VN', '2023-07-02'),
    (5, 'Hoang Thi Hoa',  NULL,          'VN', '2023-09-14'), -- <- NULL
    (6, 'Vu Van Giang',   NULL,          'JP', '2024-01-08'), -- <- NULL, không mua gì
    (7, 'Dang Ngoc Hanh', 'Ha Noi ',     'VN', '2024-02-19'), -- <- CÓ DẤU CÁCH CUỐI
    (8, 'Nguyen Van An',  'Ho Chi Minh', 'VN', '2024-03-01'); -- <- trùng tên id 1

-- ------------------------------------------------------------
-- BẢNG products — sản phẩm
-- Cố ý cho nhiều sản phẩm TRÙNG GIÁ, và 1 sản phẩm không có nhóm.
-- ------------------------------------------------------------
CREATE TABLE products (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    category VARCHAR(20) NULL,
    price DECIMAL(10, 2) NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    products (id, name, category, price)
VALUES
    (1, 'Laptop Pro', 'Electronics', 1200.00), -- <- chưa ai mua
    (2, 'Mouse',      'Electronics',   25.00),
    (3, 'Keyboard',   'Electronics',   25.00), -- <- trùng giá với Mouse
    (4, 'Desk Lamp',  'Home',          40.00),
    (5, 'Chair',      'Home',         150.00),
    (6, 'Notebook',   'Stationery',     5.00),
    (7, 'Pen',        'Stationery',     5.00), -- <- trùng giá với Notebook
    (8, 'Gift Card',  NULL,            50.00); -- <- category NULL, chưa ai mua

-- ------------------------------------------------------------
-- BẢNG orders — đơn hàng
-- Một khách nhiều đơn -> cột customer_id LẶP. Đây là nguồn "trùng"
-- tự nhiên nhất, và là lý do DISTINCT tồn tại.
-- ordered_at là DATETIME (có giờ) — nhớ kỹ, phase 4 sẽ dùng.
-- ------------------------------------------------------------
CREATE TABLE orders (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    status VARCHAR(12) NOT NULL,
    channel VARCHAR(10) NULL,
    ordered_at DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    orders (id, customer_id, status, channel, ordered_at, amount)
VALUES
    (1,  1, 'paid',      'web',   '2024-03-01 09:15:00', 250.00),
    (2,  1, 'paid',      'app',   '2024-03-01 20:40:00', 120.00), -- cùng NGÀY với đơn 1, khác GIỜ
    (3,  2, 'pending',   'web',   '2024-03-02 11:00:00',  80.00),
    (4,  3, 'paid',      'web',   '2024-03-02 14:30:00', 500.00),
    (5,  3, 'cancelled', 'app',   '2024-03-05 08:05:00',  60.00),
    (6,  3, 'paid',      'store', '2024-03-07 16:20:00', 340.00),
    (7,  4, 'paid',      'web',   '2024-03-08 10:00:00',  90.00),
    (8,  5, 'pending',   NULL,    '2024-03-10 12:45:00', 210.00), -- <- channel NULL
    (9,  5, 'paid',      'web',   '2024-03-11 09:30:00', 150.00),
    (10, 7, 'cancelled', 'app',   '2024-03-12 19:00:00',  45.00),
    (11, 8, 'paid',      'store', '2024-03-15 13:10:00', 700.00),
    (12, 1, 'refunded',  'web',   '2024-03-20 15:00:00', 250.00); -- <- cùng tiền, cùng hàng với đơn 1
-- Khách id 6 KHÔNG có đơn nào.

-- ------------------------------------------------------------
-- BẢNG order_items — chi tiết đơn (1 đơn nhiều dòng hàng)
-- Đây là bảng làm NỞ DÒNG khi JOIN -> nơi 90% chữ DISTINCT trong
-- code thật được viết ra (thường là viết sai). Phase 3 mổ xẻ.
-- amount của orders = đúng tổng qty * unit_price ở đây.
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    qty INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
) ENGINE = InnoDB;

INSERT INTO
    order_items (order_id, product_id, qty, unit_price)
VALUES
    (1,  2,  2,  25.00),
    (1,  5,  1, 150.00),
    (1,  6, 10,   5.00), -- đơn 1: 3 dòng hàng
    (2,  3,  2,  25.00),
    (2,  4,  1,  40.00),
    (2,  7,  6,   5.00),
    (3,  4,  2,  40.00), -- đơn 3: 1 dòng hàng
    (4,  4,  5,  40.00),
    (4,  5,  2, 150.00),
    (5,  2,  1,  25.00),
    (5,  7,  7,   5.00),
    (6,  4,  1,  40.00),
    (6,  5,  2, 150.00),
    (7,  4,  1,  40.00),
    (7,  6, 10,   5.00),
    (8,  2,  2,  25.00),
    (8,  5,  1, 150.00),
    (8,  6,  2,   5.00),
    (9,  5,  1, 150.00), -- đơn 9: 1 dòng hàng
    (10, 4,  1,  40.00),
    (10, 6,  1,   5.00),
    (11, 2,  4,  25.00),
    (11, 5,  4, 150.00),
    (12, 2,  2,  25.00),
    (12, 5,  1, 150.00),
    (12, 6, 10,   5.00); -- đơn 12: y hệt đơn 1
-- Sản phẩm 1 (Laptop Pro) và 8 (Gift Card) KHÔNG xuất hiện ở đây.

-- ------------------------------------------------------------
-- BẢNG page_views — log xem trang
-- Log là loại dữ liệu SINH RA ĐỂ TRÙNG. customer_id NULL = khách
-- chưa đăng nhập. Dùng cho bài kinh điển "đếm khách duy nhất".
-- ------------------------------------------------------------
CREATE TABLE page_views (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    customer_id INT UNSIGNED NULL,
    page VARCHAR(30) NOT NULL,
    viewed_on DATE NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    page_views (id, customer_id, page, viewed_on)
VALUES
    (1,  1,    '/home',       '2024-03-01'),
    (2,  1,    '/home',       '2024-03-01'), -- <- trùng HỆT dòng 1 (trừ id)
    (3,  1,    '/product/2',  '2024-03-01'),
    (4,  2,    '/home',       '2024-03-01'),
    (5,  NULL, '/home',       '2024-03-01'), -- <- khách vãng lai
    (6,  NULL, '/home',       '2024-03-02'),
    (7,  NULL, '/cart',       '2024-03-02'),
    (8,  3,    '/home',       '2024-03-02'),
    (9,  3,    '/cart',       '2024-03-02'),
    (10, 3,    '/checkout',   '2024-03-02'),
    (11, 1,    '/home',       '2024-03-02'),
    (12, 4,    '/product/5',  '2024-03-03'),
    (13, 4,    '/product/5',  '2024-03-03'),
    (14, 5,    '/home',       '2024-03-03'),
    (15, 6,    '/home',       '2024-03-03'), -- khách 6: xem mà không mua
    (16, NULL, '/product/1',  '2024-03-03'),
    (17, 2,    '/cart',       '2024-03-04'),
    (18, 2,    '/checkout',   '2024-03-04'),
    (19, 7,    '/home',       '2024-03-05'),
    (20, 8,    '/home',       '2024-03-05');

-- ------------------------------------------------------------
-- Kiểm tra nhanh: 8 / 8 / 12 / 26 / 20
-- ------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM customers)   AS customers,
    (SELECT COUNT(*) FROM products)    AS products,
    (SELECT COUNT(*) FROM orders)      AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM page_views)  AS page_views;
