-- Active: 1756872756053@@127.0.0.1@3306@distinct_lab
-- ============================================================
-- PHASE 3 — DISTINCT gặp JOIN
-- (Làm phase 1, 2 trước. Nếu chưa học lab `join` thì học trước.)
-- ============================================================
USE distinct_lab;

-- ============================================================
-- KIẾN THỨC NỀN — Nơi 90% chữ DISTINCT trên đời được viết ra
-- ============================================================
-- Trong code thật, rất ít khi người ta viết DISTINCT vì muốn dùng
-- DISTINCT. Kịch bản thật gần như luôn là thế này:
--
--   1. Viết một câu JOIN.
--   2. Kết quả ra nhiều dòng lặp hơn mong đợi.
--   3. Thêm DISTINCT vào. Hết lặp. Xong việc. Đi uống cà phê.
--
-- Bước 3 là chỗ nguy hiểm nhất trong toàn bộ SQL cơ bản, vì:
--
--   DISTINCT KHÔNG SỬA LỖI. NÓ CHỈ GIẤU LỖI ĐI.
--
-- Dòng lặp không phải là bệnh, nó là TRIỆU CHỨNG. Bệnh là: bạn đã
-- JOIN sang một bảng có quan hệ 1-nhiều, nên "một dòng kết quả" không
-- còn nghĩa là "một khách hàng" nữa. DISTINCT xoá triệu chứng và để
-- bệnh nằm nguyên đó.
--
-- Phase này cho bạn thấy hai chuyện, bằng dữ liệu thật:
--   - Có lúc DISTINCT che lỗi mà vẫn ra ĐÚNG (may mắn).
--   - Có lúc DISTINCT che lỗi và ra SAI (bài 3.2) — sai theo cách
--     không ai phát hiện được, vì kết quả trông rất hợp lý.
--
-- Câu hỏi phải tự hỏi TRƯỚC KHI gõ chữ DISTINCT:
--      "MỘT DÒNG trong kết quả này đại diện cho CÁI GÌ?"
-- Trả lời được câu đó thì thường bạn không cần DISTINCT nữa.
-- ============================================================
-- ============================================================
-- BÀI 3.1 — Nhìn thấy dòng NỞ RA
-- ============================================================
-- YÊU CẦU:
-- Chạy 3 câu dưới rồi trả lời:
--   a) Ba con số là bao nhiêu? (8 -> ? -> ?)
--   b) Sau câu 2, "một dòng" đại diện cho cái gì? Sau câu 3?
--   c) Vì sao câu 2 ra ÍT hơn 8 + số đơn? Khách nào biến mất?
--      (nhắc lại: đây là INNER JOIN)
SELECT
    COUNT(*) AS chi_customers
FROM
    customers;

SELECT
    COUNT(*) AS join_orders
FROM
    customers c
    JOIN orders o ON o.customer_id = c.id;

SELECT
    COUNT(*) AS join_them_items
FROM
    customers c
    JOIN orders o ON o.customer_id = c.id
    JOIN order_items i ON i.order_id = o.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 3.2 — BÀI QUAN TRỌNG NHẤT CỦA CẢ LAB
-- ============================================================
-- Câu hỏi nghiệp vụ: "Những khách nào đã từng mua ghế (Chair, id 5)?"
--
-- YÊU CẦU:
-- Chạy 3 câu dưới THEO THỨ TỰ, và ĐỪNG đọc trước kết quả tham chiếu.
--
-- a) Câu 1 (chưa có DISTINCT): ra mấy dòng? Tên nào lặp mấy lần?
--    Mỗi lần lặp tương ứng với cái gì?
--
-- b) Câu 2 (thêm DISTINCT full_name): ra mấy dòng? Trông rất gọn
--    gàng và hợp lý đúng không? Bạn có ký duyệt báo cáo này không?
--
-- c) Câu 3 (DISTINCT id + full_name): ra mấy dòng?
--
-- d) CÂU 2 VÀ CÂU 3 RA SỐ KHÁC NHAU. Một trong hai câu đang trả lời
--    SAI câu hỏi nghiệp vụ. Câu nào sai? Sai ở đâu? Ai bị mất?
--    (mở schema.sql, tìm khách id 1 và id 8)
SELECT
    c.full_name
