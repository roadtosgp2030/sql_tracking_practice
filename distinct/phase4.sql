-- Active: 1756872756053@@127.0.0.1@3306@distinct_lab
-- ============================================================
-- PHASE 4 — Cạm bẫy, hiệu năng, và khử trùng lặp thật
-- (Làm phase 1, 2, 3 trước)
-- ============================================================
USE distinct_lab;

-- ============================================================
-- KIẾN THỨC NỀN — DISTINCT tốn tiền như thế nào
-- ============================================================
-- Ba phase trước nói về ĐÚNG/SAI. Phase này nói thêm về GIÁ.
--
-- Để biết dòng nào trùng dòng nào, MySQL bắt buộc phải so sánh mọi
-- dòng với nhau. Nó có đúng hai cách:
--
--   1. Đổ ra BẢNG TẠM rồi băm/sắp xếp  -> EXPLAIN hiện "Using temporary"
--   2. Đi dọc một INDEX đã sắp sẵn      -> EXPLAIN hiện "Using index"
--                                          hoặc "Using index for group-by"
--
-- Cách 1 tốn RAM, hết RAM thì đổ ra ĐĨA (bảng tạm trên đĩa) — đây là
-- một trong những nguyên nhân "câu lệnh tự nhiên chậm" phổ biến nhất.
-- Cách 2 gần như miễn phí.
--
-- Một hệ quả rất thực tế: DISTINCT KHÔNG BAO GIỜ dừng sớm được như
-- LIMIT thường. Muốn biết giá trị thứ 3 có trùng giá trị nào trước đó
-- không, nó phải nhớ hết những gì đã đọc. `LIMIT 10` sau DISTINCT
-- không cứu bạn khỏi việc quét cả bảng.
--
-- Cuối phase này là phần dùng được ngay trong việc thật: tìm và XOÁ
-- các dòng trùng lặp trong một bảng bẩn.
-- ============================================================
-- ============================================================
-- BÀI 4.1 — DISTINCT vô dụng: khi danh sách cột có KHOÁ
-- ============================================================
-- YÊU CẦU:
-- a) Chạy 3 câu. Số dòng lần lượt là bao nhiêu?
-- b) Câu 1 và câu 2 có DISTINCT nhưng KHÔNG bỏ được dòng nào.
--    Vì sao? Điều gì trong định nghĩa bảng khiến việc đó là CHẮC CHẮN,
--    không phải may rủi?
-- c) Câu 3 bỏ cột id đi thì mới có dòng bị gộp. Mấy dòng bị gộp?
--    Đó là những dòng nào? (xem lại schema.sql, bảng page_views)
-- d) Rút ra: hễ trong SELECT có PRIMARY KEY (hoặc UNIQUE KEY) thì
--    DISTINCT làm được gì? Nó có tốn công không?
SELECT
    COUNT(*) AS distinct_sao
FROM
    (
        SELECT DISTINCT
            *
        FROM
            orders
    ) t;

SELECT
    COUNT(*) AS distinct_sao_pv
FROM
    (
        SELECT DISTINCT
            *
        FROM
            page_views
    ) t;

SELECT
    COUNT(*) AS bo_cot_id
FROM
    (
        SELECT DISTINCT
            customer_id,
            page,
            viewed_on
        FROM
            page_views
    ) t;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- GHI NHỚ: `SELECT DISTINCT *` trên bảng có khoá chính là câu lệnh
--          TỐN TIỀN MÀ KHÔNG LÀM GÌ. MySQL vẫn phải sắp xếp/băm toàn
--          bộ để phát hiện ra là chẳng có gì trùng. Thấy DISTINCT *
--          trong code review thì gần như chắc chắn người viết đang
--          "cho chắc" chứ không hiểu mình viết gì.
-- ============================================================
-- BÀI 4.2 — DISTINCT + LIMIT: LIMIT cắt cái gì?
-- ============================================================
-- YÊU CẦU:
-- a) Chạy 2 câu đầu. Cùng LIMIT 2 nhưng kết quả khác nhau. Giải thích
--    bằng thứ tự thực thi (xem lại phần KIẾN THỨC NỀN phase 1).
-- b) Câu 3: `ORDER BY city LIMIT 3` — MySQL phải đọc bao nhiêu dòng
--    của bảng customers để trả lời được? Nó có thể dừng sau 3 dòng
--    không? Vì sao không?
-- c) Suy ra: câu "lấy 10 thành phố đầu tiên" trên bảng 50 triệu dòng
--    có nhanh không?
SELECT DISTINCT
    status
