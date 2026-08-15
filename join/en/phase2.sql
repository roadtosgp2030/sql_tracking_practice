-- Active: 1778116211273@@127.0.0.1@3306@join_lab
-- ============================================================
-- PHASE 2 — OUTER JOIN: LEFT / RIGHT / FULL, and the ANTI-JOIN
-- (do phase1.sql first)
-- ============================================================
USE join_lab;

-- ============================================================
-- BACKGROUND — OUTER JOIN
-- ============================================================
-- INNER JOIN throws away non-matching rows. OUTER JOIN KEEPS them and
-- fills the other table's columns with NULL.
--
--      A LEFT JOIN B   -> keep ALL rows of A. B missing -> NULL
--      A RIGHT JOIN B  -> keep ALL rows of B. A missing -> NULL
--      FULL OUTER JOIN -> keep both. MySQL does NOT support it (emulate it)
--
-- Mental picture: the table written right after FROM is the "left" one,
-- the table after JOIN is the "right" one. LEFT = "protect the left side".
--
-- THE MOST IMPORTANT CONSEQUENCE — row counts:
--      INNER JOIN : can be FEWER rows than A
--      LEFT  JOIN : ALWAYS >= the number of rows in A
--                   (equal if the relation is 1-1, more if 1-to-many)
--
-- Only use RIGHT JOIN when you really must. `A RIGHT JOIN B` can always
-- be rewritten as `B LEFT JOIN A` with an identical result, and it reads
-- far better. In real code, 95% is LEFT JOIN.
-- ============================================================
-- ============================================================
-- EXERCISE 2.1 — LEFT JOIN: keep everything on the left
-- ============================================================
-- TASK:
-- The query below differs from 1.2 by exactly one word: JOIN -> LEFT JOIN.
-- a) How many rows? Compare with the 10 rows of the INNER JOIN.
-- b) What is special about the `department` column in the two new rows?
-- c) `d.name` is declared NOT NULL in the schema. So where does this
--    NULL come from?
SELECT
    e.id,
    e.full_name,
    e.department_id,
    d.name AS department
FROM
    employees e
    LEFT JOIN departments d ON e.department_id = d.id
ORDER BY
    e.id;

-- Your answers:
-- a) 12
-- b) null
-- c)
-- ============================================================
-- EXERCISE 2.2 — Swap the two tables and the result changes
-- ============================================================
-- TASK:
-- Still a LEFT JOIN, but the two tables have swapped places.
-- a) How many rows?
-- b) Who is "protected" this time? Which row is the NULL row now?
-- c) Compared to 2.1: both are LEFT JOIN with the same ON condition,
--    yet the results differ. What decides the outcome?
SELECT
    d.id,
    d.name AS department,
    e.full_name
FROM
    departments d
    LEFT JOIN employees e ON e.department_id = d.id
ORDER BY
    d.id,
    e.id;

-- Your answers:
-- a) 11
-- b) Legal
-- c)
-- ============================================================
-- EXERCISE 2.3 — RIGHT JOIN is just a LEFT JOIN written backwards
-- ============================================================
-- TASK:
-- a) Run the query below and compare with 2.2. Same or different?
-- b) Rewrite it as a LEFT JOIN without changing the result.
SELECT
    d.name AS department,
    e.full_name
FROM
    employees e
    RIGHT JOIN departments d ON e.department_id = d.id
ORDER BY
    d.id,
    e.id;

-- Rewrite with LEFT JOIN:
select d.name as department, e.full_name from departments d left join employees e on d.id = e.department_id;

-- ============================================================
-- EXERCISE 2.4 — ANTI-JOIN: finding what does NOT match
-- ============================================================
-- This is the single most useful pattern in real work:
--
--      A LEFT JOIN B ON ...   WHERE B.<NOT NULL column> IS NULL
--
-- Meaning: "keep all of A, then keep only the rows where B found no match".
-- Used for: unpaid orders, users who never verified their email,
-- products without images, orphan records...
--
-- TASK:
-- a) Run the query below. Who comes out?
-- b) Why must you test `d.id IS NULL` and NOT `d.name`?
--    (try d.name — here it happens to still be correct. But what if the
--     name column allowed NULL and some department were literally named NULL?)
-- c) Why can you NOT replace this with `WHERE e.department_id IS NULL`?
--    Think: if an employee had department_id = 99 (a deleted department),
--    which query would catch that bug?
SELECT
    e.id,
    e.full_name
FROM
    employees e
    LEFT JOIN departments d ON e.department_id = d.id
WHERE
    d.id IS NULL;

-- Your answers:
-- a)
-- b)
-- c)

-- TASK D:
-- Flip it around: find departments that have NO employees.
-- Write your query below:
select
    d.id,
    d.name
from
    departments d
    left join employees e on d.id = e.department_id
where
    e.id is null;

