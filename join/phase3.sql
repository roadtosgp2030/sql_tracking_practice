-- ============================================================
-- PHASE 3 — SELF JOIN, quan hệ NHIỀU-NHIỀU, NON-EQUI JOIN
-- (Cần đã làm phase1.sql và phase2.sql)
-- ============================================================
USE join_lab;

-- ============================================================
-- KIẾN THỨC NỀN — Ba kiểu JOIN "không tầm thường"
-- ============================================================
-- 1. SELF JOIN — nối một bảng với CHÍNH NÓ.
--    Dùng khi bảng có cột trỏ về chính bảng đó (manager_id -> id),
--    hoặc khi cần so sánh dòng với dòng.
--    BẮT BUỘC dùng alias, vì MySQL cần phân biệt "bản sao nào".
--    Cứ tưởng tượng đang có HAI bảng khác nhau tình cờ giống dữ liệu.
--
--        FROM employees e            <- vai "nhân viên"
--        JOIN employees m ON e.manager_id = m.id   <- vai "quản lý"
--
-- 2. NHIỀU-NHIỀU qua BẢNG TRUNG GIAN.
--    Không thể để một nhân viên chứa "nhiều dự án" trong 1 cột.
--    Nên tách bảng assignments(employee_id, project_id).
--    Muốn đi từ employees sang projects phải qua HAI lần JOIN:
--
--        employees --> assignments --> projects
--
-- 3. NON-EQUI JOIN — điều kiện ON không phải dấu "=".
--    ON a.salary BETWEEN g.min AND g.max, ON a.id < b.id, ON <, >, !=...
--    Hoàn toàn hợp lệ. ON chỉ cần là một biểu thức TRUE/FALSE.
--    (Chỉ lưu ý: non-equi join không dùng index tốt bằng equi join,
--     với bảng lớn phải cẩn thận — xem lại lab indexing.)
-- ============================================================
-- ============================================================
-- BÀI 3.1 — SELF JOIN: ai là sếp của ai
-- ============================================================
-- YÊU CẦU:
-- a) Chạy câu dưới. Ra bao nhiêu dòng? Ai vắng mặt so với 12 người?
-- b) Thử bỏ alias `e` và `m` đi, chạy lại. MySQL báo lỗi gì?
-- c) `m` và `e` là cùng một bảng employees. Vậy dòng "Nguyen Van An"
--    xuất hiện ở cả hai vai được không?
SELECT
    e.id,
    e.full_name AS nhan_vien,
    m.full_name AS quan_ly
FROM
    employees e
    JOIN employees m ON e.manager_id = m.id
ORDER BY
    e.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 3.2 — SELF JOIN + LEFT: đừng bỏ rơi sếp tổng
-- ============================================================
-- YÊU CẦU:
-- Sửa câu 3.1 để hiện ĐỦ 12 người. Ai không có sếp thì cột quan_ly
-- hiện chữ '(khong co sep)'.
-- Viết query của bạn bên dưới:


-- ============================================================
-- BÀI 3.3 — Đếm cấp dưới (áp dụng lại bẫy COUNT của phase 2)
-- ============================================================
-- YÊU CẦU:
-- Đếm số cấp dưới TRỰC TIẾP của từng người, đủ 12 dòng, ai không
-- quản lý ai thì ra 0.
-- Chú ý: bảng nào đứng bên TRÁI lần này? (người quản lý, hay nhân viên?)
-- Và đếm bằng COUNT(*) hay COUNT(cột)?
-- Viết query của bạn bên dưới:


-- Kiểm tra: tổng cột so_cap_duoi phải bằng số người CÓ manager_id.
-- Bằng bao nhiêu? ...
-- ============================================================
-- BÀI 3.4 — SELF JOIN ba tầng
-- ============================================================
-- YÊU CẦU:
-- Nối 3 lần cùng một bảng: nhân viên -> sếp -> sếp của sếp.
-- a) Chạy và đọc kết quả.
-- b) Vì sao PHẢI dùng LEFT JOIN ở cả hai lần? Thử đổi cái thứ hai
--    thành JOIN thường xem mất bao nhiêu dòng.
-- c) Cách này chỉ đi được số tầng CỐ ĐỊNH. Muốn đi hết cây sâu bao
--    nhiêu cũng được thì cần gì? (từ khoá: recursive CTE)
SELECT
    e.full_name AS nhan_vien,
    m.full_name AS sep,
    gm.full_name AS sep_cua_sep
