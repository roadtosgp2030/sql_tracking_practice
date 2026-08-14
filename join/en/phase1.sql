-- Active: 1778116211273@@127.0.0.1@3306@join_lab
-- ============================================================
-- PHASE 1 — What a JOIN really is & INNER JOIN
-- (run schema.sql first)
-- ============================================================
USE join_lab;

-- ============================================================
-- BACKGROUND — what is a JOIN, really?
-- ============================================================
-- Every JOIN is 2 steps, always:
--
--   STEP 1: pair EVERY row of table A with EVERY row of table B
--           (12 employees x 5 departments = 60 pairs)
--   STEP 2: keep only the pairs that satisfy the ON condition
--
-- In practice MySQL is not that dumb (it uses indexes, hash tables...),
-- but the RESULT is always identical to this 2-step model.
-- When you get stuck, come back to this model — it has never been wrong.
--
-- SYNTAX:
--      SELECT ...
--      FROM      A
--      JOIN      B  ON  A.col = B.col
--
--   JOIN       = INNER JOIN  (shorthand, exactly the same thing)
--   ON         = the PAIRING condition
--   WHERE      = the FILTER applied after pairing is done
--
-- ALIAS: `FROM employees e` lets you write `e.id` instead of
-- `employees.id`. Mandatory when you join a table with itself.
--
-- GOLDEN RULE: whenever a column name exists in more than one table
-- (id, name...), ALWAYS write the table prefix. If you don't ->
-- error "Column 'id' in field list is ambiguous".
-- ============================================================
-- ============================================================
-- EXERCISE 1.1 — See STEP 1: the Cartesian product (CROSS JOIN)
-- ============================================================
-- TASK:
-- Run both statements below. The first counts the pairs, the second
-- shows the first 12 pairs. Then answer:
--   a) How many rows? Which multiplication gives that number?
--   b) Look at the first 12 rows: how many times does each employee appear?
--   c) Does this data mean anything? (Is Nguyen Van An really in Legal?)
SELECT
    COUNT(*) AS pair_count
FROM
    employees,
    departments;

SELECT
    e.full_name,
    d.name AS department
FROM
    employees e
    CROSS JOIN departments d
ORDER BY
    e.id,
    d.id
LIMIT
    12;

-- Your answers:
-- a) 60, 12 * 5
-- b) 5
-- c) No
-- ============================================================
-- EXERCISE 1.2 — Add STEP 2: INNER JOIN
-- ============================================================
-- TASK:
-- The query below differs from 1.1 only by the ON clause.
-- a) Run it. How many rows?
-- b) employees has 12 rows. So where did 2 people go? Who are they?
--    (re-open schema.sql if you need to check the data)
SELECT
    e.id,
    e.full_name,
    d.name AS department
FROM
    employees e
    JOIN departments d ON e.department_id = d.id
ORDER BY
    e.id;

-- Your answers:
-- a) 10
-- b) They are not belongs to any departments
-- ============================================================
-- EXERCISE 1.3 — INNER JOIN cuts BOTH sides
-- ============================================================
-- TASK:
-- a) Count the rows in departments.
-- b) Count the DISTINCT departments that show up in the JOIN of 1.2.
--    (hint: COUNT(DISTINCT d.id))
-- c) Which department disappeared? Why?
-- Write your query below:
SELECT
    count(DISTINCT d.id)
FROM
    employees e
    JOIN departments d ON e.department_id = d.id;

-- Your answers:
-- a)5
-- b)4
-- c)Legal because no employee belongs to that department
-- REMEMBER: INNER JOIN keeps only rows present on BOTH sides.
--           No match -> gone, whether it was on the left or the right.
-- ============================================================
-- EXERCISE 1.4 — Joining more than 2 tables
-- ============================================================
-- TASK:
-- The query below joins 4 tables. Read the order carefully: each new
-- JOIN only needs to connect to ONE of the tables already above it.
-- a) Run it and count the rows.
-- b) Which name appears twice? Why the duplicate — is the data wrong?
-- c) Why is Ngo Huu Minh (id 10) missing? How MANY reasons are there?
SELECT
    ROW_NUMBER() OVER (ORDER BY e.id, p.id) as row_num,
    e.full_name,
    d.name AS dept,
    p.name AS project,
    a.hours
