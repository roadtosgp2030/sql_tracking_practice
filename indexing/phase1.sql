-- ============================================================
-- PHASE 1 — Đọc EXPLAIN & index đơn cột
-- (Chạy schema.sql trước)
-- ============================================================
USE indexing;

-- ============================================================
-- KIẾN THỨC NỀN — Cách đọc EXPLAIN
-- ============================================================
-- EXPLAIN cho biết MySQL ĐỊNH làm gì (không chạy thật).
-- EXPLAIN ANALYZE thì CHẠY THẬT và báo thời gian thực tế.
--
-- Các cột quan trọng của EXPLAIN:
--
--   type   : cách truy cập bảng. Từ TỆ đến TỐT:
--            ALL    = quét toàn bộ bảng (tệ nhất)
--            index  = quét toàn bộ index (đỡ hơn ALL chút xíu)
--            range  = quét 1 khoảng trong index (tốt)
--            ref    = tìm theo giá trị, có thể ra nhiều dòng (tốt)
--            eq_ref = tìm theo unique key, ra đúng 1 dòng (rất tốt)
--            const  = hằng số, đọc 1 lần duy nhất (tốt nhất)
--
--   key    : index THỰC SỰ được dùng. NULL = không dùng index nào.
--   rows   : ƯỚC LƯỢNG số dòng phải đọc. Càng nhỏ càng tốt.
--   Extra  : "Using index"    = covering index, không cần đọc bảng (rất tốt)
--            "Using where"    = lọc thêm sau khi đọc
--            "Using filesort" = phải sắp xếp thủ công (tốn kém)
--
-- MẸO: gõ \G thay cho ; ở cuối câu EXPLAIN để xem dạng dọc, dễ đọc hơn.
-- ============================================================
-- ============================================================
-- BÀI 1.1 — Baseline: truy vấn KHÔNG có index
-- ============================================================
-- YÊU CẦU:
-- Chạy EXPLAIN cho câu tìm 1 user theo email.
-- Rồi trả lời (viết câu trả lời vào phần comment bên dưới):
--   a) Cột type  bằng gì?
--   b) Cột key   bằng gì?
--   c) Cột rows  bằng bao nhiêu? So với 500,000 dòng thì sao?
EXPLAIN
SELECT
    id,
    full_name,
    city
FROM
    users
WHERE
    email = 'user250000@example.com';

-- Trả lời của bạn:
-- a) ALL
-- b) NULL
-- c) 435662
-- ============================================================
-- BÀI 1.2 — Đo thời gian THẬT
-- ============================================================
-- YÊU CẦU:
-- Chạy EXPLAIN ANALYZE cho đúng câu trên.
-- Tìm trong output: "Table scan on users ... actual time=...  rows=..."
-- Ghi lại thời gian thực tế.
EXPLAIN ANALYZE
SELECT
    id,
    full_name,
    city
FROM
    users
WHERE
    email = 'user250000@example.com';

-- Thời gian đo được của bạn: 1061 ms
-- ============================================================
-- BÀI 1.3 — Tạo index và so sánh
-- ============================================================
-- YÊU CẦU:
-- a) Tạo index tên idx_users_email trên cột email của bảng users.
-- b) Chạy lại CẢ HAI câu EXPLAIN và EXPLAIN ANALYZE ở trên.
-- c) So sánh type / key / rows / thời gian trước và sau.
-- Viết query của bạn bên dưới:
create index idx_users_email on users(email);

-- (gợi ý: CREATE INDEX <tên> ON <bảng>(<cột>);)
-- Sau khi tạo xong, chạy lại 2 câu EXPLAIN ở Bài 1.1 và 1.2.
-- Bảng so sánh của bạn:
--                 | TRƯỚC      | SAU
--   type          |  ALL       | REF
--   key           |            |idx_users_email
--   rows          |            |1
--   thời gian     |  1062      |0.9
-- ============================================================
-- BÀI 1.4 — PRIMARY KEY đã là index sẵn rồi
-- ============================================================
-- YÊU CẦU:
-- a) Chạy SHOW INDEX FROM users; — bạn thấy mấy index? Tên là gì?
-- b) Chạy EXPLAIN ANALYZE tìm user theo id (khoá chính) và so với tìm theo email.
--    Cái nào nhanh hơn? Tại sao?
SHOW INDEX
FROM
    users;

