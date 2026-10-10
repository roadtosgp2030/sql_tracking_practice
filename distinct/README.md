# DISTINCT — MySQL

Lab thực hành DISTINCT. Giống lab `join` và ngược với lab `indexing`:
dữ liệu phải **NHỎ** — 8 khách, 8 sản phẩm, 12 đơn — để bạn tự đếm bằng mắt
rồi mới hỏi MySQL, và biết ai đúng ai sai.

DISTINCT là từ khoá dễ học nhất SQL và bị dùng sai nhiều nhất SQL. Lab này
không dạy cú pháp (bạn học xong trong 30 giây), nó dạy **khi nào DISTINCT
nói dối bạn**.

## Chạy

```bash
mysql -u root < schema.sql     # 1 lần, chưa tới 1 giây
```

Sau đó làm lần lượt `phase1.sql` → `phase4.sql`. Các phase phụ thuộc nhau,
đừng nhảy cóc.

Mỗi file có phần **KẾT QUẢ THAM CHIẾU** ở cuối — kết quả chạy thật trên máy
này (MySQL 8.0.45, collation `utf8mb4_0900_ai_ci`). Tự làm trước rồi mới đối chiếu.

Muốn làm lại từ đầu: chạy lại `schema.sql` (nó tự `DROP DATABASE` trước).

Nên học lab `join` trước — phase 3 dựa hẳn vào nó.

## Nội dung

| File | Nội dung | Con số đáng nhớ |
|---|---|---|
| `phase1.sql` | DISTINCT áp lên toàn bộ danh sách cột, NULL, collation, vs GROUP BY, lỗi 3065 | 8 khách, mắt thấy **3** thành phố, MySQL trả lời **5** |
| `phase2.sql` | COUNT(*) vs COUNT(col) vs COUNT(DISTINCT), COUNT(DISTINCT a,b), SUM(DISTINCT), GROUP_CONCAT | doanh thu 2795 bị `SUM(DISTINCT)` ăn mất **250** |
| `phase3.sql` | Fan-out, DISTINCT như băng dán, EXISTS, UNION vs UNION ALL | "ai mua ghế?" — DISTINCT trả lời **3**, đáp án đúng là **4** |
| `phase4.sql` | DISTINCT vô dụng, DATETIME/FLOAT, EXPLAIN + index, ROW_NUMBER, xoá dòng trùng | index biến `Using temporary` thành `Using index for group-by` |

## Dữ liệu được cài bẫy sẵn

Đây không phải dữ liệu ngẫu nhiên. Mọi chỗ "bẩn" đều cố ý:

- **`city`** — `'Ha Noi'` (id 1), `'ha noi'` (id 2), và `'Ha Noi '` **có dấu
  cách cuối** (id 7). Nhìn màn hình không thể phân biệt.
- **`city` NULL** — 2 khách (id 5, 6). DISTINCT gom thành 1 dòng,
  COUNT(DISTINCT) vứt hẳn.
- **`'Nguyen Van An'`** — **hai người khác nhau** (id 1 và id 8) trùng tên.
  Đây là ngòi nổ của bài 3.2.
- **Vu Van Giang (id 6)** — có xem web nhưng chưa mua gì bao giờ.
- **Mouse & Keyboard cùng giá 25**, **Notebook & Pen cùng giá 5** — để thấy
  `SUM(DISTINCT price)` ăn mất hàng có thật.
- **Đơn 1 và đơn 12** — cùng khách, cùng 250.00, cùng hàng hoá, khác ngày.
  Trùng hay không trùng? Tuỳ bạn định nghĩa.
- **Laptop Pro, Gift Card** — chưa ai mua. **Gift Card** còn có `category` NULL.
- **`page_views`** — có dòng trùng hệt nhau (id 1 & 2, id 12 & 13) và khách
  vãng lai `customer_id = NULL`.

## Ba điều dễ bất ngờ nhất

1. **DISTINCT có thể gộp nhầm hai con người thành một.** Câu "khách nào đã
   mua ghế" viết bằng `DISTINCT full_name` trả về 3 người; đáp án đúng là 4.
   Hai khách trùng tên bị gộp làm một. Không có lỗi, không có cảnh báo, kết
   quả trông hoàn hảo. (phase3, bài 3.2)

2. **`SUM(DISTINCT tien)` ăn mất doanh thu thật.** Tổng đúng là 2795, nó trả
   về 2545 — vì hai đơn hàng thật tình cờ cùng số tiền 250. Con số sai nguy
   hiểm nhất không phải con số lố bịch (6190, ai cũng thấy), mà là con số
   gần đúng đủ để lọt qua mọi vòng review. (phase3, bài 3.3)

3. **`COUNT(DISTINCT ...)` không cộng được.** Số khách duy nhất mỗi ngày là
   2+2+3+1+2 = 10, nhưng cả tuần chỉ có 8 khách. Cộng cột "unique users"
   theo ngày để ra số của tuần là sai, và mọi dashboard đều từng mắc.
   (phase2, bài 2.5)

## Quy tắc rút gọn nhất

> **DISTINCT không làm dữ liệu đúng hơn. Nó chỉ làm màn hình gọn hơn.**

Thấy dòng lặp thì đừng gõ `DISTINCT` ngay. Hỏi trước: **"một dòng kết quả này
đại diện cho cái gì?"** Trả lời được câu đó thì thường bạn phát hiện bệnh nằm
ở chỗ JOIN, và cách chữa là `EXISTS` hoặc `GROUP BY`, chứ không phải DISTINCT.
