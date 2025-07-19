# Databricks notebook source
# Load products
products_df = spark.read.format("csv") \
    .option("header", True) \
    .option("inferSchema", True) \
    .load("/FileStore/tables/products_large.csv")

# Load sales
sales_df = spark.read.format("csv") \
    .option("header", True) \
    .option("inferSchema", True) \
    .load("/FileStore/tables/sales_large.csv")

# Load demand
demand_df = spark.read.format("csv") \
    .option("header", True) \
    .option("inferSchema", True) \
    .load("/FileStore/tables/demand_large.csv")

# Preview
display(products_df)
display(demand_df)
display(sales_df)

# COMMAND ----------

# Save as Delta tables
products_df.write.format("delta").mode("overwrite").save("/delta/products")
sales_df.write.format("delta").mode("overwrite").save("/delta/sales")
demand_df.write.format("delta").mode("overwrite").save("/delta/demand")

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS products
# MAGIC USING DELTA
# MAGIC LOCATION '/delta/products';
# MAGIC
# MAGIC CREATE TABLE IF NOT EXISTS sales
# MAGIC USING DELTA
# MAGIC LOCATION '/delta/sales';
# MAGIC
# MAGIC CREATE TABLE IF NOT EXISTS demand
# MAGIC USING DELTA
# MAGIC LOCATION '/delta/demand';
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM products LIMIT 5;
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC select * from demand where demand_score <0.2;
# MAGIC