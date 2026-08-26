-- Active: 1778116211273@@127.0.0.1@3306@distinct_lab
-- ============================================================
-- PHASE 2 — COUNT(DISTINCT) và các hàm gộp
-- (Làm phase 1 trước)
-- ============================================================
USE distinct_lab;

-- ============================================================
-- KIẾN THỨC NỀN — DISTINCT có HAI chỗ đứng khác nhau
-- ============================================================
-- Phase 1 học DISTINCT ở vị trí thứ nhất: ngay sau SELECT, tác dụng
-- lên CẢ DÒNG. Phase này học vị trí thứ hai: BÊN TRONG hàm gộp.
--
--   SELECT DISTINCT city FROM ...   -> khử trùng DÒNG kết quả
--   SELECT COUNT(DISTINCT city) ... -> khử trùng GIÁ TRỊ trước khi đếm
--
-- Hai thứ này KHÔNG liên quan gì nhau. Cùng tên, khác việc.
--
-- Bốn cách đếm, bốn kết quả khác nhau trên CÙNG một cột:
--
--   COUNT(*)              đếm DÒNG. Không nhìn giá trị. NULL vẫn đếm.
--   COUNT(cot)            đếm dòng có cot KHÁC NULL.
--   COUNT(DISTINCT cot)   đếm số GIÁ TRỊ khác nhau, KHÔNG kể NULL.
--   số dòng của
--   SELECT DISTINCT cot   = COUNT(DISTINCT cot) + 1 nếu cột có NULL.
--
-- LUẬT VÀNG CỦA HÀM GỘP: mọi hàm gộp (COUNT, SUM, AVG, MAX, MIN,
-- GROUP_CONCAT) đều VỨT NULL ĐI trước khi làm việc. Không có ngoại lệ,
-- trừ đúng một cái: COUNT(*).
-- ============================================================
-- ============================================================
-- BÀI 2.1 — Bài kinh điển: "hôm nay có bao nhiêu khách?"
-- ============================================================
-- Bảng page_views là log xem trang: 20 dòng, có khách chưa đăng nhập
-- (customer_id = NULL), có khách xem đi xem lại nhiều lần.
--
-- YÊU CẦU:
-- a) Chạy câu dưới. Ba con số là bao nhiêu?
-- b) Sếp hỏi: "Có bao nhiêu người vào website?". Bạn trả lời con số
--    nào trong ba con số đó? Còn "có bao nhiêu lượt xem trang?"
-- c) Con số `khach_duy_nhat` có ĐÚNG là số người thật không?
--    (gợi ý: 4 dòng NULL kia là mấy người? MySQL có biết không?)
SELECT
    COUNT(*)                    AS tat_ca,
    COUNT(customer_id)          AS co_dang_nhap,
    COUNT(DISTINCT customer_id) AS khach_duy_nhat
FROM
    page_views;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.2 — Lại chuyện NULL: hai cách "đếm giá trị khác nhau"
-- ============================================================
-- YÊU CẦU:
-- a) Chạy 2 câu dưới. Chênh nhau bao nhiêu?
-- b) Giải thích chỗ chênh. (nhắc lại bài 1.3)
-- c) Nếu bạn phải viết báo cáo "số khách đã đăng nhập", câu nào đúng?
--    Còn "log này có mấy loại customer_id"?
SELECT
    COUNT(DISTINCT customer_id) AS cach_1
FROM
    page_views;

SELECT
    COUNT(*) AS cach_2
FROM
    (
        SELECT DISTINCT
            customer_id
        FROM
            page_views
    ) t;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.3 — COUNT(DISTINCT a, b): cái bẫy ít người biết
-- ============================================================
-- COUNT(DISTINCT) nhận NHIỀU cột: `COUNT(DISTINCT a, b)` đếm số CẶP
-- (a,b) khác nhau. Nghe thì giống hệt `SELECT DISTINCT a, b`.
-- Không giống đâu.
--
-- YÊU CẦU:
-- a) Chạy cả 2 câu. Hai con số là bao nhiêu? Chênh mấy?
-- b) Chạy câu 3 để xem tận mắt 16 cặp. Đếm xem có mấy cặp chứa NULL.
--    Con số đó có bằng chỗ chênh ở câu a) không?
-- c) Rút ra luật: COUNT(DISTINCT a, b) xử lý dòng có NULL thế nào?
--    Chỉ cần MỘT cột NULL, hay phải CẢ HAI cột NULL?
SELECT
    COUNT(DISTINCT customer_id, page) AS count_distinct_2_cot
