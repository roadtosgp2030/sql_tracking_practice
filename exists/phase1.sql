-- Active: 1756872756053@@127.0.0.1@3306@exists_lab
-- ============================================================
-- PHASE 1 — EXISTS thực chất làm gì
-- (Chạy schema.sql trước)
-- ============================================================
USE exists_lab;

-- ============================================================
-- KIẾN THỨC NỀN — EXISTS là gì?
-- ============================================================
-- Định nghĩa đủ dùng cho cả đời:
--
--   EXISTS (subquery) trả về TRUE nếu subquery có ÍT NHẤT MỘT DÒNG,
--   FALSE nếu subquery RỖNG. Chấm hết.
--
-- Chữ quan trọng nhất: EXISTS không đọc GIÁ TRỊ subquery trả ra. Nó chỉ
-- đếm xem có dòng nào không. `SELECT 1`, `SELECT *`, `SELECT NULL`,
-- `SELECT cot_khong_lien_quan` bên trong EXISTS đều CHO KẾT QUẢ GIỐNG
-- HỆT NHAU, vì MySQL không bao giờ nhìn vào danh sách cột đó.
--
-- CORRELATED SUBQUERY — khái niệm bắt buộc phải hiểu trước khi đi tiếp:
-- Subquery bên trong EXISTS thường THAM CHIẾU tới cột của dòng NGOÀI
-- (outer row). Với mỗi dòng ngoài, MySQL "hỏi lại" subquery một lần
-- (về mặt khái niệm — phase 4 sẽ cho thấy MySQL thường tối ưu hoá việc
-- này chứ không hỏi lại ngu ngơ từng dòng một).
--
--   SELECT s.id FROM students s
--   WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.id)
--                                                              ^^^^
--                                              đây là chỗ NGOÀI chui vào TRONG
--
-- Không có `e.student_id = s.id` thì subquery không còn liên quan gì
-- tới từng sinh viên nữa — nó trở thành "có ai đăng ký môn nào không"
-- (một câu TRUE/FALSE DUY NHẤT cho MỌI dòng), không phải điều bạn muốn.
--
-- EXISTS QUAN TRỌNG NHẤT VÌ: nó không bao giờ NHÂN DÒNG như JOIN, và nó
-- không có khái niệm "giá trị NULL gây lỗi" như IN. Hai bài học đó là
-- nội dung của phase 2 và phase 3. Phase này chỉ học cơ chế.
-- ============================================================
-- ============================================================
-- BÀI 1.1 — SELECT 1, SELECT *, hay SELECT NULL: không quan trọng
-- ============================================================
-- YÊU CẦU:
-- Chạy cả 3 câu dưới rồi trả lời:
--   a) Ba câu ra CÙNG một kết quả không? Mấy dòng?
--   b) Vì sao MySQL không báo lỗi ở câu 3, dù `SELECT NULL` "không lấy
--      cột nào từ bảng enrollments" cả?
--   c) Từ nay bạn sẽ viết EXISTS (SELECT ... hay EXISTS (SELECT 1 ...?
--      Vì sao đa số code thật dùng SELECT 1?
SELECT
    id,
    full_name
FROM
    students s
WHERE
    EXISTS (
        SELECT 1
        FROM enrollments e
        WHERE e.student_id = s.id
    );

SELECT
    id,
    full_name
FROM
    students s
WHERE
    EXISTS (
        SELECT *
        FROM enrollments e
        WHERE e.student_id = s.id
    );

SELECT
    id,
    full_name
FROM
    students s
WHERE
    EXISTS (
        SELECT NULL
        FROM enrollments e
        WHERE e.student_id = s.id
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 1.2 — EXISTS không bao giờ nhân dòng
-- ============================================================
-- Sinh viên id 1 có 3 dòng trong enrollments (3 môn). Nếu EXISTS "hỏi
-- lại" subquery và subquery khớp 3 dòng, kết quả có ra 3 dòng sinh
-- viên 1 không?
--
-- YÊU CẦU:
-- a) Chạy câu 1 (EXISTS). Ra mấy dòng?
-- b) Chạy câu 2 (JOIN thường, không DISTINCT) trên CÙNG điều kiện. Ra
--    mấy dòng?
-- c) Vì sao hai câu, cùng dữ liệu, cùng "ý định lọc sinh viên 1", lại
--    ra số dòng khác nhau đến vậy? EXISTS trả lời cho AI: cho DÒNG
--    NGOÀI hay cho DÒNG TRONG SUBQUERY?
SELECT
    s.id,
    s.full_name
FROM
    students s
WHERE
    EXISTS (
        SELECT 1
        FROM enrollments e
        WHERE e.student_id = s.id
            AND e.student_id = 1
    );

SELECT
    s.id,
    s.full_name
FROM
    students s
    JOIN enrollments e ON e.student_id = s.id
WHERE
    s.id = 1;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- GHI NHỚ: EXISTS luôn trả về ĐÚNG MỘT giá trị TRUE/FALSE cho MỖI dòng
