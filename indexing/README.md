# Indexing — MySQL

Lab thực hành index. Khác các chủ đề trước, ở đây dữ liệu phải LỚN thì mới đo được:
`users` 500,000 dòng, `orders` 1,000,000 dòng.

## Chạy

```bash
mysql -u root < schema.sql     # 1 lần, mất ~30 giây
```

Sau đó làm lần lượt `phase1.sql` → `phase4.sql`. Các phase phụ thuộc nhau
(index tạo ở phase trước được dùng lại ở phase sau), nên đừng nhảy cóc.

Mỗi file có phần **KẾT QUẢ THAM CHIẾU** ở cuối — số liệu đo thật trên máy này
(MySQL 8.0.45). Tự làm trước rồi mới đối chiếu.

Muốn làm lại từ đầu: chạy lại `schema.sql` (nó tự `DROP DATABASE` trước).

## Nội dung

| File | Nội dung | Con số đáng nhớ |
|---|---|---|
| `phase1.sql` | Đọc EXPLAIN, index đơn cột, clustered vs secondary index | tìm theo email: **1232 ms → 0.25 ms** |
| `phase2.sql` | Composite index, quy tắc leftmost prefix, `key_len`, skip scan | thiếu cột trái: **chậm hơn 290 lần** |
| `phase3.sql` | Covering index, tránh filesort, index cho JOIN | ORDER BY: **945 ms → 0.145 ms** |
| `phase4.sql` | Khi index KHÔNG chạy + cái giá của index | bọc hàm lên cột: **chậm hơn 1600 lần** |

## Ba điều dễ bất ngờ nhất

1. **`WHERE status = 0`** trên cột VARCHAR trả về **cả 500,000 dòng** — mọi chuỗi
   không bắt đầu bằng chữ số đều ép kiểu thành 0. Sai kiểu dữ liệu không chỉ làm
   mất index, nó làm **sai kết quả**. (phase4, bài 4.3)

2. **Dùng index có lúc CHẬM HƠN quét toàn bảng.** Với `status='active'` (90% số dòng):
   index 2548 ms, quét bảng 1326 ms. MySQL còn chọn nhầm vì ước lượng sai
   (đoán 243k, thực tế 450k). (phase4, bài 4.4)

3. **MySQL 8 có "skip scan"**, nên bỏ qua cột trái của composite index không còn
   vô dụng hoàn toàn như tài liệu cũ dạy — nhưng vẫn chậm hơn 290 lần, và chỉ cứu
   được khi cột bị bỏ qua có ít giá trị phân biệt. (phase2, bài 2.3)
