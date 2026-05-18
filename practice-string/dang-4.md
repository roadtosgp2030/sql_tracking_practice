# Dạng 4 — Tạo/ghép chuỗi mới

## Bảng dữ liệu mẫu

```sql
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
```

---

## Bài 1 — Tạo mã nhân viên

**Yêu cầu:** Tạo cột `employee_code` theo quy tắc:
- 3 ký tự đầu của `department` (viết hoa)
- Dấu `-`
- 4 chữ số `birth_year`
- Dấu `-`
- `id` đệm 0 phía trước thành 3 chữ số (ví dụ: id=1 → `001`)

Ví dụ: `Nguyen Van An` → `ENG-1990-001`

**Gợi ý:** Dùng `LEFT()`, `UPPER()`, `CONCAT()`, `LPAD()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    full_name,
    CONCAT(
        UPPER(LEFT(department, 3)),
        '-',
        birth_year,
        '-',
        LPAD(id, 3, '0')
    ) AS employee_code
FROM staff;
```

**Giải thích:**
- `UPPER(LEFT(department, 3))` → 3 ký tự đầu viết hoa
- `LPAD(id, 3, '0')` → đệm `0` bên trái đủ 3 ký tự

**Kết quả:**

| full_name | employee_code |
|---|---|
| Nguyen Van An | ENG-1990-001 |
| Tran Thi Bich | MAR-1995-002 |
| Le Hoang Nam | ENG-1988-003 |
| Pham Thu Huong | HR-1992-004 |
| Vo Minh Duc | ENG-1993-005 |

</details>

---

## Bài 2 — Tạo username và email công ty

**Yêu cầu:** Tạo `username` và `email` nội bộ theo quy tắc:
- `username`: chữ cái đầu của tên (ký tự cuối) + họ (ký tự đầu đến dấu cách đầu) — tất cả viết thường
- `email`: `username` + `@company.vn`

Ví dụ: `Nguyen Van An` → username: `anguyen`, email: `anguyen@company.vn`

**Gợi ý:** Kết hợp `LEFT()`, `RIGHT()`, `LOWER()`, `LOCATE()`, `REVERSE()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    full_name,
    CONCAT(
        LOWER(LEFT(RIGHT(full_name, LOCATE(' ', REVERSE(full_name)) - 1), 1)),
        LOWER(LEFT(full_name, LOCATE(' ', full_name) - 1))
    ) AS username,
    CONCAT(
        LOWER(LEFT(RIGHT(full_name, LOCATE(' ', REVERSE(full_name)) - 1), 1)),
        LOWER(LEFT(full_name, LOCATE(' ', full_name) - 1)),
        '@company.vn'
    ) AS email
FROM staff;
```

**Kết quả:**

| full_name | username | email |
|---|---|---|
| Nguyen Van An | anguyen | anguyen@company.vn |
| Tran Thi Bich | btran | btran@company.vn |
| Le Hoang Nam | nle | nle@company.vn |

</details>

---

## Bài 3 — Tạo slug URL

**Yêu cầu:** Tạo cột `slug` từ `full_name` để dùng làm URL:
- Tất cả viết thường
- Dấu cách thay bằng dấu `-`
- Ví dụ: `Nguyen Van An` → `nguyen-van-an`

**Gợi ý:** Dùng `LOWER()` + `REPLACE()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    full_name,
    REPLACE(LOWER(full_name), ' ', '-') AS slug
FROM staff;
```

**Kết quả:**

| full_name | slug |
|---|---|
| Nguyen Van An | nguyen-van-an |
| Tran Thi Bich | tran-thi-bich |
| Le Hoang Nam | le-hoang-nam |

</details>

---

## Bài 4 — Tạo câu mô tả dạng text

**Yêu cầu:** Tạo cột `description` theo mẫu câu sau:

```
[full_name] works in [department] since [joined_year], earning [salary_formatted] VND/month.
```

Trong đó:
- `joined_year`: lấy 4 chữ số năm từ `joined_date`
- `salary_formatted`: số có dấu phẩy ngăn cách hàng nghìn (ví dụ: `15,000,000`)

**Gợi ý:** Dùng `CONCAT()`, `YEAR()`, `FORMAT()`

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    CONCAT(
        full_name,
        ' works in ',
        department,
        ' since ',
        YEAR(joined_date),
        ', earning ',
        FORMAT(salary, 0),
        ' VND/month.'
    ) AS description
FROM staff;
```

**Giải thích:**
- `YEAR(joined_date)` → lấy phần năm từ kiểu DATE
- `FORMAT(salary, 0)` → định dạng số với dấu phẩy, 0 chữ số thập phân

**Kết quả:**

| description |
|---|
| Nguyen Van An works in Engineering since 2020, earning 15,000,000 VND/month. |
| Tran Thi Bich works in Marketing since 2021, earning 12,000,000 VND/month. |

</details>

---

## Bài 5 — Tổng hợp: tạo thẻ nhân viên

**Yêu cầu:** Tạo query trả về đầy đủ thông tin "thẻ nhân viên" gồm các cột:
- `employee_code` (theo Bài 1)
- `full_name`
- `username` (theo Bài 2)
- `email` (theo Bài 2)
- `slug` (theo Bài 3)
- `description` (theo Bài 4)

Chỉ lấy nhân viên thuộc `department = 'Engineering'`.

<details>
<summary>Xem đáp án</summary>

```sql
SELECT
    CONCAT(
        UPPER(LEFT(department, 3)), '-', birth_year, '-', LPAD(id, 3, '0')
    ) AS employee_code,
    full_name,
    CONCAT(
        LOWER(LEFT(RIGHT(full_name, LOCATE(' ', REVERSE(full_name)) - 1), 1)),
        LOWER(LEFT(full_name, LOCATE(' ', full_name) - 1))
    ) AS username,
    CONCAT(
        LOWER(LEFT(RIGHT(full_name, LOCATE(' ', REVERSE(full_name)) - 1), 1)),
        LOWER(LEFT(full_name, LOCATE(' ', full_name) - 1)),
        '@company.vn'
    ) AS email,
    REPLACE(LOWER(full_name), ' ', '-') AS slug,
    CONCAT(
        full_name, ' works in ', department,
        ' since ', YEAR(joined_date),
        ', earning ', FORMAT(salary, 0), ' VND/month.'
    ) AS description
FROM staff
WHERE department = 'Engineering';
```

**Kết quả:**

| employee_code | full_name | username | email | slug | description |
|---|---|---|---|---|---|
| ENG-1990-001 | Nguyen Van An | anguyen | anguyen@company.vn | nguyen-van-an | Nguyen Van An works in Engineering since 2020... |
| ENG-1988-003 | Le Hoang Nam | nle | nle@company.vn | le-hoang-nam | Le Hoang Nam works in Engineering since 2019... |
| ENG-1993-005 | Vo Minh Duc | dvo | dvo@company.vn | vo-minh-duc | Vo Minh Duc works in Engineering since 2020... |
| ENG-1989-008 | Do Quoc Hung | hdo | hdo@company.vn | do-quoc-hung | Do Quoc Hung works in Engineering since 2018... |
| ENG-1996-010 | Ngo Minh Khoa | kngo | kngo@company.vn | ngo-minh-khoa | Ngo Minh Khoa works in Engineering since 2022... |

</details>