--          của truy vấn ngoài — bất kể subquery khớp 0, 1, hay 1000
--          dòng. Đây là khác biệt cốt lõi với JOIN, vốn tạo ra một dòng
--          kết quả cho MỖI cặp khớp.
-- ============================================================
-- BÀI 1.3 — Câu hỏi kinh điển: "sinh viên nào đã đăng ký ít nhất 1 môn?"
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu dưới. Ra mấy dòng trên tổng 8 sinh viên?
-- b) Ai vắng mặt? Mở schema.sql kiểm tra: người đó có đúng là chưa
--    đăng ký môn nào không?
-- c) Đọc to câu lệnh thành tiếng Việt. Nó có khớp đúng câu hỏi nghiệp
--    vụ không?
SELECT
    s.id,
    s.full_name
FROM
    students s
WHERE
    EXISTS (
        SELECT 1
        FROM enrollments e
        WHERE e.student_id = s.id
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 1.4 — NOT EXISTS: mặt trái của EXISTS
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu dưới. Ra mấy dòng?
-- b) So với bài 1.3 (7 dòng): 7 + số dòng ở đây có bằng 8 không? Vì
--    sao ĐÚNG PHẢI bằng 8 (gợi ý: một sinh viên chỉ có thể ở đúng MỘT
--    trong hai nhóm — đã đăng ký, hoặc chưa — không có nhóm thứ ba)?
SELECT
    s.id,
    s.full_name
FROM
    students s
WHERE
    NOT EXISTS (
        SELECT 1
        FROM enrollments e
        WHERE e.student_id = s.id
    );

-- Trả lời của bạn:
-- a)
-- b)
-- ============================================================
-- BÀI 1.5 — Xem trước quả bom của phase 2 (đừng lo nếu chưa hiểu hết)
-- ============================================================
-- Bảng drop_requests có 4 đơn xin rút môn, và CÓ ĐÚNG 1 đơn chưa rõ
-- sinh viên nào (student_id NULL — đơn giấy nộp tay).
--
-- YÊU CẦU:
-- a) Chạy câu 1 (dùng NOT IN). Ra mấy dòng?
-- b) Chạy câu 2 (dùng NOT EXISTS, cùng ý định: "sinh viên chưa từng xin
--    rút môn nào"). Ra mấy dòng?
-- c) Hai câu ra số KHÁC NHAU. Bạn nghĩ câu nào đúng? Đếm bằng tay: có
--    những sinh viên nào xuất hiện trong drop_requests (bỏ qua dòng
--    NULL)? Vậy "chưa từng xin rút" phải là những ai?
-- d) Đừng vội hiểu tại sao — phase 2 bài 2.1 sẽ mổ xẻ chi tiết.
SELECT
    s.id
FROM
    students s
WHERE
    s.id NOT IN (
        SELECT student_id
        FROM drop_requests
    );

SELECT
    s.id
FROM
    students s
