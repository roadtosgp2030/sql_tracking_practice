-- Active: 1756872756053@@127.0.0.1@3306@exists_lab
-- ============================================================
-- PHASE 2 — EXISTS vs IN vs JOIN
-- (Làm phase 1 trước)
-- ============================================================
USE exists_lab;

-- ============================================================
-- KIẾN THỨC NỀN — Ba cách viết CÙNG MỘT Ý ĐỊNH, ba mức an toàn khác nhau
-- ============================================================
-- "Sinh viên nào có liên quan gì đó tới bảng B?" có ít nhất 3 cách viết:
--
--   1. JOIN bảng B (rồi có thể phải DISTINCT để hết nhân dòng)
--   2. WHERE cot IN (SELECT cot_khac FROM B)
--   3. WHERE EXISTS (SELECT 1 FROM B WHERE dieu_kien_noi)
--
-- Ba cách này KHÔNG tương đương về độ an toàn:
--
--   JOIN   : nhân dòng nếu B khớp nhiều hơn 1 dòng. Sửa bằng DISTINCT
--            thì lại có thể gộp nhầm hai thực thể khác nhau (lab
--            distinct, phase 3) nếu quên đưa khoá chính vào.
--   IN     : nếu subquery của B có dù chỉ MỘT dòng NULL ở cột được so
--            sánh, `NOT IN` sẽ vỡ TOÀN BỘ (trả về rỗng). `IN` (không
--            NOT) thì vẫn đúng khi có NULL, nhưng `NOT IN` thì không.
--   EXISTS : không nhân dòng (phase 1), và KHÔNG BAO GIỜ vỡ vì NULL ở
--            bảng trong, dù là EXISTS hay NOT EXISTS.
--
-- Phase này chứng minh bằng dữ liệu thật, không phải bằng lý thuyết
-- suông.
-- ============================================================
-- ============================================================
-- BÀI 2.1 — BÀI QUAN TRỌNG NHẤT CỦA CẢ LAB: NOT IN + NULL
-- ============================================================
-- Câu hỏi nghiệp vụ: "Sinh viên nào CHƯA TỪNG xin rút môn nào?"
-- Bảng drop_requests có 4 đơn: student_id = 2, NULL, 5, 1.
--
-- YÊU CẦU:
-- Trước khi chạy gì, tự đếm bằng tay: bỏ dòng NULL ra, những sinh viên
-- NÀO đã từng xin rút? Vậy đáp án đúng của câu hỏi trên là những id nào?
--
-- a) Chạy câu 1 (SELECT NULL NOT IN (1,2)). Kết quả là gì? Đây có phải
--    TRUE hay FALSE không, hay là một giá trị thứ ba?
-- b) Chạy câu 2. Cùng logic nhưng vế trái là giá trị THẬT (3), vế phải
--    là danh sách CÓ một NULL. Kết quả là gì?
-- c) Chạy câu 3 (câu trả lời "CHƯA xin rút" bằng NOT IN thật). Ra mấy
--    dòng? Có khớp với đáp án bạn tự đếm ở trên không?
-- d) Chạy câu 4 (cùng câu hỏi, bằng NOT EXISTS). Ra mấy dòng?
SELECT
    NULL NOT IN (1, 2) AS thi_nghiem_1;

SELECT
    3 NOT IN (1, 2, NULL) AS thi_nghiem_2;

SELECT
    s.id,
    s.full_name
FROM
    students s
WHERE
    s.id NOT IN (
        SELECT student_id
        FROM drop_requests
    );

