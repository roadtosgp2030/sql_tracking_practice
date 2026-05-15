-- Active: 1778116211273@@127.0.0.1@3306@employees
-- Active: 1778116211273@@127.0.0.1@3306@employeesive: 1778116211273@@127.0.0.1@3306@customersive: 1778116211273@@127.0.0.1@3306@employees
SELECT
    emp_no,
    department,
    salary,
    AVG(salary) OVER (
        PARTITION BY
            department
    ) AS dept_avg,
    AVG(salary) OVER () AS company_avg
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    COUNT(*) OVER (
        PARTITION BY
            department
    ) AS dept_count
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    SUM(salary) OVER (
        PARTITION BY
            department
    ) AS dept_payroll
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    MAX(salary) OVER (
        PARTITION BY
            department
        ORDER BY
            salary
    ) AS dept_salary_total,
    MAX(salary) OVER (
        PARTITION BY
            department
    ) AS dept_salary_total
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY
            department
        ORDER BY
            salary DESC
    ) AS `row_number`,
    RANK() OVER (
        PARTITION BY
            department
        ORDER BY
            salary DESC
    ) AS dept_salary_rank,
    DENSE_RANK() OVER (
        ORDER BY
            salary DESC
    ) AS overall_salary_rank
FROM
    employees
ORDER BY
    overall_salary_rank;

SELECT
    emp_no,
    department,
    salary,
    RANK() OVER (
        ORDER BY
            salary desc
    ) AS `rank`
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    RANK() OVER (
        PARTITION BY
            department
        ORDER BY
            salary desc
    ) AS dept_rank
FROM
    employees;

SELECT
    *
FROM
    (
        SELECT
            emp_no,
            department,
            salary,
            RANK() OVER (
                PARTITION BY
                    department
                ORDER BY
                    salary desc
            ) AS dept_rank
        FROM
            employees
    ) AS sub
WHERE
    sub.dept_rank <= 3;

WITH
    ranked AS (
        SELECT
            emp_no,
            department,
            salary,
            RANK() OVER (
                PARTITION BY
                    department
                ORDER BY
                    salary desc
            ) AS dept_rank
        FROM
            employees
    )
SELECT
    *
FROM
    ranked
WHERE
    dept_rank <= 3;

WITH
    lowest_rank AS (
        SELECT
            emp_no,
            department,
            salary,
            RANK() OVER (
                PARTITION BY
                    department
                ORDER BY
                    salary
            ) AS dept_rank
        FROM
            employees
    )
SELECT
    *
FROM
    lowest_rank
WHERE
    dept_rank = 1;

SELECT
    emp_no,
    department,
    salary,
    ntile (4) OVER (
        PARTITION BY
            department
        ORDER BY
            salary desc
    ) AS dept_salary_quartile,
    ntile (4) OVER (
        ORDER BY
            salary desc
    ) AS salary_quartile
FROM
    employees
ORDER BY
    dept_salary_quartile;

SELECT
    emp_no,
    department,
    salary,
    LAST_VALUE (emp_no) OVER (
        PARTITION BY
            department
        ORDER BY
            salary desc
    ) AS highest_paid_dept,
    FIRST_VALUE (emp_no) OVER (
        ORDER BY
            salary desc
    ) AS highest_paid_overall
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    salary - lag (salary) OVER (
        PARTITION BY
            department
        ORDER BY
            salary desc
    ) AS dept_salary_diff
FROM
    employees;

SELECT
    emp_no,
    department,
    salary,
    salary - lead (salary) OVER (
        ORDER BY
            salary desc
    ) AS salary_diff
FROM
    employees;