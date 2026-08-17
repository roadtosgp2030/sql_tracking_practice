-- Active: 1778116211273@@127.0.0.1@3306@indexing
-- ============================================================
-- PHASE 2 — Composite index & quy tắc Leftmost Prefix
-- (Chạy schema.sql + làm xong phase1.sql trước)
-- ============================================================
USE indexing;

-- ============================================================
-- KIẾN THỨC NỀN — Composite index là gì
-- ============================================================
-- Composite index = index trên NHIỀU cột: INDEX(city, status, age)
--
-- Hãy hình dung nó như một cuốn danh bạ được sắp xếp theo:
--   thành phố -> rồi trong mỗi thành phố sắp theo trạng thái
--             -> rồi trong mỗi trạng thái sắp theo tuổi
--
-- => Bạn tra được "Hue" rất nhanh.
-- => Bạn tra được "Hue + banned" rất nhanh.
-- => Nhưng KHÔNG tra nhanh được "tất cả người banned trên mọi thành phố",
--    vì danh bạ không sắp theo trạng thái trước.
--
-- Đó chính là QUY TẮC LEFTMOST PREFIX:
--   Index (A, B, C) chỉ dùng được cho các tổ hợp bắt đầu từ TRÁI:
--      (A)  /  (A,B)  /  (A,B,C)     <- dùng tốt
--      (B)  /  (C)    /  (B,C)       <- KHÔNG khớp prefix
--
-- CÁCH KIỂM CHỨNG: nhìn cột key_len trong EXPLAIN.
-- key_len cho biết MySQL dùng được BAO NHIÊU BYTE đầu của index.
-- Với schema này (charset utf8mb4, 4 byte/ký tự):
--      city   VARCHAR(50) -> 50*4 + 2 (byte lưu độ dài) = 202
--      status VARCHAR(10) -> 10*4 + 2                   =  42
--      age    TINYINT     ->                            =   1
--   key_len = 202 -> chỉ dùng được cột city
--   key_len = 244 -> dùng được city + status
--   key_len = 245 -> dùng được cả 3 cột
-- ============================================================
-- ============================================================
-- BÀI 2.1 — Tạo composite index
-- ============================================================
-- YÊU CẦU:
-- Tạo index tên idx_users_city_status_age trên users(city, status, age).
-- Viết query của bạn bên dưới:
create index idx_users_city_status_age on users(city, status, age);

-- ============================================================
-- BÀI 2.2 — Khớp prefix: 1 cột, 2 cột, 3 cột
-- ============================================================
-- YÊU CẦU:
-- Chạy 3 câu EXPLAIN dưới đây. Với MỖI câu, ghi lại key_len và rows.
-- Rồi đối chiếu key_len với bảng byte ở phần KIẾN THỨC NỀN:
-- MySQL dùng được mấy cột của index?
EXPLAIN
SELECT
    id
FROM
    users
WHERE
    city = 'Hue';

EXPLAIN
SELECT
    id
FROM
    users
WHERE
    city = 'Hue'
    AND status = 'banned';

EXPLAIN
SELECT
    id
FROM
    users
WHERE
    city = 'Hue'
    AND status = 'banned'
    AND age = 30;

-- Trả lời của bạn:
--   Câu 1 (city):              key_len = .202..  rows = 48998  -> dùng 1 cột
--   Câu 2 (city+status):       key_len = .244..  rows = .985..  -> dùng .2. cột
--   Câu 3 (city+status+age):   key_len = .245..  rows = .23...  -> dùng .3. cột
-- ============================================================
-- BÀI 2.3 — Vi phạm leftmost: BỎ QUA cột đầu tiên
-- ============================================================
-- YÊU CẦU:
-- Câu này lọc theo status + age nhưng KHÔNG có city (cột đầu của index).
-- a) Chạy EXPLAIN. Cột type bằng gì? rows bằng bao nhiêu?
-- b) Chạy EXPLAIN ANALYZE. Thời gian thực tế là bao nhiêu?
-- c) So với Bài 2.2 câu 3 (có đủ city) thì chậm hơn mấy lần?
EXPLAIN
SELECT
    id
FROM
    users
WHERE
    status = 'banned'
    AND age = 30;

EXPLAIN ANALYZE
SELECT
    id
FROM
    users
WHERE
    status = 'banned'
    AND age = 30;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.4 — Nhảy cóc cột GIỮA
-- ============================================================
-- YÊU CẦU:
-- Câu này có city (cột 1) và age (cột 3) nhưng THIẾU status (cột 2).
-- a) EXPLAIN xem type / key_len / Extra là gì.
-- b) Theo quy tắc leftmost prefix "cổ điển", MySQL đáng lẽ chỉ dùng
--    được cột city thôi. Nhưng hãy đọc kỹ cột Extra — bạn thấy gì lạ?
EXPLAIN
SELECT
    id
