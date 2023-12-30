/*

Project Objective:
Design a comprehensive data analysis project using the Northwind sample database 
in SQL to gain insights into the operations of a fictional company. 
The goal is to extract valuable information from the database to support 
decision-making and improve business processes.

To gain insights into the operations of a fictional company that own's Northwind database, we join, group and sort data using sub-queries, CTEs and Temporary tables. 
We also perform various calculations using (+,*,-), CASE statements and likes to extract valuable information from the database

*/

SELECT *
FROM Northwind.dbo.Orders


-- Sales Analysis
SELECT
	OrderID,
	(UnitPrice*Quantity) total_sales
FROM Northwind.dbo.[Order Details]
ORDER BY
	(UnitPrice*Quantity) DESC

-- How many Unique products are there? - 77 Products
SELECT COUNT(*) FROM Northwind.dbo.Products

-- How many products are in Order details? - 77 Products in Order details
SELECT * FROM Northwind.dbo.[Order Details]

--Lets calculate the total sales of each Product
-- Quantities bought each time product was ordered
SELECT
	Products.ProductID, OrderID, [Order Details].UnitPrice, [Order Details].Quantity,
	CASE
		WHEN [Order Details].Discount != 0
		THEN ([Order Details].UnitPrice*Quantity*Discount)
	ELSE
		([Order Details].UnitPrice*Quantity)
	END AS Total_Sales
FROM Northwind.dbo.Products
RIGHT JOIN
	Northwind.dbo.[Order Details] ON
	Products.ProductID = [Order Details].ProductID
ORDER BY Total_Sales DESC

-- Total Sales for each Product
-- Our best sellers by total sales
SELECT
	Products.ProductID, COUNT(*) orders,
	SUM(CASE
			WHEN [Order Details].Discount != 0
			THEN ([Order Details].UnitPrice*Quantity*Discount)
		ELSE
			([Order Details].UnitPrice*Quantity)
		END) AS Total_Sales
FROM Northwind.dbo.Products
RIGHT JOIN
	Northwind.dbo.[Order Details] ON
	Products.ProductID = [Order Details].ProductID
GROUP BY Products.ProductID
ORDER BY Total_Sales DESC

--How do sales vary across different regions?
-- lets find where our customers live from the Orders and Customer Tables

SELECT
	ShipRegion, COUNT(*) num_customers
FROM Northwind.dbo.Orders
GROUP BY ShipRegion
ORDER BY COUNT(*) DESC

-- Lets find how much money we are making in each region
-- Here we also find the distribution of our customers by region
SELECT
	Orders.ShipRegion, COUNT(*) customers,
	SUM(CASE
			WHEN [Order Details].Discount != 0
			THEN ([Order Details].UnitPrice*Quantity*Discount)
		ELSE
			([Order Details].UnitPrice*Quantity)
		END) AS Total_Sales
FROM Northwind.dbo.Orders
LEFT JOIN Northwind.dbo.[Order Details]
ON Orders.OrderID = [Order Details].OrderID
GROUP BY Orders.ShipRegion
ORDER BY Total_Sales DESC

-- *CUSTOMER INSIGHT*
-- Who are the top customers in terms of spending?
-- lets use the order details table, the customer and the orders table

-- lets join customer and orders table to find out how many orders each customer made
SELECT Customers.CustomerID, COUNT(*) orders
FROM Northwind.dbo.Customers
LEFT JOIN
	Northwind.dbo.Orders ON
	Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerID
ORDER BY orders DESC

-- Lets find out how much each of our customers have spent
-- Now we know our Top customers
SELECT Customers.CustomerID, COUNT(*) quantities,
SUM(
	CASE
		WHEN [Order Details].Discount != 0
		THEN ([Order Details].UnitPrice*Quantity*Discount)
	ELSE
		([Order Details].UnitPrice*Quantity)
	END) AS Total_Sales
FROM Northwind.dbo.Customers
LEFT JOIN
	Northwind.dbo.Orders ON
	Customers.CustomerID = Orders.CustomerID
LEFT JOIN
	Northwind.dbo.[Order Details] ON
	Orders.OrderID = [Order Details].OrderID
GROUP BY Customers.CustomerID
ORDER BY Total_Sales DESC

-- How often do customers make repeat purchase?
SELECT
    CustomerID,
    COUNT(OrderID) AS NumberOfOrders,
    CASE
        WHEN COUNT(OrderID) > 1 
		THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS CustomerType
FROM
    Northwind.dbo.Orders
