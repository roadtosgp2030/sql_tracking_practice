-- ============================================================
-- PHASE 2 — Subquery trong SELECT & FROM
-- ============================================================

-- ============================================================
-- BÀI 2.1 — Correlated Subquery trong SELECT
-- ============================================================

-- Dùng lại bảng products và orders từ phase 1.
USE subquery_cte;

-- YÊU CẦU:
-- Lấy toàn bộ sản phẩm, kèm theo số lượng đơn hàng của từng sản phẩm đó.
-- Hiển thị: id, name, price, total_orders (số đơn hàng, nếu không có thì hiển thị 0)
-- Sắp xếp theo total_orders giảm dần.

-- Gợi ý:
-- Subquery nằm ngay trong SELECT, tính 1 giá trị cho mỗi dòng của bảng ngoài.
-- Mỗi dòng products sẽ chạy subquery 1 lần để đếm số orders tương ứng.
-- Dùng COUNT(*) và lọc theo product_id của dòng đang xét.

-- Viết query của bạn bên dưới:
select id,
       name,
       price,
       (select count(*) from orders o where p.id = o.product_id) as total_orders
from products p
order by total_orders desc;


-- ============================================================
-- BÀI 2.2 — Derived Table (Subquery trong FROM)
-- ============================================================

-- YÊU CẦU:
-- Tìm các sản phẩm có tổng quantity đặt hàng cao hơn mức trung bình
-- tổng quantity của tất cả sản phẩm đã được order.
-- Hiển thị: product_id, total_qty
-- Sắp xếp theo total_qty giảm dần.

-- Gợi ý:
-- Bước 1: Tính total_qty theo từng product_id từ bảng orders (GROUP BY).
-- Bước 2: Dùng kết quả đó làm "bảng tạm" trong FROM, rồi lọc AVG(total_qty).
-- Subquery trong FROM phải có alias (tên bảng tạm).

-- Viết query của bạn bên dưới:
select *
from (select product_id, sum(quantity) as total_qty from orders group by product_id) as a
where a.total_qty >
      (select avg(total_qty) from (select sum(quantity) as total_qty from orders group by product_id) as b);


-- ============================================================
-- BÀI 2.3 — Ôn tập: Subquery nhiều tầng (1)
-- ============================================================

-- YÊU CẦU:
-- Tìm các category có giá trung bình sản phẩm CAO HƠN
-- giá trung bình của toàn bộ sản phẩm.
-- Hiển thị: category, avg_price (làm tròn 2 chữ số thập phân)
-- Sắp xếp theo avg_price giảm dần.

-- Gợi ý:
-- Bước 1: Tính avg_price theo từng category (derived table).
-- Bước 2: Lọc WHERE avg_price > avg_price toàn bảng (scalar subquery).

-- Viết query của bạn bên dưới:
select *
from (select category, round(avg(price), 2) as avg_price
      from products p
      group by category) as a
where avg_price > (select round(avg(price), 2) as avg_price from products);



-- ============================================================
-- BÀI 2.4 — Ôn tập: Subquery nhiều tầng (2)
-- ============================================================

-- YÊU CẦU:
-- Tìm sản phẩm có giá CAO NHẤT trong mỗi category.
-- Hiển thị: category, name, price
-- Sắp xếp theo price giảm dần.

-- Gợi ý:
-- Bước 1: Tính max_price theo từng category (derived table).
-- Bước 2: JOIN derived table đó với bảng products để lấy tên sản phẩm.

-- Viết query của bạn bên dưới:
select p.category, name, price
from products p
         join (select category, max(price) as max_price from products group by category) as a on p.price = a.max_price and a.category = p.category;


-- ============================================================
-- BÀI 2.5 — Ôn tập: Subquery nhiều tầng (3)
-- ============================================================

-- YÊU CẦU:
-- Tìm sản phẩm được đặt hàng nhiều nhất (theo tổng quantity).
-- Nếu có nhiều sản phẩm cùng tổng qty cao nhất, hiển thị tất cả.
-- Hiển thị: name, total_qty

-- Gợi ý:
-- Bước 1: Tính total_qty theo product_id (derived table).
-- Bước 2: Lọc WHERE total_qty = MAX(total_qty) của derived table đó.
--         MAX của derived table cần thêm 1 tầng subquery nữa.

-- Viết query của bạn bên dưới:
select name, total_qty
from (select product_id, sum(quantity) as total_qty
      from orders
      group by product_id) as a
         join products on product_id = products.id
where total_qty = (select max(sum_qty)
                   from (select sum(quantity) as sum_qty
                         from orders
                         group by product_id) as b);