FROM
    customers c
    JOIN orders o ON o.customer_id = c.id
    JOIN order_items i ON i.order_id = o.id
WHERE
    i.product_id = 5;

SELECT DISTINCT
    c.full_name
FROM
    customers c
    JOIN orders o ON o.customer_id = c.id
    JOIN order_items i ON i.order_id = o.id
WHERE
    i.product_id = 5;

SELECT DISTINCT
    c.id,
    c.full_name
FROM
    customers c
    JOIN orders o ON o.customer_id = c.id
    JOIN order_items i ON i.order_id = o.id
WHERE
    i.product_id = 5;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- GHI NHỚ: DISTINCT trên cột KHÔNG PHẢI KHOÁ là một canh bạc. Nó
--          không phân biệt được "hai dòng lặp do JOIN" với "hai thực
--          thể khác nhau tình cờ trùng giá trị". Luôn để KHOÁ CHÍNH
--          trong danh sách DISTINCT.
-- ============================================================
-- BÀI 3.3 — DISTINCT KHÔNG cứu được SUM
-- ============================================================
-- Câu hỏi: "Tổng doanh thu là bao nhiêu?" Đáp án đúng: 2795.00
-- (bạn đã tính ở phase 2 bằng SUM(amount) trên riêng bảng orders).
--
-- Bây giờ tưởng tượng bạn cần JOIN thêm order_items để lọc gì đó,
-- và quên mất hậu quả.
--
-- YÊU CẦU:
-- a) Chạy 3 câu. Ba con số là bao nhiêu?
-- b) Câu 1 sai vì sao? amount của đơn 1 bị cộng mấy lần? Vì sao đúng
--    số lần đó?
-- c) Câu 2 thêm DISTINCT vào SUM — con số có vẻ "gần đúng" hơn hẳn.
--    Nhưng nó vẫn sai. Thiếu bao nhiêu? Thiếu của ai?
--    (nhắc lại bài 2.4)
-- d) Rút ra: khi SUM bị sai do JOIN, DISTINCT có bao giờ là cách
--    chữa đúng không? Vậy cách chữa đúng là gì?
SELECT
    SUM(o.amount) AS cach_1_khong_distinct
FROM
    orders o
    JOIN order_items i ON i.order_id = o.id;

SELECT
    SUM(DISTINCT o.amount) AS cach_2_sum_distinct
FROM
    orders o
    JOIN order_items i ON i.order_id = o.id;

SELECT
    SUM(amount) AS cach_3_khong_join
FROM
    orders;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- GHI NHỚ: Ba con số, chỉ một đúng. Và con số SAI NGUY HIỂM NHẤT là
--          con số ở giữa — vì nó gần đúng đủ để không ai nghi ngờ.
--          Con số 6190 quá lố, ai cũng thấy sai ngay. Con số 2545 thì
--          lọt qua mọi vòng review.
-- ============================================================
-- BÀI 3.4 — Cách chữa ĐÚNG: EXISTS
-- ============================================================
-- Quay lại câu hỏi bài 3.2: "khách nào đã mua Chair?".
-- Vấn đề gốc: ta JOIN sang order_items chỉ để KIỂM TRA một điều
-- kiện, chứ không cần lấy dữ liệu gì từ đó. Mà JOIN thì nhân dòng.
--
-- EXISTS diễn đạt đúng ý đó: "có tồn tại ít nhất một dòng thoả không?"
-- Nó dừng ngay khi tìm thấy dòng đầu tiên, và KHÔNG nhân dòng —
-- nên không có gì để mà khử trùng.
--
-- YÊU CẦU:
-- a) Chạy 2 câu dưới. Kết quả có giống câu 3 của bài 3.2 không?
-- b) Cả hai câu này có cần DISTINCT không? Vì sao KHÔNG?
-- c) Đọc to câu EXISTS thành tiếng Việt. Nó có giống câu hỏi nghiệp
--    vụ ban đầu hơn câu JOIN + DISTINCT không?
-- d) Vì sao ở đây `IN` an toàn, trong khi lab join dạy rằng NOT IN
--    rất nguy hiểm? (gợi ý: cột customer_id của orders là NOT NULL)
SELECT
    c.id,
    c.full_name
