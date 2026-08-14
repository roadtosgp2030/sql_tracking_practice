-- Active: 1778116211273@@127.0.0.1@3306@join_lab
-- ============================================================
-- PHASE 1 — Bản chất của JOIN & INNER JOIN
-- (Chạy schema.sql trước)
-- ============================================================
USE join_lab;

-- ============================================================
-- KIẾN THỨC NỀN — JOIN thực chất là gì?
-- ============================================================
-- Mọi JOIN đều là 2 bước, luôn luôn:
--
--   BƯỚC 1: ghép MỌI dòng bảng A với MỌI dòng bảng B
--           (12 nhân viên x 5 phòng = 60 cặp)
--   BƯỚC 2: giữ lại những cặp thoả điều kiện trong ON
--
-- Trong thực tế MySQL không làm ngu ngốc như vậy (nó dùng index,
-- hash table...), nhưng KẾT QUẢ luôn giống hệt mô hình 2 bước này.
-- Khi bí, hãy quay về mô hình này — nó chưa bao giờ sai.
--
-- CÚ PHÁP:
--      SELECT ...
--      FROM      A
--      JOIN      B  ON  A.cot = B.cot
--
--   JOIN       = INNER JOIN  (viết tắt, hoàn toàn giống nhau)
--   ON         = điều kiện GHÉP CẶP
--   WHERE      = điều kiện LỌC sau khi đã ghép xong
--
-- ALIAS (bí danh): `FROM employees e` cho phép viết `e.id` thay vì
-- `employees.id`. Bắt buộc phải dùng khi JOIN một bảng với chính nó.
--
-- QUY TẮC VÀNG: hễ cột nào có mặt ở nhiều bảng (id, name...) thì
-- LUÔN ghi rõ tiền tố bảng. Không ghi -> lỗi "Column 'id' is ambiguous".
-- ============================================================
-- ============================================================
-- BÀI 1.1 — Nhìn thấy BƯỚC 1: tích Descartes (CROSS JOIN)
-- ============================================================
-- YÊU CẦU:
-- Chạy 2 câu dưới. Câu đầu đếm số cặp, câu sau xem 12 cặp đầu tiên.
-- Rồi trả lời:
--   a) Kết quả đếm được bao nhiêu dòng? Nó bằng phép tính nào?
--   b) Nhìn 12 dòng đầu: mỗi nhân viên xuất hiện mấy lần?
--   c) Dữ liệu này có ý nghĩa gì không? (Nguyen Van An có thuộc phòng Legal không?)
SELECT
    COUNT(*) AS so_cap
FROM
    employees,
    departments;

SELECT
    e.full_name,
    d.name AS department
FROM
    employees e
    CROSS JOIN departments d
ORDER BY
    e.id,
    d.id
LIMIT
    12;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 1.2 — Thêm BƯỚC 2: INNER JOIN
-- ============================================================
-- YÊU CẦU:
-- Câu dưới chỉ khác Bài 1.1 ở chỗ có thêm mệnh đề ON.
-- a) Chạy nó. Đếm được bao nhiêu dòng?
-- b) Bảng employees có 12 dòng. Vậy 2 người bị mất đi đâu? Họ là ai?
--    (mở schema.sql xem lại dữ liệu nếu cần)
SELECT
    e.id,
    e.full_name,
    d.name AS department
FROM
    employees e
    JOIN departments d ON e.department_id = d.id
ORDER BY
    e.id;

-- Trả lời của bạn:
-- a)
-- b)
-- ============================================================
-- BÀI 1.3 — INNER JOIN cắt cả HAI phía
-- ============================================================
-- YÊU CẦU:
-- a) Đếm số phòng ban trong bảng departments.
-- b) Đếm số phòng ban KHÁC NHAU xuất hiện trong kết quả JOIN ở Bài 1.2.
--    (gợi ý: COUNT(DISTINCT d.id))
-- c) Phòng nào biến mất? Tại sao?
-- Viết query của bạn bên dưới:


-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- GHI NHỚ: INNER JOIN chỉ giữ dòng có mặt ở CẢ HAI bên.
--          Không khớp -> biến mất, dù ở bên trái hay bên phải.
-- ============================================================
-- BÀI 1.4 — JOIN nhiều hơn 2 bảng
-- ============================================================
-- YÊU CẦU:
-- Câu dưới nối 4 bảng. Đọc kỹ thứ tự: mỗi JOIN mới chỉ cần nối được
-- với MỘT trong các bảng đã có ở phía trên nó.
-- a) Chạy và đếm số dòng.
-- b) Tên nào xuất hiện 2 lần? Tại sao lặp — dữ liệu có bị sai không?
-- c) Vì sao Ngo Huu Minh (id 10) không có ở đây? Có MẤY lý do?
SELECT
    e.full_name,
    d.name AS dept,
    p.name AS project,
    a.hours