FROM
    page_views;

SELECT
    COUNT(*) AS so_dong_select_distinct
FROM
    (
        SELECT DISTINCT
            customer_id,
            page
        FROM
            page_views
    ) t;

SELECT DISTINCT
    customer_id,
    page
FROM
    page_views
ORDER BY
    customer_id,
    page;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.4 — SUM(DISTINCT) và AVG(DISTINCT): gần như LUÔN LUÔN SAI
-- ============================================================
-- Cú pháp này hợp lệ. MySQL chạy ngon lành, không cảnh báo gì.
-- Và nó gần như luôn cho ra con số sai.
--
-- YÊU CẦU:
-- a) Chạy câu 1. So sánh tong_that với tong_distinct — chênh bao nhiêu?
--    Số tiền bị mất đó là của sản phẩm nào? (xem lại schema.sql:
--    Mouse & Keyboard cùng giá 25, Notebook & Pen cùng giá 5)
-- b) MAX(DISTINCT price) có khác MAX(price) không? Vì sao?
--    (suy ra: DISTINCT vô nghĩa với hàm nào?)
-- c) Chạy câu 2 — đây mới là chỗ chết người. Tổng doanh thu THẬT là
--    2795. SUM(DISTINCT amount) ra bao nhiêu? Thiếu bao nhiêu?
-- d) Chạy câu 3 để tìm thủ phạm. Hai đơn hàng này có phải là dữ liệu
--    trùng lặp cần xoá không, hay là hai đơn thật?
SELECT
    SUM(price)             AS tong_that,
    SUM(DISTINCT price)    AS tong_distinct,
    AVG(price)             AS tb_that,
    AVG(DISTINCT price)    AS tb_distinct,
    MAX(price)             AS max_that,
    MAX(DISTINCT price)    AS max_distinct,
    COUNT(*)               AS so_san_pham,
    COUNT(DISTINCT price)  AS so_muc_gia
FROM
    products;

SELECT
    SUM(amount)          AS doanh_thu_that,
    SUM(DISTINCT amount) AS doanh_thu_distinct
FROM
    orders;

SELECT
    id,
    customer_id,
    ordered_at,
    amount
FROM
    orders
WHERE
    amount = 250.00;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- GHI NHỚ: SUM(DISTINCT x) chỉ đúng khi câu hỏi thật sự là "cộng các
--          GIÁ TRỊ KHÁC NHAU lại" — kiểu "tổng các mức giá đang có".
--          Nó KHÔNG BAO GIỜ là cách chữa dữ liệu bị trùng. Hai đơn
--          hàng thật tình cờ cùng số tiền sẽ bị ăn mất một đơn, và
--          không ai báo cho bạn biết.
-- ============================================================
-- BÀI 2.5 — COUNT(DISTINCT) bên trong GROUP BY
-- ============================================================
-- Đây là chỗ COUNT(DISTINCT) thật sự hữu ích và bạn sẽ dùng cả đời.
--
-- YÊU CẦU:
-- a) Chạy câu 1. Cột so_don và so_khach khác nhau ở dòng nào?
--    Ý nghĩa của từng cột là gì?
-- b) Kết quả có 5 dòng thành phố. Nhìn kỹ — có gì quen thuộc từ
--    phase 1 không? Báo cáo này đã đúng chưa?
-- c) Chạy câu 2 (báo cáo traffic theo ngày). Ngày 2024-03-01 có 5
--    lượt xem nhưng chỉ 2 khách duy nhất — 3 lượt còn lại là ai?
SELECT
    c.city,
    COUNT(*)                      AS so_don,
    COUNT(DISTINCT o.customer_id) AS so_khach
FROM
    customers c
    JOIN orders o ON o.customer_id = c.id
GROUP BY
    c.city
ORDER BY
    so_don DESC;

SELECT
    viewed_on,
    COUNT(*)                    AS luot_xem,
    COUNT(DISTINCT customer_id) AS khach_duy_nhat,
    COUNT(DISTINCT page)        AS so_trang_khac_nhau