FROM
    customers c
WHERE
    EXISTS (
        SELECT
            1
        FROM
            orders o
            JOIN order_items i ON i.order_id = o.id
        WHERE
            o.customer_id = c.id
            AND i.product_id = 5
    );

SELECT
    c.id,
    c.full_name
FROM
    customers c
WHERE
    c.id IN (
        SELECT
            o.customer_id
        FROM
            orders o
            JOIN order_items i ON i.order_id = o.id
        WHERE
            i.product_id = 5
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 3.5 — DISTINCT thừa trong subquery
-- ============================================================
-- Rất nhiều người viết `IN (SELECT DISTINCT ...)` vì nghĩ rằng như
-- vậy nhanh hơn, hoặc "cho chắc".
--
-- YÊU CẦU:
-- a) Chạy 2 câu. Kết quả có khác nhau không?
-- b) Suy nghĩ: bản thân toán tử IN hỏi cái gì? Nó có quan tâm giá trị
--    xuất hiện 1 lần hay 100 lần trong danh sách không?
-- c) Vậy chữ DISTINCT ở câu 2 mang lại gì? Nó có làm câu lệnh nhanh
--    hơn không? (gợi ý: khử trùng lặp cũng tốn công sắp xếp/băm)
SELECT
    COUNT(*) AS khong_distinct
FROM
    customers
WHERE
    id IN (
        SELECT
            customer_id
        FROM
            orders
    );

SELECT
    COUNT(*) AS co_distinct
FROM
    customers
WHERE
    id IN (
        SELECT DISTINCT
            customer_id
        FROM
            orders
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 3.6 — UNION chính là UNION ALL + DISTINCT
-- ============================================================
-- Đây là chỗ DISTINCT chạy mà bạn KHÔNG hề gõ chữ DISTINCT.
--
-- YÊU CẦU:
-- a) Chạy 3 câu. Số dòng lần lượt là bao nhiêu?
-- b) UNION đã bỏ đi bao nhiêu dòng? Nó khử trùng dựa trên cái gì?
-- c) Nhìn câu 3: trong kết quả có dòng NULL không? Có MẤY dòng NULL,
--    trong khi page_views có 4 dòng customer_id NULL? Điều này khớp
--    với luật nào ở phase 1?
-- d) Rút ra: khi nào nên dùng UNION ALL thay vì UNION?
SELECT
    COUNT(*) AS union_all_dem
FROM
    (
        SELECT
            customer_id
        FROM
            orders
        UNION ALL
        SELECT
            customer_id
        FROM
            page_views
    ) t;

SELECT
    COUNT(*) AS union_dem
FROM
    (
        SELECT
            customer_id
        FROM
            orders
        UNION
        SELECT
            customer_id
        FROM
            page_views
    ) t;

SELECT
    customer_id
FROM
    orders
UNION
SELECT
    customer_id
FROM
    page_views
ORDER BY
    customer_id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- GHI NHỚ: UNION luôn phải khử trùng lặp -> phải sắp xếp hoặc băm
