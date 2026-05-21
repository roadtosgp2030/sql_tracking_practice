-- ============================================================
-- PHASE 3 — CTE (Common Table Expressions)
-- (Chạy schema.sql trước)
-- ============================================================
USE subquery_cte;

-- ============================================================
-- BÀI 3.1 — CTE đơn giản thay thế derived table
-- ============================================================
-- YÊU CẦU:
-- Viết lại bài 2.2 bằng CTE thay vì derived table.
-- Tìm các sản phẩm có tổng quantity đặt hàng cao hơn mức trung bình
-- tổng quantity của tất cả sản phẩm đã được order.
-- Hiển thị: product_id, total_qty
-- Sắp xếp theo total_qty giảm dần.
-- Gợi ý:
-- WITH ten_cte AS (SELECT ...) SELECT ... FROM ten_cte WHERE ...
-- Dùng 2 CTE nối tiếp nhau:
--   CTE 1: tính total_qty theo product_id
--   CTE 2: tính avg_total_qty từ CTE 1  (hoặc dùng scalar subquery trong WHERE)
-- Viết query của bạn bên dưới:
with product_quantity_totals as (
  select
    product_id,
    sum(quantity) as total_qty
  from
    orders
  group by
    product_id
),
avg_total_qty as (
  select
    avg(total_qty)
  from
    product_quantity_totals
)
select
  product_id,
  total_qty
from
  product_quantity_totals
where
  total_qty > (
    select
      *
    from
      avg_total_qty
  );

-- ============================================================
-- BÀI 3.2 — Nhiều CTE nối tiếp nhau
-- ============================================================
-- YÊU CẦU:
-- Tìm sản phẩm thuộc category có doanh thu (revenue) cao nhất.
-- Revenue của 1 category = SUM(price * quantity) của tất cả đơn hàng trong category đó.
-- Hiển thị: name, price, category
-- Sắp xếp theo price giảm dần.
-- Gợi ý — chia thành 3 CTE:
--   CTE 1: Tính revenue từng đơn hàng (JOIN products + orders để lấy price * quantity)
--   CTE 2: Tổng revenue theo category
--   CTE 3 (hoặc WHERE): Lọc ra category có revenue cao nhất
-- Viết query của bạn bên dưới:
with products_revenue as (
  select
    p.id,
    p.name,
    p.category,
    p.price,
    sum(quantity),
    sum(p.price * o.quantity) as revenue
  from
    products p
    join orders o on p.id = o.product_id
  group by
    p.id
),
total_revenue_by_category as (
  select
    category,
    sum(revenue) as category_revenue
  from
    products_revenue
  group by
    category
),
highest_revenue_category as (
  select
    category
  from
    total_revenue_by_category
  where
    category_revenue = (
      select
        max(category_revenue)
      from
        total_revenue_by_category
    )
)
select
  name,
  price,
  category
from
  products_revenue pr
where
  category = (
    select
      *
    from
      highest_revenue_category
  )
  and revenue = (
    select
      max(revenue)
    from
      products_revenue
    where
      category = (
        select
          *
        from
          highest_revenue_category
      )
  );

with revenue_order as (
  select
    o.id,
    sum(p.price * o.quantity) as order_revenue
  from
    products p
    join orders o on p.id = o.product_id
  group by
    o.id
),
revenue_by_category as (
  select
    p.category,
    sum(ro.order_revenue) as category_revenue
  from
    products p
    join orders o on p.id = o.product_id
    join revenue_order ro on o.id = ro.id
  group by
    p.category
),
highest_revenue_category as (
  select
    max(category_revenue)
  from
    revenue_by_category
)
select
  name,
  price,
  category
from
  products
where
  category = (
    select
      category
    from
      revenue_by_category
    where
      category_revenue = (
        select
          *
        from
          highest_revenue_category
      )
  );

-- ============================================================
-- BÀI 3.3 — CTE: So sánh với mức trung bình của category
-- ============================================================
-- YÊU CẦU:
-- Tìm các sản phẩm có giá cao hơn giá trung bình của chính category của nó.
-- Hiển thị: name, category, price, avg_price_in_category (làm tròn 2 chữ số)
-- Sắp xếp theo category, rồi price giảm dần.
-- Gợi ý:
--   CTE 1: Tính avg price theo từng category.
--   Sau đó JOIN CTE đó với products để so sánh.
-- Viết query của bạn bên dưới:
with avg_price_category as (
  select
    category,
    round(avg(price), 2) as avg_price_in_category
  from
    products
  group by
    category
)
select
  name,
  p.category,
  price,
  avg_price_in_category
from
  products p
  join avg_price_category apc on p.category = apc.category
where
  p.price > apc.avg_price_in_category;

-- ============================================================
-- BÀI 3.4 — CTE: Xếp hạng sản phẩm theo doanh thu
-- ============================================================
-- YÊU CẦU:
-- Tính tổng doanh thu (revenue = price * quantity) của từng sản phẩm đã được đặt hàng.
-- Hiển thị: name, total_revenue, revenue_rank
--   revenue_rank = 1 là sản phẩm có doanh thu cao nhất.
-- Sắp xếp theo revenue_rank tăng dần.
-- Gợi ý:
--   CTE 1: Tính total_revenue từng sản phẩm (JOIN products + orders).
--   Dùng RANK() hoặc ROW_NUMBER() trong SELECT cuối để đánh thứ hạng.
--   Cú pháp: RANK() OVER (ORDER BY total_revenue DESC)
-- Viết query của bạn bên dưới:
with total_revenue_product as (
  select
    name,
    price * sum(quantity) as total_revenue
  from
    products p
    join orders o on p.id = o.product_id
  group by
    p.id
)
select
  *,
  rank() over (
    order by
      total_revenue desc
  ) as revenue_rank
from
  total_revenue_product;

-- ============================================================
-- BÀI 3.5 — CTE: Tỉ lệ đóng góp doanh thu
-- ============================================================
-- YÊU CẦU:
-- Tính tỉ lệ % doanh thu của từng sản phẩm so với tổng doanh thu toàn bộ đơn hàng.
-- Hiển thị: name, total_revenue, revenue_pct (làm tròn 2 chữ số, ví dụ: 65.43)
-- Sắp xếp theo revenue_pct giảm dần.
-- Gợi ý:
--   CTE 1: Tính total_revenue từng sản phẩm.
--   CTE 2: Tính grand_total (tổng tất cả revenue).
--   SELECT cuối: tính revenue_pct = total_revenue / grand_total * 100.
-- Viết query của bạn bên dưới:
with total_revenue_product as (
  select
    name,
    price * sum(quantity) as total_revenue
  from
    products p
    join orders o on p.id = o.product_id
  group by
    p.id
),
grand_total as (
  select
    sum(total_revenue) as grand_total
  from
    total_revenue_product
)
select
  *,
  round(
    total_revenue / (
      select
        *
      from
        grand_total
    ) * 100,
    2
  ) as revenue_pct
from
  total_revenue_product
order by
  revenue_pct desc;