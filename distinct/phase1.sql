-- Active: 1778116211273@@127.0.0.1@3306@distinct_lab
-- ============================================================
-- PHASE 1 — DISTINCT thực chất làm gì
-- (Chạy schema.sql trước)
-- ============================================================
USE distinct_lab;

-- ============================================================
-- KIẾN THỨC NỀN — DISTINCT là gì?
-- ============================================================
-- Định nghĩa đủ dùng cho cả đời:
--
--   DISTINCT xoá các dòng TRÙNG NHAU trong KẾT QUẢ,
--   dựa trên TOÀN BỘ danh sách cột bạn viết sau SELECT.
--
-- Ba chữ quan trọng nhất trong câu trên: "TOÀN BỘ DANH SÁCH CỘT".
-- Gần như mọi hiểu lầm về DISTINCT đều là quên mất ba chữ này.
--
-- VỊ TRÍ TRONG THỨ TỰ THỰC THI:
--
--   FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT
--                                                    -> ORDER BY -> LIMIT
--
-- Nhớ 2 hệ quả:
--   1. DISTINCT chạy SAU SELECT -> nó chỉ nhìn thấy những cột đã
--      được chọn. Cột không có trong SELECT thì với DISTINCT là
--      KHÔNG TỒN TẠI.
--   2. DISTINCT chạy TRƯỚC ORDER BY và LIMIT -> khử trùng xong mới
--      sắp xếp, sắp xếp xong mới cắt. `LIMIT 10` sau DISTINCT là
--      "10 giá trị khác nhau", không phải "10 dòng đầu".
--
-- CÚ PHÁP:
--      SELECT DISTINCT cot_a, cot_b FROM bang;
--
--   DISTINCT đứng NGAY SAU SELECT, và chỉ được viết MỘT LẦN.
--   Không có chuyện "distinct riêng cột này thôi".
-- ============================================================
-- ============================================================
-- BÀI 1.1 — Nhìn thấy vấn đề trước khi học cách chữa
-- ============================================================
-- YÊU CẦU:
-- Chạy 2 câu dưới. Câu đầu là dữ liệu thô, câu sau thêm DISTINCT.
-- Rồi trả lời:
--   a) Câu 1 ra mấy dòng? Câu 2 ra mấy dòng?
--   b) Nhìn bằng MẮT: theo bạn thực sự có bao nhiêu thành phố
--      trong bảng customers? Con số của bạn có bằng câu 2 không?
--   c) Nếu lệch — hãy đoán xem MySQL "không đồng ý" với bạn ở
--      những dòng nào.
SELECT
    city
FROM
    customers
ORDER BY
    id;

SELECT DISTINCT
    city
FROM
    customers;

-- Trả lời của bạn:
-- a) 8 - 5
-- b)
-- c)
-- ============================================================
-- BÀI 1.2 — DISTINCT áp lên TOÀN BỘ danh sách cột
-- ============================================================
-- Đây là bài quan trọng nhất phase 1. Đọc chậm.
--
-- YÊU CẦU:
-- Chạy lần lượt 3 câu dưới rồi trả lời:
--   a) Mỗi câu ra mấy dòng?
--   b) Bảng có 8 khách. Vì sao DISTINCT full_name lại ra ÍT hơn 8?
--      (xem lại schema.sql — ai trùng tên ai?)
--   c) Vì sao thêm cột city vào thì lại ra ĐỦ 8 dòng?
--   d) Rút ra quy tắc: thêm cột vào SELECT DISTINCT thì số dòng
--      TĂNG hay GIẢM? Vì sao không bao giờ ngược lại?
SELECT DISTINCT
    full_name
FROM
    customers;

SELECT DISTINCT
    full_name,
    city
FROM
    customers;

SELECT DISTINCT
    city
FROM
    customers;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ------------------------------------------------------------
