-- Bucket theo tổng hóa đơn mua hàng
WITH gmv_bucket AS (
  SELECT 
    gmv,
    CASE 
      WHEN gmv < 50000 THEN '0-50k'
      WHEN gmv < 70000 THEN '50k-70k'
      WHEN gmv < 90000 THEN '70k-90k'
      WHEN gmv < 120000 THEN '90k-120k'
      ELSE '120k+'
    END AS gmv_range
  FROM `test_dataset.transaction_data`
)

SELECT 
  gmv_range,
  COUNT(*) AS so_luong_giao_dich
FROM gmv_bucket
GROUP BY gmv_range
ORDER BY so_luong_giao_dich DESC;


-- 3 người bán có khả năng gian lận
WITH seller_stats AS (
  SELECT 
    shop_id,
    COUNT(*) AS total_orders,
    AVG(gmv) AS avg_gmv,
    SUM(CASE WHEN rebate = 20000 THEN 1 ELSE 0 END) / COUNT(*) AS rebate_ratio
  FROM `test_dataset.transaction_data`
  GROUP BY shop_id
)

SELECT *
FROM seller_stats
WHERE rebate_ratio > 0.9   -- gần như toàn bộ đơn ăn max
  AND avg_gmv BETWEEN 70000 AND 90000
ORDER BY rebate_ratio DESC, total_orders DESC;

-- 3 người mua có khả năng gian lận
WITH buyer_stats AS (
  SELECT 
    uid,
    COUNT(*) AS total_orders,
    AVG(gmv) AS avg_gmv,
    SUM(CASE WHEN rebate = 20000 THEN 1 ELSE 0 END) / COUNT(*) AS rebate_ratio
  FROM `test_dataset.transaction_data`
  GROUP BY uid
)

SELECT *
FROM buyer_stats
WHERE rebate_ratio > 0.9
  AND avg_gmv BETWEEN 70000 AND 90000
ORDER BY rebate_ratio DESC, total_orders DESC;