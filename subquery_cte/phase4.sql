-- ============================================================
-- PHASE 4 — Kết hợp & Thực tế
-- (Chạy schema.sql trước)
-- ============================================================
USE subquery_cte;

-- ============================================================
-- BÀI 4.1 — Top N per group
-- ============================================================
-- YÊU CẦU:
-- Lấy 2 sản phẩm có giá cao nhất trong mỗi category.
-- Hiển thị: category, name, price, price_rank
-- Sắp xếp theo category, rồi price_rank tăng dần.
-- Gợi ý:
--   CTE: Dùng RANK() OVER (PARTITION BY category ORDER BY price DESC) để xếp hạng
--        trong từng category riêng biệt.
--   SELECT cuối: Lọc WHERE price_rank <= 2.
--   PARTITION BY là điểm mới — chia window function theo từng nhóm.
-- Viết query của bạn bên dưới:
with products_with_rank as (
     select
          *,
          rank() over (
               partition by category
               order by
                    price desc
          ) as price_rank
     from
          products
)
select
     *
from
     products_with_rank
where
     price_rank <= 2
order by
     category,
     price_rank;

-- ============================================================
-- BÀI 4.2 — Running Total
-- ============================================================
-- YÊU CẦU:
-- Tính doanh thu tích lũy (running total) theo ngày đặt hàng.
-- Mỗi dòng hiển thị: order_date, daily_revenue, running_total
--   daily_revenue = tổng revenue trong ngày đó
--   running_total = tổng revenue từ đầu đến ngày đó (cộng dồn)
-- Sắp xếp theo order_date tăng dần.
-- Gợi ý:
--   CTE: Tính daily_revenue theo order_date (JOIN products + orders, GROUP BY order_date).
--   SELECT cuối: Dùng SUM() OVER (ORDER BY order_date) để tính running total.
--   SUM() OVER (ORDER BY ...) tự động cộng dồn từng dòng theo thứ tự.
-- Viết query của bạn bên dưới:
with order_revenue as (
     select
          order_date,
          p.price * o.quantity as order_revenue
     from
          products p
          join orders o on p.id = o.product_id
),
daily_revenue as (
     select
          order_date,
          sum(order_revenue) as daily_revenue
     from
          order_revenue
     group by
          order_date
)
select
     *,
     sum(daily_revenue) over (
          order by
               order_date
     ) as running_total
from
     daily_revenue;

-- ============================================================
-- BÀI 4.3 — Phân loại sản phẩm theo mức giá
-- ============================================================
-- YÊU CẦU:
-- Phân loại từng sản phẩm vào nhóm dựa trên giá so với trung bình toàn bảng:
--   'Above Average' — giá cao hơn trung bình
--   'Below Average' — giá thấp hơn hoặc bằng trung bình
-- Hiển thị: name, price, avg_price, price_segment
-- Sắp xếp theo price giảm dần.
-- Gợi ý:
--   CTE: Tính avg_price toàn bảng (1 giá trị).
--   SELECT cuối: CROSS JOIN với CTE đó, dùng CASE WHEN để phân loại.
--   CROSS JOIN với 1 dòng = gắn giá trị avg vào mọi dòng mà không cần subquery lồng.
-- Viết query của bạn bên dưới:
with avg_price_table as (
     select
          round(avg(price), 2) as avg_price
     from
          products
)
select
     name,
     price,
     avg_price,
     case
          when price > avg_price then 'Above Average'
          else 'Below Average'
     end as price_segment
from
     products
     join avg_price_table;