FROM
    page_views
GROUP BY
    viewed_on
ORDER BY
    viewed_on;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.6 — GROUP_CONCAT(DISTINCT ...)
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu dưới. So sánh 2 cột kết quả của khách id 1.
-- b) Vì sao cột `thuong` lặp 'Electronics' tới 3 lần? Mỗi lần lặp
--    tương ứng với cái gì trong dữ liệu?
-- c) Trong 2 cột đó, cột nào bạn muốn đưa vào báo cáo cho sếp?
SELECT
    o.customer_id,
    GROUP_CONCAT(p.category ORDER BY p.category)          AS thuong,
    GROUP_CONCAT(DISTINCT p.category ORDER BY p.category) AS chi_khac_nhau,
    count(*)
FROM
    orders o
    JOIN order_items i ON i.order_id = o.id
    JOIN products p ON p.id = i.product_id
GROUP BY
    o.customer_id
ORDER BY
    o.customer_id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.7 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Trong bảng orders: có bao nhiêu đơn, bao nhiêu khách khác nhau đã
-- đặt, và bao nhiêu kênh khác nhau đã dùng? Một câu SELECT duy nhất,
-- 3 cột. Chú ý cột channel có NULL.
-- Viết query của bạn bên dưới:
select
    count(*) as order_count,
    count(DISTINCT customer_id) as customer_count,
    count(DISTINCT channel) as channel_count
from
    orders;


-- YÊU CẦU B:
-- Mỗi khách hàng (customer_id) đã đặt bao nhiêu đơn và mua bao nhiêu
-- SẢN PHẨM KHÁC NHAU? Sắp xếp theo số sản phẩm khác nhau giảm dần.
-- (nối orders -> order_items)
-- Cạm bẫy: COUNT(*) ở đây đếm cái gì? Có phải số đơn không?
-- Viết query của bạn bên dưới:
select * from orders o join order_items oi on o.id = oi.order_id;
select
    count(DISTINCT id) as order_number,
    count(DISTINCT product_id) as product_number,
    customer_id
from
    orders o
    join order_items oi on o.id = oi.order_id
group by
    customer_id;


-- YÊU CẦU C:
-- Mỗi nhóm sản phẩm (category) có bao nhiêu sản phẩm và bao nhiêu
-- MỨC GIÁ khác nhau? Nhóm nào có 2 sản phẩm nhưng chỉ 1 mức giá?
-- Viết query của bạn bên dưới:
select * from products;
select
    category,
    count(DISTINCT name) as tong_san_pham_category,
    count(DISTINCT price) as muc_gia_khac_nhau
from
    products
where
    category is not null
GROUP BY
    category;


-- YÊU CẦU D:
-- Mỗi trang (page) có bao nhiêu lượt xem và bao nhiêu khách đã đăng
-- nhập xem nó? Trang nào có lượt xem > số khách nhiều nhất?
-- Viết query của bạn bên dưới:
select count(*) as so_luot_xem, count(DISTINCT customer_id) as so_khach from page_views GROUP BY viewed_on ORDER BY so_luot_xem;


-- YÊU CẦU E:
-- Có bao nhiêu CẶP (khách, ngày) khác nhau trong page_views?
-- Làm bằng 2 cách: COUNT(DISTINCT a, b) và đếm dòng của SELECT DISTINCT.
-- Hai cách ra khác nhau — giải thích.
-- Viết query của bạn bên dưới:
select count(DISTINCT customer_id, viewed_on) from page_views;
select count(*) from (select DISTINCT customer_id, viewed_on from page_views) as cach2;

-- YÊU CẦU F:
-- Với mỗi ngày trong page_views, liệt kê danh sách các trang đã được
-- xem, mỗi trang chỉ ghi MỘT LẦN, ngăn cách bằng dấu " | ".
-- (gợi ý: GROUP_CONCAT có tham số SEPARATOR)
-- Viết query của bạn bên dưới:
select GROUP_CONCAT(page SEPARATOR " | ") from page_views GROUP BY viewed_on;


