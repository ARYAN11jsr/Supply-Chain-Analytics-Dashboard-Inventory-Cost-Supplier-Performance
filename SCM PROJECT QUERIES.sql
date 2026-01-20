--select * from [dbo].['SCM PROJECT Processed DATASET$']
SELECT * FROM SCM_INVENTORY

--Q1. Which SKUs have Days of Inventory higher than the overall average, indicating relatively slow-moving inventory?
SELECT SKU_ID,
SKU_Name,
days_of_inventory 
FROM  scm_inventory
WHERE days_of_inventory > (SELECT AVG(days_of_inventory) FROM scm_inventory)
ORDER BY days_of_inventory DESC;

--Q2. Which SKUs are at risk of stockout?
SELECT SKU_ID,
SKU_Name,
Quantity_on_hand,
reorder_point  FROM scm_inventory
where quantity_on_hand<=reorder_point ;

--Q3. What is the total inventory value with resoect to each category ?
SELECT CATEGORY,
SUM(TOTAL_INVENTORY_VALUE_USD) as TOTAL_INVENTORY_VALUE 
FROM scm_inventory
GROUP BY CATEGORY
ORDER BY TOTAL_INVENTORY_VALUE DESC;

--Q4. What are average days of inventory with respect to various warehouses?
SELECT WAREHOUSE_ID, 
WAREHOUSE_LOCATION, 
ROUND(AVG(days_of_inventory),2) as AVG_DOI
FROM SCM_INVENTORY
GROUP BY WAREHOUSE_ID, 
WAREHOUSE_LOCATION ;

--Q5.What are the top 10 SKUs holding the maximum inventory value?
SELECT TOP(10) SKU_ID,SKU_NAME,
TOTAL_INVENTORY_VALUE_USD 
FROM scm_inventory
ORDER BY TOTAL_INVENTORY_VALUE_USD DESC;

--Q6. What is the Inventory value contribution by ABC class ?
SELECT ABC_class,
SUM(TOTAL_INVENTORY_VALUE_USD) AS TOTAL_INVENTORY_VALUE
FROM scm_inventory
GROUP BY ABC_CLASS;

--Q7. Which high-value SKUs are moving slowly and may be tying up working capital?
SELECT SKU_ID, SKU_Name, 
AVG_DAILY_SALES, TOTAL_INVENTORY_VALUE_USD
FROM scm_inventory
WHERE AVG_DAILY_SALES < (SELECT AVG(avg_daily_sales) FROM scm_inventory)
AND TOTAL_INVENTORY_VALUE_USD > (SELECT AVG(TOTAL_INVENTORY_VALUE_USD) FROM scm_inventory)
ORDER BY TOTAL_INVENTORY_VALUE_USD ASC;

--Q8. What are the SKUs with declining demand (high churn rate) ?
SELECT SKU_ID,SKU_NAME,
SKU_CHURN_RATE FROM scm_inventory
WHERE SKU_Churn_Rate > 5
ORDER BY SKU_Churn_Rate DESC;

--Q9. How does each product category contribute to overall monthly demand?
SELECT CATEGORY, 
SUM(FORECAST_NEXT_30D) AS FORECAST_30D 
FROM scm_inventory
GROUP BY CATEGORY;

--Q10. Which SKUs have a demand–supply gap higher than the overall average?
SELECT SKU_ID,SKU_NAME,GAP_Percentage 
FROM SCM_INVENTORY
WHERE GAP_Percentage > (select avg(gap_percentage) from scm_inventory)
ORDER BY GAP_PERCENTAGE DESC;

--Q11. What is the average on-time delivery performance for each supplier?
SELECT SUPPLIER_NAME,
ROUND(AVG(Supplier_OnTime_Pct),2) as AVG_ONTIME_DP
FROM scm_inventory
GROUP BY SUPPLIER_NAME
ORDER BY AVG_ONTIME_DP DESC;

--Q12. Who are the Suppliers causing frequent delays (actual > expected lead time) ?
SELECT Supplier_Name,count(*) as Delayed_Orders FROM scm_inventory
WHERE Actual_Lead_Time_Days > Expected_Lead_Time_Days
GROUP BY Supplier_Name
ORDER BY Delayed_Orders DESC ;

