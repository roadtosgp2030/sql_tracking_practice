-- ============================================================
-- PHASE 3 — SELF JOIN, MANY-TO-MANY, NON-EQUI JOIN
-- (do phase1.sql and phase2.sql first)
-- ============================================================
USE join_lab;

-- ============================================================
-- BACKGROUND — three "non-trivial" kinds of JOIN
-- ============================================================
-- 1. SELF JOIN — join a table to ITSELF.
--    Used when the table has a column pointing back at itself
--    (manager_id -> id), or when you need to compare row against row.
--    Aliases are MANDATORY, because MySQL must tell the copies apart.
--    Just imagine TWO different tables that happen to hold the same data.
--
--        FROM employees e            <- the "employee" role
--        JOIN employees m ON e.manager_id = m.id   <- the "manager" role
--
-- 2. MANY-TO-MANY through a JUNCTION table.
--    You cannot store "many projects" for one employee in a single column,
--    so you split it out into assignments(employee_id, project_id).
--    Going from employees to projects requires TWO joins:
--
--        employees --> assignments --> projects
--
-- 3. NON-EQUI JOIN — the ON condition is not "=".
--    ON a.salary BETWEEN g.min AND g.max, ON a.id < b.id, ON <, >, !=...
--    All perfectly legal. ON only has to be a TRUE/FALSE expression.
--    (One caveat: non-equi joins use indexes far less effectively than
--     equi joins; be careful on big tables — see the indexing lab.)
-- ============================================================
-- ============================================================
-- EXERCISE 3.1 — SELF JOIN: who reports to whom
-- ============================================================
-- TASK:
-- a) Run it. How many rows? Who is missing out of the 12 people?
-- b) Remove the aliases `e` and `m` and run again. What error does MySQL give?
-- c) `m` and `e` are the same employees table. So can "Nguyen Van An"
--    appear in both roles?
SELECT
    e.id,
    e.full_name AS employee,
    m.full_name AS manager
FROM
    employees e
    JOIN employees m ON e.manager_id = m.id
ORDER BY
    e.id;

-- Your answers:
-- a)
-- b)
-- c) yes
-- ============================================================
-- EXERCISE 3.2 — SELF JOIN + LEFT: don't drop the top boss
-- ============================================================
-- TASK:
-- Fix 3.1 so all 12 people show up. Anyone without a manager should
-- display '(no manager)' in the manager column.
-- Write your query below:
select e.id,
    e.full_name AS employee,
    COALESCE(m.full_name, '(no manager)') AS manager
    from employees e
    left join employees m on e.manager_id = m.id;

-- ============================================================
-- EXERCISE 3.3 — Count direct reports (reusing the COUNT trap from phase 2)
-- ============================================================
-- TASK:
-- Count each person's DIRECT reports, all 12 rows; people who manage
-- nobody must show 0.
-- Careful: which table goes on the LEFT this time? (the manager, or the
-- employee?) And do you count with COUNT(*) or COUNT(column)?
-- Write your query below:

select
    m.full_name,
    count(e.id)
from
    employees m
    left join employees e on e.manager_id = m.id
group by
    m.id,
    m.full_name;

-- Check: the sum of the report_count column must equal the number of
-- people who HAVE a manager_id. How many is that? ...
-- ============================================================
-- EXERCISE 3.4 — Three-level SELF JOIN
-- ============================================================
-- TASK:
-- Join the same table three times: employee -> manager -> manager's manager.
-- a) Run it and read the result.
-- b) Why MUST both joins be LEFT JOIN? Try changing the second one to a
--    plain JOIN and see how many rows you lose.
-- c) This approach only walks a FIXED number of levels. What do you need
--    to walk a tree of arbitrary depth? (keyword: recursive CTE)

SELECT
    e.full_name AS employee,
    m.full_name AS manager,
    gm.full_name AS grand_manager
FROM
    employees e
    LEFT JOIN employees m ON e.manager_id = m.id
    LEFT JOIN employees gm ON m.manager_id = gm.id