SELECT
    s.id,
    s.full_name
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
-- GHI NHỚ: `NOT IN (a, b, NULL)` không bao giờ là FALSE — nó là TRUE
--          hoặc NULL, không bao giờ bằng "khớp một trong các giá trị".
--          Cơ chế: `x NOT IN (a,b,c)` = `x<>a AND x<>b AND x<>c`. Nếu
--          MỘT so sánh cho ra NULL (vì c là NULL), và không so sánh nào
--          khác cho ra FALSE, thì cả phép AND thành NULL. WHERE coi
--          NULL là "không giữ dòng này" — y hệt FALSE. Kết quả: MỌI
--          dòng ngoài đều bị loại, kể cả dòng lẽ ra phải đúng.
--          Đây không phải lỗi hiếm — CHỈ CẦN đúng 1 dòng NULL ở bất kỳ
--          đâu trong subquery là đủ giết chết toàn bộ NOT IN.
--          NOT EXISTS không có cơ chế "AND cả danh sách" này — nó chỉ
--          hỏi "join tới subquery có ra dòng nào không", và một dòng
--          NULL bên trong subquery đơn giản là KHÔNG BAO GIỜ khớp được
--          điều kiện `d.student_id = s.id` (vì NULL = bất cứ gì đều
--          NULL, không phải TRUE) — nên nó không tham gia, không phá
--          gì cả.
-- ============================================================
-- BÀI 2.2 — Khi KHÔNG có NULL, EXISTS và IN cho kết quả giống hệt
-- ============================================================
-- enrollments.student_id là NOT NULL (ràng buộc bảng). Vậy `IN` ở đây
-- có an toàn không?
--
-- YÊU CẦU:
-- a) Chạy 2 câu dưới. Kết quả có giống bài 1.3 (EXISTS, 7 dòng) không?
-- b) Rút ra: `IN` (không phải `NOT IN`) có nguy hiểm như `NOT IN`
--    không? Khi nào thì bạn PHẢI kiểm tra cột có NULL hay không trước
--    khi dùng `IN`/`NOT IN`?
SELECT
    id,
    full_name
FROM
    students
WHERE
    id IN (
        SELECT student_id
        FROM enrollments
    )
ORDER BY
    id;

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
    )
ORDER BY
    id;

-- Trả lời của bạn:
-- a)
-- b)
-- ============================================================
-- BÀI 2.3 — EXISTS tránh được bẫy gộp nhầm của DISTINCT (nhắc lại lab distinct)
-- ============================================================
-- Nhớ lại: id 1 và id 8 CÙNG tên 'Nguyen Van A', là HAI người khác nhau.
-- Cả hai đều đã đăng ký môn nào đó.
--
-- YÊU CẦU:
-- Chạy 4 câu dưới THEO THỨ TỰ:
-- a) Câu 1 (JOIN thô, không DISTINCT): ra mấy dòng?
-- b) Câu 2 (DISTINCT full_name): ra mấy dòng? Tên 'Nguyen Van A' xuất
--    hiện mấy lần trong kết quả?
-- c) Câu 3 (DISTINCT id, full_name — đúng theo lab distinct): ra mấy
--    dòng?
-- d) Câu 4 (EXISTS, không DISTINCT gì cả): ra mấy dòng? So với câu 3?
-- e) BÀI HỌC: câu 2 sai ở đâu, và vì sao câu 4 (EXISTS) không cần phải
--    "nhớ" thêm khoá chính vào như câu 3 mới ra đúng?
SELECT
    s.full_name
FROM
    students s
    JOIN enrollments e ON e.student_id = s.id;

SELECT DISTINCT
    s.full_name
FROM
    students s
    JOIN enrollments e ON e.student_id = s.id;

SELECT DISTINCT
    s.id,
    s.full_name
FROM
    students s
    JOIN enrollments e ON e.student_id = s.id
ORDER BY
    s.id;

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
    )
ORDER BY
    s.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- e)
