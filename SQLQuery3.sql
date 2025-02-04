WITH TotalRevenue AS (
    SELECT SUM(total_price) AS Total_Revenue
    FROM pizza_sales
),
AvgOrderValue AS (
    SELECT SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value
    FROM pizza_sales
),
TotalPizzasSold AS (
    SELECT SUM(quantity) AS Total_Pizza_Sold
    FROM pizza_sales
),
TotalOrders AS (
    SELECT COUNT(DISTINCT order_id) AS Total_Orders
    FROM pizza_sales
),
AvgPizzasPerOrder AS (
    SELECT CAST(SUM(quantity) AS DECIMAL(10,2)) / CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS Avg_Pizzas_per_Order
    FROM pizza_sales
),
OrdersByDay AS (
    SELECT DATENAME(DW, order_date) AS Order_Day, COUNT(DISTINCT order_id) AS Total_Orders
    FROM pizza_sales
    GROUP BY DATENAME(DW, order_date)
),
OrdersByHour AS (
    SELECT DATEPART(HOUR, order_time) AS Order_Hours, COUNT(DISTINCT order_id) AS Total_Orders
    FROM pizza_sales
    GROUP BY DATEPART(HOUR, order_time)
),
RevenueByCategory AS (
    SELECT pizza_category, 
           CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue,
           CAST(SUM(total_price) * 100.0 / (SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS PCT
    FROM pizza_sales
    GROUP BY pizza_category
),
RevenueBySize AS (
    SELECT pizza_size, 
           CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue,
           CAST(SUM(total_price) * 100.0 / (SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS PCT
    FROM pizza_sales
    GROUP BY pizza_size
),
CategorySalesFebruary AS (
    SELECT pizza_category, SUM(quantity) AS Total_Quantity_Sold
    FROM pizza_sales
    WHERE MONTH(order_date) = 2
    GROUP BY pizza_category
),
Top5BestSellingPizzas AS (
    SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizza_Sold
    FROM pizza_sales
    GROUP BY pizza_name
    ORDER BY Total_Pizza_Sold DESC
),
Top5LeastSellingPizzas AS (
    SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizza_Sold
    FROM pizza_sales
    GROUP BY pizza_name
    ORDER BY Total_Pizza_Sold ASC
)
SELECT 
    -- Total Revenue and Average Order Value
    (SELECT Total_Revenue FROM TotalRevenue) AS Total_Revenue,
    (SELECT Avg_Order_Value FROM AvgOrderValue) AS Avg_Order_Value,

    -- Total Pizzas Sold and Orders
    (SELECT Total_Pizza_Sold FROM TotalPizzasSold) AS Total_Pizzas_Sold,
    (SELECT Total_Orders FROM TotalOrders) AS Total_Orders,

    -- Average Pizzas Per Order
    (SELECT Avg_Pizzas_per_Order FROM AvgPizzasPerOrder) AS Avg_Pizzas_per_Order,

    -- Orders by Day and Hour
    (SELECT STRING_AGG(CONCAT(Order_Day, ': ', Total_Orders), ', ') FROM OrdersByDay) AS Orders_By_Day,
    (SELECT STRING_AGG(CONCAT(Order_Hours, ': ', Total_Orders), ', ') FROM OrdersByHour) AS Orders_By_Hour,

    -- Revenue by Category and Size
    (SELECT STRING_AGG(CONCAT(pizza_category, ': ', Total_Revenue, ' (', PCT, '%)'), ', ') FROM RevenueByCategory) AS Revenue_By_Category,
    (SELECT STRING_AGG(CONCAT(pizza_size, ': ', Total_Revenue, ' (', PCT, '%)'), ', ') FROM RevenueBySize) AS Revenue_By_Size,

    -- Category Sales in February
    (SELECT STRING_AGG(CONCAT(pizza_category, ': ', Total_Quantity_Sold), ', ') FROM CategorySalesFebruary) AS February_Category_Sales,

    -- Top 5 Best-Selling and Least-Selling Pizzas
    (SELECT STRING_AGG(CONCAT(pizza_name, ': ', Total_Pizza_Sold), ', ') FROM Top5BestSellingPizzas) AS Top_5_Best_Selling_Pizzas,
    (SELECT STRING_AGG(CONCAT(pizza_name, ': ', Total_Pizza_Sold), ', ') FROM Top5LeastSellingPizzas) AS Top_5_Least_Selling_Pizzas;