FROM
    orders
LIMIT
    2;

SELECT
    status
FROM
    orders
LIMIT
    2;

SELECT DISTINCT
    city
FROM
    customers
ORDER BY
    city
LIMIT
    3;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 4.3 — "Trùng" phụ thuộc KIỂU DỮ LIỆU: DATETIME
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu 1. Hai con số khác nhau. Chênh mấy? Vì sao?
--    (gợi ý: đơn 1 và đơn 2 cùng ngày 2024-03-01, khác giờ;
--     đơn 3 và đơn 4 cùng ngày 2024-03-02)
-- b) Sếp hỏi "công ty có đơn hàng vào bao nhiêu NGÀY khác nhau?".
--    Con số nào đúng?
-- c) Chạy câu 2 để xem danh sách ngày.
-- d) Bài học chung: nếu bạn DISTINCT trên một cột DATETIME/TIMESTAMP,
--    khả năng rất cao là bạn đang không khử trùng được gì cả. Vì sao?
SELECT
    COUNT(DISTINCT ordered_at)       AS theo_datetime,
    COUNT(DISTINCT DATE(ordered_at)) AS theo_ngay,
    COUNT(*)                         AS so_don
FROM
    orders;

SELECT DISTINCT
    DATE(ordered_at) AS ngay
FROM
    orders
ORDER BY
    ngay;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 4.4 — "Trùng" phụ thuộc KIỂU DỮ LIỆU: FLOAT
-- ============================================================
-- Đây là cái bẫy sẽ làm bạn mất một buổi chiều nếu chưa từng gặp.
--
-- YÊU CẦU:
-- a) Chạy câu 1. Hai giá trị "0.3" nhưng COUNT(DISTINCT) ra mấy?
-- b) Chạy câu 2. `0.1+0.2 = 0.3` trả về 0 (SAI) với DOUBLE.
--    Nhìn cột thuc_te — con số thật sự là bao nhiêu?
-- c) Chạy câu 3: cũng phép tính đó nhưng với DECIMAL thì bằng nhau.
-- d) Rút ra: có nên DISTINCT / GROUP BY / so sánh "=" trên cột
--    FLOAT hoặc DOUBLE không? Tiền bạc thì dùng kiểu gì?
SELECT
    COUNT(DISTINCT v) AS so_gia_tri_khac_nhau,
    COUNT(*)          AS so_dong
FROM
    (
        SELECT
            CAST(0.1 AS DOUBLE) + CAST(0.2 AS DOUBLE) AS v
        UNION ALL
        SELECT
            CAST(0.3 AS DOUBLE)
    ) t;

SELECT
    CAST(0.1 AS DOUBLE) + CAST(0.2 AS DOUBLE) = CAST(0.3 AS DOUBLE) AS bang_nhau,
    FORMAT(CAST(0.1 AS DOUBLE) + CAST(0.2 AS DOUBLE), 20)           AS thuc_te;

SELECT
    0.1 + 0.2 = 0.3 AS decimal_bang_nhau;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 4.5 — Giá của DISTINCT, và cách INDEX làm nó gần như miễn phí
-- ============================================================
-- Nối lại với lab `indexing`.
--
-- YÊU CẦU:
-- a) Chạy câu 1 và 2. Nhìn cột Extra. Hai câu khác nhau chỗ nào?
--    Vì sao DISTINCT id lại không cần bảng tạm?
-- b) Chạy câu 3 (orders.customer_id chưa có index) — Extra là gì?
-- c) Chạy câu 4 để tạo index, rồi chạy lại câu 3. Extra đổi thành gì?
--    Cột `type` đổi từ gì sang gì? Cột `rows` đổi từ 12 xuống mấy?
-- d) Chạy câu 5 để dọn index đi.
-- e) Giải thích bằng lời: vì sao index làm DISTINCT nhanh lên?
--    (gợi ý: index đã SẮP XẾP sẵn, mà các giá trị bằng nhau thì nằm
--     cạnh nhau -> MySQL chỉ cần nhảy sang giá trị KHÁC tiếp theo,
--     không cần đọc từng dòng)
EXPLAIN SELECT DISTINCT
    city
