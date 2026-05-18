CREATE TABLE contacts (
    id      INT,
    name    VARCHAR(100),
    email   VARCHAR(100),
    phone   VARCHAR(20),
    code    VARCHAR(20)
);

INSERT INTO contacts VALUES
(1,  'Nguyen Van An',   'van.an@techcorp.com',   '0912345678',  'SP-2024-001'),
(2,  'Tran Thi Bich',   'thi.bich@',             '091234567',   'SP-2024-002'),
(3,  'Le Hoang Nam',    'hoang.nam@yahoo.com',   '09123456789', 'SV-2024-003'),
(4,  'Pham Thu Huong',  'thu.huong@outlook.com', '0912345678',  'SP-202-004'),
(5,  'Vo Minh Duc',     'minh.duc@gmail.com',    '0912345678',  'SP-2024-005'),
(6,  'Dang Van Em',     'van.em@',               '08123456789', 'SP-2024-006'),
(7,  'Bui Thi Phuong',  'thi.phuong@gmail.com',  '0312345678',  'SV-2024-007'),
(8,  'Do Quoc Hung',    '@gmail.com',             '0912 345678', 'SP-2024-008'),
(9,  'Hoang Thi Lan',   'thi.lan@hotmail.com',   '0912345678',  'SP-2024-009'),
(10, 'Ngo Minh Khoa',   'minh.khoa@gmail.com',   '0912345678',  'SV-2024-010');

select email from contacts where email not like '%_@_%._%';

select phone from contacts where phone not regexp '0[89][0-9]{8}$';

select code from contacts where code not regexp '^S[PV]-[0-9]{4}-[0-9]{3}$';

select name, email, code, name from contacts where name like '%Thi%';
select name, email, code, name from contacts where email like '%gmail.com';
select name, email, code, name from contacts where code regexp '^SP-[0-9]{4}-[0-9]{3}$';
select name, email, code, name from contacts where name regexp '^(Nguyen|Tran|Le)';

select
    id,
    name,
    case
        when email like '%_@_%._%' then 1
        else 0
    end as email_ok,
    case
        when phone regexp '0[89][0-9]{8}$' then 1
        else 0
    end as phone_ok,
    case
        when code regexp '^S[PV]-[0-9]{4}-[0-9]{3}$' then 1
        else 0
    end as code_ok
from contacts;