-- BÀI 1.2b — DISTINCT KHÔNG PHẢI LÀ HÀM
-- ------------------------------------------------------------
-- Cú pháp dưới đây trông như gọi hàm `DISTINCT(city)`. Rất nhiều
-- người viết vậy và tin rằng "chỉ distinct cột city thôi".
--
-- YÊU CẦU:
-- a) Trước khi chạy, ĐOÁN: câu này ra mấy dòng?
-- b) Chạy. Đúng như bạn đoán không?
-- c) So với `SELECT DISTINCT city FROM customers` (5 dòng) — vì sao khác?
-- d) Vậy cặp ngoặc kia có tác dụng gì?
SELECT DISTINCT
    (city),
    country
FROM
    customers;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 1.3 — DISTINCT và NULL
-- ============================================================
-- Nhắc lại từ lab JOIN: NULL không BẰNG bất cứ thứ gì, kể cả NULL.
-- Vậy hai dòng NULL có bị coi là trùng nhau không?
--
-- YÊU CẦU:
-- Bảng customers có 2 khách city = NULL (id 5 và 6).
-- a) Chạy câu 1: trong kết quả có mấy dòng NULL?
-- b) Chạy câu 2 (đếm số dòng của câu 1) và câu 3 (COUNT DISTINCT).
--    Hai số này CHÊNH NHAU. Chênh mấy? Vì sao?
-- c) Kết luận: DISTINCT coi NULL là "một giá trị" hay "không có giá trị"?
--    Còn COUNT(DISTINCT ...) thì sao?
SELECT DISTINCT
    city
FROM
    customers;

SELECT
    COUNT(*) AS so_dong_distinct
FROM
    (
        SELECT DISTINCT
            city
        FROM
            customers
    ) t;

SELECT
    COUNT(DISTINCT city) AS count_distinct_city
FROM
    customers;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- GHI NHỚ: DISTINCT gom mọi NULL thành ĐÚNG MỘT dòng (nó dùng luật
--          "not distinct from", không dùng dấu "="). Nhưng mọi hàm
--          gộp — kể cả COUNT(DISTINCT) — đều VỨT NULL trước khi làm
--          việc. Hai bên hành xử khác nhau trên cùng một dữ liệu.
-- ============================================================
-- BÀI 1.4 — Bẫy lớn nhất: "trùng" theo MySQL ≠ "trùng" theo mắt bạn
-- ============================================================
-- Ở bài 1.1 bạn đếm bằng mắt được 3 thành phố (Ha Noi, Ho Chi Minh,
-- Da Nang) nhưng MySQL ra 5 dòng. Giờ mổ xẻ chỗ lệch.
--
-- YÊU CẦU:
-- a) Chạy câu 1. Nhìn cột `len`: có 2 dòng cùng hiện chữ "Ha Noi"
--    nhưng độ dài khác nhau. Chuyện gì đã xảy ra?
-- b) Trong 8 khách, ai viết 'ha noi' chữ thường (id 2)? Vì sao khách
--    đó KHÔNG tạo ra dòng thứ 3 "ha noi" trong kết quả?
-- c) Chạy câu 2 — cùng một cột, 4 cách hỏi, 4 con số. Giải thích
--    từng con số. (gợi ý: mỗi collation trả lời khác nhau cho 2 câu
--    hỏi: "HOA có bằng thường không?" và "dấu cách cuối có tính không?")
-- d) Chạy câu 3. Muốn có đáp án "3 thành phố" như mắt người, phải làm gì?
SELECT DISTINCT
    city,
    LENGTH(city) AS len
FROM
    customers;

SELECT
    COUNT(DISTINCT city)                            AS mac_dinh,
    COUNT(DISTINCT city COLLATE utf8mb4_general_ci) AS general_ci,
    COUNT(DISTINCT city COLLATE utf8mb4_bin)        AS bin_coll,
    COUNT(DISTINCT BINARY city)                     AS nhi_phan