--Q13. What is average lead time per supplier ?
SELECT Supplier_Name,
ROUND(AVG(Actual_Lead_Time_Days),2) as Avg_Lead_Time FROM scm_inventory
GROUP BY Supplier_Name 
ORDER BY Avg_Lead_Time DESC;

--Q14.What is the  Supplier contribution to total inventory value ?
SELECT Supplier_Name,
SUM(Total_Inventory_Value_USD) AS inventory_value FROM scm_inventory
GROUP BY Supplier_Name
ORDER BY inventory_value DESC;

--Q15. What is the total damaged quantity for each warehouse?
SELECT Warehouse_ID,Warehouse_Location,
SUM(DAMAGED_QTY) AS TOTAL_DAMAGED_QUANTITY FROM scm_inventory
GROUP BY Warehouse_ID,Warehouse_Location
ORDER BY TOTAL_DAMAGED_QUANTITY DESC ;

--Q16. Which  Warehouse has the highest return rate ?
SELECT Warehouse_ID,Warehouse_Location,
SUM(Returns_Qty) AS TOTAL_RETURNS FROM scm_inventory
GROUP BY Warehouse_ID,Warehouse_Location
ORDER  BY TOTAL_RETURNS DESC ;

--Q17. Which SKUs are approaching expiry based on inventory aging?
SELECT SKU_ID, SKU_Name, Expiry_Date, Stock_Age_Days
FROM scm_inventory
WHERE Inventory_Status = 'Expiring Soon' ;

--Q18.How many SKUs are managed using FIFO versus FEFO?
SELECT FIFO_FEFO , 
COUNT(*) AS SKU_COUNT FROM scm_inventory
GROUP BY FIFO_FEFO;

--Q19. How does forecast accuracy vary across different product categories?
SELECT CATEGORY,
ROUND(AVG(Demand_Forecast_Accuracy_Pct),4)*100 AS AVG_ACCURACY  
FROM scm_inventory
GROUP BY CATEGORY 
ORDER BY Category;

--Q20. What are the SKUs with poor forecast accuracy ?
SELECT SKU_ID, SKU_Name,
Demand_Forecast_Accuracy_Pct
FROM scm_inventory
WHERE Demand_Forecast_Accuracy_Pct < 0.70;

--Q21. Which are the SKUs whose forecasted demand exceeds available stock ?
SELECT SKU_ID, SKU_Name, Forecast_Next_30d,
Quantity_On_Hand
FROM scm_inventory
WHERE Forecast_Next_30d > Quantity_On_Hand;

--Q22. What is the inventory count variance for each warehouse?
SELECT Warehouse_ID,
ROUND(AVG(Count_Variance),3) AS avg_variance
FROM scm_inventory
GROUP BY Warehouse_ID;

--Q23. What are the latest inventory audit results for each SKU?
SELECT SKU_ID, SKU_Name, Audit_Date, Count_Variance
FROM scm_inventory
ORDER BY Audit_Date DESC;

--Q24. How does average unit cost vary across different product categories?
SELECT Category,
ROUND(AVG(Unit_Cost_USD),2) AS avg_unit_cost
FROM scm_inventory
GROUP BY Category;

--Q25.Which SKUs have experienced rising procurement costs over time?
SELECT SKU_ID, SKU_Name, 
Unit_Cost_USD, Last_Purchase_Price_USD
FROM scm_inventory
WHERE Last_Purchase_Price_USD > Unit_Cost_USD;

--Q26. What is the total inventory value held at each warehouse?
SELECT Warehouse_ID,
SUM(Total_Inventory_Value_USD) AS locked_capital
FROM scm_inventory
GROUP BY Warehouse_ID
ORDER BY locked_capital DESC;

--Q27. Which A-class SKUs are slow-moving and pose a high inventory risk?
SELECT SKU_ID, SKU_Name, ABC_Class, Avg_Daily_Sales
FROM scm_inventory
WHERE ABC_Class = 'A'
AND Avg_Daily_Sales <  (SELECT AVG(Avg_Daily_Sales) FROM scm_inventory)
ORDER BY Avg_Daily_Sales;