FROM
    users
WHERE
    city = 'Hue'
    AND age = 30;

-- Trả lời của bạn:
-- a)
-- b)
-- ============================================================
-- BÀI 2.5 — Tự làm: thứ tự cột trong index có quan trọng không?
-- ============================================================
-- YÊU CẦU A:
-- Tạo thêm index idx_test_age_city trên users(age, city) — ĐẢO thứ tự.
-- Viết query của bạn bên dưới:
-- YÊU CẦU B:
-- Chạy EXPLAIN cho: WHERE age = 30 AND city = 'Hue'
-- MySQL chọn index nào trong 2 index đang có? Tại sao?
-- (gợi ý: nhìn cột possible_keys và key)
-- Viết query của bạn bên dưới:
-- YÊU CẦU C:
-- Xoá idx_test_age_city đi sau khi làm xong.
-- Viết query của bạn bên dưới:
-- ============================================================
-- KẾT QUẢ THAM CHIẾU (đã chạy thật, MySQL 8.0.45)
-- ============================================================
-- BÀI 2.2 — Khớp prefix đầy đủ:
--   WHERE city                    -> type=ref  key_len=202  rows=48998  Extra: Using index
--   WHERE city+status             -> type=ref  key_len=244  rows=  985  Extra: Using index
--   WHERE city+status+age         -> type=ref  key_len=245  rows=   23  Extra: Using index
--
--   => Càng khớp nhiều cột của prefix, key_len càng dài, rows càng ít.
--      Từ 48998 dòng xuống còn 23 dòng.
--
-- BÀI 2.3 — Bỏ qua cột đầu (status + age, thiếu city):
--   type: range   rows: 243042   Extra: Using where; Using index for skip scan
--   EXPLAIN ANALYZE:
--     -> Filter: ((users.age = 30) and (users.status = 'banned'))
--          (actual time=0.0833..4.78 rows=194 loops=1)
--         -> Covering index skip scan ... over status = 'banned'
--              (actual time=0.0238..4.49 rows=10126 loops=1)
--
--   So sánh với Bài 2.2 câu 3 (có đủ city):
--     có city    : 0.0165 ms, đọc 23 dòng
--     thiếu city : 4.78   ms, đọc 10126 dòng
--     => CHẬM HƠN ~290 LẦN.
--
-- BÀI 2.4 — Nhảy cóc cột giữa (city + age, thiếu status):
--   type: range   key_len=245   rows=4899
--   Extra: Using where; Using index for skip scan
--
-- ============================================================
-- LƯU Ý QUAN TRỌNG — "SKIP SCAN" (MySQL 8.0.13 trở lên)
-- ============================================================
-- Nhiều tài liệu cũ dạy rằng: bỏ qua cột trái là index HOÀN TOÀN vô dụng.
-- Điều đó KHÔNG còn đúng 100% với MySQL 8.
--
-- MySQL 8 có tối ưu hoá tên là "skip scan": khi cột bị bỏ qua có ÍT
-- giá trị phân biệt, MySQL sẽ tự lặp qua từng giá trị đó rồi tra như
-- bình thường. Ví dụ ở Bài 2.3, nó lặp qua cả 20 thành phố, mỗi thành
-- phố tra một lần "status='banned' AND age=30", rồi gộp kết quả lại.
--
-- NHƯNG — và đây mới là điều cần nhớ:
--   1) Skip scan CHỈ cứu vãn được phần nào. Nó vẫn chậm hơn 290 lần
--      so với việc khớp prefix cho đúng.
--   2) Nó chỉ hoạt động khi cột bị bỏ qua có ÍT giá trị (ở đây: 20
--      thành phố, 3 trạng thái). Nếu cột đầu là email (500,000 giá trị
--      khác nhau) thì skip scan vô dụng, MySQL sẽ quét toàn bộ index.
--
-- => Quy tắc leftmost prefix VẪN là thứ bạn phải thiết kế theo.
--    Skip scan chỉ là lưới an toàn, không phải cái để dựa vào.
--
-- KẾT LUẬN PHASE 2:
--   Thứ tự cột trong composite index là QUYẾT ĐỊNH THIẾT KẾ, không phải
--   chuyện tuỳ tiện. Nguyên tắc chung: đặt cột hay được lọc bằng dấu "="
--   lên trước, cột lọc theo khoảng (>, <, BETWEEN) để sau cùng.
-- ============================================================
