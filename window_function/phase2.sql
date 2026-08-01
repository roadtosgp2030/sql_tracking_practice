-- Active: 1778116211273@@127.0.0.1@3306@window_function
-- ============================================================
-- PHASE 2: AGGREGATE WINDOW FUNCTIONS + PARTITION BY
-- ============================================================
-- Điểm khác biệt cốt lõi so với GROUP BY:
--   GROUP BY  → gộp nhiều dòng thành 1 dòng
--   OVER(...) → giữ nguyên tất cả các dòng, thêm cột tính toán
--
-- Các hàm aggregate dùng được với OVER():
--   SUM()   → tổng
--   AVG()   → trung bình
--   COUNT() → đếm
--   MAX()   → lớn nhất
--   MIN()   → nhỏ nhất
--
-- Cú pháp:
--   SUM(salary) OVER (PARTITION BY department)
--   → tính tổng lương theo từng phòng ban, hiển thị trên mỗi dòng
-- ============================================================
-- ------------------------------------------------------------
-- SETUP DATA (dùng lại bảng employees từ phase1)
-- Nếu chưa có, chạy lại phần setup của phase1.sql trước.
-- ------------------------------------------------------------
USE window_function;

-- ============================================================
-- BÀI TẬP
-- ============================================================
-- ------------------------------------------------------------
-- [BÀI 1 - DỄ] Hiển thị tất cả nhân viên cùng với tổng lương
-- của toàn công ty (không PARTITION BY).
-- Kết quả: mỗi dòng đều có cùng một giá trị total_salary.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    *,
    sum(salary) over() as total_salary
from
    employees;

-- ------------------------------------------------------------
-- [BÀI 2 - DỄ] Hiển thị tất cả nhân viên cùng với:
--   - Tổng lương của phòng ban họ (dept_total)
--   - Lương trung bình của phòng ban họ (dept_avg)
--   - Số nhân viên trong phòng ban họ (dept_count)
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    *,
    sum(salary) over(PARTITION BY department) as dept_total,
    round(avg(salary) over(PARTITION BY department), 2) as dept_avg,
    count(*) over(PARTITION BY department) as dept_count
from
    employees;

-- ------------------------------------------------------------
-- [BÀI 3 - TRUNG BÌNH] Tính % lương của mỗi nhân viên
-- so với tổng lương phòng ban.
-- Cột kết quả: name, department, salary, dept_total, salary_pct
-- Làm tròn salary_pct 2 chữ số thập phân.
-- Gợi ý: salary_pct = salary / dept_total * 100
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    name,
    department,
    salary,
    sum(salary) over(PARTITION BY department) as dept_total,
    round(
        salary / sum(salary) over(PARTITION BY department) * 100,
        2
    ) as salary_pct
from
    employees;

-- ------------------------------------------------------------
-- [BÀI 4 - TRUNG BÌNH] Tìm những nhân viên có lương
-- cao hơn mức lương trung bình của phòng ban họ.
-- Hiển thị: name, department, salary, dept_avg
-- Gợi ý: tính dept_avg trong subquery/CTE rồi lọc bên ngoài.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
with dept_avg_cte as (
    select
        avg(salary) over(PARTITION BY department) as dept_avg
    from
        employees
)
select
    name,
    department,
    salary
from
    employees e1;

-- ------------------------------------------------------------
-- [BÀI 5 - KHÓ] Với mỗi nhân viên, hiển thị:
--   - salary: lương của họ
--   - dept_max: lương cao nhất trong phòng ban
--   - company_max: lương cao nhất toàn công ty
--   - diff_from_dept_max: khoảng cách so với người lương cao nhất phòng ban
-- Sắp xếp theo department, salary giảm dần.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
-- ============================================================
-- ĐÁP ÁN
-- ============================================================
/*
 
 -- BÀI 1
 SELECT
 name,
 department,
 salary,
 SUM(salary) OVER () AS total_salary
 FROM employees;
 
 -- BÀI 2
 SELECT
 name,
 department,
 salary,
 SUM(salary)   OVER (PARTITION BY department) AS dept_total,
 AVG(salary)   OVER (PARTITION BY department) AS dept_avg,
 COUNT(*)      OVER (PARTITION BY department) AS dept_count
 FROM employees;
 
 -- BÀI 3
 SELECT
 name,
 department,
 salary,
 SUM(salary) OVER (PARTITION BY department) AS dept_total,
 ROUND(salary / SUM(salary) OVER (PARTITION BY department) * 100, 2) AS salary_pct
 FROM employees;
 
 -- BÀI 4
 WITH dept_stats AS (
 SELECT
 name,
 department,
 salary,
 AVG(salary) OVER (PARTITION BY department) AS dept_avg
 FROM employees
 )
 SELECT name, department, salary, ROUND(dept_avg, 2) AS dept_avg
 FROM dept_stats
 WHERE salary > dept_avg;
 
 -- BÀI 5
 SELECT
 name,
 department,
 salary,
 MAX(salary) OVER (PARTITION BY department) AS dept_max,
 MAX(salary) OVER ()                        AS company_max,
 MAX(salary) OVER (PARTITION BY department) - salary AS diff_from_dept_max
 FROM employees
 ORDER BY department, salary DESC;
 
 */