EXPLAIN ANALYZE
SELECT
    id,
    full_name,
    city
FROM
    users
WHERE
    id = 250000;

-- Trả lời của bạn:
-- a) 2 indexes. 1 là id, 2 là idx_users_email
-- b) tìm theo khóa chính nhanh hơn, vì tìm theo email thì phải lookup 2 lần
-- ============================================================
-- BÀI 1.5 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Đếm số đơn hàng của user_id = 12345 trong bảng orders.
-- Chạy EXPLAIN ANALYZE TRƯỚC khi tạo index. Ghi lại type / rows / thời gian.
-- Viết query của bạn bên dưới:
explain analyze select count(*) as order_counts from orders where user_id = 12345;
-- type ALL, rows 982491, time 655

-- YÊU CẦU B:
-- Tạo index trên orders(user_id), chạy lại, so sánh.
-- Viết query của bạn bên dưới:
create index idx_order_user on orders(user_id);
show index from orders;

-- YÊU CẦU C:
-- Xoá index vừa tạo đi (DROP INDEX ... ON orders;) và kiểm tra lại bằng SHOW INDEX.
-- Viết query của bạn bên dưới:
drop index idx_order_user on orders;
-- ============================================================
-- KẾT QUẢ THAM CHIẾU (đã chạy thật trên máy bạn, MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 1.1 — CHƯA có index:
--            type: ALL          <- quét toàn bộ bảng
--             key: NULL         <- không dùng index nào
--            rows: 486085       <- ước lượng phải đọc ~486k / 500k dòng
--           Extra: Using where
--
-- BÀI 1.2 — EXPLAIN ANALYZE khi CHƯA có index:
--   -> Filter: (users.email = 'user250000@example.com')
--        (actual time=599..1232 rows=1 loops=1)
--       -> Table scan on users
--            (actual time=2.07..1159 rows=500000 loops=1)
--   => Đọc đủ 500,000 dòng, mất ~1232 ms, chỉ để lấy về 1 dòng.
--
-- BÀI 1.3 — SAU khi CREATE INDEX idx_users_email ON users(email);
--            type: ref              <- tra cứu theo giá trị
--             key: idx_users_email
--         key_len: 482
--            rows: 1                <- chỉ đọc 1 dòng!
--   -> Index lookup on users using idx_users_email
--        (actual time=0.249..0.252 rows=1 loops=1)
--
--   BẢNG SO SÁNH:
--                 | TRƯỚC       | SAU
--     type        | ALL         | ref
--     key         | NULL        | idx_users_email
--     rows        | 486085      | 1
--     thời gian   | 1232 ms     | 0.25 ms     <- NHANH GẤP ~4900 LẦN
--
-- BÀI 1.4 — SHOW INDEX cho thấy có index PRIMARY trên cột id.
--   Trong InnoDB, PRIMARY KEY là "clustered index": dữ liệu của dòng
--   được lưu NGAY TRONG cây index đó. Nên tìm theo id là nhanh nhất —
--   tìm thấy index là có luôn dữ liệu, không phải đi đọc thêm chỗ khác.
--   Còn index trên email là "secondary index": nó chỉ chứa email + id,
--   tìm được id rồi phải quay lại clustered index lấy nốt các cột khác
--   (bước này gọi là "back to table" / lookup phụ).
--
-- KẾT LUẬN PHASE 1:
--   Không index -> MySQL buộc phải đọc từng dòng một để so sánh (O(n)).
--   Có index    -> MySQL đi theo cây B+Tree, vài bước là tới (O(log n)).
--   Với 500k dòng, khác biệt là ~5000 lần.
-- ============================================================