ORDER BY
    e.id;

-- Your answers:
-- a)
-- b)
-- c)
-- ============================================================
-- EXERCISE 3.5 — SELF JOIN for PAIRS + the `a.id < b.id` trick
-- ============================================================
-- TASK:
-- The query below lists pairs of colleagues in the same department.
-- a) Run it as-is. How many pairs?
-- b) Change `a.id < b.id` to `a.id <> b.id` and run again. How many now?
--    Why twice as many?
-- c) Remove that condition entirely (keep only the department match).
--    How many rows? What do the extra rows mean?
-- d) Conclusion: how does `<` differ from `<>` when building pairs?
SELECT
    d.name AS department,
    a.full_name AS person_1,
    b.full_name AS person_2
FROM
    employees a
    JOIN employees b ON a.department_id = b.department_id
    AND a.id < b.id
    JOIN departments d ON d.id = a.department_id
ORDER BY
    d.id,
    a.id,
    b.id;

-- Your answers:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- EXERCISE 3.6 — MANY-TO-MANY: going through the junction table
-- ============================================================
-- TASK A:
-- The assignments table holds nothing but numbers (employee_id,
-- project_id, hours). Run `SELECT * FROM assignments;` — it is
-- completely unreadable. JOIN it into a table with PEOPLE NAMES and
-- PROJECT NAMES.
-- Write your query below:
select
    a.hours,
    e.full_name,
    p.name
from
    assignments a
    left join employees e on a.employee_id = e.id
    left join projects p on a.project_id = p.id;


-- TASK B:
-- For EACH employee (all 12): the number of projects and total hours.
-- People with no work must show 0 and 0 (not NULL).
-- Write your query below:
select
    e.full_name,
    count(p.id) as number_proj,
    sum(a.hours) as total_hours
from
    employees e
    left join assignments a on e.id = a.employee_id
    left join projects p on a.project_id = p.id
group by e.full_name;

-- TASK C:
-- The query below finds pairs of people who have WORKED TOGETHER on a
-- project. It self-joins the JUNCTION table (a1, a2), not employees.
-- a) Run it and verify a few pairs by eye against schema.sql.
-- b) What happens if you drop `a1.employee_id < a2.employee_id`?
--    (think about the case where a1 and a2 land on the SAME row)
select employee_id from assignments
EXCEPT
SELECT
    a1.employee_id
FROM
    assignments a1
    JOIN assignments a2 ON a1.project_id = a2.project_id
    AND a1.employee_id < a2.employee_id;


select * from assignments;

    SELECT
    a1.employee_id
FROM
    assignments a1
    JOIN assignments a2 ON a1.project_id = a2.project_id
    AND a1.employee_id < a2.employee_id;

SELECT
    p.name AS project,
    e1.full_name AS person_1,
    e2.full_name AS person_2
FROM
    assignments a1
    JOIN assignments a2 ON a1.project_id = a2.project_id
    AND a1.employee_id < a2.employee_id
    JOIN employees e1 ON e1.id = a1.employee_id
    JOIN employees e2 ON e2.id = a2.employee_id
    JOIN projects p ON p.id = a1.project_id
ORDER BY
    p.id,
    e1.id,
    e2.id;

-- Your answers:
-- a)
-- b)
-- ============================================================
-- EXERCISE 3.7 — NON-EQUI JOIN: joining by RANGE, not by "="
-- ============================================================
-- salary_grades has no column that matches employees with "=".
-- It only has min_salary / max_salary. We join with BETWEEN.
--
-- TASK:
-- a) Run it. How many rows? Who is lost and why?
--    (re-read the salary grade section of schema.sql)
-- b) Change it to a LEFT JOIN so all 12 people appear.
-- c) If two grades had OVERLAPPING ranges (say C: 3500-5000 and
--    B: 5000-7999), how many rows would a person earning 5000 produce?
--    Why is that a dangerous bug?
SELECT
    e.full_name,
    e.salary,
    g.grade