GROUP BY
    CustomerID
ORDER BY
    NumberOfOrders DESC;

--ORDER PROCESSING
--What is the average time taken to process an order?
SELECT 
	AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS avg_shipping_time
FROM Northwind.dbo.Orders

-- Are there any patterns in the time it takes to fulfill different types of orders?

-- Not all items were shipped on time
SELECT
    OrderType,
    AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS AvgProcessingTime
FROM (
    SELECT
        OrderID,
        OrderDate,
        ShippedDate,
        CASE
            WHEN ShippedDate IS NOT NULL THEN 'Shipped on Time'
            ELSE 'Not Shipped on Time'
        END AS OrderType
    FROM
        Northwind.dbo.Orders
) AS OrderTypes
GROUP BY
    OrderType;


SELECT 
	Orders.OrderID, [Order Details].ProductID,
	[Order Details].Quantity,
	DATENAME(dw,Orders.OrderDate) as orderday, DATENAME(dw,ShippedDate) as shipped_day,
	CAST((ShippedDate - OrderDate) AS numeric) AS shipping_time
FROM 
	Northwind.dbo.Orders
LEFT JOIN
	Northwind.dbo.[Order Details] ON
	Orders.OrderID = [Order Details].OrderID
ORDER BY ProductID DESC, [Order Details].Quantity DESC


-- **INVENTORY MANAGEMENT**
-- What is the current stock Level for each Product?
SELECT 
	ProductName, UnitsInStock, UnitsOnOrder, 
	(UnitsInStock - UnitsOnOrder) as quantity_in_stock
FROM 
	Northwind.dbo.Products

-- Which products are running low on stock?
SELECT 
	ProductName, UnitsInStock, UnitsOnOrder, 
	(UnitsInStock - UnitsOnOrder) as quantity_in_stock,
	Case
		WHEN (UnitsInStock - UnitsOnOrder) <= 0
		THEN 'Quantity Low'
	ELSE 'In stock'
	END AS status
FROM 
	Northwind.dbo.Products
ORDER BY quantity_in_stock

-- How often should the company reorder products based on historical data?
WITH ProductOrderFrequency AS (
    SELECT
        p.ProductID,
        COUNT(o.OrderID) AS OrderCount,
        AVG(DATEDIFF(day, o.OrderDate, o.ShippedDate)) AS AvgProcessingTime
    FROM
        Northwind.dbo.[Order Details] od
        JOIN Northwind.dbo.Orders o ON od.OrderID = o.OrderID
        RIGHT JOIN Northwind.dbo.Products p ON od.ProductID = p.ProductID
    GROUP BY
        p.ProductID
)

SELECT
    p.ProductName,
    ISNULL(po.OrderCount, 0) AS OrderCount,
    po.AvgProcessingTime,
    CASE
        WHEN po.OrderCount = 0 THEN 'No historical orders'
        WHEN po.AvgProcessingTime IS NULL THEN 'Not shipped yet'
        ELSE
            CASE
                WHEN po.OrderCount <= 5 THEN 'Low frequency'
                WHEN po.OrderCount <= 10 THEN 'Medium frequency'
                ELSE 'High frequency'
            END
    END AS ReorderFrequency
FROM
    Northwind.dbo.Products p
LEFT JOIN
    ProductOrderFrequency po ON p.ProductID = po.ProductID
ORDER BY
    ReorderFrequency;


-- Employee Performance:

    --How many orders has each employee handled?
SELECT * FROM Northwind.dbo.Employees

SELECT
	EmployeeID, COUNT(*) AS num_of_orders_handled
FROM
	Northwind.dbo.Orders
GROUP BY EmployeeID
ORDER BY num_of_orders_handled DESC

    --What is the average order processing time for each employee?
SELECT
	EmployeeID, COUNT(*) AS num_of_orders_handled,
	AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS processing_time
FROM
	Northwind.dbo.Orders
GROUP BY EmployeeID
ORDER BY processing_time DESC

    --Are there any employees who need additional training or support?
SELECT
	EmployeeID, MAX(processing_time) AS max_processing_time
FROM
(
	SELECT
		EmployeeID, COUNT(*) AS num_of_orders_handled,
		AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS processing_time
	FROM
		Northwind.dbo.Orders
	GROUP BY EmployeeID
	) AS orders_handled
GROUP BY EmployeeID
	
--Supplier Relationships:

    --Which suppliers provide the most products?
		-- we have to consider all products sold and those in stock

