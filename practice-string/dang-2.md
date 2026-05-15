# Dạng 2 — Chuẩn hóa dữ liệu

## Bảng dữ liệu mẫu

```sql
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
```

---

## Bài 1 — Xóa khoảng trắng thừa ở đầu và cuối

**Yêu cầu:** Chuẩn hóa cột `name`, `email`, `city` — xóa khoảng trắng thừa ở đầu và cuối chuỗi.

**Gợi ý:** Dùng `TRIM()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    TRIM(name)  AS name,
    TRIM(email) AS email,
    TRIM(city)  AS city
FROM customers;
```

**Lưu ý:** `TRIM()` chỉ xóa khoảng trắng ở **đầu và cuối**, không xóa khoảng trắng dư ở **giữa** chuỗi (xem Bài 2).

</details>

---

## Bài 2 — Xử lý khoảng trắng thừa ở giữa chuỗi

**Yêu cầu:** `name` của row id=3 là `'le hoang    nam'` — có nhiều dấu cách giữa các từ. Chuẩn hóa về đúng 1 dấu cách.

**Gợi ý:** MySQL không có hàm `SQUISH()` hay `NORMALIZE_SPACE()`. Dùng kết hợp `TRIM()` + `REPLACE()` nhiều lần, hoặc dùng `REGEXP_REPLACE()`.

<details>
<summary>Xem đáp án</summary>

```sql
-- Cách 1: REGEXP_REPLACE (MySQL 8.0+)
SELECT
    id,
    TRIM(REGEXP_REPLACE(name, '\\s+', ' ')) AS name
FROM customers;

-- Cách 2: REPLACE lồng nhau (xử lý tối đa 4 dấu cách liên tiếp)
SELECT
    id,
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(name, '    ', ' '), '   ', ' '), '  ', ' '), '  ', ' ')) AS name
FROM customers;
```

**Giải thích Cách 1:**
- `\\s+` → regex khớp 1 hoặc nhiều ký tự whitespace liên tiếp
- `REGEXP_REPLACE(name, '\\s+', ' ')` → thay tất cả bằng 1 dấu cách
- Bọc ngoài `TRIM()` để xóa nốt đầu/cuối

**Cách 2** là workaround khi không có REGEXP, nhưng không triệt để nếu có > 4 dấu cách.

</details>

---

## Bài 3 — Chuẩn hóa hoa/thường

**Yêu cầu:** Chuẩn hóa `email` về chữ thường, `city` về dạng **Title Case** (chữ cái đầu mỗi từ viết hoa).

**Gợi ý:** `LOWER()` cho email. MySQL không có `INITCAP()` — dùng `CONCAT()` + `UPPER()` + `LOWER()` + `SUBSTRING()` cho city (chỉ cần xử lý 1 từ, không cần toàn bộ Title Case).

<details>
<summary>Xem đáp án</summary>

```sql
-- Chuẩn hóa email về lowercase
SELECT
    id,
    LOWER(TRIM(email)) AS email
FROM customers;

-- Chuẩn hóa city: chữ cái đầu viết hoa, còn lại viết thường
-- (áp dụng cho city 1 từ hoặc đơn giản hóa)
SELECT
    id,
    CONCAT(
        UPPER(LEFT(TRIM(city), 1)),
        LOWER(SUBSTRING(TRIM(city), 2))
    ) AS city
FROM customers;
```

**Lưu ý:** Cách trên chỉ viết hoa chữ cái đầu tiên của toàn chuỗi, không phải từng từ (vì MySQL thiếu INITCAP). Xử lý từng từ cần REGEXP hoặc stored procedure.

</details>

---

## Bài 4 — Chuẩn hóa số điện thoại

**Yêu cầu:** Cột `phone` đang có nhiều định dạng khác nhau (`0912-345-678`, `(091) 234 5678`, `0908.123.456`). Chuẩn hóa về định dạng chỉ gồm chữ số thuần túy (ví dụ: `0912345678`).

**Gợi ý:** Dùng `REPLACE()` nhiều lần để xóa các ký tự `-`, `.`, `(`, `)`, ` `.

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    id,
    phone,
    TRIM(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(phone, '-', ''),
        '.', ''),
        '(', ''),
        ')', ''),
        ' ', '')
    ) AS phone_clean
FROM customers;
```

**Hoặc dùng REGEXP_REPLACE (gọn hơn):**
```sql
SELECT
    id,
    phone,
    REGEXP_REPLACE(phone, '[^0-9]', '') AS phone_clean
FROM customers;
```

**Giải thích Cách 2:**
- `[^0-9]` → regex khớp bất kỳ ký tự **không phải** chữ số
- Thay tất cả bằng chuỗi rỗng `''` → chỉ còn lại số

**Kết quả:**

| id | phone | phone_clean |
|---|---|---|
| 1 | 0912-345-678 | 0912345678 |
| 2 | (091) 234 5678 | 0912345678 |
| 3 | 0908.123.456 | 0908123456 |
| 4 | 091 345 6789 | 0913456789 |
| 5 | 0923-456-789 | 0923456789 |

</details>

---

## Bài 5 — Tổng hợp: chuẩn hóa toàn bộ bảng

**Yêu cầu:** Viết một query trả về toàn bộ bảng `customers` đã được chuẩn hóa:
- `name`: trim khoảng trắng, xóa khoảng trắng thừa giữa các từ
- `email`: trim + lowercase
- `phone`: chỉ giữ lại chữ số
- `city`: trim + chữ cái đầu viết hoa, còn lại viết thường

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    id,
    TRIM(REGEXP_REPLACE(name, '\\s+', ' '))     AS name,
    LOWER(TRIM(email))                           AS email,
    REGEXP_REPLACE(phone, '[^0-9]', '')          AS phone,
    CONCAT(
        UPPER(LEFT(TRIM(city), 1)),
        LOWER(SUBSTRING(TRIM(city), 2))
    )                                            AS city
FROM customers;
```

**Kết quả:**

| id | name | email | phone | city |
|---|---|---|---|---|
| 1 | Nguyen van an | van.an@gmail.com | 0912345678 | Ha noi |
| 2 | Tran thi bich | thi.bich@gmail.com | 0912345678 | Ho chi minh |
| 3 | Le hoang nam | hoang.nam@yahoo.com | 0908123456 | Da nang |
| 4 | Pham thu huong | thu.huong@outlook.com | 0913456789 | Hue |
| 5 | Vo minh duc | minh.duc@gmail.com | 0923456789 | Can tho |

</details>
