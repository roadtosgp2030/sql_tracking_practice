CREATE TABLE staff (
    id          INT,
    full_name   VARCHAR(100),
    department  VARCHAR(50),
    birth_year  INT,
    salary      DECIMAL(10,2),
    joined_date DATE
);

INSERT INTO staff VALUES
(1,  'Nguyen Van An',      'Engineering',  1990, 15000000, '2020-03-15'),
(2,  'Tran Thi Bich',      'Marketing',    1995, 12000000, '2021-07-01'),
(3,  'Le Hoang Nam',       'Engineering',  1988, 18000000, '2019-01-10'),
(4,  'Pham Thu Huong',     'HR',           1992, 11000000, '2022-05-20'),
(5,  'Vo Minh Duc',        'Engineering',  1993, 16000000, '2020-11-03'),
(6,  'Dang Van Em',        'Marketing',    1997, 10000000, '2023-02-14'),
(7,  'Bui Thi Phuong',     'HR',           1991, 11500000, '2021-09-30'),
(8,  'Do Quoc Hung',       'Engineering',  1989, 17000000, '2018-06-01'),
(9,  'Hoang Thi Lan',      'Marketing',    1994, 13000000, '2020-08-22'),
(10, 'Ngo Minh Khoa',      'Engineering',  1996, 14000000, '2022-12-05');

# Bài 1
select concat(upper(left(department, 3)), '-', birth_year, '-', lpad(id, 3, '0')) as code
from staff;

# Bài 2
select concat(lower(left(substring_index(full_name, ' ', -1), 1)),
              lower(substring_index(full_name, ' ', 1))) as username,
    concat(concat(lower(left(substring_index(full_name, ' ', -1), 1)),
              lower(substring_index(full_name, ' ', 1))), '@company.vn') as email
from staff;

with base as (
    select concat(lower(left(substring_index(full_name, ' ', -1), 1)),
              lower(substring_index(full_name, ' ', 1))) as username
    from staff
)
select username, concat(username, '@company.vn') as email from base;

# Bài 3
select full_name, lower(replace(full_name, ' ', '-')) as slug from staff;

# Bài 4
with base as (
    select full_name, department, left(joined_date, 4) as joined_year, format(salary, '0') as salary_formatted from staff
)
select concat(full_name, ' works in ', department, ' since ', joined_year, ' earning ', salary_formatted, ' VND/month.') as description from base;

# Bài 5:
with base as (
    select *, concat(lower(left(substring_index(full_name, ' ', -1), 1)),
              lower(substring_index(full_name, ' ', 1))) as username,
        left(joined_date, 4) as joined_year,
         format(salary, '0') as salary_formatted
    from staff
)
select
    concat(upper(left(department, 3)), '-', birth_year, '-', lpad(id, 3, '0')) as employee_code,
    full_name,
    username,
    concat(username + '@company.vn') as email,
    lower(replace(full_name, ' ', '-')) as slug,
    concat(full_name, ' works in ', department, ' since ', joined_year, ' earning ', salary_formatted, ' VND/month.') as description
from base where department = 'Engineering';