-- GHI NHỚ: DISTINCT full_name gộp HAI SINH VIÊN THẬT làm MỘT dòng tên
--          'Nguyen Van A', vì nó chỉ nhìn thấy GIÁ TRỊ đã SELECT ra,
--          không biết id là ai. EXISTS không có bước "gộp giá trị" nào
--          cả — nó lọc DÒNG NGOÀI (students, định danh bằng s.id) dựa
--          trên một điều kiện TRUE/FALSE, nên không thể gộp nhầm hai
--          dòng ngoài khác khoá chính, bất kể chúng trùng tên đến đâu.
-- ============================================================
-- BÀI 2.4 — EXISTS với nhiều điều kiện (AND) trong subquery
-- ============================================================
-- Câu hỏi: "Sinh viên nào đã học môn Co So Du Lieu (id 2) với điểm từ
-- 9 trở lên?"
--
-- YÊU CẦU:
-- a) Trước khi chạy: mở schema.sql, tìm các dòng enrollments có
--    course_id = 2. Có mấy dòng? Điểm của từng dòng?
-- b) Dòng nào có grade NULL (id 3, môn 2)? `NULL >= 9` cho kết quả gì?
--    Dòng đó có được tính là "đạt điều kiện" không?
-- c) Chạy câu dưới. Ra mấy dòng? Có sinh viên nào tên trùng nhau trong
--    kết quả không? EXISTS có phân biệt được họ không?
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
            AND e.course_id = 2
            AND e.grade >= 9
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.5 — Kết hợp EXISTS và NOT EXISTS trong cùng một câu
-- ============================================================
-- Câu hỏi: "Sinh viên nào đã học ít nhất 1 môn khoa CNTT, nhưng CHƯA
-- học môn nào của khoa Ngoai Ngu?"
--
-- YÊU CẦU:
-- a) Trước khi chạy: khoa CNTT có các môn nào (id)? Khoa Ngoai Ngu có
--    các môn nào? Sinh viên nào đã học môn Ngoai Ngu (xem enrollments)?
-- b) Chạy câu dưới. Ra mấy dòng, id nào?
-- c) Sinh viên id 8 có xuất hiện trong kết quả không? Anh ta học môn
--    nào thuộc CNTT? (đừng quên: 'Nguyen Van A' id 8 học chéo sang cả
--    Kinh Te, nhưng câu hỏi này không loại trừ điều đó)
SELECT
    s.id,
    s.full_name
FROM
    students s
WHERE
    EXISTS (
        SELECT 1
        FROM enrollments e
            JOIN courses c ON c.id = e.course_id
        WHERE e.student_id = s.id
            AND c.department = 'CNTT'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM enrollments e
            JOIN courses c ON c.id = e.course_id
        WHERE e.student_id = s.id
            AND c.department = 'Ngoai Ngu'
    );

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.6 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Viết lại bài 2.1 câu d) (sinh viên chưa từng xin rút môn) từ đầu,
-- không nhìn lại lời giải. Dùng NOT EXISTS.
-- Viết query của bạn bên dưới:
select * from students s where not EXISTS (select 1 from drop_requests dr where s.id = dr.student_id);

-- YÊU CẦU B:
-- Liệt kê các khoa (department) có ít nhất 1 sinh viên đạt điểm >= 9 ở
-- một môn thuộc khoa đó. (gợi ý: EXISTS nối courses -> enrollments)
-- Viết query của bạn bên dưới:
select DISTINCT c.department from courses c WHERE EXISTS (select 1 from enrollments e where c.id = e.course_id and e.grade >= 9);

-- YÊU CẦU C:
-- Liệt kê sinh viên KHÔNG học môn nào của khoa Kinh Te (kể cả sinh
-- viên có major = 'Kinh Te' — chú ý major và "đã học môn của khoa nào"
-- là hai chuyện khác nhau).
-- Viết query của bạn bên dưới:
select * from students s where NOT EXISTS (select 1 from enrollments e join courses c on e.course_id = c.id where c.department = 'Kinh Te' and s.id = e.student_id);

-- YÊU CẦU D:
-- Đọc lại 2 câu dưới. KHÔNG chạy trước. Với mỗi câu, đoán xem: có an
-- toàn với NULL không? Vì sao?
--   1) SELECT * FROM students WHERE id IN (SELECT student_id FROM enrollments);
--   2) SELECT * FROM students WHERE id NOT IN (SELECT student_id FROM enrollments);
-- Sau đó chạy để kiểm chứng cả hai đều ra kết quả bình thường (không
-- rỗng bất thường). Vì sao câu 2 ở đây AN TOÀN, trong khi bài 2.1 câu 3
-- (NOT IN trên drop_requests) lại KHÔNG?
-- Trả lời của bạn:
SELECT * FROM students WHERE id IN (SELECT student_id FROM enrollments);
SELECT * FROM students WHERE id NOT IN (SELECT student_id FROM enrollments);