FROM
    customers;

EXPLAIN SELECT DISTINCT
    id
FROM
    customers;

EXPLAIN SELECT DISTINCT
    customer_id
FROM
    orders;

CREATE INDEX idx_orders_customer ON orders (customer_id);

-- (chạy lại câu 3 ở đây rồi mới chạy dòng dưới)
DROP INDEX idx_orders_customer ON orders;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- e)
-- ============================================================
-- BÀI 4.6 — MySQL KHÔNG CÓ "DISTINCT ON"
-- ============================================================
-- Câu hỏi rất hay gặp: "lấy ĐƠN MỚI NHẤT của MỖI khách hàng".
--
-- Người quen PostgreSQL sẽ viết `SELECT DISTINCT ON (customer_id) ...`.
-- MySQL không có cú pháp đó. Và DISTINCT thường KHÔNG làm được việc
-- này, vì DISTINCT chỉ biết XOÁ dòng trùng, không biết CHỌN dòng nào
-- trong nhóm để giữ lại.
--
-- YÊU CẦU:
-- a) Thử nghĩ xem có cách nào dùng DISTINCT để giải bài này không.
--    (không có — hãy tự thuyết phục mình vì sao)
-- b) Chạy câu dưới (dùng ROW_NUMBER). Ra mấy dòng? Vì sao không phải 8?
-- c) `PARTITION BY` đóng vai trò gì? `ORDER BY` trong OVER() đóng vai
--    trò gì? Đổi DESC thành ASC thì được cái gì?
-- d) Muốn lấy đơn ĐẮT NHẤT mỗi khách thì sửa chỗ nào?
SELECT
    customer_id,
    id AS order_id,
    ordered_at,
    amount
FROM
    (
        SELECT
            o.*,
            ROW_NUMBER() OVER (
                PARTITION BY o.customer_id
                ORDER BY o.ordered_at DESC
            ) AS rn
        FROM
            orders o
    ) t
WHERE
    rn = 1
ORDER BY
    customer_id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 4.7 — Việc thật: TÌM và XOÁ dòng trùng lặp
-- ============================================================
-- Bảng page_views có dòng trùng thật (dòng 1 và 2 giống hệt nhau trừ
-- id; dòng 12 và 13 cũng vậy). Giờ ta dọn chúng.
--
-- Ta làm trên BẢN SAO `pv_nhap` — không bao giờ tập DELETE trên bảng
-- gốc, kể cả trong lab.
--
-- YÊU CẦU:
-- a) Chạy 3 câu đầu (tạo bản sao, đếm, tìm nhóm trùng).
--    Có mấy nhóm trùng? Câu tìm trùng dùng GROUP BY chứ không dùng
--    DISTINCT — vì sao DISTINCT không tìm được dòng trùng?
-- b) Chạy câu DELETE. Xoá mất mấy dòng? Còn lại bao nhiêu?
-- c) Chạy câu kiểm tra cuối — phải ra 0.
-- d) Trong câu DELETE, vì sao phải dùng `<=>` cho customer_id mà
--    không dùng `=`? Thử đổi thành `=` xem chuyện gì xảy ra khi cột
--    có NULL. (đây chính là bài học NULL của phase 1, quay lại lần cuối)
-- e) Sau khi dọn xong, làm gì để bảng KHÔNG BAO GIỜ trùng lại nữa?
DROP TABLE IF EXISTS pv_nhap;

CREATE TABLE pv_nhap AS
SELECT
    *
FROM
    page_views;

SELECT
    COUNT(*) AS truoc_khi_don
FROM
    pv_nhap;

-- Tìm các nhóm bị trùng (bỏ cột id ra khỏi tiêu chí "thế nào là trùng")
SELECT
    customer_id,
    page,
    viewed_on,
    COUNT(*)         AS so_ban,
    MIN(id)          AS giu_lai,
    GROUP_CONCAT(id) AS cac_id
FROM
    pv_nhap
GROUP BY
    customer_id,
    page,
    viewed_on
HAVING
    COUNT(*) > 1;

-- Xoá, giữ lại dòng có id NHỎ NHẤT trong mỗi nhóm
DELETE t
FROM
    pv_nhap t
    JOIN (
        SELECT
            customer_id,
            page,
            viewed_on,
            MIN(id) AS giu
        FROM
            pv_nhap
        GROUP BY
            customer_id,
            page,
            viewed_on
        HAVING
            COUNT(*) > 1
    ) d ON (t.customer_id <=> d.customer_id)
    AND t.page = d.page
    AND t.viewed_on = d.viewed_on