FROM
    employees e
    JOIN departments d ON e.department_id = d.id
    JOIN assignments a ON a.employee_id = e.id
    JOIN projects p ON p.id = a.project_id
ORDER BY
    e.id,
    p.id;

-- Your answers:
-- a) 12
-- b) Tran Thi Binh, no
-- c)
-- ============================================================
-- EXERCISE 1.5 — Using ON and WHERE together
-- ============================================================
-- TASK:
-- List the full name + department name of employees earning > 4000,
-- sorted by salary descending.
-- The salary condition belongs in WHERE, NOT in ON.
-- (With an INNER JOIN both placements give the same result — but with
--  a LEFT JOIN they are COMPLETELY different. Phase 4 dissects that.
--  For now, build the habit: ON pairs, WHERE filters.)
-- Write your query below:
select
    e.full_name,
    d.name,
    e.salary
from
    employees e
    join departments d on e.department_id = d.id
where
    e.salary > 4000
order by
    salary desc;


-- ============================================================
-- EXERCISE 1.6 — USING: shorthand when both columns SHARE A NAME
-- ============================================================
-- TASK:
-- Do assignments and projects both have a column called `project_id`?
-- NO — projects names its key column `id`. So USING does NOT work here.
-- a) Run the query below and read the error MySQL gives you.
-- b) Conclude: what is the requirement for using USING?
SELECT
    *
FROM
    assignments a
    JOIN projects p USING (project_id);

-- Your answers:
-- a)
-- b)
-- ============================================================
-- EXERCISE 1.7 — On your own
-- ============================================================
-- TASK A:
-- List every project together with the NAME OF THE DEPARTMENT that owns it.
-- Count the rows, and identify which project is lost compared to the 7 originals.
-- Write your query below:
select p.name as project_name, d.name as department_name from projects p join departments d on p.department_id = d.id;


-- Row count: ...   Missing project: ...

-- TASK B:
-- List employee name + project name they work on + hours,
-- ONLY for projects with budget >= 30000, sorted by hours descending.
-- (join employees -> assignments -> projects)
-- Write your query below:
select
    e.full_name as employee_name,
    p.name as project_name,
    a.hours as hours
from
    employees e
    join departments d on e.department_id = d.id
    join projects p on e.id = p.department_id
    join assignments a on e.id = a.employee_id;


-- TASK C:
-- Total hours spent on EACH project (with the project name).
-- Use JOIN + GROUP BY. Note: only 5 projects have data.
-- Write your query below:
select
    p.name as project_name,
    sum(a.hours)
from
    projects p
    join assignments a on p.id = a.project_id
group by
    p.name;


