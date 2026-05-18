# Dạng 3 — Kiểm tra & lọc theo pattern

## Bảng dữ liệu mẫu

```sql
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
```

**Quy tắc hợp lệ:**
- `email`: có đúng 1 dấu `@`, phần trước không rỗng, phần sau có dấu `.`
- `phone`: đúng 10 chữ số, bắt đầu bằng `08` hoặc `09`
- `code`: định dạng `SP-YYYY-NNN` hoặc `SV-YYYY-NNN` (SP/SV, 4 chữ số năm, 3 chữ số thứ tự)

---

## Bài 1 — Lọc email không hợp lệ

**Yêu cầu:** Tìm các row có `email` không hợp lệ. Điều kiện hợp lệ:
- Có ký tự `@`
- Phần trước `@` không rỗng
- Phần sau `@` có chứa dấu `.`

**Gợi ý:** Dùng `LIKE`, `LOCATE()`, `LENGTH()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT id, name, email
FROM contacts
WHERE email NOT LIKE '%_@_%._%';
```

**Giải thích pattern `%_@_%._%`:**
- `%` → bất kỳ chuỗi nào (kể cả rỗng)
- `_` → đúng 1 ký tự bất kỳ (bắt buộc có)
- `_@_` → phần trước và sau `@` phải có ít nhất 1 ký tự
- `%._%` → sau `@` phải có dấu `.` với ít nhất 1 ký tự mỗi bên

**Kết quả — email không hợp lệ:**

| id | name | email |
|---|---|---|
| 2 | Tran Thi Bich | thi.bich@ |
| 6 | Dang Van Em | van.em@ |
| 8 | Do Quoc Hung | @gmail.com |

</details>

---

## Bài 2 — Lọc số điện thoại không hợp lệ

**Yêu cầu:** Tìm các row có `phone` không hợp lệ. Điều kiện hợp lệ:
- Đúng 10 ký tự
- Chỉ gồm chữ số (không có dấu cách, gạch ngang...)
- Bắt đầu bằng `08` hoặc `09`

**Gợi ý:** Dùng `LENGTH()`, `REGEXP`

<details>
<summary>Xem đáp án</summary>

```sql
-- Cách 1: LIKE
SELECT id, name, phone
FROM contacts
WHERE phone NOT LIKE '0[89][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
   OR LENGTH(phone) != 10;

-- Cách 2: REGEXP (gọn hơn)
SELECT id, name, phone
FROM contacts
WHERE phone NOT REGEXP '^0[89][0-9]{8}$';
```

**Giải thích regex `^0[89][0-9]{8}$`:**
- `^` → bắt đầu chuỗi
- `0` → ký tự đầu là 0
- `[89]` → ký tự thứ 2 là 8 hoặc 9
- `[0-9]{8}` → tiếp theo đúng 8 chữ số
- `$` → kết thúc chuỗi

**Kết quả — phone không hợp lệ:**

| id | name | phone |
|---|---|---|
| 2 | Tran Thi Bich | 091234567 (9 số) |
| 3 | Le Hoang Nam | 09123456789 (11 số) |
| 6 | Dang Van Em | 08123456789 (11 số) |
| 7 | Bui Thi Phuong | 0312345678 (bắt đầu 03) |
| 8 | Do Quoc Hung | 0912 345678 (có dấu cách) |

</details>

---

## Bài 3 — Lọc mã sản phẩm không đúng định dạng

**Yêu cầu:** Tìm các row có `code` không đúng định dạng `SP-YYYY-NNN` hoặc `SV-YYYY-NNN`:
- 2 ký tự đầu là `SP` hoặc `SV`
- Tiếp theo dấu `-`
- 4 chữ số (năm)
- Tiếp theo dấu `-`
- 3 chữ số (thứ tự)

<details>
<summary>Xem đáp án</summary>

```sql
SELECT id, name, code
FROM contacts
WHERE code NOT REGEXP '^S[PV]-[0-9]{4}-[0-9]{3}$';
```

**Kết quả — code không hợp lệ:**

| id | name | code |
|---|---|---|
| 3 | Le Hoang Nam | SV-2024-003 — hợp lệ (SV được chấp nhận) |
| 4 | Pham Thu Huong | SP-202-004 (năm chỉ có 3 số) |

</details>

---

## Bài 4 — Tìm theo pattern linh hoạt với LIKE

**Yêu cầu:** Viết các query lọc theo từng điều kiện sau (mỗi câu 1 query):

1. Tìm `name` có chứa chữ `'Thi'`
2. Tìm `email` thuộc domain `gmail.com`
3. Tìm `code` thuộc loại `SP` (không phải `SV`)
4. Tìm `name` bắt đầu bằng một trong các họ: `Nguyen`, `Tran`, `Le`

<details>
<summary>Xem đáp án</summary>

```sql
-- 1. Name chứa 'Thi'
SELECT * FROM contacts WHERE name LIKE '%Thi%';

-- 2. Email domain gmail.com
SELECT * FROM contacts WHERE email LIKE '%@gmail.com';

-- 3. Code loại SP
SELECT * FROM contacts WHERE code LIKE 'SP-%';

-- 4. Họ Nguyen, Tran hoặc Le (dùng OR hoặc REGEXP)
SELECT * FROM contacts
WHERE name LIKE 'Nguyen %'
   OR name LIKE 'Tran %'
   OR name LIKE 'Le %';

-- Hoặc gọn hơn với REGEXP
SELECT * FROM contacts
WHERE name REGEXP '^(Nguyen|Tran|Le) ';
```

</details>

---

## Bài 5 — Tổng hợp: báo cáo kiểm tra chất lượng dữ liệu

**Yêu cầu:** Viết một query trả về toàn bộ bảng, thêm 3 cột đánh dấu tính hợp lệ:
- `email_ok`: 1 nếu email hợp lệ, 0 nếu không
- `phone_ok`: 1 nếu phone hợp lệ, 0 nếu không
- `code_ok`: 1 nếu code hợp lệ, 0 nếu không

**Gợi ý:** Dùng `CASE WHEN ... THEN 1 ELSE 0 END` kết hợp với các điều kiện ở các bài trên.

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    id,
    name,
    email,
    phone,
    code,
    CASE WHEN email REGEXP '^[^@]+@[^@]+\\.[^@]+$' THEN 1 ELSE 0 END AS email_ok,
    CASE WHEN phone REGEXP '^0[89][0-9]{8}$'        THEN 1 ELSE 0 END AS phone_ok,
    CASE WHEN code  REGEXP '^S[PV]-[0-9]{4}-[0-9]{3}$' THEN 1 ELSE 0 END AS code_ok
FROM contacts;
```

**Kết quả:**

| id | name | email_ok | phone_ok | code_ok |
|---|---|---|---|---|
| 1 | Nguyen Van An | 1 | 1 | 1 |
| 2 | Tran Thi Bich | 0 | 0 | 1 |
| 3 | Le Hoang Nam | 1 | 0 | 1 |
| 4 | Pham Thu Huong | 1 | 1 | 0 |
| 5 | Vo Minh Duc | 1 | 1 | 1 |
| 6 | Dang Van Em | 0 | 0 | 1 |
| 7 | Bui Thi Phuong | 1 | 0 | 1 |
| 8 | Do Quoc Hung | 0 | 0 | 1 |
| 9 | Hoang Thi Lan | 1 | 1 | 1 |
| 10 | Ngo Minh Khoa | 1 | 1 | 1 |

</details>