WHERE
    t.id > d.giu;

SELECT
    COUNT(*) AS sau_khi_don
FROM
    pv_nhap;

-- Kiểm tra: phải ra 0
SELECT
    COUNT(*) AS con_nhom_trung
FROM
    (
        SELECT
            1
        FROM
            pv_nhap
        GROUP BY
            customer_id,
            page,
            viewed_on
        HAVING
            COUNT(*) > 1
    ) t;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- e)
-- ============================================================
-- BÀI 4.8 — Tự làm (tổng hợp cả 4 phase)
-- ============================================================
-- YÊU CẦU A:
-- Bảng orders có "đơn trùng" không? Định nghĩa: cùng customer_id,
-- cùng amount, cùng NGÀY (không tính giờ).
-- Viết query tìm chúng. Nếu tìm được, đó có phải dữ liệu lỗi không?
-- Viết query của bạn bên dưới:
select customer_id, amount, day(ordered_at), count(*) as trung from orders GROUP BY customer_id, amount, day(ordered_at);

-- YÊU CẦU B:
-- Với mỗi khách hàng, tìm SẢN PHẨM ĐẮT NHẤT họ từng mua (tên + giá).
-- Mỗi khách đúng 1 dòng. DISTINCT không giải được — dùng ROW_NUMBER.
-- Viết query của bạn bên dưới:
select customer_id, unit_price from (
    select o.customer_id, unit_price, ROW_NUMBER() over(PARTITION BY customer_id ORDER BY unit_price desc) as row_order from orders o join order_items oi on o.id = oi.order_id
) as t where row_order = 1;

-- YÊU CẦU C:
-- Câu dưới đây SAI. Chạy nó, rồi chỉ ra sai ở đâu và sửa lại.
-- (nó định trả lời: "mỗi thành phố có bao nhiêu khách và bao nhiêu đơn")
SELECT DISTINCT
    lower(trim(c.city)) as city,
    COUNT(o.id) AS so_luong
FROM
    customers c
    LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY
    lower(trim(c.city));

-- Sai ở đâu: ...
-- Query đã sửa của bạn:


-- YÊU CẦU D:
-- Viết một câu trả lời được: "có bao nhiêu khách hàng đã mua ít nhất
-- 2 nhóm sản phẩm (category) khác nhau?" — kết quả là MỘT con số.
-- Viết query của bạn bên dưới:
select count(*) from (
    select 1 from (
    select o.customer_id, p.category from orders o join order_items oi on o.id = oi.order_id join products p on oi.product_id = p.id group by o.customer_id, p.category
) as t group by customer_id having count(*) > 1
) as t;