FROM
    customers;

SELECT DISTINCT
    TRIM(city) AS city_sach
FROM
    customers;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- GHI NHỚ: DISTINCT không có định nghĩa "trùng nhau" của riêng nó.
--          Nó đi mượn định nghĩa của COLLATION. Đổi collation là đổi
--          kết quả, dù dữ liệu không đổi một byte nào.
-- ============================================================
-- BÀI 1.5 — DISTINCT vs GROUP BY
-- ============================================================
-- YÊU CẦU:
-- a) Chạy 2 câu dưới. Kết quả có giống hệt nhau không?
-- b) Nếu giống — vì sao ngôn ngữ lại cần cả hai?
--    Thử viết câu thứ 3: "mỗi thành phố có bao nhiêu khách".
--    Bạn làm được bằng DISTINCT không?
-- c) Rút ra: khi nào dùng DISTINCT, khi nào dùng GROUP BY?
SELECT DISTINCT
    city
FROM
    customers;

SELECT
    city
FROM
    customers
GROUP BY
    city;

-- Viết câu c) của bạn bên dưới:


-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- GHI NHỚ: DISTINCT = "cho tôi danh sách các giá trị khác nhau".
--          GROUP BY = "gom thành nhóm để TÍNH TOÁN trên từng nhóm".
--          Cần con số kèm theo (đếm, tổng, trung bình) -> GROUP BY.
--          Chỉ cần danh sách -> DISTINCT, vì đọc rõ ý hơn.
-- ============================================================
-- BÀI 1.6 — DISTINCT + ORDER BY: một lỗi bạn CHẮC CHẮN sẽ gặp
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu 1 (không có DISTINCT) — chạy được bình thường.
-- b) Chạy câu 2 (thêm DISTINCT) — MySQL báo lỗi. Chép mã lỗi ra đây.
-- c) Giải thích vì sao câu 2 KHÔNG THỂ chạy được, kể cả nếu MySQL
--    muốn chiều bạn. (gợi ý: kết quả có 5 dòng city; 'Ha Noi' được
--    gom từ khách id 1 và id 2, hai người có signup_on khác nhau.
--    Vậy dòng 'Ha Noi' phải sắp theo ngày NÀO?)
-- d) Chạy câu 3 — hợp lệ. Nhìn thứ tự: NULL nằm ở đâu? 'Ha Noi' và
--    'Ha Noi ' nằm cạnh nhau — điều đó nói lên gì về ORDER BY?
SELECT
    city
FROM
    customers
ORDER BY
    signup_on;

SELECT DISTINCT
    city
FROM
    customers
ORDER BY
    signup_on;

SELECT DISTINCT
    city
FROM
    customers
ORDER BY
    city;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 1.7 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Liệt kê các trạng thái đơn hàng khác nhau (orders.status).
-- Đoán trước số dòng, rồi chạy để kiểm tra.
-- Viết query của bạn bên dưới:
select DISTINCT status from orders;

-- Đoán: ...   Thực tế: ...

-- YÊU CẦU B:
-- Liệt kê các kênh bán hàng khác nhau (orders.channel).
-- Có 12 đơn. Kết quả ra mấy dòng? Trong đó có dòng nào đặc biệt không?
-- Viết query của bạn bên dưới:
select DISTINCT channel from orders;

-- YÊU CẦU C:
-- Liệt kê id các khách hàng ĐÃ TỪNG đặt hàng, sắp xếp tăng dần.
-- Bảng customers có 8 khách. Kết quả ra mấy dòng? Ai vắng mặt?
-- Viết query của bạn bên dưới:
select DISTINCT customer_id from orders;

-- YÊU CẦU D:
-- Liệt kê các nhóm sản phẩm (products.category).
-- Sau đó đếm bằng COUNT(DISTINCT category).
-- Hai con số này KHÁC NHAU. Giải thích tại sao (nhắc lại bài 1.3).
-- Viết query của bạn bên dưới:
select count(*) from (select DISTINCT category from products) as x;
select count(DISTINCT category) from products;

