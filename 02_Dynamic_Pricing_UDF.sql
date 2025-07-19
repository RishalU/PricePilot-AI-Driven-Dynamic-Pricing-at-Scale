-- Databricks notebook source
-- MAGIC %python
-- MAGIC # Load Delta tables
-- MAGIC products_df = spark.read.format("delta").load("/delta/products")
-- MAGIC demand_df = spark.read.format("delta").load("/delta/demand")
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC from pyspark.sql.functions import col
-- MAGIC
-- MAGIC # We'll join demand and products on product_id (latest demand per product)
-- MAGIC latest_demand = demand_df.orderBy("timestamp", ascending=False) \
-- MAGIC     .dropDuplicates(["product_id"])
-- MAGIC
-- MAGIC joined_df = products_df.join(latest_demand, on="product_id", how="left")
-- MAGIC
-- MAGIC display(joined_df.select("product_id", "base_price", "demand_score", "competitor_price"))
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC from pyspark.sql.functions import udf
-- MAGIC from pyspark.sql.types import FloatType
-- MAGIC
-- MAGIC def dynamic_price(base_price, demand_score, competitor_price):
-- MAGIC     try:
-- MAGIC         if demand_score is None:
-- MAGIC             return float(base_price)
-- MAGIC         if demand_score > 0.8:
-- MAGIC             return float(base_price) + (0.1 * float(base_price))
-- MAGIC         elif demand_score < 0.3:
-- MAGIC             return float(base_price) - (0.15 * float(base_price))
-- MAGIC         else:
-- MAGIC             return float(base_price)
-- MAGIC     except:
-- MAGIC         return float(base_price)
-- MAGIC
-- MAGIC dynamic_price_udf = udf(dynamic_price, FloatType())
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # Add optimized_price column
-- MAGIC final_df = joined_df.withColumn("optimized_price", dynamic_price_udf(
-- MAGIC     col("base_price"), col("demand_score"), col("competitor_price")
-- MAGIC ))
-- MAGIC
-- MAGIC # Preview result
-- MAGIC display(final_df.select("product_id", "base_price", "optimized_price", "demand_score"))
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC final_df.write.format("delta").mode("overwrite").save("/delta/optimized_prices")
-- MAGIC

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS optimized_prices
USING DELTA
LOCATION '/delta/optimized_prices';