FROM
    employees e
    left JOIN salary_grades g ON e.salary BETWEEN g.min_salary AND g.max_salary
ORDER BY
    e.salary DESC;

-- Rewrite as a LEFT JOIN here:


-- Your answers:
-- a)
-- b)
-- c)
-- ============================================================
-- EXERCISE 3.8 — On your own
-- ============================================================
-- TASK A:
-- List employee + department name + manager name + salary grade, for
-- ALL 12 people.
-- (4 tables joined, with employees appearing twice)
-- Write your query below:
select
    e.full_name as employee_name,
    d.name as department_name,
    m.full_name as manager_name,
    sg.grade as salary_grade
from
    employees e
    left join departments d on e.department_id = d.id
    left join employees m on e.manager_id = m.id
    left join salary_grades sg on e.salary between sg.min_salary
    and sg.max_salary;

-- TASK B:
-- How many people and what total payroll does each department have?
-- All 5 departments; Legal must show 0 and 0.
-- Write your query below:
select
    d.name as department_name,
    count(e.id) as total_people,
    COALESCE(sum(e.salary), 0) as total_payroll
from
    departments d
    left join employees e on d.id = e.department_id
group by
    d.id,
    d.name;

-- TASK C:
-- Find employees working on a project that does NOT belong to their own
-- department. (hint: join employees -> assignments -> projects and
-- compare e.department_id with p.department_id; watch out for NULL)
-- Write your query below:
select
    *
from
    employees e
    left join assignments a on e.id = a.employee_id
    left join projects p on a.project_id = p.id
where
    e.department_id != p.department_id;


-- TASK D:
-- For each employee, count how many people in the company earn MORE
-- than they do. (non-equi self join: ON b.salary > a.salary, then
--  GROUP BY + COUNT — remember LEFT JOIN so the top earner shows 0)
-- Write your query below:
select
    e1.full_name,
    count(e2.id)
from
    employees e1
    left join employees e2 on e2.salary > e1.salary
group by
    e1.id,
    e1.full_name;

