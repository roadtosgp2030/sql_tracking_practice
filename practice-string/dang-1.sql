-- Active: 1778116211273@@127.0.0.1@3306@practice_string
CREATE TABLE employees (
    id       INT,
    full_name VARCHAR(100),
    email    VARCHAR(100)
);

INSERT INTO employees VALUES
(1, 'Nguyen Van An',      'van.an@techcorp.com'),
(2, 'Tran Thi Bich',      'thi.bich@gmail.com'),
(3, 'Le Hoang Nam',       'hoang.nam@techcorp.com'),
(4, 'Pham Thi Thu Huong', 'thu.huong@outlook.com'),
(5, 'Vo Minh Duc',        'minh.duc@gmail.com');

-- Bài 1
select full_name, left(full_name, LOCATE(' ', full_name) - 1) as ho from employees;

-- Bài 2
select full_name, right(full_name, LOCATE(" ", REVERSE(full_name)) - 1) as ten from employees;

-- Bài 3
select email, left(email, LOCATE('@', email) - 1) as username from employees;

-- Bài 4
select email, right(email, LOCATE('@', reverse(email)) - 1) as domain from employees;
select email, substring(email, LOCATE('@', email) + 1, LENGTH(email)) as domain from employees;

-- Bài 5
select
    full_name,
    left(full_name, LOCATE(' ', full_name) - 1) as ho,
    substring(full_name, LENGTH(full_name) - LOCATE(' ', REVERSE(full_name)) + 2, LENGTH(full_name)) as ten,
    left(email, LOCATE('@', email) - 1) as username,
    substring(email, LOCATE('@', email) + 1, length(email)) as domain
from employees where substring(email, LOCATE('@', email) + 1, length(email)) = 'techcorp.com';
select * from (
    select
        full_name,
        left(full_name, LOCATE(' ', full_name) - 1) as ho,
        substring(full_name, LENGTH(full_name) - LOCATE(' ', REVERSE(full_name)) + 2, LENGTH(full_name)) as ten,
        left(email, LOCATE('@', email) - 1) as username,
        substring(email, LOCATE('@', email) + 1, length(email)) as domain
    from employees
) t
where t.domain = 'techcorp.com';
with cte as (
    select
        full_name,
        left(full_name, LOCATE(' ', full_name) - 1) as ho,
        substring(full_name, LENGTH(full_name) - LOCATE(' ', REVERSE(full_name)) + 2, LENGTH(full_name)) as ten,
        left(email, LOCATE('@', email) - 1) as username,
        substring(email, LOCATE('@', email) + 1, length(email)) as domain
    from employees
)
select * from cte where domain = 'techcorp.com';