--          TOÀN BỘ kết quả. Với dữ liệu lớn đây là phần đắt nhất câu
--          lệnh. Nếu bạn BIẾT hai nhánh không thể trùng nhau (ví dụ
--          "đơn tháng 1" UNION "đơn tháng 2"), dùng UNION ALL. Mặc
--          định của nhiều người là UNION — mặc định đúng nên là
--          UNION ALL, chỉ dùng UNION khi thật sự cần khử trùng.
-- ============================================================
-- BÀI 3.7 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Liệt kê các sản phẩm ĐÃ TỪNG được bán (có mặt trong order_items),
-- kèm id và tên, sắp theo id. Bảng có 8 sản phẩm — ra mấy dòng?
-- Ai vắng mặt?
-- Viết query của bạn bên dưới:
select DISTINCT p.id, p.name from order_items oi join products p on oi.product_id = p.id ORDER BY p.id;


-- YÊU CẦU B:
-- Làm lại câu A nhưng KHÔNG dùng DISTINCT và KHÔNG dùng JOIN.
-- (gợi ý: EXISTS hoặc IN)
-- Viết query của bạn bên dưới:
select id, name from products p where exists (
    select 1 from order_items oi where oi.product_id = p.id
)


-- YÊU CẦU C:
-- Liệt kê các thành phố ĐÃ CÓ khách đặt hàng. Nhớ bài học phase 1 về
-- dữ liệu bẩn — kết quả không được có 2 dòng "Ha Noi".
-- Viết query của bạn bên dưới:
select distinct lower(trim(city)) from customers c join orders o on c.id = o.customer_id where city is not null;

-- YÊU CẦU D:
-- Tìm những khách đã mua CẢ HAI nhóm 'Electronics' VÀ 'Home'.
-- Cạm bẫy: `WHERE p.category = 'Electronics' AND p.category = 'Home'`
-- luôn ra 0 dòng — vì sao? (một dòng thì category chỉ có một giá trị)
-- Gợi ý: dùng 2 lần EXISTS, hoặc GROUP BY + HAVING COUNT(DISTINCT ...).
-- Viết cả HAI cách:
select c.* from customers c 
WHERE exists (
    select 1 from  orders o
    join order_items oi on o.id = oi.order_id
    join products p on oi.product_id = p.id
    where o.customer_id = c.id and p.category = 'Electronics'
) and EXISTS (
    select 1 from  orders o
    join order_items oi on o.id = oi.order_id
    join products p on oi.product_id = p.id
    where o.customer_id = c.id and p.category = 'Home'
);

-- YÊU CẦU E:
-- Đây là bài bẫy. Chạy câu dưới rồi trả lời: nó ra mấy dòng, và có
-- ĐÚNG là "danh sách tất cả khách hàng kèm việc họ có đơn hay không"
-- không? Nếu bỏ DISTINCT đi thì ra mấy dòng?
SELECT DISTINCT
    c.id,
    c.full_name,
    o.id IS NOT NULL AS co_don
FROM
    customers c
    LEFT JOIN orders o ON o.customer_id = c.id
ORDER BY
    c.id;

-- Trả lời của bạn:


-- YÊU CẦU F:
-- Với mỗi khách hàng, đếm số ĐƠN và số SẢN PHẨM KHÁC NHAU đã mua,
-- nhưng phải giữ đủ CẢ 8 KHÁCH (kể cả khách chưa mua gì, hiện 0).
-- (gợi ý: LEFT JOIN + COUNT(DISTINCT ...), nhắc lại bẫy COUNT(*) ở
--  lab join phase 2)
-- Viết query của bạn bên dưới:
select c.id, c.full_name, count(DISTINCT o.id) as order_num, count(DISTINCT oi.product_id)
from customers c
left join orders o on c.id = o.customer_id
left join order_items oi on o.id = oi.order_id
group by c.id, c.full_name;

