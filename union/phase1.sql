-- Active: 1778116211273@@127.0.0.1@3306@union_practice
-- ============================================================
-- PHASE 1: UNION & UNION ALL
-- ============================================================
-- UNION dùng để gộp kết quả của 2+ SELECT thành 1 tập kết quả.
--
-- Quy tắc bắt buộc:
--   - Số cột phải bằng nhau
--   - Kiểu dữ liệu tương ứng phải tương thích
--   - Tên cột lấy từ SELECT đầu tiên
--
-- Sự khác biệt quan trọng:
--   UNION      → tự động loại bỏ dòng trùng lặp (chậm hơn)
--   UNION ALL  → giữ lại tất cả, kể cả trùng    (nhanh hơn)
--
-- ORDER BY chỉ được dùng 1 lần, ở cuối cùng (sau UNION/UNION ALL).
-- ============================================================

USE union_practice;

-- ============================================================
-- BÀI TẬP
-- ============================================================

-- ------------------------------------------------------------
-- [BÀI 1 - DỄ] Lấy danh sách email của tất cả customers VÀ
-- vendors trong một kết quả duy nhất.
-- Kết quả gồm 1 cột: email
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select email from customers
UNION
select email from vendors;

-- ------------------------------------------------------------
-- [BÀI 2 - DỄ] Lấy danh sách các thành phố (city) có
-- customers HOẶC vendors, không trùng lặp, sắp xếp A-Z.
-- Kết quả gồm 1 cột: city
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select city from customers
UNION
select city from vendors;

-- ------------------------------------------------------------
-- [BÀI 3 - DỄ] Hiển thị tất cả nhân viên (hiện tại + đã nghỉ)
-- với các cột: name, department, salary
-- Giữ lại tất cả dòng, kể cả trùng.
-- Gợi ý: former_employees cũng có name, department, salary.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select name, department, salary from current_employees
union all
select name, department, salary from former_employees;

-- ------------------------------------------------------------
-- [BÀI 4 - TRUNG BÌNH] Tạo danh sách tất cả contact trong hệ
-- thống (customers + vendors) với cột:
--   name, email, city, type
-- Trong đó type = 'Customer' hoặc 'Vendor' để phân biệt nguồn.
-- Sắp xếp theo city.
-- Gợi ý: dùng giá trị chuỗi cố định làm cột thứ 4.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select name, email, city, 'Customer' AS type from customers
union all
select name, email, city, 'Vendor' AS type from vendors order by city;

-- ------------------------------------------------------------
-- [BÀI 5 - TRUNG BÌNH] Lấy tất cả đơn hàng (online + instore)
-- của khách hàng 'Nguyen Van An', gồm cột:
--   product, amount, order_date, channel
-- Trong đó channel = 'Online' hoặc 'In-store'.
-- Sắp xếp theo order_date tăng dần.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select product, amount, order_date, 'Online' as channel from online_orders
union ALL
select product, amount, order_date, 'In-store' as channel from instore_orders;

-- ------------------------------------------------------------
-- [BÀI 6 - TRUNG BÌNH] Tổng hợp TẤT CẢ đơn hàng (online +
-- instore), tính tổng doanh thu (total_revenue) theo từng sản
-- phẩm.
-- Kết quả: product, total_revenue
-- Sắp xếp theo total_revenue giảm dần.
-- Gợi ý: dùng UNION ALL bên trong subquery hoặc CTE, rồi
--        GROUP BY bên ngoài.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
with orders as (
    select product, amount from online_orders
    union all
    select product, amount from instore_orders
)
select product, sum(amount) from orders group by product;

-- ------------------------------------------------------------
-- [BÀI 7 - KHÓ] Tạo báo cáo nhân sự đầy đủ gồm cột:
--   name, department, salary, status
-- Trong đó status = 'Đang làm' hoặc 'Đã nghỉ'.
-- Sắp xếp theo department A-Z, sau đó salary giảm dần.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
with employee_report as (
    select name, department, salary, 'Dang lam' as status from current_employees
    union ALL
    select name, department, salary, 'Da nghi' as status from former_employees ORDER BY department, salary desc
)
select name, department, salary, status from employee_report;

-- ------------------------------------------------------------
-- [BÀI 8 - KHÓ] Tìm tất cả nhân viên từng thuộc phòng IT
-- (cả hiện tại lẫn cũ). Hiển thị: name, salary, status.
-- Chỉ lấy những người có salary >= 14000000.
-- Sắp xếp theo salary giảm dần.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
with employee_report as (
    select name, department, salary, 'Dang lam' as status from current_employees 
    union ALL
    select name, department, salary, 'Da nghi' as status from former_employees ORDER BY department, salary desc
)
select name, salary, department, status from employee_report where salary >= 14000000 && department = 'IT';

-- ============================================================
-- ĐÁP ÁN
-- ============================================================
/*

-- BÀI 1
SELECT email FROM customers
UNION
SELECT email FROM vendors;

-- BÀI 2
SELECT city FROM customers
UNION
SELECT city FROM vendors
ORDER BY city;

-- BÀI 3
SELECT name, department, salary FROM current_employees
UNION ALL
SELECT name, department, salary FROM former_employees;

-- BÀI 4
SELECT name, email, city, 'Customer' AS type FROM customers
UNION
SELECT name, email, city, 'Vendor'   AS type FROM vendors
ORDER BY city;

-- BÀI 5
SELECT product, amount, order_date, 'Online'   AS channel FROM online_orders   WHERE customer_name = 'Nguyen Van An'
UNION ALL
SELECT product, amount, order_date, 'In-store' AS channel FROM instore_orders  WHERE customer_name = 'Nguyen Van An'
ORDER BY order_date;

-- BÀI 6
SELECT product, SUM(amount) AS total_revenue
FROM (
    SELECT product, amount FROM online_orders
    UNION ALL
    SELECT product, amount FROM instore_orders
) AS all_orders
GROUP BY product
ORDER BY total_revenue DESC;

-- BÀI 7
SELECT name, department, salary, 'Đang làm' AS status FROM current_employees
UNION ALL
SELECT name, department, salary, 'Đã nghỉ'  AS status FROM former_employees
ORDER BY department, salary DESC;

-- BÀI 8
SELECT name, salary, 'Đang làm' AS status FROM current_employees WHERE department = 'IT' AND salary >= 14000000
UNION ALL
SELECT name, salary, 'Đã nghỉ'  AS status FROM former_employees  WHERE department = 'IT' AND salary >= 14000000
ORDER BY salary DESC;

*/