SELECT
	SupplierID,
	SUM(UnitsInStock + UnitsOnOrder) AS total_stock
FROM Northwind.dbo.Products p
LEFT JOIN Northwind.dbo.[Order Details] od ON p.ProductID = od.ProductID
LEFT JOIN Northwind.dbo.Orders o ON od.OrderID = o.OrderID
GROUP BY SupplierID
ORDER BY total_stock DESC

    --What is the average delivery time from different suppliers?

SELECT
	SupplierID,
	SUM(UnitsInStock + UnitsOnOrder) AS total_stock,
	AVG(DATEDIFF(day, o.OrderDate, o.ShippedDate)) AS avg_delivery_time
FROM Northwind.dbo.Products p
LEFT JOIN Northwind.dbo.[Order Details] od ON p.ProductID = od.ProductID
LEFT JOIN Northwind.dbo.Orders o ON od.OrderID = o.OrderID
GROUP BY SupplierID
ORDER BY avg_delivery_time

    --Are there any suppliers that consistently deliver late? That will be supplier 23

--Product Performance:

    --How do product sales vary over time?

SELECT
	CAST(YEAR(OrderDate) as numeric ) AS year_,
	SUM(od.UnitPrice * od.Quantity) AS total_sales
FROM Northwind.dbo.Products p
LEFT JOIN Northwind.dbo.[Order Details] od ON p.ProductID = od.ProductID
LEFT JOIN Northwind.dbo.Orders o ON od.OrderID = o.OrderID
GROUP BY YEAR(OrderDate)
ORDER BY year_

    --Is there a correlation between marketing efforts and product sales?

    --Which products have the highest profit margins?


--Customer Segmentation:

    --Can customers be segmented based on their purchasing behavior?
WITH CustomerSegments AS (
    SELECT
        CustomerID,
        SUM([Order Details].UnitPrice * [Order Details].Quantity * (1 - [Order Details].Discount)) AS TotalSpent
    FROM
        Northwind.dbo.Orders
        JOIN Northwind.dbo.[Order Details] ON Orders.OrderID = [Order Details].OrderID
    GROUP BY
        CustomerID
)

SELECT
    c.CustomerID, c.CompanyName, cs.TotalSpent,
    CASE
        WHEN cs.TotalSpent IS NULL THEN 'No Purchases'
        WHEN cs.TotalSpent <= 1000 THEN 'Low Spending'
        WHEN cs.TotalSpent <= 5000 THEN 'Medium Spending'
        ELSE 'High Spending'
    END AS CustomerSegment
FROM
    Northwind.dbo.Customers c
LEFT JOIN
    CustomerSegments cs ON c.CustomerID = cs.CustomerID
ORDER BY
    cs.TotalSpent DESC;
	   
    --Are there trends in the types of products different customer segments prefer?
		--CTE categorizes customers into segments based on their total spending.
WITH CustomerSegments AS (
    SELECT
        c.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpent,
        CASE
            WHEN SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) IS NULL THEN 'No Purchases'
            WHEN SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) <= 1000 THEN 'Low Spending'
            WHEN SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) <= 5000 THEN 'Medium Spending'
            ELSE 'High Spending'
        END AS CustomerSegment
    FROM
        Northwind.dbo.Customers c
        LEFT JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
        LEFT JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
    GROUP BY
        c.CustomerID
)
		-- retrive distinct products within each category for each customer segment
SELECT
    cs.CustomerSegment,
    c.CategoryName,
    COUNT(DISTINCT p.ProductID) AS NumberOfProducts
FROM
    CustomerSegments cs
    LEFT JOIN Northwind.dbo.Orders o ON cs.CustomerID = o.CustomerID
    LEFT JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
    LEFT JOIN Northwind.dbo.Products p ON od.ProductID = p.ProductID
	LEFT JOIN Northwind.dbo.Categories c ON p.CategoryID = c.CategoryID
GROUP BY
    cs.CustomerSegment,
    c.CategoryName
ORDER BY
    cs.CustomerSegment,
    NumberOfProducts DESC;


    --How can marketing strategies be tailored to different customer segments?


/*Financial Analysis:

    What are the total revenues and expenses for a given period?
    What is the net profit for the company?
    Are there any cost-saving opportunities based on the analysis?

Trend Analysis:

    How have sales, customer behavior, and other key metrics changed over time?
    Are there any seasonal trends in product sales or customer activity?
    What factors contribute to fluctuations in sales performance?
	*/




