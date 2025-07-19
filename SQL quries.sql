-- Databricks notebook source
SELECT 
  category,
  ROUND(AVG(base_price), 2) AS avg_base_price,
  ROUND(AVG(optimized_price), 2) AS avg_optimized_price,
  ROUND(AVG(optimized_price - base_price), 2) AS avg_delta
FROM optimized_prices
GROUP BY category
ORDER BY avg_delta DESC;


-- COMMAND ----------

SELECT 
  product_id, 
  name,
  base_price,
  optimized_price,
  ROUND(optimized_price - base_price, 2) AS price_increase
FROM optimized_prices
ORDER BY price_increase DESC
LIMIT 10;


-- COMMAND ----------

SELECT 
  product_id,
  name,
  ROUND(demand_score, 2) AS demand,
  ROUND(optimized_price, 2) AS new_price
FROM optimized_prices
ORDER BY demand DESC
LIMIT 20;


-- COMMAND ----------

SELECT 
  product_id, 
  name,
  base_price,
  optimized_price,
  ROUND(base_price - optimized_price, 2) AS price_drop
FROM optimized_prices
WHERE optimized_price < base_price
ORDER BY price_drop DESC
LIMIT 10;


-- COMMAND ----------

SELECT 
  product_id,
  name,
  base_price,
  optimized_price,
  demand_score
FROM optimized_prices
WHERE ROUND(optimized_price - base_price, 2) = 0
  AND demand_score > 0.75
ORDER BY demand_score DESC;


-- COMMAND ----------

SELECT 
  product_id,
  name,
  base_price,
  competitor_price,
  optimized_price,
  ROUND(optimized_price - competitor_price, 2) AS diff_vs_competitor
FROM optimized_prices
ORDER BY diff_vs_competitor DESC;


-- COMMAND ----------

SELECT
  product_id,
  name,
  category,
  base_price,
  optimized_price,
  demand_score,
  CASE
    WHEN demand_score >= 0.8 THEN 'High Demand'
    WHEN demand_score >= 0.5 THEN 'Medium Demand'
    ELSE 'Low Demand'
  END AS demand_segment
FROM optimized_prices
ORDER BY demand_segment DESC, product_id;