-- ============================================================
-- REFERENCE RESULTS (actually run on MySQL 8.0.45)
-- Only look after you have done the work yourself!
-- ============================================================
-- EXERCISE 3.1 — SELF JOIN: 10 rows
--   Missing id 1 (Nguyen Van An) and id 12 (Truong Van Phuc): manager_id NULL.
--   b) No aliases -> ERROR 1066 (42000): Not unique table/alias: 'employees'
--      MySQL has no way to know which copy `employees.id` refers to.
--   c) YES. Nguyen Van An appears in the `m` role (5 times, as a manager)
--      and he is also present in `e` — his own row is just eliminated by
--      the INNER JOIN because he himself has no manager. One data row can
--      play several roles at once; the alias IS the name of the role.
--
-- EXERCISE 3.2 — solution:
--   SELECT e.id, e.full_name AS employee,
--          COALESCE(m.full_name, '(no manager)') AS manager
--   FROM employees e LEFT JOIN employees m ON e.manager_id = m.id
--   ORDER BY e.id;
--   -> 12 rows; id 1 and id 12 show '(no manager)'
--
-- EXERCISE 3.3 — solution (note: the MANAGER goes on the LEFT):
--   SELECT m.id, m.full_name AS manager, COUNT(e.id) AS report_count
--   FROM employees m LEFT JOIN employees e ON e.manager_id = m.id
--   GROUP BY m.id, m.full_name
--   ORDER BY report_count DESC, m.id;
--   +----+-----------------+--------------+
--   |  1 | Nguyen Van An   |            5 |
--   |  2 | Tran Thi Binh   |            2 |
--   |  5 | Hoang Thi Hoa   |            2 |
--   |  7 | Dang Ngoc Hanh  |            1 |
--   |  3 | Le Minh Cuong   |            0 |   <- the other 8 people are all 0
--   +----+-----------------+--------------+
--   Total = 5+2+2+1 = 10, exactly the number of people with a manager_id (12 - 2).
--   COUNT(*) would return 1 for all 8 of the trailing people — WRONG.
--   The ON condition here is `e.manager_id = m.id`, i.e. REVERSED from 3.1.
--   Same table, same column, only the roles swapped -> a completely
--   different question.
--
-- EXERCISE 3.4 — three-level SELF JOIN: 12 rows
--   | Le Minh Cuong   | Tran Thi Binh  | Nguyen Van An |
--   | Tran Thi Binh   | Nguyen Van An  | NULL          |
--   | Truong Van Phuc | NULL           | NULL          |
--   b) If the second join is INNER: only 5 rows survive (people with all
--      3 levels). LEFT JOIN is "contagious": once you have gone LEFT,
--      every following join must be LEFT too, otherwise you lose exactly
--      the rows you just protected.
--   c) You need a RECURSIVE CTE (WITH RECURSIVE). A JOIN only walks as
--      many levels as you type out by hand.
--
-- EXERCISE 3.5 — pairing:
--   a) `a.id < b.id`  -> 10 pairs (Eng 6, Sales 3, Marketing 1, HR 0)
--      Formula: a department of n people gives n*(n-1)/2 pairs. 4->6, 3->3, 2->1, 1->0.
--   b) `a.id <> b.id` -> 20 rows. Each pair appears twice: (An,Binh) and
--      (Binh,An). The same relationship, counted in both directions.
--   c) Removing it entirely -> 30 rows. 10 extra self-pairs
--      (An,An), (Binh,Binh)... because An obviously shares a department with An.
--   d) `<>` eliminates self-pairs but still lets the mirrored pair
--      through. `<` eliminates BOTH at once — every pair exactly once.
--      This is the standard trick for any "list the pairs" problem.
--      (Note: Minh and Phuc appear in no pair because their department_id
--       is NULL, and NULL = NULL is still not true.)
--
-- EXERCISE 3.6 A — solution:
--   SELECT e.full_name, p.name AS project, a.hours
--   FROM assignments a
--   JOIN employees e ON e.id = a.employee_id
--   JOIN projects  p ON p.id = a.project_id
--   ORDER BY e.id, p.id;
--   -> 12 rows. A junction table is meaningless on its own; you must
--      join both ends to read it.
--
-- EXERCISE 3.6 B — solution:
--   SELECT e.id, e.full_name,
--          COUNT(a.project_id)        AS project_count,
--          COALESCE(SUM(a.hours), 0)  AS total_hours
--   FROM employees e LEFT JOIN assignments a ON a.employee_id = e.id
--   GROUP BY e.id, e.full_name
--   ORDER BY project_count DESC, e.id;
--   +----+-----------------+---------------+-------------+
--   |  2 | Tran Thi Binh   |             2 |         180 |
--   |  3 | Le Minh Cuong   |             2 |         350 |
--   |  1 | Nguyen Van An   |             1 |          20 |
--   |  ...                                                |
--   | 10 | Ngo Huu Minh    |             0 |           0 |
--   | 12 | Truong Van Phuc |             0 |           0 |
--   +----+-----------------+---------------+-------------+
--   Without COALESCE, total_hours for Minh/Phuc comes out NULL.
--
-- EXERCISE 3.6 C — 10 co-working pairs:
--   Website Redesign 3 pairs, Mobile App 3, CRM Migration 3, Brand Campaign 1.
--   b) Drop the `<` condition -> 32 rows instead of 10:
--        10 x 2 = 20 (each pair twice, forwards and backwards)
--        +   12     (each assignments row pairs with itself:
--                    a1 and a2 land on EXACTLY the same row -> (An, An))
--      => 32. Self-pairing is the easiest trap to forget in a self join.
--
-- EXERCISE 3.7 — NON-EQUI JOIN:
--   a) 11 rows. Truong Van Phuc (salary 2500) is lost — the lowest grade
--      is D, starting at 2600. No range contains 2500 -> no match.
--      This is a very common data bug: the lookup table has a GAP, and
--      the INNER JOIN silently swallows the record.
--   b) LEFT JOIN -> 12 rows, Phuc has grade = NULL. Using a LEFT JOIN is
--      precisely how you DISCOVER that gap.
--   c) Someone earning 5000 would produce TWO rows (one for C, one for B).
--      Dangerous because a "12 employees" table suddenly becomes 13 rows,
--      and every SUM/COUNT downstream is wrong. A range lookup table MUST
--      be free of overlaps and free of gaps.
--
-- EXERCISE 3.8 A — solution:
--   SELECT e.full_name AS employee,
--          COALESCE(d.name, '-')      AS department,
--          COALESCE(m.full_name, '-') AS manager,
--          COALESCE(g.grade, '-')     AS salary_grade
--   FROM employees e
--   LEFT JOIN departments   d ON d.id = e.department_id
--   LEFT JOIN employees     m ON m.id = e.manager_id
--   LEFT JOIN salary_grades g ON e.salary BETWEEN g.min_salary AND g.max_salary
--   ORDER BY e.id;
--   -> 12 rows. Every join must be LEFT; a single INNER loses people.
--
-- EXERCISE 3.8 B — solution:
--   SELECT d.name AS department, COUNT(e.id) AS headcount,
--          COALESCE(SUM(e.salary), 0) AS payroll
--   FROM departments d LEFT JOIN employees e ON e.department_id = d.id
--   GROUP BY d.id, d.name ORDER BY d.id;
--   Engineering 4 / 23500.00 | Sales 3 / 12200.00 | Marketing 2 / 7800.00
--   HR 1 / 4500.00 | Legal 0 / 0.00
--   Note: 23500+12200+7800+4500 = 48000, but the company's total payroll
--   is 53500 — the 5500 difference is Minh (3000) and Phuc (2500), the
--   two people who belong to no department. A report grouped by
--   department ALWAYS omits the orphan rows; know it and say so.
--
-- EXERCISE 3.8 C — solution:
--   SELECT e.full_name, d.name AS their_department, p.name AS project
--   FROM employees e
--   JOIN assignments a ON a.employee_id = e.id
--   JOIN projects    p ON p.id = a.project_id
--   LEFT JOIN departments d ON d.id = e.department_id
--   WHERE NOT (e.department_id <=> p.department_id);
--   -> 0 rows. In this data everyone works on their own department's projects.
--   Use the <=> operator (NULL-safe equal) instead of = so that NULL does
--   not turn the condition into UNKNOWN. Try `WHERE e.department_id <>
--   p.department_id` — it also returns 0 rows, but for a DIFFERENT reason
--   (any comparison touching NULL is discarded). The two queries happen
--   to agree here, but they say different things.
--
-- EXERCISE 3.8 D — solution:
--   SELECT a.full_name, a.salary, COUNT(b.id) AS people_earning_more
--   FROM employees a LEFT JOIN employees b ON b.salary > a.salary
--   GROUP BY a.id, a.full_name, a.salary
--   ORDER BY people_earning_more;
--   -> An 0, Binh 1, Hoa 2, Hanh 3, Lan 4, Cuong 5, Dung 6, Nga 7,
--      Giang 8, Minh 9, Khanh 10, Phuc 11
--   This is RANK() done by hand. Window functions do it far more neatly,
--   but understanding how a JOIN produces it is what teaches you the idea.
--
-- PHASE 3 TAKEAWAYS:
--   1. SELF JOIN: the alias IS the "role". Swapping roles in ON changes
--      the question entirely (3.1 asks "who is my manager", 3.3 asks
--      "who reports to me").
--   2. LEFT JOIN is contagious: once you go LEFT, every later join must
--      be LEFT too.
--   3. For pairs use `a.id < b.id`, not `<>`.
--   4. Many-to-many always needs a junction table and TWO joins.
--   5. ON does not have to be "=". BETWEEN, <, > are all valid. But a
--      range lookup table with gaps or overlaps produces wrong results
--      or lost rows, and nobody will tell you.
-- ============================================================