FROM
    employees e
    JOIN departments d ON e.department_id = d.id
    JOIN assignments a ON a.employee_id = e.id
    JOIN projects p ON p.id = a.project_id
ORDER BY
    e.id,
    p.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 1.5 — ON và WHERE dùng chung
-- ============================================================
-- YÊU CẦU:
-- Liệt kê họ tên + tên phòng của các nhân viên có lương > 4000,
-- sắp xếp lương giảm dần.
-- Điều kiện lương phải nằm ở WHERE, KHÔNG phải ON.
-- (Với INNER JOIN thì đặt đâu cũng ra kết quả giống nhau — nhưng
--  với LEFT JOIN thì KHÁC HẲN. Phase 4 sẽ mổ xẻ. Giờ cứ tập thói
--  quen: ON để ghép, WHERE để lọc.)
-- Viết query của bạn bên dưới:


-- ============================================================
-- BÀI 1.6 — USING: viết tắt khi hai cột TRÙNG TÊN
-- ============================================================
-- YÊU CẦU:
-- Bảng assignments và projects đều có cột tên `project_id`?  KHÔNG —
-- projects đặt tên cột khoá là `id`. Nên ở đây KHÔNG dùng USING được.
-- a) Chạy câu dưới, xem MySQL báo lỗi gì.
-- b) Rút ra: điều kiện để dùng USING là gì?
SELECT
    *
FROM
    assignments a
    JOIN projects p USING (project_id);

-- Trả lời của bạn:
-- a)
-- b)
-- ============================================================
-- BÀI 1.7 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Liệt kê mỗi dự án kèm TÊN PHÒNG BAN phụ trách nó.
-- Đếm xem ra mấy dòng, và dự án nào bị mất so với 7 dòng gốc.
-- Viết query của bạn bên dưới:


-- Số dòng: ...   Dự án bị mất: ...

-- YÊU CẦU B:
-- Liệt kê tên nhân viên + tên dự án họ tham gia + số giờ,
-- CHỈ lấy các dự án có budget >= 30000, sắp xếp theo hours giảm dần.
-- (nối employees -> assignments -> projects)
-- Viết query của bạn bên dưới:


-- YÊU CẦU C:
-- Tổng số giờ đã bỏ ra cho TỪNG dự án (kèm tên dự án).
-- Dùng JOIN + GROUP BY. Chú ý: chỉ 5 dự án có dữ liệu.
-- Viết query của bạn bên dưới:


-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 1.1 — CROSS JOIN:
--   so_cap = 60   (12 employees x 5 departments)
--   12 dòng đầu: Nguyen Van An lặp 5 lần, mỗi lần ghép 1 phòng khác nhau.
--   Dữ liệu VÔ NGHĨA: An bị ghép cả với Legal, Sales, HR... Đây mới là
--   nguyên liệu thô, chưa lọc.
--   (Viết `FROM a, b` cũng chính là CROSS JOIN — cú pháp cũ, dễ quên
--    điều kiện nối. Hãy luôn viết JOIN ... ON cho rõ ràng.)
--
-- BÀI 1.2 — INNER JOIN: 10 dòng
--   +----+----------------+-------------+
--   | id | full_name      | department  |
--   +----+----------------+-------------+
--   |  1 | Nguyen Van An  | Engineering |
--   |  2 | Tran Thi Binh  | Engineering |
--   |  3 | Le Minh Cuong  | Engineering |
--   |  4 | Pham Quoc Dung | Engineering |
--   |  5 | Hoang Thi Hoa  | Sales       |
--   |  6 | Vu Van Giang   | Sales       |
--   |  7 | Dang Ngoc Hanh | Marketing   |
--   |  8 | Bui Gia Khanh  | Marketing   |
--   |  9 | Do Thi Lan     | HR          |
--   | 11 | Ly Thi Nga     | Sales       |
--   +----+----------------+-------------+
--   MẤT id 10 (Ngo Huu Minh) và id 12 (Truong Van Phuc):
--   cả hai có department_id = NULL. Mà NULL = 5 không đúng, NULL = NULL
--   cũng KHÔNG đúng — NULL không bằng bất cứ thứ gì, kể cả chính nó.
--   Nên chúng không ghép được với dòng nào.
--
-- BÀI 1.3 — departments có 5, nhưng COUNT(DISTINCT d.id) = 4.
--   Mất phòng Legal (id 5) vì không nhân viên nào có department_id = 5.
--   => INNER JOIN cắt CẢ HAI phía, không thiên vị bảng nào.
--
-- BÀI 1.4 — JOIN 4 bảng: 12 dòng
--   Tran Thi Binh và Le Minh Cuong mỗi người xuất hiện 2 lần, vì mỗi
--   người tham gia 2 dự án. Dữ liệu KHÔNG sai: đơn vị của mỗi dòng
--   không còn là "nhân viên" nữa mà là "một lần phân công".
--   Luôn tự hỏi: "MỘT DÒNG kết quả này đại diện cho cái gì?"
--
--   Ngo Huu Minh vắng mặt vì HAI lý do độc lập, chỉ cần một là đủ chết:
--     1. department_id NULL -> rớt ở JOIN departments
--     2. không có dòng nào trong assignments -> rớt ở JOIN assignments
--
-- BÀI 1.5 — lời giải:
--   SELECT e.full_name, d.name AS department, e.salary
--   FROM employees e
--   JOIN departments d ON e.department_id = d.id
--   WHERE e.salary > 4000
--   ORDER BY e.salary DESC;
--   -> 6 dòng: An 9000, Binh 6500, Hoa 5500, Hanh 5000, Lan 4500, Cuong 4200
--
-- BÀI 1.6 — MySQL báo:
--   ERROR 1054 (42S22): Unknown column 'project_id' in 'from clause'
--   USING(x) chỉ chạy khi CẢ HAI bảng đều có cột tên đúng là `x`.
--   Ở đây projects đặt tên cột khoá là `id`, không phải `project_id`.
--   Khác biệt còn lại: USING gộp 2 cột thành 1 trong kết quả SELECT *,
--   còn ON giữ nguyên cả hai. Khi tên cột không trùng -> bắt buộc ON.
--
-- BÀI 1.7 A — projects JOIN departments: 6 dòng.
--   SELECT p.name AS project, d.name AS department
--   FROM projects p JOIN departments d ON p.department_id = d.id;
--   Mất 'Data Warehouse' (department_id = NULL).
--   Lưu ý: 'Office Relocation' VẪN CÒN, vì nó có department_id = 5 và
--   phòng Legal có tồn tại — Legal chỉ thiếu NHÂN VIÊN, không thiếu dự án.
--
-- BÀI 1.7 B — lời giải:
--   SELECT e.full_name, p.name AS project, a.hours
--   FROM employees e
--   JOIN assignments a ON a.employee_id = e.id
--   JOIN projects p ON p.id = a.project_id
--   WHERE p.budget >= 30000
--   ORDER BY a.hours DESC;
--   -> 9 dòng (budget >= 30000 gồm dự án 1, 2, 3 — dự án 6 đủ budget
--      nhưng không ai làm nên không xuất hiện).
--      Cao nhất: Le Minh Cuong / Website Redesign / 200
--
-- BÀI 1.7 C — lời giải:
--   SELECT p.name AS project, SUM(a.hours) AS total_hours
--   FROM projects p JOIN assignments a ON a.project_id = p.id
--   GROUP BY p.id, p.name
--   ORDER BY total_hours DESC;
--   +-------------------+-------------+
--   | Mobile App        |         390 |
--   | Website Redesign  |         340 |
--   | CRM Migration     |         340 |
--   | Brand Campaign    |         290 |
--   | Recruiting Portal |         100 |
--   +-------------------+-------------+
--   Chỉ 5 dòng — dự án 6, 7 không xuất hiện vì INNER JOIN loại chúng.
--   Muốn thấy chúng với total = 0, phải dùng LEFT JOIN -> phase 2.
--
-- KẾT LUẬN PHASE 1:
--   1. JOIN = ghép mọi cặp, rồi lọc theo ON. Bí thì quay về mô hình này.
--   2. INNER JOIN cắt cả hai phía — dòng không khớp biến mất im lặng,
--      MySQL không hề cảnh báo. Luôn ĐẾM SỐ DÒNG trước và sau khi JOIN.
--   3. NULL không khớp với bất cứ gì, kể cả NULL khác.
--   4. Sau khi JOIN, "một dòng" có thể không còn là "một nhân viên" nữa.
-- ============================================================