-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 2.1 — Đếm tay: sinh viên có đơn xin rút (bỏ NULL) là id 1, 2, 5.
--   "Chưa từng xin rút" đúng ra là 8 - 3 = 5 người: id 3, 4, 6, 7, 8.
--
--   a) SELECT NULL NOT IN (1,2)  ->  NULL   (không phải TRUE, không FALSE)
--   b) SELECT 3 NOT IN (1,2,NULL) -> NULL   (dù 3 rõ ràng khác 1 và 2!)
--   c) NOT IN thật trên drop_requests -> 0 DÒNG.
--   d) NOT EXISTS thật -> 5 dòng: id 3, 4, 6, 7, 8. Khớp đúng đếm tay.
--
--   Vì sao (b) lại là NULL chứ không phải TRUE: `3 NOT IN (1,2,NULL)`
--   giãn ra thành `3<>1 AND 3<>2 AND 3<>NULL` = `TRUE AND TRUE AND NULL`
--   = NULL. Chỉ cần MỘT phần tử NULL trong danh sách là đủ biến toàn bộ
--   phép AND thành NULL, bất kể vế trái là gì. WHERE loại bỏ NULL y hệt
--   FALSE, nên (c) mất trắng toàn bộ 8 sinh viên, không chỉ mất 3 người
--   đáng lẽ phải loại.
--
-- BÀI 2.2 — cả 2 câu ra HỆT NHAU: 7 dòng, id 1,2,3,4,5,7,8.
--   `IN` không có bẫy NOT IN gặp phải: `x IN (a,b,NULL)` có thể vẫn ra
--   TRUE nếu x khớp a hoặc b — chỉ NOT IN mới cần "loại trừ TẤT CẢ",
--   nên chỉ NOT IN mới bị một NULL phá hỏng toàn bộ phép AND. Ở đây
--   enrollments.student_id NOT NULL nên hoàn toàn không có gì để bàn —
--   nhưng nếu mai này ai đó nới lỏng ràng buộc đó, `IN` (không NOT) vẫn
--   an toàn, `NOT IN` thì lập tức nguy hiểm.
--
-- BÀI 2.3 — 15 / 6 / 7 / 7 dòng:
--   Câu 1 (JOIN thô): 15 dòng — đúng bằng số dòng enrollments, fan-out
--   y hệt lab distinct phase 3.
--   Câu 2 (DISTINCT full_name): 6 dòng — 'Nguyen Van A' CHỈ CÒN 1 dòng,
--   dù đại diện cho CẢ id 1 và id 8. Trông gọn, và SAI: một sinh viên
--   biến mất khỏi báo cáo mà không có cảnh báo gì.
--   Câu 3 (DISTINCT id, full_name): 7 dòng, đúng — 'Nguyen Van A' xuất
--   hiện 2 lần vì có 2 id khác nhau.
--   Câu 4 (EXISTS): 7 dòng, giống hệt câu 3 — mà KHÔNG cần nhớ thêm
--   khoá chính vào SELECT.
--   Bài học: EXISTS lọc DÒNG NGOÀI dựa trên một phép TRUE/FALSE; nó
--   không tạo ra danh sách giá trị nào để mà DISTINCT phải khử trùng.
--   Không có bước gộp -> không có gì để gộp nhầm.
--
-- BÀI 2.4 — enrollments có course_id=2 ở 4 dòng:
--   (1,2,9.0), (2,2,7.0), (3,2,NULL), (8,2,9.5).
--   `NULL >= 9` = NULL (không TRUE, không FALSE) -> dòng của sinh viên
--   3 KHÔNG được tính là đạt (đúng, vì "chưa có điểm" thì đâu thể nói
--   là "đạt điểm 9 trở lên").
--   Kết quả: 2 dòng — id 1 và id 8. CẢ HAI đều tên 'Nguyen Van A' nhưng
--   EXISTS xử lý từng dòng ngoài ĐỘC LẬP theo s.id, không hề lẫn lộn
--   hai người dù trùng tên hệt nhau.
--
-- BÀI 2.5 — CNTT = {1,2,3}. Ngoai Ngu = {6,7}. Ai học Ngoai Ngu: chỉ
--   id 7 (Dang Van G).
--   Kết quả: 4 dòng — id 1, 2, 3, 8.
--   Sinh viên 8 CÓ mặt: anh ta học course_id=2 (Co So Du Lieu, khoa
--   CNTT) và course_id=4 (Kinh Te Vi Mo) — không học môn Ngoai Ngu nào,
--   nên thoả cả hai điều kiện, dù major của anh ta ghi là 'Kinh Te'.
--   Đây là điểm mấu chốt: EXISTS đọc DỮ LIỆU THẬT (đã đăng ký môn gì),
--   không đọc cột major — hai thứ có thể không khớp nhau, và trong đời
--   thật thường không khớp (sinh viên học chéo ngành, học tự chọn...).
--
-- BÀI 2.6 A — lời giải: (giống bài 2.1 câu d)
--   SELECT s.id, s.full_name FROM students s
--   WHERE NOT EXISTS (SELECT 1 FROM drop_requests d WHERE d.student_id = s.id);
--   -> 5 dòng: id 3, 4, 6, 7, 8.
--
-- BÀI 2.6 B — lời giải:
--   SELECT DISTINCT c.department FROM courses c
--   WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.course_id = c.id AND e.grade >= 9);
--   -> CNTT, Ngoai Ngu.
--   (CNTT nhờ điểm 9.0 và 9.5 ở môn 2; Ngoai Ngu nhờ điểm 9.0 ở môn 6.
--    Kinh Te không đạt: điểm cao nhất ở đó là 8.0. Nghe Thuat không có
--    ai học nên chắc chắn không đạt.)
--
-- BÀI 2.6 C — lời giải:
--   SELECT s.id, s.full_name FROM students s
--   WHERE NOT EXISTS (
--     SELECT 1 FROM enrollments e JOIN courses c ON c.id = e.course_id
--     WHERE e.student_id = s.id AND c.department = 'Kinh Te');
--   -> 5 dòng: id 1, 2, 3, 6, 7.
--   Sinh viên id 8 tuy KHÔNG có major 'CNTT' gì đặc biệt nhưng CÓ học
--   course_id=4 (Kinh Te Vi Mo, khoa Kinh Te) nên bị loại khỏi danh
--   sách này — một lần nữa, "đã học môn của khoa nào" khác "major là
--   khoa nào".
--
-- BÀI 2.6 D —
--   1) `IN` — AN TOÀN với NULL, vì chỉ cần khớp MỘT giá trị không-NULL
--      trong danh sách là đủ TRUE; NULL trong danh sách chỉ có thể biến
--      một kết quả FALSE thành NULL (khi không khớp gì và có NULL), nó
--      không làm mất các kết quả TRUE đã có.
--   2) `NOT IN` — chỉ AN TOÀN Ở ĐÂY vì enrollments.student_id NOT NULL,
--      nên danh sách con hoàn toàn không có phần tử NULL nào để phá.
--      Bản chất phép toán vẫn NGUY HIỂM y hệt bài 2.1 — chỉ là dữ liệu
--      lần này "sạch" nên không lộ ra. Đây chính là loại lỗi tiềm ẩn
--      nguy hiểm nhất: code chạy đúng suốt nhiều năm, tới ngày có ai đó
--      cho phép cột kia nhận NULL thì NOT IN lặng lẽ trả về rỗng.
--   => THÓI QUEN AN TOÀN: đừng bao giờ đánh giá `NOT IN` là an toàn hay
--      không dựa trên "có NULL BÂY GIỜ" — hãy dùng NOT EXISTS làm mặc
--      định, để khỏi phải theo dõi ràng buộc NOT NULL của người khác.
--
-- KẾT LUẬN PHASE 2:
--   1. `NOT IN` vỡ HOÀN TOÀN (trả về rỗng) nếu subquery có dù chỉ MỘT
--      dòng NULL ở cột so sánh. `IN` (không NOT) thì an toàn.
--   2. `NOT EXISTS` không có cạm bẫy đó, vì cơ chế của nó là "join có
--      khớp không", không phải "loại trừ khỏi danh sách".
--   3. EXISTS lọc DÒNG NGOÀI theo khoá của chính nó -> không thể gộp
--      nhầm hai thực thể trùng giá trị hiển thị, khác hẳn DISTINCT trên
--      cột không phải khoá.
--   4. EXISTS nhận nhiều điều kiện AND/OR trong subquery như WHERE bình
--      thường; NULL trong các cột đó (như grade) chỉ ảnh hưởng đúng
--      dòng có NULL, không lan ra dòng khác.
--   5. Cột nghiệp vụ (như major) và dữ liệu giao dịch thật (như đã
--      đăng ký môn gì) là HAI NGUỒN SỰ THẬT khác nhau — đừng giả định
--      chúng luôn khớp nhau.
-- ============================================================