-- ============================================================
-- EXERCISE 2.5 — FULL OUTER JOIN: MySQL lacks it, emulate it
-- ============================================================
-- We want: ALL employees + ALL departments, including the lonely ones
-- on either side. PostgreSQL/SQL Server have `FULL OUTER JOIN`. MySQL
-- does not. The workaround: LEFT JOIN  UNION  RIGHT JOIN.
--
-- UNION (without ALL) removes duplicates by itself — exactly what we
-- need, because the "matching" part shows up in both halves.
--
-- TASK:
-- a) Run it. How many rows? (12 employees + 1 lonely department = ?)
-- b) Change UNION to UNION ALL and count again. What is the difference, and why?
-- c) WARNING: if two employees had the SAME NAME in the same department,
--    UNION would collapse them into one row — data loss! How do you avoid that?
SELECT
    e.full_name,
    d.name AS department
FROM
    employees e
    LEFT JOIN departments d ON e.department_id = d.id
UNION
SELECT
    e.full_name,
    d.name
FROM
    employees e
    RIGHT JOIN departments d ON e.department_id = d.id;

-- Your answers:
-- a)
-- b)
-- c)
-- ============================================================
-- EXERCISE 2.6 — THE CLASSIC TRAP: COUNT(*) after a LEFT JOIN
-- ============================================================
-- TASK:
-- Count employees per department. The query below returns BOTH ways of
-- counting.
-- a) Run it and look at the Legal row: what does each column say?
-- b) Legal has 0 employees. Why does COUNT(*) return 1?
-- c) Derive the rule: what do you count with after a LEFT JOIN?

select count(*), count(e.id), d.name as department_name from employees e right join departments d on e.department_id = d.id group by d.id;

SELECT
    d.name AS department,
    COUNT(*) AS count_star,
    COUNT(e.id) AS count_col
FROM
    departments d
    LEFT JOIN employees e ON e.department_id = d.id
GROUP BY
    d.id,
    d.name
ORDER BY
    d.id;

-- Your answers:
-- a)
-- b)
-- c)
-- ============================================================
-- EXERCISE 2.7 — On your own
-- ============================================================
-- TASK A:
-- Total hours for EACH project — including projects nobody works on
-- (they must show 0, not NULL). All 7 rows.
-- (hint: LEFT JOIN + COALESCE(...) or IFNULL(...))
-- Write your query below:
select
    p.name as project_name,
    ifnull(sum(a.hours), 0) as total_hours
from
    projects p
    left join assignments a on p.id = a.project_id
group by
    p.id
order by
    total_hours desc;

-- TASK B:
-- Find employees who are NOT assigned to any project.
-- Write your query below:
select
    e.id,
    e.full_name,
    p.name as project_name
from
    employees e
    left join departments d on e.department_id = d.id
    left join projects p on d.id = p.department_id
    where p.name is null;

-- TASK C:
-- Find projects that NOBODY is working on.
-- Write your query below:
select
    count(e.id),
    p.name
from
    projects p
    left join assignments a on p.id = a.project_id
    left join employees e on e.id = a.employee_id
    where
    e.id is null
group by
    p.id;

-- TASK D:
-- List every employee with their department name and the department's city.
-- Employees without a department should show '(no department)' instead of NULL.
-- All 12 rows.
-- Write your query below:
select e.full_name, COALESCE(d.name, '(no department)') from employees e left join departments d on e.department_id = d.id;