--Q28. Which SKUs have safety stock coverage higher than the average?
SELECT SKU_ID, SKU_Name, Safety_Stock, Avg_Daily_Sales
FROM scm_inventory
WHERE Safety_Stock >
(SELECT AVG(Safety_Stock / Avg_Daily_Sales) FROM scm_inventory) ;

--Q29. What is the distribution of inventory status across all SKUs?
SELECT Inventory_Status,
COUNT(*) AS SKU_COUNT
FROM scm_inventory
GROUP BY Inventory_Status;

--Q30. What percentage of total inventory value is contributed by top SKUs?
WITH X AS (
    SELECT SKU_ID,SKU_Name,Total_Inventory_Value_USD,
        SUM(Total_Inventory_Value_USD) OVER () AS total_inventory_value,
        SUM(Total_Inventory_Value_USD) OVER (ORDER BY Total_Inventory_Value_USD DESC) AS cumulative_inventory_value
    FROM scm_inventory
)
SELECT SKU_ID,SKU_Name,Total_Inventory_Value_USD,
ROUND((cumulative_inventory_value * 100.0) / total_inventory_value, 2) AS cumulative_inventory_value_pct
FROM X
ORDER BY Total_Inventory_Value_USD DESC;

--Q31. Which SKUs contribute the highest inventory value within each warehouse?
WITH Y AS (
    SELECT Warehouse_ID,Warehouse_Location,SKU_ID,SKU_Name,Total_Inventory_Value_USD,
        RANK() OVER (PARTITION BY Warehouse_ID ORDER BY Total_Inventory_Value_USD DESC) AS value_rank
    FROM scm_inventory
)
SELECT Warehouse_ID,Warehouse_Location,SKU_ID,SKU_Name,
Total_Inventory_Value_USD,value_rank
FROM Y
WHERE value_rank <= 3
ORDER BY Warehouse_ID, value_rank;

--Q32. How do suppliers rank based on on-time delivery and lead time performance?
WITH supplier_performance AS (
    SELECT Supplier_Name,
    ROUND(AVG(Supplier_OnTime_Pct),3) AS avg_ontime_pct,
    ROUND(AVG(Actual_Lead_Time_Days),3) AS avg_lead_time
    FROM scm_inventory
    GROUP BY Supplier_Name
)
SELECT
    Supplier_Name,avg_ontime_pct,avg_lead_time,
    RANK() OVER (
        ORDER BY avg_ontime_pct DESC,
                 avg_lead_time ASC
    ) AS supplier_rank
FROM supplier_performance
ORDER BY supplier_rank;

--Q33. Which SKUs fall in the top quartile of demand–supply gap magnitude?
WITH gap_ranked AS (
    SELECT
        SKU_ID,
        SKU_Name,
        Gap_Percentage,
        NTILE(4) OVER (
            ORDER BY [Gap %] DESC
        ) AS gap_quartile
    FROM scm_inventory
)
SELECT
    SKU_ID,
    SKU_Name,
    Gap_Percentage
FROM gap_ranked
WHERE gap_quartile = 1
ORDER BY Gap_Percentage DESC;

--Q34. Which A-class SKUs fall in the bottom quartile of sales velocity?
WITH a_class_sales_rank AS (
    SELECT
        SKU_ID,
        SKU_Name,
        ABC_Class,
        Avg_Daily_Sales,
        NTILE(4) OVER (
            ORDER BY Avg_Daily_Sales ASC
        ) AS sales_quartile
    FROM scm_inventory
    WHERE ABC_Class = 'A'
)
SELECT
    SKU_ID,
    SKU_Name,
    Avg_Daily_Sales
FROM a_class_sales_rank
WHERE sales_quartile = 1
ORDER BY Avg_Daily_Sales ASC;

--Q35. What is the inventory turnover ratio for each SKU based on annualized demand?
SELECT SKU_ID, SKU_Name,
       Avg_Daily_Sales,
       Quantity_On_Hand,
       (Avg_Daily_Sales * 365.0 / NULLIF(Quantity_On_Hand,0)) AS turnover_ratio
FROM scm_inventory;







