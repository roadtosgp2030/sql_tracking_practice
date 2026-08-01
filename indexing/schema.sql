-- ============================================================
-- SCHEMA & DATA — Dùng chung cho tất cả các phase
-- ============================================================
-- LƯU Ý: Khác với các chủ đề trước (10-20 dòng là đủ), INDEX chỉ
-- thể hiện tác dụng khi bảng ĐỦ LỚN. Với 10 dòng, MySQL quét sạch
-- bảng còn nhanh hơn là đọc index. Nên ở đây ta sinh:
--   users  :   500,000 dòng
--   orders : 1,000,000 dòng
--
-- Chạy file này 1 lần:  mysql -u root < schema.sql
-- Mất khoảng 30-60 giây.
-- ============================================================

DROP DATABASE IF EXISTS indexing;

CREATE DATABASE indexing;

USE indexing;

-- ------------------------------------------------------------
-- Bảng phụ: 10 chữ số. CROSS JOIN 6 lần -> sinh ra 1 triệu số.
-- (Đây chỉ là thủ thuật sinh data, không phải nội dung bài học)
-- ------------------------------------------------------------
CREATE TABLE digits (d INT NOT NULL);

INSERT INTO
    digits
VALUES
    (0),
    (1),
    (2),
    (3),
    (4),
    (5),
    (6),
    (7),
    (8),
    (9);

-- ------------------------------------------------------------
-- BẢNG users — 500,000 dòng
-- CỐ TÌNH KHÔNG tạo index nào ngoài PRIMARY KEY.
-- Các phase sau sẽ tự tạo index để quan sát sự khác biệt.
-- ------------------------------------------------------------
CREATE TABLE users (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    email VARCHAR(120) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    status VARCHAR(10) NOT NULL,
    age TINYINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    users (
        id,
        email,
        full_name,
        city,
        status,
        age,
        created_at
    )
SELECT
    n,
    CONCAT('user', n, '@example.com'), -- UNIQUE, selectivity cao nhất
    CONCAT(
        ELT(
            1 + (n % 10),
            'Nguyen', 'Tran', 'Le', 'Pham', 'Hoang',
            'Vu', 'Dang', 'Bui', 'Do', 'Ngo'
        ),
        ' ',
        ELT(
            1 + ((n DIV 10) % 10),
            'Van', 'Thi', 'Minh', 'Quoc', 'Hoai',
            'Thanh', 'Ngoc', 'Huu', 'Gia', 'Kim'
        ),
        ' ',
        ELT(
            1 + ((n DIV 100) % 10),
            'An', 'Binh', 'Cuong', 'Dung', 'Em',
            'Phuc', 'Giang', 'Hung', 'Khanh', 'Linh'
        )
    ),
    -- 20 thành phố -> mỗi thành phố ~25,000 dòng.
    -- Dùng CRC32 để các cột ĐỘC LẬP nhau (nếu dùng n % 20 và n % 100
    -- thì city và status bị tương quan -> nhiều tổ hợp rỗng).
    ELT(
        1 + (CRC32(CONCAT('c', n)) % 20),
        'Ha Noi', 'Ho Chi Minh', 'Da Nang', 'Hai Phong', 'Can Tho',
        'Hue', 'Nha Trang', 'Vung Tau', 'Bien Hoa', 'Buon Ma Thuot',
        'Quy Nhon', 'Nam Dinh', 'Vinh', 'Thai Nguyen', 'Ha Long',
        'Rach Gia', 'Long Xuyen', 'Thanh Hoa', 'Pleiku', 'Ca Mau'
    ),
    -- CỐ TÌNH LỆCH: ~90% active. Dùng để học "low cardinality"
    CASE
        WHEN CRC32(CONCAT('s', n)) % 100 < 90 THEN 'active'
        WHEN CRC32(CONCAT('s', n)) % 100 < 98 THEN 'inactive'
        ELSE 'banned'
    END,
    18 + CRC32(CONCAT('a', n)) % 53, -- tuổi 18..70
    DATE_ADD(
        '2022-01-01 00:00:00',
        INTERVAL CRC32(CONCAT('d', n)) % 94608000 SECOND
    ) -- rải đều trong 3 năm 2022..2024
FROM
    (
        SELECT
            (
                d6.d * 100000 + d5.d * 10000 + d4.d * 1000
                + d3.d * 100 + d2.d * 10 + d1.d
            ) + 1 AS n
        FROM
            digits d1,
            digits d2,
            digits d3,
            digits d4,
            digits d5,
            digits d6
    ) seq
WHERE
    n <= 500000;

-- ------------------------------------------------------------
-- BẢNG orders — 1,000,000 dòng
-- Cũng KHÔNG có index trên user_id (kể cả foreign key).
-- ------------------------------------------------------------
CREATE TABLE orders (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(12) NOT NULL,
    created_at DATETIME NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    orders (id, user_id, amount, status, created_at)
SELECT
    n,
    1 + (CRC32(CONCAT('u', n)) % 500000), -- rải đơn hàng cho 500k user
    ROUND(10 + (CRC32(CONCAT('m', n)) % 99000) / 100, 2),
    ELT(
        1 + (CRC32(CONCAT('t', n)) % 5),
        'pending', 'paid', 'shipped', 'delivered', 'cancelled'
    ),
    DATE_ADD(
        '2022-01-01 00:00:00',
        INTERVAL CRC32(CONCAT('o', n)) % 94608000 SECOND
    )
FROM
    (
        SELECT
            (
                d6.d * 100000 + d5.d * 10000 + d4.d * 1000
                + d3.d * 100 + d2.d * 10 + d1.d
            ) + 1 AS n
        FROM
            digits d1,
            digits d2,
            digits d3,
            digits d4,
            digits d5,
            digits d6
    ) seq;

ANALYZE TABLE users, orders;