FROM
    employees e
    LEFT JOIN employees m ON e.manager_id = m.id
    LEFT JOIN employees gm ON m.manager_id = gm.id
ORDER BY
    e.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 3.5 — SELF JOIN tìm CẶP + mẹo `a.id < b.id`
-- ============================================================
-- YÊU CẦU:
-- Câu dưới liệt kê các cặp đồng nghiệp cùng phòng.
-- a) Chạy nguyên bản. Ra bao nhiêu cặp?
-- b) Đổi `a.id < b.id` thành `a.id <> b.id`, chạy lại. Ra bao nhiêu?
--    Vì sao gấp đôi?
-- c) Bỏ hẳn điều kiện đó (chỉ còn cùng department_id). Ra bao nhiêu?
--    Những dòng thừa mới có ý nghĩa gì?
-- d) Kết luận: `<` khác `<>` chỗ nào khi ghép cặp?
SELECT
    d.name AS phong,
    a.full_name AS nguoi_1,
    b.full_name AS nguoi_2
FROM
    employees a
    JOIN employees b ON a.department_id = b.department_id
    AND a.id < b.id
    JOIN departments d ON d.id = a.department_id
ORDER BY
    d.id,
    a.id,
    b.id;

-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- d)
-- ============================================================
-- BÀI 3.6 — Quan hệ NHIỀU-NHIỀU: đi qua bảng trung gian
-- ============================================================
-- YÊU CẦU A:
-- Bảng assignments chỉ chứa toàn số (employee_id, project_id, hours).
-- Chạy `SELECT * FROM assignments;` xem — hoàn toàn không đọc được.
-- Hãy JOIN để biến nó thành bảng có TÊN NGƯỜI và TÊN DỰ ÁN.
-- Viết query của bạn bên dưới:


-- YÊU CẦU B:
-- Với TỪNG nhân viên (đủ 12 người): số dự án tham gia và tổng số giờ.
-- Người chưa làm gì phải ra 0 và 0 (không phải NULL).
-- Viết query của bạn bên dưới:


-- YÊU CẦU C:
-- Câu dưới tìm các cặp người TỪNG LÀM CHUNG dự án. Nó self-join bảng
-- TRUNG GIAN (a1, a2) chứ không self-join employees.
-- a) Chạy và kiểm chứng vài cặp bằng mắt với dữ liệu trong schema.sql.
-- b) Nếu bỏ `a1.employee_id < a2.employee_id`, chuyện gì xảy ra?
--    (nghĩ tới cả trường hợp a1 và a2 là CÙNG một dòng)
SELECT
    p.name AS du_an,
    e1.full_name AS nguoi_1,
    e2.full_name AS nguoi_2
FROM
    assignments a1
    JOIN assignments a2 ON a1.project_id = a2.project_id
    AND a1.employee_id < a2.employee_id
    JOIN employees e1 ON e1.id = a1.employee_id
    JOIN employees e2 ON e2.id = a2.employee_id
    JOIN projects p ON p.id = a1.project_id
ORDER BY
    p.id,
    e1.id,
    e2.id;

-- Trả lời của bạn:
-- a)
-- b)
-- ============================================================
-- BÀI 3.7 — NON-EQUI JOIN: nối bằng KHOẢNG, không bằng "="
-- ============================================================
-- Bảng salary_grades không có cột nào khớp "=" với employees.
-- Nó chỉ có min_salary / max_salary. Ta nối bằng BETWEEN.
--
-- YÊU CẦU:
-- a) Chạy câu dưới. Ra bao nhiêu dòng? Ai bị mất và vì sao?
--    (mở schema.sql đọc lại phần bậc lương)
-- b) Sửa thành LEFT JOIN để đủ 12 người.
-- c) Nếu hai bậc lương bị CHỒNG KHOẢNG (ví dụ C: 3500-5000 và
--    B: 5000-7999), một người lương 5000 sẽ ra mấy dòng? Vì sao
--    đây là lỗi nguy hiểm?
SELECT
    e.full_name,
    e.salary,
    g.grade
FROM
    employees e
    JOIN salary_grades g ON e.salary BETWEEN g.min_salary AND g.max_salary
ORDER BY
    e.salary DESC;

