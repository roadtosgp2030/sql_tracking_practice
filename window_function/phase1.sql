-- Active: 1778116211273@@127.0.0.1@3306@window_function
-- ============================================================
-- PHASE 1: ROW_NUMBER, RANK, DENSE_RANK
-- ============================================================
-- Cú pháp cơ bản:
--   <window_function>() OVER ([PARTITION BY ...] [ORDER BY ...])
--
-- ROW_NUMBER  → đánh số thứ tự liên tục, không bao giờ trùng (1,2,3,4,5)
-- RANK        → giống nhau thì cùng hạng, nhảy số sau (1,2,2,4,5)
-- DENSE_RANK  → giống nhau thì cùng hạng, KHÔNG nhảy số  (1,2,2,3,4)
-- ============================================================
-- ------------------------------------------------------------
-- SETUP DATA
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS window_function;

USE window_function;

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO
    employees
VALUES
    (1, 'An', 'Engineering', 9000),
    (2, 'Binh', 'Engineering', 7500),
    (3, 'Cuong', 'Engineering', 7500),
    (4, 'Dung', 'Engineering', 6000),
    (5, 'Em', 'Marketing', 8000),
    (6, 'Phong', 'Marketing', 8000),
    (7, 'Giang', 'Marketing', 5500),
    (8, 'Hoa', 'HR', 7000),
    (9, 'Ich', 'HR', 6500),
    (10, 'Khanh', 'HR', 6500);

-- ============================================================
-- BÀI TẬP
-- ============================================================
-- ------------------------------------------------------------
-- [BÀI 1 - DỄ] Đánh số thứ tự tất cả nhân viên
-- theo lương giảm dần (dùng ROW_NUMBER).
-- Kết quả mong đợi: mỗi nhân viên có một số thứ tự duy nhất.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    *,
    ROW_NUMBER() over(
        ORDER BY
            salary desc
    ) as salary_rank
from
    employees;

-- ------------------------------------------------------------
-- [BÀI 2 - DỄ] Xếp hạng tất cả nhân viên theo lương giảm dần.
-- Dùng cả RANK và DENSE_RANK trong cùng một query để thấy sự khác biệt.
-- Kết quả mong đợi: nhân viên cùng lương có cùng hạng.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    salary,
    rank() over(
        order by
            salary desc
    ) as rank1,
    dense_rank() over(
        order by
            salary desc
    ) as rank2
from
    employees;

-- ------------------------------------------------------------
-- [BÀI 3 - TRUNG BÌNH] Xếp hạng nhân viên theo lương TRONG TỪNG PHÒNG BAN
-- (dùng PARTITION BY department).
-- Mỗi phòng ban có bảng xếp hạng riêng, bắt đầu lại từ 1.
-- Dùng DENSE_RANK.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    salary,
    department,
    dense_rank() over(
        PARTITION BY department
        ORDER BY
            salary
    )
from
    employees;

-- ------------------------------------------------------------
-- [BÀI 4 - TRUNG BÌNH] Tìm nhân viên xếp hạng 1 (lương cao nhất)
-- trong mỗi phòng ban.
-- Gợi ý: dùng subquery hoặc CTE bên ngoài để lọc rank = 1.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    *
from
    (
        select
            *,
            rank() over(
                ORDER BY
                    salary
            ) as salary_rank
        from
            employees
    ) as a
where
    salary_rank = 1;

-- ------------------------------------------------------------
-- [BÀI 5 - KHÓ] Tìm nhân viên có lương cao thứ 2 trong mỗi phòng ban.
-- Nếu phòng ban không có người xếp hạng 2, không cần hiển thị.
-- Dùng DENSE_RANK để xử lý trường hợp nhiều người cùng lương.
-- ------------------------------------------------------------
-- Viết query của bạn ở đây:
select
    *
from
    (
        select
            *,
            rank() over(
                PARTITION BY department
                ORDER BY
                    salary
            ) salary_rank
        from
            employees
    ) as a
where
    salary_rank = 2;

-- ============================================================
-- ĐÁP ÁN (kéo xuống xem sau khi đã tự làm)
-- ============================================================
/*
 
 -- BÀI 1
 SELECT
 name,
 department,
 salary,
 ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
 FROM employees;
 
 -- BÀI 2
 SELECT
 name,
 salary,
 RANK()       OVER (ORDER BY salary DESC) AS rank_result,
 DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_result
 FROM employees;
 
 -- BÀI 3
 SELECT
 name,
 department,
 salary,
 DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
 FROM employees;
 
 -- BÀI 4
 WITH ranked AS (
 SELECT
 name,
 department,
 salary,
 DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
 FROM employees
 )
 SELECT name, department, salary
 FROM ranked
 WHERE dept_rank = 1;
 
 -- BÀI 5
 WITH ranked AS (
 SELECT
 name,
 department,
 salary,
 DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
 FROM employees
 )
 SELECT name, department, salary
 FROM ranked
 WHERE dept_rank = 2;
 
 */