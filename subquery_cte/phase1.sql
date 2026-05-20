-- ============================================================
-- PHASE 1 — Subquery trong WHERE
-- (Chạy schema.sql trước)
-- ============================================================
USE subquery_cte;

-- ============================================================
-- BÀI 1.1 — Scalar Subquery trong WHERE
-- ============================================================

-- YÊU CẦU:
-- Lấy ra tất cả sản phẩm có giá CAO HƠN giá trung bình của toàn bộ sản phẩm.
-- Hiển thị: id, name, price
-- Sắp xếp theo price giảm dần.

-- Viết query của bạn bên dưới:
select id, name, price from products where price > (select avg(price) from products) order by price desc;


-- ============================================================
-- BÀI 1.2 — Subquery với IN / NOT IN
-- ============================================================

-- YÊU CẦU A:
-- Lấy ra tất cả sản phẩm ĐÃ từng được đặt hàng.
-- Hiển thị: id, name, price

-- YÊU CẦU B:
-- Lấy ra tất cả sản phẩm CHƯA bao giờ được đặt hàng.
-- Hiển thị: id, name, price

-- Viết query của bạn bên dưới:
select products.id, name, price from products join orders on products.id = orders.product_id group by products.id;

select products.id, name, price
from products
where id in (select product_id from orders);

select products.id, name, price
from products
         left join orders on products.id = orders.product_id
where orders.product_id is NULL;

select p.id, name, price
from products p
where not exists (
    select 1
    from orders o
    where o.product_id = p.id
);

select p.id, name, price
from products p
where p.id not in (select product_id from orders);


-- ============================================================
-- BÀI 1.3 — Subquery với EXISTS / NOT EXISTS
-- ============================================================

-- YÊU CẦU A:
-- Lấy ra tất cả sản phẩm có ít nhất 1 đơn hàng với quantity >= 3.
-- Hiển thị: id, name, price

-- YÊU CẦU B:
-- Lấy ra tất cả sản phẩm KHÔNG có đơn hàng nào với quantity >= 3.
-- Hiển thị: id, name, price

-- Viết query của bạn bên dưới:
select p.id, name, price
from products p
where exists (
    select 1
    from orders o
    where o.quantity >= 3 and p.id = o.product_id
);

select p.id, name, price
from products p
where not exists (
    select 1
    from orders o
    where o.quantity >= 3 and p.id = o.product_id
);