-- ============================================================
-- REFERENCE RESULTS (actually run on MySQL 8.0.45)
-- Only look after you have done the work yourself!
-- ============================================================
-- EXERCISE 2.1 — LEFT JOIN: 12 rows (INNER JOIN gave only 10)
--   | 10 | Ngo Huu Minh    |          NULL | NULL       |
--   | 12 | Truong Van Phuc |          NULL | NULL       |
--   The NULL in `department` is NOT data stored in the departments table.
--   It is a NULL MySQL MADE UP to fill the gap when nothing matched.
--   A column declared NOT NULL can still come out NULL after an OUTER
--   JOIN — the NOT NULL constraint applies to the TABLE, not to the
--   RESULT of a query.
--
-- EXERCISE 2.2 — departments LEFT JOIN employees: 11 rows
--   +----+-------------+----------------+
--   |  1 | Engineering | Nguyen Van An  |
--   |  1 | Engineering | Tran Thi Binh  |
--   |  1 | Engineering | Le Minh Cuong  |
--   |  1 | Engineering | Pham Quoc Dung |
--   |  2 | Sales       | Hoang Thi Hoa  |
--   |  2 | Sales       | Vu Van Giang   |
--   |  2 | Sales       | Ly Thi Nga     |
--   |  3 | Marketing   | Dang Ngoc Hanh |
--   |  3 | Marketing   | Bui Gia Khanh  |
--   |  4 | HR          | Do Thi Lan     |
--   |  5 | Legal       | NULL           |  <- the empty department is kept
--   +----+-------------+----------------+
--   This time Legal is saved, while Minh and Phuc disappear.
--   => Table order decides WHICH SIDE is protected. LEFT JOIN is not
--      symmetric — that is the biggest difference from INNER JOIN.
--   Note 11 > 5: Engineering expands into 4 rows because it has 4
--   employees. LEFT JOIN guarantees "no row of A is lost", NOT
--   "the row count equals A".
--
-- EXERCISE 2.3 — RIGHT JOIN gives EXACTLY the same result as 2.2.
--   Rewrite: FROM departments d LEFT JOIN employees e
--                  ON e.department_id = d.id
--   Just swap the two tables and change RIGHT to LEFT.
--
-- EXERCISE 2.4 — ANTI-JOIN:
--   a) Ngo Huu Minh (10), Truong Van Phuc (12)
--   b) Test a column that can NEVER be NULL in table B — usually the
--      primary key, or the very column used in ON. If you test a
--      nullable column you cannot tell "no match" apart from
--      "matched, but the value happens to be NULL".
--   c) `WHERE e.department_id IS NULL` only catches people who LEFT the
--      department blank. The anti-join ALSO catches department_id = 99
--      pointing at a non-existent department (garbage data / missing
--      foreign key). The two queries MEAN different things — do not
--      substitute one for the other.
--   D) Departments with no employees:
--      SELECT d.id, d.name FROM departments d
--      LEFT JOIN employees e ON e.department_id = d.id
--      WHERE e.id IS NULL;
--      -> 5 | Legal
--
-- EXERCISE 2.5 — emulated FULL OUTER: 13 rows
--   = 12 employees (including the 2 with NULL department) + 1 row (NULL, Legal)
--   b) UNION ALL gives 23 rows: 12 + 11, where the matching part (10
--      rows) is counted twice. UNION deduplicated it for us.
--   c) UNION deduplicates across ALL selected columns. Two people with
--      the same name in the same department would collapse into one.
--      Avoid it by always SELECTing the primary key (e.id) so every row
--      is unique.
--
-- EXERCISE 2.6 — THE COUNT TRAP:
--   +-------------+------------+-----------+
--   | department  | count_star | count_col |
--   +-------------+------------+-----------+
--   | Engineering |          4 |         4 |
--   | Sales       |          3 |         3 |
--   | Marketing   |          2 |         2 |
--   | HR          |          1 |         1 |
--   | Legal       |          1 |         0 |   <-- HERE
--   +-------------+------------+-----------+
--   COUNT(*) counts ROWS. Legal has exactly 1 row — the all-NULL row
--   invented by the LEFT JOIN. So it returns 1.
--   COUNT(e.id) counts NON-NULL values of that column -> 0. CORRECT.
--
--   => RULE: after a LEFT JOIN, ALWAYS count with
--      COUNT(<column of the right table>), never COUNT(*). This is the
--      most common source of wrong numbers in real SQL — and it is
--      silent, nobody reports an error to you.
--      (SUM is the opposite problem: SUM(NULL) is NULL, so wrap it in
--       COALESCE(..., 0))
--
-- EXERCISE 2.7 A — solution:
--   SELECT p.name AS project, COALESCE(SUM(a.hours), 0) AS total_hours
--   FROM projects p LEFT JOIN assignments a ON a.project_id = p.id
--   GROUP BY p.id, p.name ORDER BY total_hours DESC;
--   +-------------------+-------------+
--   | Mobile App        |         390 |
--   | Website Redesign  |         340 |
--   | CRM Migration     |         340 |
--   | Brand Campaign    |         290 |
--   | Recruiting Portal |         100 |
--   | Data Warehouse    |           0 |
--   | Office Relocation |           0 |
--   +-------------------+-------------+
--   Compared with 1.7C (INNER JOIN, 5 rows): now all 7 are there. Drop
--   the COALESCE and the last two rows show NULL instead of 0.
--
-- EXERCISE 2.7 B — solution:
--   SELECT e.id, e.full_name FROM employees e
--   LEFT JOIN assignments a ON a.employee_id = e.id
--   WHERE a.employee_id IS NULL;
--   -> 10 Ngo Huu Minh, 12 Truong Van Phuc
--
-- EXERCISE 2.7 C — solution:
--   SELECT p.id, p.name FROM projects p
--   LEFT JOIN assignments a ON a.project_id = p.id
--   WHERE a.project_id IS NULL;
--   -> 6 Data Warehouse, 7 Office Relocation
--
-- EXERCISE 2.7 D — solution:
--   SELECT e.full_name,
--          COALESCE(d.name, '(no department)') AS department,
--          COALESCE(d.city, '-')               AS city
--   FROM employees e LEFT JOIN departments d ON e.department_id = d.id
--   ORDER BY e.id;
--   -> 12 rows, Minh and Phuc show '(no department)'
--
-- PHASE 2 TAKEAWAYS:
--   1. LEFT JOIN = "keep everything on the left, fill gaps with NULL".
--   2. The order of the two tables decides which side is protected —
--      swapping them changes the result. With INNER JOIN, swapping is harmless.
--   3. The ANTI-JOIN pattern `LEFT JOIN ... WHERE b.pk IS NULL` finds
--      what is MISSING. Memorise it; you will use it forever.
--   4. NULLs produced by an OUTER JOIN poison every calculation after
--      them: COUNT(*) miscounts, SUM returns NULL, `=` comparisons never hold.
--   5. MySQL has no FULL OUTER JOIN -> LEFT UNION RIGHT.
-- ============================================================
