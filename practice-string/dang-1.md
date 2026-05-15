# Dạng 1 — Trích xuất thông tin từ chuỗi

## Bảng dữ liệu mẫu

```sql
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
```

---

## Bài 1 — Lấy họ (từ đầu đến dấu cách đầu tiên)

**Yêu cầu:** Từ `full_name`, lấy ra **họ** (từ đầu tiên).

**Gợi ý:** Dùng `LEFT()` + `CHARINDEX()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    full_name,
    LEFT(full_name, CHARINDEX(' ', full_name) - 1) AS ho
FROM employees;
```

**Giải thích:**
- `CHARINDEX(' ', full_name)` → tìm vị trí dấu cách đầu tiên
- `-1` → bỏ chính dấu cách đó
- `LEFT(..., n)` → lấy n ký tự từ trái

**Kết quả:**

| full_name | ho |
|---|---|
| Nguyen Van An | Nguyen |
| Tran Thi Bich | Tran |
| Le Hoang Nam | Le |
| Pham Thi Thu Huong | Pham |
| Vo Minh Duc | Vo |

</details>

---

## Bài 2 — Lấy tên (từ cuối chuỗi)

**Yêu cầu:** Từ `full_name`, lấy ra **tên** (từ cuối cùng).

**Gợi ý:** Dùng `RIGHT()` + `REVERSE()` + `CHARINDEX()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    full_name,
    RIGHT(full_name, CHARINDEX(' ', REVERSE(full_name)) - 1) AS ten
FROM employees;
```

**Giải thích:**
- `REVERSE(full_name)` → đảo chuỗi → dấu cách cuối thành dấu cách đầu
- `CHARINDEX(' ', REVERSE(...))` → vị trí dấu cách đầu tiên trong chuỗi đảo = độ dài của từ cuối
- `RIGHT(..., n)` → lấy n ký tự từ phải

**Kết quả:**

| full_name | ten |
|---|---|
| Nguyen Van An | An |
| Tran Thi Bich | Bich |
| Le Hoang Nam | Nam |
| Pham Thi Thu Huong | Huong |
| Vo Minh Duc | Duc |

</details>

---

## Bài 3 — Lấy username từ email

**Yêu cầu:** Từ `email`, lấy phần trước dấu `@`.

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    email,
    LEFT(email, CHARINDEX('@', email) - 1) AS username
FROM employees;
```

**Kết quả:**

| email | username |
|---|---|
| van.an@techcorp.com | van.an |
| thi.bich@gmail.com | thi.bich |
| hoang.nam@techcorp.com | hoang.nam |
| thu.huong@outlook.com | thu.huong |
| minh.duc@gmail.com | minh.duc |

</details>

---

## Bài 4 — Lấy domain từ email

**Yêu cầu:** Từ `email`, lấy phần sau dấu `@` (ví dụ: `techcorp.com`).

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    email,
    SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email)) AS domain
FROM employees;
```

**Giải thích:**
- `CHARINDEX('@', email) + 1` → vị trí bắt đầu sau dấu `@`
- `LEN(email)` → lấy đến hết chuỗi (dư cũng không sao)

**Kết quả:**

| email | domain |
|---|---|
| van.an@techcorp.com | techcorp.com |
| thi.bich@gmail.com | gmail.com |
| hoang.nam@techcorp.com | techcorp.com |
| thu.huong@outlook.com | outlook.com |
| minh.duc@gmail.com | gmail.com |

</details>

---

## Bài 5 — Tổng hợp: tách toàn bộ thông tin

**Yêu cầu:** Tạo một query trả về: `ho`, `ten`, `username`, `domain` trong một lần.

**Bonus:** Chỉ lấy nhân viên thuộc domain `techcorp.com`.

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    full_name,
    LEFT(full_name, CHARINDEX(' ', full_name) - 1)              AS ho,
    RIGHT(full_name, CHARINDEX(' ', REVERSE(full_name)) - 1)    AS ten,
    LEFT(email, CHARINDEX('@', email) - 1)                      AS username,
    SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email))     AS domain
FROM employees
WHERE SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email)) = 'techcorp.com';
```

**Kết quả:**

| full_name | ho | ten | username | domain |
|---|---|---|---|---|
| Nguyen Van An | Nguyen | An | van.an | techcorp.com |
| Le Hoang Nam | Le | Nam | hoang.nam | techcorp.com |

</details>
