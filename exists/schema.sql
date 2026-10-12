-- ============================================================
-- SCHEMA & DATA — Dùng chung cho tất cả các phase
-- ============================================================
-- EXISTS là chủ đề về "CÓ TỒN TẠI HAY KHÔNG", không phải về giá trị.
-- Dữ liệu vẫn NHỎ và ĐẾM ĐƯỢC BẰNG MẮT như các lab khác:
--   students    :  8 dòng
--   courses     :  8 dòng
--   enrollments : 15 dòng
--   drop_requests:  4 dòng
--
-- Bẫy cố ý cài sẵn (bám sát các bài học riêng của EXISTS):
--   - students: 'Nguyen Van A' xuất hiện ở id 1 VÀ id 8 — hai người
--     khác nhau trùng tên (giống lab distinct), dùng để chứng minh
--     EXISTS không mắc bẫy gộp nhầm hai người như DISTINCT full_name.
--   - Vu Thi Phuong (id 6): CHƯA đăng ký môn nào.
--   - Hoi Hoa (course id 8): CHƯA có ai đăng ký, và thuộc khoa
--     'Nghe Thuat' — khoa duy nhất không ai theo học.
--   - enrollments.grade: có NULL (id 3 môn 2, id 5 môn 4) — nghĩa là
--     CHƯA CÓ ĐIỂM, không phải điểm 0.
--   - drop_requests.student_id: có ĐÚNG 1 dòng NULL (đơn giấy nộp tay,
--     chưa xác định là sinh viên nào) — đây là quả bom của cả lab,
--     dùng để cho nổ tung NOT IN ở phase 2.
--
-- Chạy file này 1 lần:  mysql -u root < schema.sql
-- ============================================================
DROP DATABASE IF EXISTS exists_lab;

CREATE DATABASE exists_lab;

USE exists_lab;

-- ------------------------------------------------------------
-- BẢNG students — sinh viên
-- ------------------------------------------------------------
CREATE TABLE students (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    major VARCHAR(20) NOT NULL,
    city VARCHAR(30) NULL
) ENGINE = InnoDB;

INSERT INTO
    students (id, full_name, major, city)
VALUES
    (1, 'Nguyen Van A',  'CNTT',      'Ha Noi'),
    (2, 'Tran Thi B',    'CNTT',      'Ho Chi Minh'),
    (3, 'Le Van C',      'CNTT',      'Ha Noi'),
    (4, 'Pham Thi D',    'Kinh Te',   'Da Nang'),
    (5, 'Hoang Van E',   'Kinh Te',   NULL),
    (6, 'Vu Thi Phuong', 'Ngoai Ngu', 'Ha Noi'),   -- <- chưa đăng ký môn nào
    (7, 'Dang Van G',    'Ngoai Ngu', 'Ho Chi Minh'),
    (8, 'Nguyen Van A',  'Kinh Te',   'Da Nang');  -- <- trùng tên id 1

-- ------------------------------------------------------------
-- BẢNG courses — môn học
-- ------------------------------------------------------------
CREATE TABLE courses (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    department VARCHAR(20) NOT NULL,
    credit TINYINT UNSIGNED NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    courses (id, name, department, credit)
VALUES
    (1, 'Lap Trinh C',     'CNTT',       3),
    (2, 'Co So Du Lieu',   'CNTT',       4),
    (3, 'Mang May Tinh',   'CNTT',       3),
    (4, 'Kinh Te Vi Mo',   'Kinh Te',    3),
    (5, 'Marketing',       'Kinh Te',    3),
    (6, 'Tieng Anh 1',     'Ngoai Ngu',  2),
    (7, 'Tieng Anh 2',     'Ngoai Ngu',  2),
    (8, 'Hoi Hoa',         'Nghe Thuat', 2); -- <- chưa ai đăng ký

-- ------------------------------------------------------------
-- BẢNG enrollments — kết quả đăng ký + điểm
-- grade NULL = chưa có điểm (đang chờ thi), KHÔNG PHẢI điểm 0.
-- ------------------------------------------------------------
CREATE TABLE enrollments (
    student_id INT UNSIGNED NOT NULL,
    course_id INT UNSIGNED NOT NULL,
    semester VARCHAR(10) NOT NULL,
    grade DECIMAL(3, 1) NULL,
    PRIMARY KEY (student_id, course_id, semester)
) ENGINE = InnoDB;

INSERT INTO
    enrollments (student_id, course_id, semester, grade)
VALUES
    (1, 1, '2024HK1', 8.5),
    (1, 2, '2024HK1', 9.0),
    (1, 3, '2024HK2', 7.5), -- SV 1: học đủ 3 môn CNTT (1,2,3)
    (2, 1, '2024HK1', 6.0),
    (2, 2, '2024HK1', 7.0), -- SV 2: thiếu môn 3
    (3, 1, '2024HK1', 5.5),
    (3, 2, '2024HK1', NULL), -- <- chưa có điểm
    (3, 3, '2024HK2', 8.0), -- SV 3: cũng học đủ 3 môn CNTT
    (4, 4, '2024HK1', 7.0),
    (4, 5, '2024HK1', 8.0), -- SV 4: học đủ 2 môn Kinh Te
    (5, 4, '2024HK1', NULL), -- <- chưa có điểm
    (7, 6, '2024HK1', 9.0),
    (7, 7, '2024HK1', 8.5),
    (8, 2, '2024HK1', 9.5), -- SV 8 (trùng tên SV 1) học chung môn 2
    (8, 4, '2024HK2', 7.0); -- và học chéo sang Kinh Te
-- SV 6 KHÔNG có dòng nào. Môn 8 (Hoi Hoa) KHÔNG có dòng nào.

-- ------------------------------------------------------------
-- BẢNG drop_requests — đơn xin rút môn
-- student_id CHO PHÉP NULL: đơn nộp giấy, nhân viên chưa kịp nhập
-- tên sinh viên vào hệ thống. Đây là dữ liệu THẬT trông như thế nào.
-- ------------------------------------------------------------
CREATE TABLE drop_requests (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    student_id INT UNSIGNED NULL,
    course_id INT UNSIGNED NOT NULL,
    requested_on DATE NOT NULL
) ENGINE = InnoDB;

INSERT INTO
    drop_requests (id, student_id, course_id, requested_on)
VALUES
    (1, 2,    1, '2024-03-01'),
    (2, NULL, 4, '2024-03-02'), -- <- đơn giấy, chưa rõ là ai
    (3, 5,    4, '2024-03-03'),
    (4, 1,    3, '2024-03-10');

-- ------------------------------------------------------------
-- Kiểm tra nhanh: 8 / 8 / 15 / 4
-- ------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM students)      AS students,
    (SELECT COUNT(*) FROM courses)       AS courses,
    (SELECT COUNT(*) FROM enrollments)   AS enrollments,
    (SELECT COUNT(*) FROM drop_requests) AS drop_requests;