-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 2.1 — 20 / 16 / 8
--   +--------+--------------+----------------+
--   | tat_ca | co_dang_nhap | khach_duy_nhat |
--   |     20 |           16 |              8 |
--   +--------+--------------+----------------+
--   "Bao nhiêu lượt xem trang?" -> 20 (COUNT(*))
--   "Bao nhiêu người vào web?"  -> 8 người ĐÃ ĐĂNG NHẬP, cộng thêm
--                                  một số người lạ không đếm được.
--   4 dòng NULL kia có thể là 1 người vào 4 lần, hoặc 4 người khác
--   nhau. MySQL KHÔNG BIẾT, và COUNT(DISTINCT) cũng không biết —
--   nó chỉ lặng lẽ bỏ qua cả 4 dòng.
--   => Đây là lý do các hệ thống analytics thật luôn có `session_id`
--      hoặc `device_id` cho khách vãng lai. Không có cột đó thì câu
--      hỏi "bao nhiêu người" là câu hỏi KHÔNG TRẢ LỜI ĐƯỢC, dù bạn
--      viết SQL giỏi cỡ nào.
--
-- BÀI 2.2 — 8 và 9, chênh đúng 1.
--   COUNT(DISTINCT customer_id) = 8 : vứt NULL.
--   SELECT DISTINCT customer_id  = 9 dòng : giữ 1 dòng NULL.
--   "Số khách đã đăng nhập" -> 8.  "Log có mấy loại giá trị" -> 9.
--   Chênh lệch luôn là 0 hoặc 1. Nếu bạn thấy chênh 1 và không giải
--   thích được, gần như chắc chắn cột đó có NULL.
--
-- BÀI 2.3 — 13 và 16, chênh 3.
--   COUNT(DISTINCT customer_id, page) = 13
--   SELECT DISTINCT customer_id, page = 16 dòng
--   Ba cặp bị COUNT vứt đi, đều là cặp có customer_id = NULL:
--     (NULL, '/home')       <- từ dòng 5 và 6
--     (NULL, '/cart')       <- dòng 7
--     (NULL, '/product/1')  <- dòng 16
--   LUẬT: COUNT(DISTINCT a, b, c) bỏ dòng nếu BẤT KỲ cột nào NULL,
--   không cần tất cả cùng NULL. Càng nhiều cột, càng nhiều dòng bị
--   vứt âm thầm. Đây là cái bẫy tệ nhất trong phase này vì nó không
--   để lại dấu vết nào trên màn hình.
--
--   (Để ý: 16 dòng DISTINCT chứ không phải 20 — dòng 1&2 trùng hệt
--    nhau, dòng 12&13 cũng vậy, và (NULL,'/home') xuất hiện 2 lần.)
--
-- BÀI 2.4 — SUM(DISTINCT) ăn tiền:
--   +-----------+---------------+---------+-------------+
--   | tong_that | tong_distinct | tb_that | tb_distinct |
--   |   1500.00 |       1470.00 | 187.500 |     245.000 |
--   +-----------+---------------+---------+-------------+
--   Mất 30 = 25 (Keyboard, trùng giá Mouse) + 5 (Pen, trùng giá
--   Notebook). Hai sản phẩm CÓ THẬT bị bốc hơi khỏi phép tính.
--   AVG lệch còn nặng hơn: 187.5 -> 245 (vì mẫu số tụt từ 8 xuống 6).
--
--   MAX(DISTINCT price) = MAX(price) = 1200. DISTINCT hoàn toàn vô
--   nghĩa với MAX/MIN — giá trị lớn nhất không đổi khi bỏ bản sao.
--
--   Trên orders:  2795.00  ->  2545.00.  Bốc hơi ĐÚNG 250.
--   Thủ phạm: đơn 1 và đơn 12, cùng khách id 1, cùng 250.00, nhưng
--   khác ngày (01/03 và 20/03) và khác trạng thái (paid / refunded).
--   Đây là HAI ĐƠN THẬT, không phải dữ liệu trùng. SUM(DISTINCT) đã
--   xoá mất một khoản doanh thu có thật.
--   => Trùng GIÁ TRỊ không có nghĩa là trùng SỰ KIỆN.
--
-- BÀI 2.5 A/B — báo cáo theo thành phố:
--   +-------------+--------+----------+
--   | city        | so_don | so_khach |
--   +-------------+--------+----------+
--   | Ha Noi      |      4 |        2 |   <- khách 1 và 2
--   | Ho Chi Minh |      4 |        2 |   <- khách 3 và 8
--   | NULL        |      2 |        1 |   <- khách 5 (khách 6 không mua)
--   | Da Nang     |      1 |        1 |
--   | Ha Noi      |      1 |        1 |   <- 'Ha Noi ' có dấu cách!
--   +-------------+--------+----------+
--   Báo cáo này SAI, và sai theo kiểu không ai phát hiện ra: Ha Noi
--   bị tách làm 2 dòng, sếp đọc sẽ tưởng có 2 thị trường. Lỗi từ
--   phase 1 vẫn theo bạn tới tận đây. Chữa: GROUP BY TRIM(c.city).
--
-- BÀI 2.5 C — traffic theo ngày:
--   +------------+----------+----------------+--------------------+
--   | viewed_on  | luot_xem | khach_duy_nhat | so_trang_khac_nhau |
--   +------------+----------+----------------+--------------------+
--   | 2024-03-01 |        5 |              2 |                  2 |
--   | 2024-03-02 |        6 |              2 |                  3 |
--   | 2024-03-03 |        5 |              3 |                  3 |
--   | 2024-03-04 |        2 |              1 |                  2 |
--   | 2024-03-05 |        2 |              2 |                  1 |
--   +------------+----------+----------------+--------------------+
--   Ngày 01/03: 5 lượt = khách 1 (3 lượt) + khách 2 (1) + NULL (1).
--   khach_duy_nhat = 2 vì lượt NULL bị vứt.
--   Chú ý: cột khach_duy_nhat KHÔNG cộng dọc được! 2+2+3+1+2 = 10,
--   nhưng cả tuần chỉ có 8 khách. COUNT(DISTINCT) là hàm KHÔNG CỘNG
--   ĐƯỢC (non-additive) — muốn con số cả tuần thì phải tính lại từ
--   dữ liệu gốc, không được cộng các con số theo ngày.
--   Đây là lỗi kinh điển của mọi dashboard "unique users".
--
-- BÀI 2.6 — GROUP_CONCAT:
--   khách 1: thuong = Electronics,Electronics,Electronics,Home,Home,
--                     Home,Stationery,Stationery,Stationery
--            chi_khac_nhau = Electronics,Home,Stationery
--   Mỗi lần lặp = MỘT DÒNG order_items. Khách 1 có 3 đơn (1, 2, 12),
--   mỗi đơn 3 dòng hàng = 9 dòng, nên mỗi nhóm lặp 3 lần.
--   Cột `chi_khac_nhau` mới là thứ đưa vào báo cáo.
--   (Cẩn thận: GROUP_CONCAT có giới hạn độ dài mặc định 1024 ký tự,
--    quá thì bị CẮT ÂM THẦM. Chỉnh bằng group_concat_max_len.)
--
-- BÀI 2.7 A — lời giải:
--   SELECT COUNT(*) AS so_don,
--          COUNT(DISTINCT customer_id) AS so_khach,
--          COUNT(DISTINCT channel) AS so_kenh
--   FROM orders;
--   -> 12 | 7 | 3      (so_kenh = 3, KHÔNG phải 4: NULL bị vứt)
--
-- BÀI 2.7 B — lời giải:
--   SELECT o.customer_id,
--          COUNT(*)                     AS dong_hang,
--          COUNT(DISTINCT o.id)         AS so_don,
--          COUNT(DISTINCT i.product_id) AS so_san_pham
--   FROM orders o JOIN order_items i ON i.order_id = o.id
--   GROUP BY o.customer_id
--   ORDER BY so_san_pham DESC;
--   +-------------+-----------+--------+-------------+
--   | customer_id | dong_hang | so_don | so_san_pham |
--   +-------------+-----------+--------+-------------+
--   |           1 |         9 |      3 |           6 |
--   |           3 |         6 |      3 |           4 |
--   |           5 |         4 |      2 |           3 |
--   |           4 |         2 |      1 |           2 |
--   |           7 |         2 |      1 |           2 |
--   |           8 |         2 |      1 |           2 |
--   |           2 |         1 |      1 |           1 |
--   +-------------+-----------+--------+-------------+
--   Nhìn khách id 1: COUNT(*) = 9 nhưng khách đó chỉ có 3 ĐƠN.
--   COUNT(*) ở đây đếm DÒNG order_items (số dòng hàng), KHÔNG phải
--   số đơn. Muốn số đơn PHẢI viết COUNT(DISTINCT o.id).
--   Ba con số 9 / 3 / 6 đều đúng — nhưng chúng trả lời BA câu hỏi
--   khác nhau. Đây chính là cầu nối sang phase 3.
--
-- BÀI 2.7 C — lời giải:
--   SELECT category, COUNT(*) AS so_sp, COUNT(DISTINCT price) AS so_gia
--   FROM products GROUP BY category;
--   +-------------+-------+--------+
--   | NULL        |     1 |      1 |
--   | Electronics |     3 |      2 |
--   | Home        |     2 |      2 |
--   | Stationery  |     2 |      1 |
--   +-------------+-------+--------+
--   Stationery: 2 sản phẩm (Notebook, Pen) nhưng chỉ 1 mức giá (5.00).
--   Chú ý GROUP BY VẪN tạo ra nhóm NULL (Gift Card) — trong khi
--   COUNT(DISTINCT category) = 3 lại vứt nó. Cùng một cột, cùng một
--   câu lệnh, hai bộ phận hành xử ngược nhau.
--
-- BÀI 2.7 D — lời giải:
--   SELECT page, COUNT(*) AS luot,
--          COUNT(DISTINCT customer_id) AS khach
--   FROM page_views GROUP BY page ORDER BY luot DESC;
--   +------------+------+-------+
--   | /home      |   11 |     7 |
--   | /cart      |    3 |     2 |
--   | /checkout  |    2 |     2 |
--   | /product/5 |    2 |     1 |
--   | /product/1 |    1 |     0 |   <- 1 lượt xem, 0 khách!
--   | /product/2 |    1 |     1 |
--   +------------+------+-------+
--   '/home' chênh nhiều nhất: 11 lượt / 7 khách.
--   Nhưng dòng đáng sợ nhất là '/product/1': trang CÓ người xem mà
--   báo cáo ghi 0 khách, vì lượt xem duy nhất đó là khách vãng lai
--   (customer_id NULL). COUNT(DISTINCT) trả về 0 chứ không phải NULL
--   khi cả nhóm đều NULL — nên nó trông y như "thật sự không có ai".
--
-- BÀI 2.7 E — lời giải:
--   SELECT COUNT(DISTINCT customer_id, viewed_on) AS cach_1 FROM page_views;
--   SELECT COUNT(*) AS cach_2 FROM
--     (SELECT DISTINCT customer_id, viewed_on FROM page_views) t;
--   -> 10 và 13. Chênh 3 = ba cặp (NULL, ngày) bị COUNT vứt:
--      (NULL,'2024-03-01'), (NULL,'2024-03-02'), (NULL,'2024-03-03').
--
-- BÀI 2.7 F — lời giải:
--   SELECT viewed_on,
--          GROUP_CONCAT(DISTINCT page ORDER BY page SEPARATOR ' | ') AS cac_trang
--   FROM page_views GROUP BY viewed_on ORDER BY viewed_on;
--   -> 2024-03-01 | /home | /product/2
--      2024-03-02 | /cart | /checkout | /home
--      ...
--
-- KẾT LUẬN PHASE 2:
--   1. COUNT(*) đếm DÒNG (NULL vẫn tính). Mọi hàm gộp khác VỨT NULL.
--   2. COUNT(DISTINCT x) và số dòng của SELECT DISTINCT x luôn lệch
--      nhau đúng 1 khi cột có NULL.
--   3. COUNT(DISTINCT a, b) bỏ dòng nếu BẤT KỲ cột nào NULL.
--   4. SUM/AVG(DISTINCT) gần như luôn sai. Trùng GIÁ TRỊ không phải
--      trùng SỰ KIỆN. MAX/MIN(DISTINCT) thì vô nghĩa.
--   5. COUNT(DISTINCT) KHÔNG CỘNG ĐƯỢC theo nhóm. Tổng của các nhóm
--      không bằng con số toàn cục. Đừng bao giờ cộng cột "unique".
-- ============================================================
