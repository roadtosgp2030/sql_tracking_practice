-- ============================================================
-- PHASE 2 — OUTER JOIN: LEFT / RIGHT / FULL và ANTI-JOIN
-- (Cần đã làm phase1.sql)
-- ============================================================
USE join_lab;

-- ============================================================
-- KIẾN THỨC NỀN — OUTER JOIN
-- ============================================================
-- INNER JOIN vứt bỏ dòng không khớp. OUTER JOIN thì GIỮ LẠI chúng,
-- và điền NULL vào các cột của bảng bên kia.
--
--      A LEFT JOIN B   -> giữ HẾT dòng của A. B thiếu -> NULL
--      A RIGHT JOIN B  -> giữ HẾT dòng của B. A thiếu -> NULL
--      FULL OUTER JOIN -> giữ hết cả hai. MySQL KHÔNG hỗ trợ (phải tự ghép)
--
-- Ghi nhớ hình ảnh: bảng viết ngay sau FROM là "trái", bảng viết sau
-- JOIN là "phải". LEFT = "bảo vệ bên trái".
--
-- HỆ QUẢ QUAN TRỌNG NHẤT — số dòng:
--      INNER JOIN : có thể ÍT hơn A
--      LEFT  JOIN : LUÔN >= số dòng của A
--                   (bằng A nếu quan hệ 1-1, nhiều hơn nếu 1-nhiều)
--
-- Chỉ dùng RIGHT JOIN khi thật cần. `A RIGHT JOIN B` luôn viết lại được
-- thành `B LEFT JOIN A` với kết quả y hệt, mà đọc dễ hơn nhiều. Trong
-- code thật, 95% là LEFT JOIN.
-- ============================================================
-- ============================================================
-- BÀI 2.1 — LEFT JOIN: giữ hết bên trái
-- ============================================================
-- YÊU CẦU:
-- Câu dưới chỉ khác Bài 1.2 đúng một chữ: JOIN -> LEFT JOIN.
-- a) Ra bao nhiêu dòng? So với 10 dòng của INNER JOIN?
-- b) Hai dòng mới thêm có gì đặc biệt ở cột `department`?
-- c) Cột `d.name` là NOT NULL trong schema. Vậy NULL này ở đâu ra?
SELECT
    e.id,
    e.full_name,
    e.department_id,
    d.name AS department
FROM
    employees e
    LEFT JOIN departments d ON e.department_id = d.id
ORDER BY
    e.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.2 — Đảo thứ tự hai bảng thì kết quả đổi
-- ============================================================
-- YÊU CẦU:
-- Vẫn LEFT JOIN, nhưng đổi chỗ hai bảng.
-- a) Ra bao nhiêu dòng?
-- b) Lần này ai được "bảo vệ"? Dòng NULL bây giờ là dòng nào?
-- c) So với Bài 2.1: hai câu cùng là LEFT JOIN, cùng điều kiện ON,
--    nhưng kết quả khác nhau. Điều gì quyết định?
SELECT
    d.id,
    d.name AS department,
    e.full_name
FROM
    departments d
    LEFT JOIN employees e ON e.department_id = d.id
ORDER BY
    d.id,
    e.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.3 — RIGHT JOIN chỉ là LEFT JOIN viết ngược
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu dưới, so kết quả với Bài 2.2. Giống hay khác?
-- b) Viết lại câu này thành LEFT JOIN mà kết quả không đổi.
SELECT
    d.name AS department,
    e.full_name
FROM
    employees e
    RIGHT JOIN departments d ON e.department_id = d.id
ORDER BY
    d.id,
    e.id;

-- Viết lại bằng LEFT JOIN:


-- ============================================================
-- BÀI 2.4 — ANTI-JOIN: tìm cái KHÔNG khớp
-- ============================================================
-- Đây là mẫu câu hay dùng nhất trong công việc thật:
--
--      A LEFT JOIN B ON ...   WHERE B.<cột NOT NULL> IS NULL
--
-- Ý nghĩa: "giữ hết A, rồi chỉ lấy những dòng mà B không ghép được".
-- Dùng để tìm: đơn hàng chưa thanh toán, user chưa xác thực email,
-- sản phẩm chưa có ảnh, bản ghi mồ côi (orphan)...
--
-- YÊU CẦU:
-- a) Chạy câu dưới. Ra ai?
-- b) Vì sao phải kiểm tra `d.id IS NULL` mà KHÔNG được dùng `d.name`?
--    (thử đổi sang d.name xem — ở đây may mà vẫn đúng. Nhưng nếu cột
--     name cho phép NULL và có phòng tên NULL thì sao?)
-- c) Vì sao KHÔNG được viết `WHERE e.department_id IS NULL` thay thế?
--    Nghĩ xem: nếu một nhân viên có department_id = 99 (phòng đã bị xoá)
--    thì câu nào bắt được lỗi đó?
SELECT
    e.id,
    e.full_name
FROM
    employees e
    LEFT JOIN departments d ON e.department_id = d.id
WHERE
    d.id IS NULL;

-- Trả lời của bạn:
-- a)
-- b)
-- c)

-- YÊU CẦU D:
-- Đảo lại: tìm phòng ban KHÔNG có nhân viên nào.
-- Viết query của bạn bên dưới:


-- ============================================================
-- BÀI 2.5 — FULL OUTER JOIN: MySQL không có, tự ghép
-- ============================================================
-- Ta muốn: MỌI nhân viên + MỌI phòng ban, kể cả bên nào lẻ loi.
-- PostgreSQL/SQL Server có `FULL OUTER JOIN`. MySQL thì không.
-- Cách thay thế: LEFT JOIN  UNION  RIGHT JOIN.
--
-- UNION (không có ALL) tự loại dòng trùng — chính là thứ ta cần,
-- vì phần "khớp nhau" xuất hiện ở cả hai nửa.
--
-- YÊU CẦU:
-- a) Chạy câu dưới. Ra bao nhiêu dòng? (12 nhân viên + 1 phòng lẻ = ?)
-- b) Đổi UNION thành UNION ALL, đếm lại. Chênh bao nhiêu? Vì sao?
-- c) CẢNH BÁO: nếu có 2 nhân viên TRÙNG TÊN và trùng phòng, UNION sẽ
--    gộp họ thành 1 dòng — mất dữ liệu! Cách tránh là gì?
SELECT
    e.full_name,
    d.name AS department
FROM
    employees e
    LEFT JOIN departments d ON e.department_id = d.id
UNION
SELECT
    e.full_name,
    d.name
FROM
    employees e
    RIGHT JOIN departments d ON e.department_id = d.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.6 — BẪY KINH ĐIỂN: COUNT(*) sau LEFT JOIN
-- ============================================================
-- YÊU CẦU:
-- Đếm số nhân viên mỗi phòng. Câu dưới trả về CẢ HAI cách đếm.
-- a) Chạy và nhìn dòng Legal: hai cột ra số gì?
-- b) Phòng Legal có 0 nhân viên. Vì sao COUNT(*) lại ra 1?
-- c) Rút ra quy tắc: sau LEFT JOIN thì đếm bằng gì?
SELECT
    d.name AS department,
    COUNT(*) AS count_star,
    COUNT(e.id) AS count_col
FROM
    departments d
    LEFT JOIN employees e ON e.department_id = d.id
GROUP BY
    d.id,
    d.name
ORDER BY
    d.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 2.7 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Tổng số giờ của TỪNG dự án — kể cả dự án chưa ai làm (phải ra 0,
-- không phải NULL). Đủ 7 dòng.
-- (gợi ý: LEFT JOIN + COALESCE(...) hoặc IFNULL(...))
-- Viết query của bạn bên dưới:


-- YÊU CẦU B:
-- Tìm nhân viên CHƯA được phân công dự án nào.
-- Viết query của bạn bên dưới:


-- YÊU CẦU C:
-- Tìm dự án CHƯA có ai tham gia.
-- Viết query của bạn bên dưới:


-- YÊU CẦU D:
-- Liệt kê mọi nhân viên kèm tên phòng và tên thành phố của phòng đó.
-- Nhân viên chưa có phòng thì hiện chữ '(chua xep phong)' thay vì NULL.
-- Đủ 12 dòng.
-- Viết query của bạn bên dưới:


-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 2.1 — LEFT JOIN: 12 dòng (INNER JOIN chỉ 10)
--   | 10 | Ngo Huu Minh    |          NULL | NULL       |
--   | 12 | Truong Van Phuc |          NULL | NULL       |
--   NULL ở cột `department` KHÔNG phải dữ liệu trong bảng departments.
--   Đó là NULL do MySQL BỊA RA để lấp chỗ trống khi không ghép được.
--   Cột d.name khai báo NOT NULL vẫn có thể ra NULL sau OUTER JOIN —
--   ràng buộc NOT NULL áp lên BẢNG, không áp lên KẾT QUẢ truy vấn.
--
-- BÀI 2.2 — departments LEFT JOIN employees: 11 dòng
--   +----+-------------+----------------+
--   |  1 | Engineering | Nguyen Van An  |
--   |  1 | Engineering | Tran Thi Binh  |
--   |  1 | Engineering | Le Minh Cuong  |
--   |  1 | Engineering | Pham Quoc Dung |
--   |  2 | Sales       | Hoang Thi Hoa  |
--   |  2 | Sales       | Vu Van Giang   |
--   |  2 | Sales       | Ly Thi Nga     |
--   |  3 | Marketing   | Dang Ngoc Hanh |
--   |  3 | Marketing   | Bui Gia Khanh  |
--   |  4 | HR          | Do Thi Lan     |
--   |  5 | Legal       | NULL           |  <- phòng rỗng được giữ lại
--   +----+-------------+----------------+
--   Lần này Legal được cứu, còn Minh và Phuc lại biến mất.
--   => Thứ tự bảng quyết định BÊN NÀO được bảo vệ. LEFT JOIN không
--      đối xứng — đây là điểm khác lớn nhất so với INNER JOIN.
--   Chú ý 11 > 5: Engineering nở thành 4 dòng vì có 4 nhân viên.
--   LEFT JOIN bảo đảm "không mất dòng nào của A", KHÔNG bảo đảm
--   "số dòng bằng A".
--
-- BÀI 2.3 — RIGHT JOIN cho kết quả GIỐNG HỆT Bài 2.2.
--   Viết lại: FROM departments d LEFT JOIN employees e
--                  ON e.department_id = d.id
--   Chỉ cần đổi chỗ hai bảng và đổi RIGHT thành LEFT.
--
-- BÀI 2.4 — ANTI-JOIN:
--   a) Ngo Huu Minh (10), Truong Van Phuc (12)
--   b) Phải kiểm tra cột chắc chắn KHÔNG BAO GIỜ NULL trong bảng B —
--      thường là khoá chính, hoặc chính cột dùng trong ON. Nếu kiểm
--      tra một cột cho phép NULL, bạn sẽ không phân biệt được
--      "không ghép được" với "ghép được nhưng giá trị vốn là NULL".
--   c) `WHERE e.department_id IS NULL` chỉ bắt được người BỎ TRỐNG phòng.
--      Anti-join bắt được CẢ trường hợp department_id = 99 trỏ tới phòng
--      không tồn tại (dữ liệu rác / thiếu khoá ngoại). Hai câu này KHÁC
--      NHAU về ý nghĩa, đừng thay thế cho nhau.
--   D) Phòng không có nhân viên:
--      SELECT d.id, d.name FROM departments d
--      LEFT JOIN employees e ON e.department_id = d.id
--      WHERE e.id IS NULL;
--      -> 5 | Legal
--
-- BÀI 2.5 — FULL OUTER giả lập: 13 dòng
--   = 12 nhân viên (kể cả 2 người NULL phòng) + 1 dòng (NULL, Legal)
--   b) UNION ALL ra 23 dòng: 12 + 11, phần khớp nhau (10 dòng) bị đếm
--      hai lần. UNION đã khử trùng giúp.
--   c) UNION khử trùng theo TOÀN BỘ các cột được SELECT. Hai người
--      trùng tên + trùng phòng sẽ bị gộp mất 1. Cách tránh: luôn
--      SELECT thêm khoá chính (e.id) để mỗi dòng là duy nhất.
--
-- BÀI 2.6 — BẪY COUNT:
--   +-------------+------------+-----------+
--   | department  | count_star | count_col |
--   +-------------+------------+-----------+
--   | Engineering |          4 |         4 |
--   | Sales       |          3 |         3 |
--   | Marketing   |          2 |         2 |
--   | HR          |          1 |         1 |
--   | Legal       |          1 |         0 |   <-- ĐÂY
--   +-------------+------------+-----------+
--   COUNT(*) đếm SỐ DÒNG. Legal có đúng 1 dòng — dòng toàn NULL do
--   LEFT JOIN bịa ra. Nên nó ra 1.
--   COUNT(e.id) đếm số giá trị KHÁC NULL của cột đó -> ra 0. ĐÚNG.
--
--   => QUY TẮC: sau LEFT JOIN, LUÔN đếm bằng COUNT(<cột của bảng phải>),
--      không bao giờ COUNT(*). Đây là lỗi báo cáo sai số phổ biến nhất
--      trong SQL thực tế — và nó im lặng, không ai báo lỗi cho bạn.
--      (SUM thì ngược lại: SUM(NULL) ra NULL, nên cần COALESCE(...,0))
--
-- BÀI 2.7 A — lời giải:
--   SELECT p.name AS project, COALESCE(SUM(a.hours), 0) AS total_hours
--   FROM projects p LEFT JOIN assignments a ON a.project_id = p.id
--   GROUP BY p.id, p.name ORDER BY total_hours DESC;
--   +-------------------+-------------+
--   | Mobile App        |         390 |
--   | Website Redesign  |         340 |
--   | CRM Migration     |         340 |
--   | Brand Campaign    |         290 |
--   | Recruiting Portal |         100 |
--   | Data Warehouse    |           0 |
--   | Office Relocation |           0 |
--   +-------------------+-------------+
--   So với Bài 1.7C (INNER JOIN, 5 dòng): giờ đủ 7. Bỏ COALESCE thì
--   hai dòng cuối ra NULL chứ không phải 0.
--
-- BÀI 2.7 B — lời giải:
--   SELECT e.id, e.full_name FROM employees e
--   LEFT JOIN assignments a ON a.employee_id = e.id
--   WHERE a.employee_id IS NULL;
--   -> 10 Ngo Huu Minh, 12 Truong Van Phuc
--
-- BÀI 2.7 C — lời giải:
--   SELECT p.id, p.name FROM projects p
--   LEFT JOIN assignments a ON a.project_id = p.id
--   WHERE a.project_id IS NULL;
--   -> 6 Data Warehouse, 7 Office Relocation
--
-- BÀI 2.7 D — lời giải:
--   SELECT e.full_name,
--          COALESCE(d.name, '(chua xep phong)') AS department,
--          COALESCE(d.city, '-')                AS city
--   FROM employees e LEFT JOIN departments d ON e.department_id = d.id
--   ORDER BY e.id;
--   -> 12 dòng, Minh và Phuc hiện '(chua xep phong)'
--
-- KẾT LUẬN PHASE 2:
--   1. LEFT JOIN = "giữ hết bên trái, thiếu thì NULL".
--   2. Thứ tự hai bảng quyết định bên nào được bảo vệ — đổi chỗ là
--      đổi kết quả. INNER JOIN thì đổi chỗ vô hại.
--   3. Mẫu ANTI-JOIN `LEFT JOIN ... WHERE b.pk IS NULL` để tìm cái
--      THIẾU. Nhớ mẫu này, dùng cả đời.
--   4. NULL sinh ra từ OUTER JOIN đầu độc mọi phép tính phía sau:
--      COUNT(*) đếm nhầm, SUM ra NULL, so sánh = luôn sai.
--   5. MySQL không có FULL OUTER JOIN -> LEFT UNION RIGHT.
-- ============================================================
