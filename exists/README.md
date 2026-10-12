# EXISTS — MySQL

Lab thực hành EXISTS. Cùng triết lý với lab `distinct`: dữ liệu phải **NHỎ** —
8 sinh viên, 8 môn học, 15 lượt đăng ký, 4 đơn xin rút môn — để bạn tự đếm
bằng mắt rồi mới hỏi MySQL.

EXISTS là toán tử trả lời đúng MỘT câu hỏi: **"có tồn tại ít nhất một dòng
thoả điều kiện không?"** — CÓ hay KHÔNG, không hơn không kém. Nghe đơn giản,
nhưng nó là cách chữa đúng cho nhiều bệnh của JOIN và DISTINCT (đã thấy ở lab
`distinct`, phase 3), và có những luật riêng — nhất là với NULL — mà `IN`
không có.

## Chạy

```bash
mysql -u root < schema.sql     # 1 lần, chưa tới 1 giây
```

Sau đó làm lần lượt `phase1.sql` → `phase4.sql`. Các phase phụ thuộc nhau,
đừng nhảy cóc.

Mỗi file có phần **KẾT QUẢ THAM CHIẾU** ở cuối — kết quả chạy thật trên máy
này (MySQL 8.0.45). Tự làm trước rồi mới đối chiếu.

Muốn làm lại từ đầu: chạy lại `schema.sql` (nó tự `DROP DATABASE` trước).

Nên học lab `distinct` trước — phase 2 và phase 3 dựa hẳn vào các bài học
của nó (fan-out, gộp nhầm hai thực thể trùng tên, cạm bẫy NULL).

## Nội dung

| File | Nội dung | Con số đáng nhớ |
|---|---|---|
| `phase1.sql` | EXISTS là gì, correlated subquery, EXISTS không nhân dòng, NOT EXISTS | EXISTS lọc đúng **7/8** sinh viên, không cần DISTINCT |
| `phase2.sql` | EXISTS vs IN vs JOIN, cạm bẫy NULL của NOT IN, EXISTS nhiều điều kiện | `NOT IN` với 1 dòng NULL trả về **0** dòng — sai hoàn toàn |
| `phase3.sql` | Phép chia quan hệ (relational division) bằng NOT EXISTS lồng, EXISTS đa cấp, EXISTS trong DELETE | "học đủ mọi môn CNTT" — chỉ **2/8** sinh viên đạt |
| `phase4.sql` | MySQL tối ưu EXISTS thế nào (semi-join), EXPLAIN, EXISTS vs COUNT(*)>0, ORDER BY/LIMIT vô nghĩa trong EXISTS | EXISTS dừng ở lần khớp đầu tiên; `COUNT(*) > 0` thì không |

## Dữ liệu được cài bẫy sẵn

- **`students.full_name`** — `'Nguyen Van A'` xuất hiện ở id 1 (Ha Noi) và
  id 8 (Da Nang). Hai người khác nhau, trùng tên — y hệt bẫy ở lab
  `distinct`, nhưng lần này để chứng minh EXISTS **không** mắc bẫy đó.
- **Vu Thi Phuong (id 6)** — chưa đăng ký môn nào.
- **Hoi Hoa (course id 8)**, khoa `Nghe Thuat` — chưa ai đăng ký. Đây cũng
  là khoa duy nhất không có sinh viên nào theo học.
- **`enrollments.grade`** — 2 dòng NULL (id 3 môn 2, id 5 môn 4): CHƯA CÓ
  ĐIỂM, không phải điểm 0.
- **`drop_requests.student_id`** — đúng **1 dòng NULL** (đơn giấy, nhân
  viên chưa kịp nhập tên sinh viên). Đây là quả bom chính của cả lab.

## Ba điều dễ bất ngờ nhất

1. **`NOT IN` với một dòng NULL trong danh sách con trả về RỖNG, luôn
   luôn, bất kể vế ngoài là gì.** Không phải "thiếu vài dòng" — là **0
   dòng**, kể cả với sinh viên rõ ràng không hề dính đơn xin rút môn nào.
   `NOT EXISTS` viết cùng ý nghĩa thì đúng tuyệt đối. (phase2, bài 2.1)

2. **EXISTS không cần DISTINCT để tránh gộp nhầm hai người trùng tên** —
   trong khi `SELECT DISTINCT full_name` sau JOIN thì có. Vì EXISTS lọc
   trên DÒNG NGOÀI (định danh bằng khoá chính `s.id`), còn DISTINCT lọc
   trên GIÁ TRỊ đã SELECT ra (`full_name`, không phải khoá). Cùng dữ liệu,
   cùng câu hỏi, một cách luôn đúng, một cách phải "may mắn". (phase2,
   bài 2.3)

3. **Muốn viết "sinh viên đã học TẤT CẢ các môn X"** thì `COUNT(DISTINCT
   course_id) = tổng số môn X` là cách MONG MANH — sai ngay khi ai đó
   thêm một môn X mới hoặc có dữ liệu trùng. Cách CHẮC CHẮN là NOT EXISTS
   lồng NOT EXISTS: "không tồn tại môn X nào mà sinh viên chưa học". Đây
   là bài toán logic gọi là **phép chia quan hệ**, và EXISTS là công cụ
   duy nhất diễn đạt nó tự nhiên. (phase3, bài 3.2)

## Quy tắc rút gọn nhất

> **EXISTS chỉ hỏi "CÓ hay KHÔNG". Nó không quan tâm subquery trả về giá
> trị gì, mấy dòng, hay có NULL không.**

Đó chính là lý do nó an toàn ở những chỗ `IN`/`NOT IN` và `JOIN` bị sập
bẫy: không có giá trị nào để so sánh sai, không có dòng nào để nhân lên.
Thấy mình sắp viết `JOIN ... DISTINCT` chỉ để "kiểm tra có tồn tại hay
không" — đó là lúc nên đổi sang EXISTS.