WHERE
    NOT EXISTS (
        SELECT 1
        FROM drop_requests d
        WHERE d.student_id = s.id
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 1.6 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Liệt kê các môn học ĐÃ CÓ ít nhất 1 sinh viên đăng ký (id + tên),
-- sắp theo id, dùng EXISTS. Bảng courses có 8 môn — ra mấy dòng?
-- Viết query của bạn bên dưới:
select
    *
from
    courses c
where
    exists(
        select
            1
        from
            enrollments e
        where
            c.id = e.course_id
    );

-- YÊU CẦU B:
-- Liệt kê các môn CHƯA có ai đăng ký, dùng NOT EXISTS.
-- Viết query của bạn bên dưới:
select
    *
from
    courses c
where
    not exists(
        select
            1
        from
            enrollments e
        where
            c.id = e.course_id
    );

-- YÊU CẦU C:
-- Đếm số sinh viên đã đăng ký ít nhất 1 môn bằng cách bọc EXISTS trong
-- COUNT(*) (subquery ngoài cùng đếm số dòng của kết quả EXISTS).
-- Viết query của bạn bên dưới:
select count(*) from students s where exists(select 1 from enrollments e where s.id = e.student_id);

-- YÊU CẦU D:
-- So sánh con số ở câu C với COUNT(DISTINCT student_id) FROM
-- enrollments. Hai con số này có bằng nhau không? Vì sao ở đây KHÔNG
-- có cạm bẫy lệch-1-do-NULL như lab distinct phase 2 (gợi ý: cột
-- enrollments.student_id có NOT NULL không)?
-- Viết query của bạn bên dưới:
select count(DISTINCT student_id) from enrollments;

-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 1.1 — cả 3 câu ra HỆT NHAU, 7 dòng:
--   id 1,2,3,4,5,7,8 (vắng id 6 — Vu Thi Phuong).
--   MySQL không hề đọc danh sách cột sau SELECT bên trong EXISTS — nó
--   chỉ dò xem WHERE của subquery có khớp dòng nào không. Vì vậy
--   `SELECT NULL` không "lấy cột NULL ra" — không có gì được LẤY RA cả,
--   EXISTS chỉ cần biết CÓ DÒNG hay KHÔNG.
--   Quy ước phổ biến: viết `EXISTS (SELECT 1 ...)` vì nó nói thẳng ý
--   định "tôi không cần giá trị gì, chỉ cần biết có hay không".
--
-- BÀI 1.2 — 1 dòng (EXISTS) vs 3 dòng (JOIN).
--   Câu EXISTS: dòng NGOÀI là students, và với s.id=1 có tồn tại ít
--   nhất 1 dòng enrollments khớp -> TRUE đúng 1 lần cho đúng 1 sinh
--   viên -> 1 dòng kết quả.
--   Câu JOIN: mỗi dòng enrollments khớp với s.id=1 tạo ra MỘT dòng kết
--   quả riêng -> sinh viên 1 có 3 môn -> 3 dòng, lặp lại y hệt tên.
--   EXISTS trả lời cho DÒNG NGOÀI ("sinh viên này có thoả không?").
--   JOIN trả lời cho TỪNG CẶP khớp ("cặp sinh viên-môn nào thoả?").
--   Đây là khác biệt gốc rễ, không phải chi tiết cú pháp.
--
-- BÀI 1.3 — 7 dòng: id 1,2,3,4,5,7,8.
--   Vắng: id 6 (Vu Thi Phuong) — đúng như schema.sql đã ghi chú "chưa
--   đăng ký môn nào". Đọc thành lời: "lấy sinh viên s SAO CHO tồn tại
--   một dòng enrollments của chính sinh viên đó" — khớp thẳng câu hỏi.
--
-- BÀI 1.4 — 1 dòng: chỉ id 6.
--   7 (bài 1.3) + 1 (bài 1.4) = 8 = tổng số sinh viên. Đây là quy luật
--   BẮT BUỘC đúng: EXISTS và NOT EXISTS trên CÙNG một điều kiện chia
--   đúng 2 tập con không giao nhau và phủ kín toàn bộ (SQL 2 giá trị:
--   với mỗi dòng ngoài, subquery hoặc CÓ dòng khớp, hoặc KHÔNG — không
--   có khả năng thứ ba, kể cả khi subquery đụng NULL). Nếu cộng lại mà
--   không ra tổng số dòng gốc, chắc chắn có gì sai trong điều kiện.
--
-- BÀI 1.5 — 0 dòng (NOT IN) vs 5 dòng (NOT EXISTS): id 3,4,6,7,8.
--   Ba sinh viên có đơn xin rút (bỏ dòng NULL ra): id 1, 2, 5.
--   "Chưa từng xin rút" đúng ra phải là 8 - 3 = 5 người: 3,4,6,7,8.
--   Đó chính xác là kết quả của NOT EXISTS. NOT IN cho ra 0 — rỗng
--   toàn bộ, kể cả những sinh viên hoàn toàn vô can. Phase 2 bài 2.1
--   giải thích CƠ CHẾ vì sao chỉ một NULL lại phá sập cả câu lệnh.
--
-- BÀI 1.6 A — lời giải (7 dòng, vắng id 8 "Hoi Hoa"):
--   SELECT c.id, c.name FROM courses c
--   WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.course_id = c.id)
--   ORDER BY c.id;
--
-- BÀI 1.6 B — lời giải (1 dòng: id 8, Hoi Hoa):
--   SELECT c.id, c.name FROM courses c
--   WHERE NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.course_id = c.id);
--
-- BÀI 1.6 C — lời giải: 7
--   SELECT COUNT(*) FROM students s
--   WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.id);
--
-- BÀI 1.6 D — 7 và 7, BẰNG NHAU.
--   Không lệch vì enrollments.student_id là NOT NULL (ràng buộc trong
--   schema.sql) — không có dòng NULL nào để COUNT(DISTINCT) phải vứt.
--   Nhắc lại lab distinct bài 1.3: độ lệch giữa hai cách đếm CHỈ xuất
--   hiện khi cột có NULL. Cột này sạch, nên không có gì để lệch.
--
-- KẾT LUẬN PHASE 1:
--   1. EXISTS chỉ trả lời CÓ/KHÔNG. Danh sách cột trong SELECT của
--      subquery hoàn toàn không được MySQL đọc tới.
--   2. EXISTS không bao giờ nhân dòng — nó trả về đúng 1 kết quả
--      TRUE/FALSE cho mỗi dòng ngoài, dù subquery khớp bao nhiêu dòng.
--   3. Correlated subquery (điều kiện nối cột ngoài với cột trong) là
--      phần bắt buộc — thiếu nó, EXISTS mất hết ý nghĩa lọc theo từng
--      dòng.
--   4. EXISTS và NOT EXISTS trên cùng điều kiện luôn cộng lại đúng bằng
--      tổng số dòng của bảng ngoài. Nếu không, hãy nghi ngờ điều kiện.
--   5. NOT IN có thể trả về RỖNG một cách âm thầm khi subquery có NULL.
--      NOT EXISTS thì không — nhưng phải đợi phase 2 để hiểu vì sao.
-- ============================================================