-- ============================================================
-- REFERENCE RESULTS (actually run on MySQL 8.0.45)
-- Only look after you have done the work yourself!
-- ============================================================
-- EXERCISE 1.1 — CROSS JOIN:
--   pair_count = 60   (12 employees x 5 departments)
--   First 12 rows: Nguyen Van An repeats 5 times, once per department.
--   The data is MEANINGLESS: An is paired with Legal, Sales, HR... This
--   is only the raw material, not yet filtered.
--   (Writing `FROM a, b` IS a CROSS JOIN — the old syntax, easy to forget
--    the join condition with. Always write JOIN ... ON explicitly.)
--
-- EXERCISE 1.2 — INNER JOIN: 10 rows
--   +----+----------------+-------------+
--   | id | full_name      | department  |
--   +----+----------------+-------------+
--   |  1 | Nguyen Van An  | Engineering |
--   |  2 | Tran Thi Binh  | Engineering |
--   |  3 | Le Minh Cuong  | Engineering |
--   |  4 | Pham Quoc Dung | Engineering |
--   |  5 | Hoang Thi Hoa  | Sales       |
--   |  6 | Vu Van Giang   | Sales       |
--   |  7 | Dang Ngoc Hanh | Marketing   |
--   |  8 | Bui Gia Khanh  | Marketing   |
--   |  9 | Do Thi Lan     | HR          |
--   | 11 | Ly Thi Nga     | Sales       |
--   +----+----------------+-------------+
--   LOST id 10 (Ngo Huu Minh) and id 12 (Truong Van Phuc): both have
--   department_id = NULL. And NULL = 5 is not true, NULL = NULL is not
--   true either — NULL equals nothing, not even itself.
--   So they cannot pair with any row.
--
-- EXERCISE 1.3 — departments has 5, but COUNT(DISTINCT d.id) = 4.
--   Legal (id 5) is lost because no employee has department_id = 5.
--   => INNER JOIN cuts BOTH sides; it favours neither table.
--
-- EXERCISE 1.4 — 4-table JOIN: 12 rows
--   Tran Thi Binh and Le Minh Cuong each appear twice, because each of
--   them works on 2 projects. The data is NOT wrong: the unit of a row
--   is no longer "an employee", it is "one assignment".
--   Always ask yourself: "what does ONE ROW of this result represent?"
--
--   Ngo Huu Minh is absent for TWO independent reasons — either one alone
--   is fatal:
--     1. department_id NULL -> dropped by JOIN departments
--     2. no row in assignments -> dropped by JOIN assignments
--
-- EXERCISE 1.5 — solution:
--   SELECT e.full_name, d.name AS department, e.salary
--   FROM employees e
--   JOIN departments d ON e.department_id = d.id
--   WHERE e.salary > 4000
--   ORDER BY e.salary DESC;
--   -> 6 rows: An 9000, Binh 6500, Hoa 5500, Hanh 5000, Lan 4500, Cuong 4200
--
-- EXERCISE 1.6 — MySQL says:
--   ERROR 1054 (42S22): Unknown column 'project_id' in 'from clause'
--   USING(x) only works when BOTH tables have a column named exactly `x`.
--   Here projects names its key column `id`, not `project_id`.
--   The other difference: USING merges the two columns into one in
--   SELECT *, while ON keeps both. When the names differ -> ON is required.
--
-- EXERCISE 1.7 A — projects JOIN departments: 6 rows.
--   SELECT p.name AS project, d.name AS department
--   FROM projects p JOIN departments d ON p.department_id = d.id;
--   Lost 'Data Warehouse' (department_id = NULL).
--   Note: 'Office Relocation' IS STILL THERE, because it has
--   department_id = 5 and Legal does exist — Legal is only missing
--   EMPLOYEES, not projects.
--
-- EXERCISE 1.7 B — solution:
--   SELECT e.full_name, p.name AS project, a.hours
--   FROM employees e
--   JOIN assignments a ON a.employee_id = e.id
--   JOIN projects p ON p.id = a.project_id
--   WHERE p.budget >= 30000
--   ORDER BY a.hours DESC;
--   -> 9 rows (budget >= 30000 covers projects 1, 2, 3 — project 6 has
--      enough budget but nobody works on it, so it never shows up).
--      Top row: Le Minh Cuong / Website Redesign / 200
--
-- EXERCISE 1.7 C — solution:
--   SELECT p.name AS project, SUM(a.hours) AS total_hours
--   FROM projects p JOIN assignments a ON a.project_id = p.id
--   GROUP BY p.id, p.name
--   ORDER BY total_hours DESC;
--   +-------------------+-------------+
--   | Mobile App        |         390 |
--   | Website Redesign  |         340 |
--   | CRM Migration     |         340 |
--   | Brand Campaign    |         290 |
--   | Recruiting Portal |         100 |
--   +-------------------+-------------+
--   Only 5 rows — projects 6 and 7 are eliminated by the INNER JOIN.
--   To see them with total = 0 you need a LEFT JOIN -> phase 2.
--
-- PHASE 1 TAKEAWAYS:
--   1. JOIN = pair everything, then filter with ON. Stuck? Go back to
--      that model.
--   2. INNER JOIN cuts both sides — non-matching rows vanish silently,
--      MySQL never warns you. Always COUNT THE ROWS before and after a JOIN.
--   3. NULL matches nothing, not even another NULL.
--   4. After a JOIN, "one row" may no longer be "one employee".
-- ============================================================