-- YÊU CẦU E:
-- Liệt kê các CẶP (status, channel) khác nhau đã từng xuất hiện.
-- Trước khi chạy, hãy đoán: kết quả nhiều hơn hay ít hơn
-- (số status khác nhau) x (số channel khác nhau)? Vì sao?
-- Viết query của bạn bên dưới:
select DISTINCT status, channel from orders;

-- Đoán: ...   Thực tế: ...

-- YÊU CẦU F:
-- Cho ra danh sách thành phố "SẠCH": không phân biệt hoa thường,
-- không dính dấu cách thừa, viết HOA hết. Kết quả phải ra 4 dòng
-- (3 thành phố + NULL).
-- Viết query của bạn bên dưới:
select DISTINCT upper(trim(city)) from customers;

-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45,
-- collation mặc định utf8mb4_0900_ai_ci)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 1.1 — thô 8 dòng, DISTINCT 5 dòng:
--   +-------------+
--   | Ha Noi      |   <- gom id 1 và id 2 ('ha noi' chữ thường)
--   | Ho Chi Minh |   <- gom id 3 và id 8
--   | Da Nang     |
--   | NULL        |   <- gom id 5 và id 6, chỉ ra MỘT dòng
--   | Ha Noi      |   <- id 7, thực ra là 'Ha Noi ' CÓ DẤU CÁCH CUỐI
--   +-------------+
--   Mắt người đếm 3 thành phố. MySQL nói 5. Cả hai đều "đúng" —
--   chỉ là đang dùng hai định nghĩa "trùng nhau" khác nhau.
--   Dòng cuối là loại bug tệ nhất: nhìn màn hình KHÔNG THỂ phân biệt.
--
-- BÀI 1.2 — 7 / 8 / 5 dòng
--   DISTINCT full_name       = 7  (id 1 và id 8 đều tên 'Nguyen Van An')
--   DISTINCT full_name, city = 8  (hai An khác thành phố -> tách ra)
--   DISTINCT city            = 5
--   => THÊM CỘT thì số dòng chỉ có thể TĂNG hoặc GIỮ NGUYÊN, không
--      bao giờ giảm. Vì thêm cột = thêm cơ hội để hai dòng KHÁC nhau.
--      Muốn ít dòng hơn thì bỏ bớt cột, không phải thêm.
--
-- BÀI 1.2b — `SELECT DISTINCT (city), country` ra 6 dòng:
--   +-------------+---------+
--   | Ha Noi      | VN      |
--   | Ho Chi Minh | VN      |
--   | Da Nang     | VN      |
--   | NULL        | VN      |   <- id 5
--   | NULL        | JP      |   <- id 6  (2 dòng NULL, KHÔNG gom nữa!)
--   | Ha Noi      | VN      |
--   +-------------+---------+
--   DISTINCT là TỪ KHOÁ, không phải hàm. Cặp ngoặc chỉ là ngoặc toán
--   học bọc quanh tên cột — MySQL bỏ qua nó hoàn toàn. Câu này y hệt
--   `SELECT DISTINCT city, country`, tức distinct trên CẢ HAI cột.
--   Đừng bao giờ viết DISTINCT(...) — nó lừa chính người viết.
--
-- BÀI 1.3 — 5 và 4.
--   Kết quả DISTINCT có ĐÚNG MỘT dòng NULL (dù có 2 khách NULL).
--   COUNT(DISTINCT city) = 4 vì hàm gộp VỨT NULL đi trước khi đếm.
--   Chênh lệch luôn đúng bằng 1 nếu cột có NULL, bằng 0 nếu không.
--   => "Có bao nhiêu thành phố?" và "COUNT(DISTINCT city)" là HAI
--      câu hỏi khác nhau. Rất nhiều báo cáo sai chỉ vì chỗ này.
--
-- BÀI 1.4 — cùng 1 cột, 4 con số:
--   +----------+------------+----------+----------+
--   | mac_dinh | general_ci | bin_coll | nhi_phan |
--   |        4 |          3 |        4 |        5 |
--   +----------+------------+----------+----------+
--   Mỗi collation trả lời 2 câu hỏi độc lập:
--                        HOA=thường?   dấu cách cuối tính?
--     utf8mb4_0900_ai_ci    CÓ bằng      CÓ tính (NO PAD)   -> 4
--     utf8mb4_general_ci    CÓ bằng      KHÔNG (PAD SPACE)  -> 3
--     utf8mb4_bin           KHÔNG bằng   KHÔNG (PAD SPACE)  -> 4
--     BINARY (chuỗi byte)   KHÔNG bằng   CÓ tính            -> 5
--   Chú ý hai số 4 giống nhau nhưng vì LÝ DO NGƯỢC NHAU:
--     0900_ai_ci gom {Ha Noi, ha noi} nhưng tách 'Ha Noi ' ra;
--     utf8mb4_bin gom {Ha Noi, 'Ha Noi '} nhưng tách 'ha noi' ra.
--   Số giống nhau KHÔNG có nghĩa là hiểu giống nhau.
--
--   LENGTH cho thấy tang chứng: 'Ha Noi' = 6 byte, 'Ha Noi ' = 7 byte.
--
--   TRIM(city) -> 4 dòng (Ha Noi / Ho Chi Minh / Da Nang / NULL).
--   Muốn "3 thành phố" đúng như mắt người thì phải làm SẠCH dữ liệu
--   (TRIM, UPPER), chứ DISTINCT không tự đoán ý bạn.
--
--   ĐIỀU QUAN TRỌNG NHẤT: nếu phải bọc hàm quanh cột (TRIM, UPPER,
--   LOWER) mới ra đúng, thì dữ liệu của bạn đang bẩn. Sửa lúc GHI
--   (thêm ràng buộc, chuẩn hoá khi INSERT) tốt hơn sửa lúc ĐỌC —
--   sửa lúc đọc còn làm MySQL không dùng được index (xem lab indexing).
--
-- BÀI 1.5 — hai câu ra kết quả GIỐNG HỆT (5 dòng, cùng thứ tự).
--   Về mặt kết quả, `SELECT DISTINCT a` ≡ `SELECT a ... GROUP BY a`.
--   Nhưng GROUP BY làm được thứ DISTINCT KHÔNG bao giờ làm được:
--     SELECT city, COUNT(*) AS so_khach
--     FROM customers GROUP BY city;
--   DISTINCT chỉ biết XOÁ dòng, không biết TÍNH TOÁN trên nhóm.
--   Chọn cái nào? Chọn cái nói đúng Ý ĐỊNH của bạn cho người đọc sau.
--
-- BÀI 1.6 — câu 2 báo lỗi:
--   ERROR 3065 (HY000): Expression #1 of ORDER BY clause is not in
--   SELECT list, references column 'distinct_lab.customers.signup_on'
--   which is not in SELECT list; this is incompatible with DISTINCT
--
--   Đây KHÔNG phải MySQL khó tính. Nó thật sự vô nghĩa: dòng 'Ha Noi'
--   trong kết quả được gom từ khách id 1 (2023-01-05) và id 2
--   (2023-02-11). Sắp xếp nó theo ngày nào? Câu hỏi không có đáp án,
--   nên câu lệnh bị từ chối. Lỗi này là bạn của bạn.
--
--   Quy tắc: sau DISTINCT, ORDER BY chỉ được dùng cột CÓ TRONG SELECT.
--   Cần sắp theo signup_on -> phải đưa signup_on vào SELECT, mà làm
--   vậy thì DISTINCT lại tách hết ra 8 dòng. Muốn "thành phố sắp theo
--   ngày đăng ký sớm nhất" thì đó là bài của GROUP BY:
--     SELECT city, MIN(signup_on) AS lan_dau
--     FROM customers GROUP BY city ORDER BY lan_dau;
--
--   Câu 3 (ORDER BY city) chạy được, thứ tự:
--     NULL, Da Nang, Ha Noi, Ha Noi , Ho Chi Minh
--   NULL xếp ĐẦU khi ASC. 'Ha Noi' và 'Ha Noi ' đứng cạnh nhau —
--   ORDER BY cũng dùng chính collation đó, nên nó coi hai giá trị
--   này gần như bằng nhau, chỉ khác ở byte thừa.
--
-- BÀI 1.7 A — 4 dòng: paid, pending, cancelled, refunded
--   SELECT DISTINCT status FROM orders;
--
-- BÀI 1.7 B — 4 dòng: web, app, store, NULL
--   Dòng NULL là đơn số 8 (chưa ghi nhận kênh). Nếu ai đó hỏi
--   "công ty bán qua mấy kênh?" thì đáp án là 3, không phải 4.
--   Số dòng của DISTINCT ≠ số kênh có thật.
--
-- BÀI 1.7 C — 7 dòng: 1, 2, 3, 4, 5, 7, 8
--   SELECT DISTINCT customer_id FROM orders ORDER BY customer_id;
--   Vắng mặt: khách id 6 (Vu Van Giang) — có xem web (page_views)
--   nhưng chưa mua gì. Nhớ nhân vật này, phase 3 sẽ dùng lại.
--
-- BÀI 1.7 D — DISTINCT category ra 4 dòng
--   (Electronics, Home, Stationery, NULL)
--   nhưng COUNT(DISTINCT category) = 3.
--   NULL là 'Gift Card' (id 8) — sản phẩm chưa xếp nhóm.
--
-- BÀI 1.7 E — 7 dòng:
--   +-----------+---------+
--   | cancelled | app     |
--   | paid      | app     |
--   | paid      | store   |
--   | paid      | web     |
--   | pending   | NULL    |
--   | pending   | web     |
--   | refunded  | web     |
--   +-----------+---------+
--   4 status x 4 channel = 16 tổ hợp CÓ THỂ có, thực tế chỉ 7 tổ hợp
--   ĐÃ TỪNG xảy ra. DISTINCT nhiều cột luôn cho bạn tổ hợp CÓ THẬT
--   trong dữ liệu, không phải mọi tổ hợp về lý thuyết. Muốn đủ 16
--   (kể cả tổ hợp 0 đơn) thì phải CROSS JOIN — xem lab join.
--
-- BÀI 1.7 F — lời giải:
--   SELECT DISTINCT UPPER(TRIM(city)) AS city FROM customers;
--   -> HA NOI, HO CHI MINH, DA NANG, NULL  (4 dòng)
--   Chú ý TRIM/UPPER không đụng gì tới NULL: NULL vào thì NULL ra.
--
-- KẾT LUẬN PHASE 1:
--   1. DISTINCT áp lên TOÀN BỘ danh sách cột sau SELECT. Thêm cột ->
--      số dòng chỉ tăng, không bao giờ giảm.
--   2. DISTINCT không phải hàm. `DISTINCT(a), b` = `DISTINCT a, b`.
--   3. DISTINCT gom mọi NULL thành MỘT dòng.
--      COUNT(DISTINCT) thì VỨT NULL đi. Luôn lệch nhau 1.
--   4. "Trùng nhau" do COLLATION quyết định, không phải do DISTINCT.
--      Hoa/thường và dấu cách cuối là hai chỗ hay cắn nhất.
--   5. Sau DISTINCT, ORDER BY chỉ dùng được cột có trong SELECT.
--      Muốn sắp theo cột khác -> đó là việc của GROUP BY.
-- ============================================================