-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 3.1 — 8 -> 12 -> 26
--   Sau JOIN orders : 1 dòng = 1 ĐƠN HÀNG (không phải 1 khách).
--   Sau JOIN items  : 1 dòng = 1 DÒNG HÀNG trong 1 đơn.
--   Chỉ 12 dòng chứ không phải 8+12: INNER JOIN nên khách id 6
--   (Vu Van Giang, chưa mua gì) rớt luôn khỏi kết quả.
--   Danh tính của "một dòng" đã đổi HAI LẦN mà không có cảnh báo nào.
--
-- BÀI 3.2 — 7 / 3 / 4 dòng.  ĐÂY LÀ BÀI ĐÁNG NHỚ NHẤT CỦA LAB.
--
--   Câu 1 (7 dòng):
--     Nguyen Van An, Le Minh Cuong, Le Minh Cuong, Hoang Thi Hoa,
--     Hoang Thi Hoa, Nguyen Van An, Nguyen Van An
--     Mỗi dòng = một lần Chair xuất hiện trong một đơn.
--
--   Câu 2 — DISTINCT full_name (3 dòng):
--     Nguyen Van An, Le Minh Cuong, Hoang Thi Hoa
--     Gọn gàng. Hợp lý. VÀ SAI.
--
--   Câu 3 — DISTINCT id, full_name (4 dòng):
--     +----+---------------+
--     |  1 | Nguyen Van An |
--     |  3 | Le Minh Cuong |
--     |  5 | Hoang Thi Hoa |
--     |  8 | Nguyen Van An |   <- người này bị câu 2 XOÁ MẤT
--     +----+---------------+
--
--   Có HAI khách hàng khác nhau cùng tên 'Nguyen Van An' (id 1 ở
--   Ha Noi, id 8 ở Ho Chi Minh). Cả hai đều thật sự đã mua Chair.
--   DISTINCT trên full_name không thể biết điều đó — với nó, hai
--   chuỗi giống nhau là một. Nó gộp hai KHÁCH HÀNG làm một.
--
--   Hậu quả trong đời thật: gửi email marketing thiếu 1 người, tính
--   sai số khách mua hàng, báo cáo giao cho sếp bị lệch. Và không có
--   lỗi nào, không có cảnh báo nào — kết quả trông hoàn hảo.
--
--   LUẬT: nếu danh sách DISTINCT không chứa KHOÁ CHÍNH của thực thể
--   bạn đang đếm, bạn đang đánh cược rằng dữ liệu không có trùng tên.
--   Trong 8 dòng dữ liệu đồ chơi đã có trùng rồi. Dữ liệu thật thì sao?
--
-- BÀI 3.3 — 6190.00 / 2545.00 / 2795.00
--   Câu 1 = 6190: amount của mỗi đơn bị cộng đúng bằng SỐ DÒNG HÀNG
--   của đơn đó. Đơn 1 có 3 dòng hàng -> 250 cộng 3 lần = 750.
--   Đây là fan-out, đã học ở lab join phase 4.
--
--   Câu 2 = 2545: DISTINCT gom mọi amount bằng nhau lại còn một.
--   Đơn 1 và đơn 12 đều 250.00 -> mất đúng 250. Con số này gần đúng
--   tới mức nguy hiểm: lệch 8.9%, không ai để ý.
--
--   Câu 3 = 2795: ĐÚNG. Vì không JOIN thì không nở dòng.
--
--   Cách chữa đúng khi bắt buộc phải JOIN: gộp trước rồi mới JOIN,
--   hoặc dùng subquery:
--     SELECT SUM(amount) FROM orders o
--     WHERE EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.id);
--   -> vẫn 2795.00, mà vẫn lọc được theo order_items.
--   Nguyên tắc: ĐỪNG BAO GIỜ SUM một cột thuộc bảng "một" sau khi đã
--   JOIN sang bảng "nhiều". DISTINCT không cứu được, chỉ đổi kiểu sai.
--
-- BÀI 3.4 — cả 2 câu ra ĐÚNG 4 dòng, giống hệt câu 3 bài 3.2:
--   id 1, 3, 5, 8.
--   Không cần DISTINCT, vì không có gì bị nhân lên: EXISTS chỉ trả
--   lời CÓ/KHÔNG cho từng dòng customers, mỗi khách vẫn đúng 1 dòng.
--   Đọc thành tiếng Việt: "lấy khách nào MÀ TỒN TẠI một đơn của khách
--   đó có chứa sản phẩm 5" — đúng y hệt câu hỏi nghiệp vụ.
--
--   `IN` ở đây an toàn vì orders.customer_id là NOT NULL. Với NOT IN
--   thì chỉ một NULL trong danh sách con là trả về RỖNG (xem lab join
--   phase 4). Thói quen tốt: dùng EXISTS / NOT EXISTS cho mọi trường
--   hợp, khỏi phải nhớ cột nào NULL được cột nào không.
--
-- BÀI 3.5 — cả 2 câu đều ra 7. Giống hệt nhau.
--   IN chỉ hỏi "giá trị này có nằm trong danh sách không?" — có mặt
--   1 lần hay 100 lần thì câu trả lời vẫn thế. DISTINCT trong subquery
--   IN/EXISTS là THỪA về mặt kết quả.
--   Về tốc độ nó cũng không giúp: bộ tối ưu đã tự xử lý phần khử
--   trùng theo cách của nó. Thêm DISTINCT có khi còn bắt MySQL sắp
--   xếp thêm một lần vô ích. Viết thừa chữ nào là tốn chữ đó.
--
-- BÀI 3.6 — 32 / 9 / 9 dòng
--   UNION ALL: 12 (orders) + 20 (page_views) = 32, giữ nguyên hết.
--   UNION    : 9. Bỏ 23 dòng, khử trùng trên TOÀN BỘ danh sách cột.
--   Kết quả câu 3: NULL, 1, 2, 3, 4, 5, 6, 7, 8
--   page_views có 4 dòng NULL, kết quả chỉ còn ĐÚNG MỘT dòng NULL —
--   y hệt luật ở phase 1 bài 1.3. UNION dùng chung cỗ máy khử trùng
--   với DISTINCT, nên mọi luật của DISTINCT đều áp dụng cho UNION.
--
--   (Để ý khách id 6 xuất hiện ở đây: không có đơn nào, nhưng có
--    xem web. UNION lấy hợp của hai tập.)
--
-- BÀI 3.7 A — 6 dòng: Mouse, Keyboard, Desk Lamp, Chair, Notebook, Pen
--   SELECT DISTINCT p.id, p.name
--   FROM products p JOIN order_items i ON i.product_id = p.id
--   ORDER BY p.id;
--   Vắng: Laptop Pro (id 1) và Gift Card (id 8) — chưa ai mua.
--   Ở đây DISTINCT ĐÚNG vì danh sách có chứa p.id (khoá chính).
--
-- BÀI 3.7 B — lời giải (cách nên dùng):
--   SELECT p.id, p.name FROM products p
--   WHERE EXISTS (SELECT 1 FROM order_items i WHERE i.product_id = p.id)
--   ORDER BY p.id;
--   -> cùng 6 dòng, không cần DISTINCT, và diễn đạt đúng ý hơn.
--
-- BÀI 3.7 C — lời giải:
--   SELECT DISTINCT TRIM(c.city) AS city
--   FROM customers c JOIN orders o ON o.customer_id = c.id;
--   -> Ha Noi, Ho Chi Minh, Da Nang, NULL  (4 dòng)
--   Không có TRIM thì ra 5 dòng với 2 dòng 'Ha Noi'. Dòng NULL là
--   khách id 5 (Hoang Thi Hoa) — có mua hàng nhưng chưa điền thành phố.
--
-- BÀI 3.7 D — cả hai cách đều ra id 1, 3, 5, 8:
--   Cách 1 (hai EXISTS):
--     SELECT c.id, c.full_name FROM customers c
--     WHERE EXISTS (SELECT 1 FROM orders o
--                   JOIN order_items i ON i.order_id = o.id
--                   JOIN products p ON p.id = i.product_id
--                   WHERE o.customer_id = c.id AND p.category = 'Electronics')
--       AND EXISTS (SELECT 1 FROM orders o
--                   JOIN order_items i ON i.order_id = o.id
--                   JOIN products p ON p.id = i.product_id
--                   WHERE o.customer_id = c.id AND p.category = 'Home');
--
--   Cách 2 (gọn hơn, dùng COUNT(DISTINCT) trong HAVING):
--     SELECT c.id, c.full_name FROM customers c
--     JOIN orders o ON o.customer_id = c.id
--     JOIN order_items i ON i.order_id = o.id
--     JOIN products p ON p.id = i.product_id
--     WHERE p.category IN ('Electronics','Home')
--     GROUP BY c.id, c.full_name
--     HAVING COUNT(DISTINCT p.category) = 2;
--
--   Vì sao `category='Electronics' AND category='Home'` luôn rỗng:
--   điều kiện WHERE xét TỪNG DÒNG một. Trong một dòng, category chỉ
--   có đúng một giá trị, không thể vừa là cái này vừa là cái kia.
--   Điều kiện "cả hai" là điều kiện trên NHÓM, nên phải xử lý bằng
--   HAVING hoặc bằng nhiều EXISTS. Đây là chỗ COUNT(DISTINCT) toả
--   sáng: "nhóm này chạm được mấy giá trị khác nhau?".
--
-- BÀI 3.7 E — 8 dòng có DISTINCT, 13 dòng nếu bỏ DISTINCT.
--   Có DISTINCT thì kết quả TRÔNG đúng: 8 khách, khách id 6 co_don=0.
--   Nhưng nó chỉ đúng NHỜ MAY MẮN: cột co_don của mọi đơn cùng một
--   khách đều bằng 1 nên các dòng lặp giống hệt nhau và bị gộp lại.
--   Đổi `o.id IS NOT NULL` thành `o.amount` là hỏng ngay — khách 1
--   sẽ ra 2 dòng (250 và 120), vì các dòng lặp không còn giống nhau.
--   DISTINCT ở đây là băng dán dán trúng chỗ. Cách viết đúng là
--   LEFT JOIN + GROUP BY (câu F), hoặc EXISTS.
--
-- BÀI 3.7 F — lời giải:
--   SELECT c.id, c.full_name,
--          COUNT(DISTINCT o.id)         AS so_don,
--          COUNT(DISTINCT i.product_id) AS so_san_pham
--   FROM customers c
--   LEFT JOIN orders o      ON o.customer_id = c.id
--   LEFT JOIN order_items i ON i.order_id = o.id
--   GROUP BY c.id, c.full_name
--   ORDER BY c.id;
--   -> 8 dòng, khách id 6 ra 0 và 0.
--   Phải là COUNT(DISTINCT o.id), KHÔNG được COUNT(*): COUNT(*) sẽ
--   đếm dòng NULL do LEFT JOIN bịa ra thành 1 (lab join, bài 2.6),
--   và với các khách khác thì nó đếm dòng hàng chứ không đếm đơn.
--   Một câu lệnh, hai cái bẫy cũ cùng lúc.
--
-- KẾT LUẬN PHASE 3:
--   1. Thấy dòng lặp sau JOIN -> hỏi "một dòng này là cái gì?" TRƯỚC,
--      đừng gõ DISTINCT ngay. Dòng lặp là triệu chứng, không phải bệnh.
--   2. DISTINCT thiếu KHOÁ CHÍNH có thể gộp nhầm hai thực thể khác
--      nhau (bài 3.2). Sai mà không ai phát hiện được.
--   3. SUM/AVG sai do JOIN thì DISTINCT không chữa được — nó chỉ đổi
--      từ kiểu sai này sang kiểu sai khác, và kiểu sau khó phát hiện hơn.
--   4. Chỉ cần KIỂM TRA điều kiện, không cần lấy dữ liệu -> EXISTS.
--      Không nhân dòng thì không cần khử trùng.
--   5. DISTINCT trong subquery IN/EXISTS luôn là chữ thừa.
--   6. UNION = UNION ALL + DISTINCT. Không cần khử trùng thì dùng
--      UNION ALL.
-- ============================================================
