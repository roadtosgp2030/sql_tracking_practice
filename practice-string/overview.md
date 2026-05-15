# Xử lý String trong SQL — Tổng quan các dạng bài tập

## Các hàm cơ bản

| Hàm | Mô tả | Ví dụ |
|-----|-------|-------|
| `LEN()` / `LENGTH()` | Độ dài chuỗi | `LEN('hello')` → 5 |
| `UPPER()` / `LOWER()` | Chuyển hoa/thường | `UPPER('abc')` → 'ABC' |
| `TRIM()` / `LTRIM()` / `RTRIM()` | Xóa khoảng trắng | `TRIM('  hi  ')` → 'hi' |
| `SUBSTRING()` / `SUBSTR()` | Cắt chuỗi con | `SUBSTRING('hello', 2, 3)` → 'ell' |
| `LEFT()` / `RIGHT()` | Lấy n ký tự trái/phải | `LEFT('hello', 3)` → 'hel' |
| `CHARINDEX()` / `INSTR()` / `POSITION()` | Tìm vị trí ký tự | `CHARINDEX('l', 'hello')` → 3 |
| `REPLACE()` | Thay thế chuỗi | `REPLACE('abc', 'b', 'x')` → 'axc' |
| `CONCAT()` / `\|\|` | Nối chuỗi | `CONCAT('a', 'b')` → 'ab' |
| `REVERSE()` | Đảo ngược chuỗi | `REVERSE('abc')` → 'cba' |
| `REPLICATE()` / `REPEAT()` | Lặp chuỗi | `REPLICATE('ab', 3)` → 'ababab' |
| `STUFF()` / `INSERT()` | Chèn chuỗi vào vị trí | `STUFF('hello', 2, 3, 'XY')` → 'hXYo' |
| `FORMAT()` | Định dạng chuỗi | `FORMAT(1234.5, 'N2')` → '1,234.50' |

## Các kỹ thuật quan trọng

**Pattern Matching với LIKE:**
```sql
WHERE name LIKE 'A%'      -- bắt đầu bằng A
WHERE name LIKE '%son'    -- kết thúc bằng son
WHERE name LIKE '_a%'     -- ký tự thứ 2 là 'a'
WHERE name LIKE '[0-9]%'  -- bắt đầu bằng số (SQL Server)
```

**Tách chuỗi (Split):**
```sql
-- Lấy phần trước dấu '@' trong email
LEFT(email, CHARINDEX('@', email) - 1)

-- Lấy phần sau dấu '@'
SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email))
```

**Padding (đệm ký tự):**
```sql
-- Đệm số 0 vào trước
RIGHT('000' + CAST(id AS VARCHAR), 5)   -- → '00042'
```

---

## Danh sách các dạng bài tập

| Dạng | Chủ đề | File |
|------|--------|------|
| Dạng 1 | Trích xuất thông tin từ chuỗi | [dang-1.md](dang-1.md) |
| Dạng 2 | Chuẩn hóa dữ liệu | [dang-2.md](dang-2.md) |
| Dạng 3 | Kiểm tra & lọc theo pattern | [dang-3.md](dang-3.md) |
| Dạng 4 | Tạo/ghép chuỗi mới | [dang-4.md](dang-4.md) |
| Dạng 5 | Xử lý chuỗi có cấu trúc phân tách | [dang-5.md](dang-5.md) |
| Dạng 6 | So sánh & tìm kiếm nâng cao | [dang-6.md](dang-6.md) |
| Dạng 7 | Kết hợp string với aggregate | [dang-7.md](dang-7.md) |