-- YÊU CẦU E:
-- Đọc lại 3 câu dưới. KHÔNG chạy. Với mỗi câu, trả lời: DISTINCT ở
-- đây là ĐÚNG, THỪA, hay SAI? Sau đó chạy để kiểm chứng.
--   1) SELECT DISTINCT c.id, c.full_name FROM customers c
--      JOIN orders o ON o.customer_id = c.id;
--   2) SELECT DISTINCT o.id, o.amount FROM orders o;
--   3) SELECT DISTINCT c.city FROM customers c
--      JOIN orders o ON o.customer_id = c.id;
-- Trả lời của bạn:
-- 1)
-- 2)
-- 3)
-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 4.1 — 12 / 20 / 18
--   `SELECT DISTINCT * FROM orders`     -> 12, y hệt COUNT(*).
--   `SELECT DISTINCT * FROM page_views` -> 20, y hệt COUNT(*).
--   Cả hai bảng đều có PRIMARY KEY `id`. Mà khoá chính thì theo định
--   nghĩa là DUY NHẤT. Nên hai dòng bất kỳ CHẮC CHẮN khác nhau ít
--   nhất ở cột id -> không bao giờ có gì để gộp. Đây là điều CHẮC
--   CHẮN do cấu trúc bảng, không phải do dữ liệu hiện tại may mắn.
--
--   Bỏ cột id ra: 18 dòng. Gộp được 2 dòng:
--     id 1 và 2   : (1, '/home', '2024-03-01')
--     id 12 và 13 : (4, '/product/5', '2024-03-03')
--   Muốn tìm trùng, phải bỏ cột định danh ra khỏi tiêu chí so sánh.
--
-- BÀI 4.2 — DISTINCT + LIMIT
--   `SELECT DISTINCT status ... LIMIT 2` -> paid, pending
--   `SELECT status ... LIMIT 2`          -> paid, paid
--   Thứ tự: SELECT -> DISTINCT -> ORDER BY -> LIMIT. Khử trùng xong
--   MỚI cắt. Nên LIMIT 2 sau DISTINCT nghĩa là "2 giá trị KHÁC NHAU
--   đầu tiên", không phải "2 dòng đầu tiên".
--
--   `ORDER BY city LIMIT 3` -> NULL, Da Nang, Ha Noi.
--   MySQL phải đọc HẾT 8 dòng. Không thể dừng sớm: muốn biết dòng
--   thứ 4 có trùng dòng nào trước không thì phải xem hết đã. Và muốn
--   sắp xếp đúng thì cũng phải có đủ dữ liệu.
--   => Trên bảng 50 triệu dòng, "lấy 10 thành phố đầu" vẫn quét cả
--      bảng nếu không có index trên cột đó. LIMIT không cứu bạn.
--
-- BÀI 4.3 — 12 / 10 / 12
--   COUNT(DISTINCT ordered_at) = 12 = đúng bằng số đơn: KHÔNG khử
--   được dòng nào, vì không đơn nào trùng nhau tới từng giây.
--   COUNT(DISTINCT DATE(ordered_at)) = 10. Gộp được 2:
--     đơn 1 (09:15) + đơn 2 (20:40) -> cùng 2024-03-01
--     đơn 3 (11:00) + đơn 4 (14:30) -> cùng 2024-03-02
--   "Có đơn vào bao nhiêu ngày khác nhau?" -> 10.
--
--   DISTINCT trên DATETIME hầu như luôn vô dụng: độ phân giải tới
--   giây (hoặc micro giây) khiến hai sự kiện gần như không bao giờ
--   trùng khít. Muốn gom theo ngày/tháng thì phải nói rõ: DATE(),
--   DATE_FORMAT(), YEAR()... Nhưng nhớ bài 4.5: bọc hàm quanh cột là
--   mất index. Cách chuyên nghiệp là thêm cột `ordered_on DATE` sinh
--   sẵn và đánh index lên nó.
--
-- BÀI 4.4 — FLOAT
--   COUNT(DISTINCT v) = 2 trên 2 dòng — hai giá trị "cùng là 0.3"
--   mà MySQL coi là KHÁC NHAU.
--   `0.1+0.2 = 0.3` với DOUBLE -> 0 (SAI).
--   Giá trị thật: 0.30000000000000004
--   Cùng phép tính với DECIMAL -> 1 (ĐÚNG).
--
--   Lý do: FLOAT/DOUBLE là số nhị phân dấu chấm động, không biểu diễn
--   chính xác được 0.1 hay 0.2 (giống như hệ thập phân không viết
--   chính xác được 1/3). Sai số cỡ 10^-17, đủ để "=" trả về sai.
--
--   LUẬT: KHÔNG BAO GIỜ dùng FLOAT/DOUBLE cho tiền, và không bao giờ
--   DISTINCT / GROUP BY / so sánh "=" trên chúng. Tiền -> DECIMAL.
--   Cả lab này dùng DECIMAL(10,2), nên nó an toàn.
--
-- BÀI 4.5 — EXPLAIN
--   SELECT DISTINCT city FROM customers:
--     type=ALL, key=NULL, Extra = "Using temporary"
--     -> quét cả bảng, dựng bảng tạm để khử trùng.
--
--   SELECT DISTINCT id FROM customers:
--     type=index, key=PRIMARY, Extra = "Using index"
--     -> KHÔNG có "Using temporary". Vì id là khoá chính: MySQL biết
--        chắc mọi giá trị đã duy nhất, nên nó bỏ hẳn bước khử trùng.
--
--   SELECT DISTINCT customer_id FROM orders (chưa có index):
--     type=ALL, rows=12, Extra = "Using temporary"
--   Sau CREATE INDEX idx_orders_customer:
--     type=range, key=idx_orders_customer, rows=8,
--     Extra = "Using index for group-by"
--
--   "Using index for group-by" là loose index scan: index đã sắp xếp
--   nên các customer_id giống nhau nằm liền kề. MySQL đọc giá trị
--   đầu tiên rồi NHẢY THẲNG sang giá trị khác tiếp theo, bỏ qua toàn
--   bộ dòng ở giữa. Trên bảng lớn, đây là khác biệt giữa 3 giây và
--   3 mili giây.
--
--   Xem thêm lab `indexing`. Quy tắc chung vẫn thế: hàm bọc quanh cột
--   (DATE(x), TRIM(x), UPPER(x)) làm index vô dụng — nên cái giá của
--   "dữ liệu bẩn phải TRIM lúc đọc" ở phase 1 không chỉ là xấu code,
--   mà là mất luôn index.
--
-- BÀI 4.6 — ROW_NUMBER: 7 dòng, không phải 8.
--   +-------------+----------+---------------------+--------+
--   | customer_id | order_id | ordered_at          | amount |
--   +-------------+----------+---------------------+--------+
--   |           1 |       12 | 2024-03-20 15:00:00 | 250.00 |
--   |           2 |        3 | 2024-03-02 11:00:00 |  80.00 |
--   |           3 |        6 | 2024-03-07 16:20:00 | 340.00 |
--   |           4 |        7 | 2024-03-08 10:00:00 |  90.00 |
--   |           5 |        9 | 2024-03-11 09:30:00 | 150.00 |
--   |           7 |       10 | 2024-03-12 19:00:00 |  45.00 |
--   |           8 |       11 | 2024-03-15 13:10:00 | 700.00 |
--   +-------------+----------+---------------------+--------+
--   7 dòng vì bảng orders chỉ có 7 khách xuất hiện — khách id 6 chưa
--   mua gì nên không có mặt trong bảng orders.
--
--   PARTITION BY = "đánh số lại từ 1 cho MỖI khách".
--   ORDER BY trong OVER() = "đánh số theo thứ tự nào" -> quyết định
--   ai được rn = 1. DESC -> đơn mới nhất. ASC -> đơn đầu tiên.
--   Đắt nhất mỗi khách: đổi thành ORDER BY o.amount DESC.
--
--   Vì sao DISTINCT không làm được: DISTINCT chỉ có một quyền là XOÁ
--   dòng trùng, và nó không được chọn giữ dòng nào — các dòng trùng
--   theo định nghĩa là giống hệt nhau. Ở đây các đơn của cùng một
--   khách KHÁC NHAU (khác ngày, khác tiền), ta muốn giữ MỘT dòng cụ
--   thể. Đó là bài toán XẾP HẠNG, không phải khử trùng.
--
-- BÀI 4.7 — dọn trùng: 20 -> 18, còn 0 nhóm trùng.
--   Hai nhóm trùng tìm được:
--     (1, '/home', '2024-03-01')      : id 1, 2   -> giữ 1
--     (4, '/product/5', '2024-03-03') : id 12, 13 -> giữ 12
--
--   Vì sao DISTINCT không tìm được dòng trùng: DISTINCT XOÁ chúng đi
--   trong im lặng, nó không BÁO CÁO cho bạn cái gì đã bị xoá và bị
--   xoá mấy lần. Muốn biết "cái gì trùng, trùng mấy lần, id nào" thì
--   phải GROUP BY + HAVING COUNT(*) > 1. DISTINCT giấu, GROUP BY chỉ.
--
--   `<=>` (NULL-safe equal): `NULL = NULL` cho ra NULL (không đúng,
--   không sai) nên dòng đó không JOIN được và KHÔNG BỊ XOÁ.
--   `NULL <=> NULL` cho ra 1 (đúng). Trong bảng này customer_id có
--   NULL, nên nếu viết `=` thì các dòng trùng của khách vãng lai sẽ
--   sống sót âm thầm — bạn chạy DELETE, thấy "OK", và vẫn còn trùng.
--   Đây là lần cuối NULL cắn bạn trong lab này.
--
--   Sau khi dọn xong, chống trùng quay lại bằng ràng buộc, không phải
--   bằng cách chạy DELETE định kỳ:
--     ALTER TABLE pv_nhap
--       ADD UNIQUE KEY uq_pv (customer_id, page, viewed_on);
--   (lưu ý: UNIQUE trong MySQL vẫn CHO PHÉP nhiều dòng NULL — đúng
--    theo chuẩn SQL, nhưng nghĩa là ràng buộc này không chặn được
--    trùng ở các dòng có customer_id NULL.)
--
-- BÀI 4.8 A — lời giải:
--   SELECT customer_id, DATE(ordered_at) AS ngay, amount, COUNT(*) AS n,
--          GROUP_CONCAT(id) AS cac_don
--   FROM orders
--   GROUP BY customer_id, DATE(ordered_at), amount
--   HAVING COUNT(*) > 1;
--   -> 0 dòng. Đơn 1 và đơn 12 cùng khách, cùng 250.00, nhưng khác
--      ngày (01/03 và 20/03) nên KHÔNG trùng theo định nghĩa này.
--   Bài học: "trùng lặp" không phải khái niệm của MySQL, nó là khái
--   niệm NGHIỆP VỤ. Bạn phải tự định nghĩa, rồi mới viết được SQL.
--   Đổi định nghĩa (bỏ ngày đi) là đáp án đổi ngay.
--
-- BÀI 4.8 B — lời giải:
--   SELECT customer_id, name, price FROM (
--     SELECT o.customer_id, p.name, p.price,
--            ROW_NUMBER() OVER (PARTITION BY o.customer_id
--                               ORDER BY p.price DESC, p.id) AS rn
--     FROM orders o
--     JOIN order_items i ON i.order_id = o.id
--     JOIN products p ON p.id = i.product_id) t
--   WHERE rn = 1 ORDER BY customer_id;
--   -> 7 dòng. Thêm `p.id` vào ORDER BY để phá hoà (tie-break) cho
--      kết quả ổn định — nếu không, hai sản phẩm cùng giá thì MySQL
--      chọn cái nào là tuỳ hứng, chạy 2 lần có thể ra 2 kết quả khác
--      nhau. Nhớ: Mouse và Keyboard cùng giá 25.
--
-- BÀI 4.8 C — câu SAI cho ra:
--   +-------------+----------+
--   | Ha Noi      |        4 |
--   | Ho Chi Minh |        4 |
--   | Da Nang     |        1 |
--   | NULL        |        3 |   <- con số này là cái gì?!
--   | Ha Noi      |        1 |
--   +-------------+----------+
--   Nhóm NULL có 2 khách (id 5, 6) và 2 đơn (của khách 5), nhưng cột
--   so_luong ghi 3. Nó không phải số khách, cũng không phải số đơn —
--   nó là 2 đơn thật + 1 dòng ma do LEFT JOIN bịa ra cho khách id 6.
--   Một con số không trả lời câu hỏi nào cả.
--
--   Câu này sai HAI chỗ:
--   1. Chữ DISTINCT là THỪA và gây hiểu lầm: đã GROUP BY c.city thì
--      mỗi thành phố chỉ ra đúng 1 dòng rồi, không thể có gì trùng
--      để mà khử. DISTINCT ở đây chỉ tốn thêm một bước sắp xếp.
--   2. COUNT(*) đếm SAI: sau LEFT JOIN nó đếm số DÒNG (tức số đơn),
--      chứ không phải số khách. Với khách chưa mua gì, LEFT JOIN bịa
--      ra một dòng NULL và COUNT(*) vẫn đếm thành 1 (bẫy kinh điển
--      của lab join, bài 2.6).
--   Sửa:
--     SELECT TRIM(c.city) AS city,
--            COUNT(DISTINCT c.id) AS so_khach,
--            COUNT(DISTINCT o.id) AS so_don
--     FROM customers c
--     LEFT JOIN orders o ON o.customer_id = c.id
--     GROUP BY TRIM(c.city);
--   +-------------+----------+--------+
--   | NULL        |        2 |      2 |
--   | Da Nang     |        1 |      1 |
--   | Ha Noi      |        3 |      5 |
--   | Ho Chi Minh |        2 |      4 |
--   +-------------+----------+--------+
--   (TRIM để gộp 'Ha Noi' với 'Ha Noi ' — bài học phase 1. Nhờ vậy
--    Ha Noi mới hiện đúng 3 khách / 5 đơn thay vì bị tách làm hai.)
--   Nhóm NULL: 2 khách, 2 đơn — COUNT(DISTINCT o.id) không đếm dòng
--   ma của khách id 6, vì o.id của dòng đó là NULL.
--
-- BÀI 4.8 D — lời giải:
--   SELECT COUNT(*) AS so_khach FROM (
--     SELECT o.customer_id
--     FROM orders o
--     JOIN order_items i ON i.order_id = o.id
--     JOIN products p ON p.id = i.product_id
--     GROUP BY o.customer_id
--     HAVING COUNT(DISTINCT p.category) >= 2) t;
--   -> 6.  (chỉ khách id 2 mua đúng 1 nhóm — Desk Lamp/Home)
--   Chú ý: p.category có NULL (Gift Card), nhưng sản phẩm đó chưa ai
--   mua nên không ảnh hưởng. Nếu có, COUNT(DISTINCT) sẽ lặng lẽ
--   không tính nhóm NULL đó — bài 2.1.
--
-- BÀI 4.8 E — đáp án:
--   1) ĐÚNG (và cần thiết). JOIN orders nhân dòng theo số đơn; danh
--      sách DISTINCT có chứa c.id nên không gộp nhầm hai khách trùng
--      tên. -> 7 dòng. Dù vậy, EXISTS vẫn là cách diễn đạt tốt hơn.
--   2) THỪA. o.id là khoá chính của orders -> mọi dòng đã duy nhất
--      sẵn, DISTINCT không bỏ được dòng nào mà vẫn tốn công. (bài 4.1)
--   3) ĐÚNG về cú pháp nhưng KẾT QUẢ ĐÁNG NGỜ: ra 5 dòng, trong đó
--      có 2 dòng cùng hiện 'Ha Noi' và 1 dòng NULL. Đây là DISTINCT
--      chạy đúng trên dữ liệu bẩn — đúng luật, sai nghiệp vụ.
--      Muốn đúng: SELECT DISTINCT TRIM(c.city) ...
--
-- ============================================================
-- CHECKLIST — dán lên tường
-- ============================================================
-- TRƯỚC KHI GÕ CHỮ `DISTINCT`, HỎI 5 CÂU:
--
--   1. "MỘT DÒNG kết quả này đại diện cho CÁI GÌ?"
--      Trả lời được thì thường bạn đã biết mình cần gì khác DISTINCT.
--
--   2. "Dòng lặp từ đâu ra?"
--      Nếu do JOIN sang bảng 1-nhiều -> bệnh nằm ở JOIN, không nằm ở
--      kết quả. Cân nhắc EXISTS, hoặc gộp trước rồi mới JOIN.
--
--   3. "Danh sách cột của tôi có chứa KHOÁ CHÍNH không?"
--      Có khoá chính rồi -> DISTINCT vô dụng (bài 4.1).
--      Không có khoá chính -> nguy cơ gộp nhầm hai thực thể (bài 3.2).
--
--   4. "Cột này có NULL không?"
--      Có -> DISTINCT giữ 1 dòng NULL, COUNT(DISTINCT) vứt hẳn.
--      Hai con số sẽ lệch nhau 1 và bạn phải giải thích được vì sao.
--
--   5. "Dữ liệu có sạch không?"
--      Hoa/thường, dấu cách thừa, DATETIME, FLOAT — bốn chỗ khiến
--      "trùng theo mắt người" khác "trùng theo MySQL".
--
-- BA CÂU KHÔNG BAO GIỜ ĐƯỢC VIẾT:
--   - SELECT DISTINCT *            (bảng có khoá -> luôn vô dụng)
--   - SUM(DISTINCT tien)           (ăn mất giao dịch thật)
--   - ... IN (SELECT DISTINCT x)   (thừa 100%)
--
-- KHI NÀO DISTINCT LÀ ĐÚNG:
--   - Lấy danh sách giá trị để đổ vào dropdown / bộ lọc.
--   - Đã có khoá chính trong danh sách cột và bạn hiểu vì sao có lặp.
--   - COUNT(DISTINCT x) để đếm "số thứ khác nhau" — dùng thoải mái,
--     chỉ nhớ nó KHÔNG CỘNG ĐƯỢC giữa các nhóm (bài 2.5).
--
-- CÂU CHỐT CỦA CẢ LAB:
--   DISTINCT không làm dữ liệu của bạn đúng hơn.
--   Nó chỉ làm màn hình của bạn gọn hơn.
-- ============================================================
