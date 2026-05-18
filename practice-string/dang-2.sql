CREATE TABLE customers (
    id       INT,
    name     VARCHAR(100),
    email    VARCHAR(100),
    phone    VARCHAR(20),
    city     VARCHAR(50)
);

INSERT INTO customers VALUES
(1, '  nguyen van an ',  'Van.An@Gmail.COM  ',   '0912-345-678',  'ha noi'),
(2, 'TRAN THI BICH',     '  thi.bich@gmail.com', '(091) 234 5678', 'HO CHI MINH'),
(3, 'le hoang    nam',   'Hoang.Nam@Yahoo.com',  '0908.123.456',  'Da Nang  '),
(4, '  Pham Thu Huong',  'thu.huong@OUTLOOK.COM','091 345 6789 ',  '  hue'),
(5, 'VO MINH DUC  ',     'Minh.Duc@Gmail.com  ', '0923-456-789',  'can tho');

-- Bài 1
select trim(name) as name, trim(email) as email, trim(city) as city from customers;

-- Bài 2
select trim(regexp_replace(name, '\\s+', ' ')) as name from customers;

# Bài 3
select lower(email) as email, concat(upper(left(trim(city), 1)), lower(substring(trim(city), 2))) as city from customers;

# Bài 4
select regexp_replace(phone, '[^0-9]+', '') as phone from customers;

# Bài 5
select
    trim(regexp_replace(name, '\\s+', ' ')) as name,
    trim(lower(email)) as email,
    regexp_replace(phone, '[ .()-]+', '') as phone,
    concat(upper(left(trim(city), 1)), lower(substr(trim(city), 2))) as city
from customers;