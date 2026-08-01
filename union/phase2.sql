-- Active: 1778116211273@@127.0.0.1@3306@union_practice
-- ============================================================
-- PHASE 2: UNION NÂNG CAO — CÁC PATTERN THỰC TẾ
-- ============================================================
-- Các pattern trong phase này:
--
--   1. Summary row  : UNION ALL để thêm dòng tổng vào cuối báo cáo
--   2. Full Outer Join: LEFT JOIN UNION ALL RIGHT JOIN
--      (MySQL không có FULL OUTER JOIN)
--   3. INTERSECT simulation: tìm giao nhau giữa 2 tập dữ liệu
--   4. EXCEPT simulation  : tìm hiệu giữa 2 tập dữ liệu
--
-- ⚠ Lỗi phổ biến — ORDER BY trong CTE:
--
--   SAI (MySQL có thể báo lỗi hoặc bỏ qua ORDER BY):
--     WITH cte AS (
--         SELECT ... UNION ALL SELECT ... ORDER BY col   ← sai chỗ
--     )
--     SELECT * FROM cte;
--
--   ĐÚNG — ORDER BY chỉ được đặt ở câu SELECT ngoài cùng:
--     WITH cte AS (
--         SELECT ... UNION ALL SELECT ...
--     )
--     SELECT * FROM cte ORDER BY col;                   ← đúng chỗ
-- ============================================================

USE union_practice;

-- ============================================================
-- BÀI TẬP
-- ============================================================

-- ------------------------------------------------------------
-- [BÀI 1 - TRUNG BÌNH] Tính tổng doanh thu từng tháng,
-- gộp cả 2 kênh (online + instore) lại.
-- Kết quả: month_num, total_revenue
-- Sắp xếp theo tháng tăng dần.
-- Gợi ý: dùng MONTH(order_date) để lấy số tháng.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
with orders as (
    select month(order_date) as month_num, amount from online_orders
    UNION all
    select month(order_date) as month_num, amount from instore_orders
)
select month_num, sum(amount) from orders group by month_num order by month_num;

-- ------------------------------------------------------------
-- [BÀI 2 - TRUNG BÌNH] Báo cáo doanh thu theo kênh bán hàng,
-- kèm thêm 1 dòng tổng cộng ở cuối.
-- Kết quả mong muốn:
--   channel    | total_revenue
--   In-store   | 22500000
--   Online     | 44500000
--   TOTAL      | 67000000
-- Gợi ý: tính doanh thu mỗi kênh, rồi UNION ALL thêm 1 SELECT
--        tính tổng toàn bộ với channel = 'TOTAL'.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
with instore_revenue as (
    select 'In-store' as channel, sum(amount) as total_revenue from instore_orders
),
online_revenue as (
    select 'Online' as channel, sum(amount) as total_revenue from online_orders
),
total_revenue as (
    select 'TOTAL' as channel, sum(total_revenue) from (
        select * from instore_revenue
        union ALL
        select * from online_revenue
    ) as revenue
)
select * from instore_revenue
UNION ALL
select * from online_revenue
UNION ALL
select * from total_revenue;

-- ------------------------------------------------------------
-- [BÀI 3 - KHÓ] Liệt kê TẤT CẢ thành phố từ customers VÀ
-- vendors (kể cả thành phố chỉ có trong 1 bảng).
-- Với mỗi thành phố, hiển thị số lượng customers và vendors.
-- Kết quả: city, customer_count, vendor_count
-- Sắp xếp theo city A-Z.
--
-- Đây là pattern FULL OUTER JOIN — MySQL không hỗ trợ trực
-- tiếp nên phải dùng:
--   LEFT JOIN (customers → vendors)
--   UNION ALL
--   LEFT JOIN ngược lại, lọc những thành phố chưa xuất hiện
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:

select city, count(*) as customer_count from customers group by city;

SELECT city, count(*) as vendor_count from vendors group by city;

-- ------------------------------------------------------------
-- [BÀI 4 - KHÓ] Lấy top 5 đơn hàng có giá trị lớn nhất
-- từ tất cả kênh (online + instore).
-- Kết quả: customer_name, product, amount, channel
-- Sắp xếp theo amount giảm dần, chỉ lấy 5 dòng đầu.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:


-- ------------------------------------------------------------
-- [BÀI 5 - KHÓ] Tìm những sản phẩm được bán ở CẢ HAI kênh
-- (vừa có trong online_orders, vừa có trong instore_orders).
-- Kết quả: product (không trùng lặp)
--
-- Đây là pattern INTERSECT simulation.
-- Gợi ý: UNION ALL 2 bảng, thêm cột để biết nguồn gốc,
--        rồi GROUP BY + HAVING COUNT(DISTINCT src) = 2.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:


-- ------------------------------------------------------------
-- [BÀI 6 - RẤT KHÓ] Tìm những thành phố "không chung" —
-- tức là chỉ có trong customers HOẶC chỉ có trong vendors,
-- nhưng không có trong cả hai.
-- Kết quả: city, note ('Chỉ có customers' hoặc 'Chỉ có vendors')
-- Sắp xếp theo city.
--
-- Đây là pattern EXCEPT simulation (tìm hiệu 2 tập).
-- Gợi ý: dùng NOT IN, UNION 2 chiều.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:


-- ============================================================
-- ĐÁP ÁN
-- ============================================================
/*

-- BÀI 1
SELECT MONTH(order_date) AS month_num, SUM(amount) AS total_revenue
FROM (
    SELECT order_date, amount FROM online_orders
    UNION ALL
    SELECT order_date, amount FROM instore_orders
) AS all_orders
GROUP BY MONTH(order_date)
ORDER BY month_num;

-- BÀI 2
SELECT channel, SUM(amount) AS total_revenue
FROM (
    SELECT 'Online'   AS channel, amount FROM online_orders
    UNION ALL
    SELECT 'In-store' AS channel, amount FROM instore_orders
) AS all_orders
GROUP BY channel
UNION ALL
SELECT 'TOTAL', SUM(amount)
FROM (
    SELECT amount FROM online_orders
    UNION ALL
    SELECT amount FROM instore_orders
) AS grand_total
ORDER BY total_revenue;

-- BÀI 3
SELECT c.city,
       COUNT(DISTINCT c.id) AS customer_count,
       COUNT(DISTINCT v.id) AS vendor_count
FROM customers c
LEFT JOIN vendors v ON c.city = v.city
GROUP BY c.city

UNION ALL

SELECT v.city,
       0              AS customer_count,
       COUNT(*)       AS vendor_count
FROM vendors v
LEFT JOIN customers c ON v.city = c.city
WHERE c.id IS NULL
GROUP BY v.city

ORDER BY city;

-- BÀI 4
SELECT customer_name, product, amount, 'Online'   AS channel FROM online_orders
UNION ALL
SELECT customer_name, product, amount, 'In-store' AS channel FROM instore_orders
ORDER BY amount DESC
LIMIT 5;

-- BÀI 5
SELECT product
FROM (
    SELECT product, 'online'   AS src FROM online_orders
    UNION ALL
    SELECT product, 'instore'  AS src FROM instore_orders
) AS combined
GROUP BY product
HAVING COUNT(DISTINCT src) = 2;

-- BÀI 6
SELECT city, 'Chỉ có customers' AS note
FROM customers
WHERE city NOT IN (SELECT city FROM vendors)
GROUP BY city

UNION

SELECT city, 'Chỉ có vendors' AS note
FROM vendors
WHERE city NOT IN (SELECT city FROM customers)
GROUP BY city

ORDER BY city;

*/