-- Sửa thành LEFT JOIN ở đây:


-- Trả lời của bạn:
-- a)
-- b)
-- c)
-- ============================================================
-- BÀI 3.8 — Tự làm
-- ============================================================
-- YÊU CẦU A:
-- Liệt kê nhân viên + tên phòng + tên sếp + bậc lương, ĐỦ 12 người.
-- (nối 4 bảng, trong đó employees xuất hiện 2 lần)
-- Viết query của bạn bên dưới:


-- YÊU CẦU B:
-- Mỗi phòng ban có bao nhiêu người và tổng quỹ lương bao nhiêu?
-- Đủ 5 phòng, Legal phải ra 0 và 0.
-- Viết query của bạn bên dưới:


-- YÊU CẦU C:
-- Tìm những nhân viên làm việc cho dự án KHÔNG THUỘC phòng ban của
-- chính họ. (gợi ý: nối employees -> assignments -> projects rồi so
-- sánh e.department_id với p.department_id; cẩn thận với NULL)
-- Viết query của bạn bên dưới:


-- YÊU CẦU D:
-- Với mỗi nhân viên, đếm xem có bao nhiêu người trong công ty lương
-- CAO HƠN họ. (self join non-equi: ON b.salary > a.salary, rồi
--  GROUP BY + COUNT — nhớ LEFT JOIN để người lương cao nhất ra 0)
-- Viết query của bạn bên dưới:


-- ============================================================
-- KẾT QUẢ THAM CHIẾU (chạy thật trên MySQL 8.0.45)
-- Chỉ xem sau khi đã tự làm xong!
-- ============================================================
-- BÀI 3.1 — SELF JOIN: 10 dòng
--   Vắng id 1 (Nguyen Van An) và id 12 (Truong Van Phuc): manager_id NULL.
--   b) Bỏ alias -> ERROR 1066 (42000): Not unique table/alias: 'employees'
--      MySQL không có cách nào biết `employees.id` là của bản nào.
--   c) CÓ. Nguyen Van An xuất hiện ở vai `m` (5 lần, làm sếp) và cũng
--      có mặt trong bảng `e` — chỉ là dòng của ông ấy bị INNER JOIN
--      loại vì bản thân ông không có sếp. Một dòng dữ liệu đóng được
--      nhiều vai cùng lúc; alias chính là tên vai.
--
-- BÀI 3.2 — lời giải:
--   SELECT e.id, e.full_name AS nhan_vien,
--          COALESCE(m.full_name, '(khong co sep)') AS quan_ly
--   FROM employees e LEFT JOIN employees m ON e.manager_id = m.id
--   ORDER BY e.id;
--   -> 12 dòng; id 1 và id 12 hiện '(khong co sep)'
--
-- BÀI 3.3 — lời giải (chú ý: quản lý đứng TRÁI):
--   SELECT m.id, m.full_name AS quan_ly, COUNT(e.id) AS so_cap_duoi
--   FROM employees m LEFT JOIN employees e ON e.manager_id = m.id
--   GROUP BY m.id, m.full_name
--   ORDER BY so_cap_duoi DESC, m.id;
--   +----+-----------------+-------------+
--   |  1 | Nguyen Van An   |           5 |
--   |  2 | Tran Thi Binh   |           2 |
--   |  5 | Hoang Thi Hoa   |           2 |
--   |  7 | Dang Ngoc Hanh  |           1 |
--   |  3 | Le Minh Cuong   |           0 |   <- 8 người còn lại đều 0
--   +----+-----------------+-------------+
--   Tổng = 5+2+2+1 = 10, đúng bằng số người có manager_id (12 - 2).
--   Dùng COUNT(*) sẽ ra 1 cho tất cả 8 người cuối — SAI.
--   Điều kiện ON lần này là `e.manager_id = m.id`, tức ĐẢO so với 3.1.
--   Cùng một bảng, cùng một cột, chỉ đổi vai -> đổi hẳn câu hỏi.
--
-- BÀI 3.4 — SELF JOIN ba tầng: 12 dòng
--   | Le Minh Cuong   | Tran Thi Binh  | Nguyen Van An |
--   | Tran Thi Binh   | Nguyen Van An  | NULL          |
--   | Truong Van Phuc | NULL           | NULL          |
--   b) Nếu lần JOIN thứ hai là INNER: chỉ còn 5 dòng (những người có
--      đủ 3 tầng). LEFT JOIN có tính "lây": một khi đã LEFT ở bước
--      trước, các bước sau cũng phải LEFT, nếu không sẽ mất lại đúng
--      những dòng mình vừa giữ được.
--   c) Cần RECURSIVE CTE (WITH RECURSIVE). JOIN chỉ đi được số tầng
--      mà bạn viết ra bằng tay.
--
-- BÀI 3.5 — ghép cặp:
--   a) `a.id < b.id`  -> 10 cặp (Eng 6, Sales 3, Marketing 1, HR 0)
--      Công thức: phòng n người cho n*(n-1)/2 cặp. 4->6, 3->3, 2->1, 1->0.
--   b) `a.id <> b.id` -> 20 dòng. Mỗi cặp xuất hiện 2 lần: (An,Binh)
--      và (Binh,An). Cùng một quan hệ, đếm hai lượt.
--   c) Bỏ hẳn -> 30 dòng. Thêm 10 dòng tự ghép với chính mình
--      (An,An), (Binh,Binh)... vì rõ ràng An cùng phòng với An.
--   d) `<>` loại được dòng tự ghép nhưng vẫn để lọt cặp đảo ngược.
--      `<` loại CẢ HAI cùng lúc — mỗi cặp đúng một lần. Đây là mẹo
--      chuẩn cho mọi bài toán "liệt kê các cặp".
--      (Ghi chú: Minh và Phuc không xuất hiện cặp nào vì department_id
--       NULL, mà NULL = NULL vẫn không đúng.)
--
-- BÀI 3.6 A — lời giải:
--   SELECT e.full_name, p.name AS project, a.hours
--   FROM assignments a
--   JOIN employees e ON e.id = a.employee_id
--   JOIN projects  p ON p.id = a.project_id
--   ORDER BY e.id, p.id;
--   -> 12 dòng. Bảng trung gian tự nó vô nghĩa; phải nối cả hai đầu
--      mới đọc được.
--
-- BÀI 3.6 B — lời giải:
--   SELECT e.id, e.full_name,
--          COUNT(a.project_id)        AS so_du_an,
--          COALESCE(SUM(a.hours), 0)  AS tong_gio
--   FROM employees e LEFT JOIN assignments a ON a.employee_id = e.id
--   GROUP BY e.id, e.full_name
--   ORDER BY so_du_an DESC, e.id;
--   +----+-----------------+----------+----------+
--   |  2 | Tran Thi Binh   |        2 |      180 |
--   |  3 | Le Minh Cuong   |        2 |      350 |
--   |  1 | Nguyen Van An   |        1 |       20 |
--   |  ...                                        |
--   | 10 | Ngo Huu Minh    |        0 |        0 |
--   | 12 | Truong Van Phuc |        0 |        0 |
--   +----+-----------------+----------+----------+
--   Không có COALESCE thì tong_gio của Minh/Phuc ra NULL.
--
-- BÀI 3.6 C — 10 cặp làm chung:
--   Website Redesign 3 cặp, Mobile App 3, CRM Migration 3, Brand Campaign 1.
--   b) Bỏ điều kiện `<` -> 32 dòng thay vì 10:
--        10 x 2 = 20 (mỗi cặp lặp 2 lần, xuôi và ngược)
--        +   12     (mỗi dòng assignments tự ghép với chính nó:
--                    a1 và a2 rơi vào ĐÚNG cùng một dòng -> (An, An))
--      => 32. Tự ghép là cái bẫy dễ quên nhất khi self-join.
--
-- BÀI 3.7 — NON-EQUI JOIN:
--   a) 11 dòng. Mất Truong Van Phuc (lương 2500) — bậc thấp nhất là
--      D bắt đầu từ 2600. Không khoảng nào chứa 2500 -> không ghép được.
--      Đây là lỗi dữ liệu rất hay gặp: bảng tra cứu có KHE HỞ, và
--      INNER JOIN im lặng nuốt mất bản ghi.
--   b) LEFT JOIN -> 12 dòng, Phuc có grade = NULL. Dùng LEFT JOIN
--      chính là cách PHÁT HIỆN ra khe hở đó.
--   c) Người lương 5000 sẽ ra HAI dòng (một cho C, một cho B). Nguy
--      hiểm vì bảng "12 nhân viên" bỗng thành 13 dòng, và mọi SUM/COUNT
--      phía sau đều sai. Bảng tra cứu theo khoảng BẮT BUỘC phải không
--      chồng lấn và không hở.
--
-- BÀI 3.8 A — lời giải:
--   SELECT e.full_name AS nhan_vien,
--          COALESCE(d.name, '-')         AS phong,
--          COALESCE(m.full_name, '-')    AS sep,
--          COALESCE(g.grade, '-')        AS bac_luong
--   FROM employees e
--   LEFT JOIN departments  d ON d.id = e.department_id
--   LEFT JOIN employees    m ON m.id = e.manager_id
--   LEFT JOIN salary_grades g ON e.salary BETWEEN g.min_salary AND g.max_salary
--   ORDER BY e.id;
--   -> 12 dòng. Tất cả đều phải là LEFT, chỉ cần một cái INNER là mất người.
--
-- BÀI 3.8 B — lời giải:
--   SELECT d.name AS phong, COUNT(e.id) AS so_nguoi,
--          COALESCE(SUM(e.salary), 0) AS quy_luong
--   FROM departments d LEFT JOIN employees e ON e.department_id = d.id
--   GROUP BY d.id, d.name ORDER BY d.id;
--   Engineering 4 / 23500.00 | Sales 3 / 12200.00 | Marketing 2 / 7800.00
--   HR 1 / 4500.00 | Legal 0 / 0.00
--   Lưu ý: 23500+12200+7800+4500 = 48000, còn tổng lương cả công ty là
--   53500 — chênh 5500 là lương của Minh (3000) và Phuc (2500), hai
--   người không thuộc phòng nào. Báo cáo gộp theo phòng LUÔN thiếu
--   những dòng mồ côi; phải biết mà nói rõ.
--
-- BÀI 3.8 C — lời giải:
--   SELECT e.full_name, d.name AS phong_cua_nguoi, p.name AS du_an
--   FROM employees e
--   JOIN assignments a ON a.employee_id = e.id
--   JOIN projects    p ON p.id = a.project_id
--   LEFT JOIN departments d ON d.id = e.department_id
--   WHERE NOT (e.department_id <=> p.department_id);
--   -> 0 dòng. Trong dữ liệu này ai cũng làm dự án của phòng mình.
--   Dùng toán tử <=> (NULL-safe equal) thay vì = để NULL không làm
--   điều kiện thành UNKNOWN. Thử đổi thành `WHERE e.department_id <>
--   p.department_id` — cũng ra 0 dòng, nhưng vì lý do KHÁC (mọi so
--   sánh dính NULL đều bị loại). Hai câu tình cờ cùng kết quả ở đây,
--   nhưng nói hai điều khác nhau.
--
-- BÀI 3.8 D — lời giải:
--   SELECT a.full_name, a.salary, COUNT(b.id) AS so_nguoi_luong_cao_hon
--   FROM employees a LEFT JOIN employees b ON b.salary > a.salary
--   GROUP BY a.id, a.full_name, a.salary
--   ORDER BY so_nguoi_luong_cao_hon;
--   -> An 0, Binh 1, Hoa 2, Hanh 3, Lan 4, Cuong 5, Dung 6, Nga 7,
--      Giang 8, Minh 9, Khanh 10, Phuc 11
--   Đây chính là RANK() làm bằng tay. Hàm cửa sổ làm việc này gọn hơn
--   nhiều, nhưng hiểu được cách JOIN làm ra nó thì mới nắm được bản chất.
--
-- KẾT LUẬN PHASE 3:
--   1. SELF JOIN: alias chính là "vai diễn". Đảo vai trong ON là đổi
--      hẳn câu hỏi (3.1 hỏi "sếp của tôi là ai", 3.3 hỏi "ai là lính của tôi").
--   2. LEFT JOIN có tính lây: đã LEFT thì các JOIN sau cũng phải LEFT.
--   3. Ghép cặp thì dùng `a.id < b.id`, không dùng `<>`.
--   4. Nhiều-nhiều luôn cần bảng trung gian và HAI lần JOIN.
--   5. ON không nhất thiết phải là "=". BETWEEN, <, > đều hợp lệ.
--      Nhưng bảng tra theo khoảng mà hở hoặc chồng lấn thì kết quả
--      sai hoặc mất dòng, và không ai báo cho bạn biết.
-- ============================================================
