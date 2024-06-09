
USE classicmodels;

SHOW TABLES;

SELECT *FROM customers;
SELECT *FROM employees;
SELECT *FROM offices;
SELECT *FROM orderdetails;
SELECT *FROM orders;
SELECT *FROM payments;
SELECT *FROM productlines;
SELECT*FROM products;

ALTER TABLE employees
ADD full_name CHAR(50);

UPDATE employees 
SET full_name = CONCAT(firstName, ' ', lastName);

#Creating a Temporary table for sales Evaluation

CREATE Temporary table sales AS
SELECT	orderNumber,
		productCode, 
        quantityOrdered, 
        priceEach, 
        orderlineNumber, 
        (quantityOrdered * priceEach) as total_sales
FROM orderdetails;


SELECT * FROM sales;


#Add a cost price columns for each of the products 

Alter Table sales 
add cost_price Decimal(5,2);

Update sales s
Inner join products p
using(productCode)
Set s.cost_price=p.buyPrice;

#Add toal cost column in the Temporary Table

Alter table sales
add total_cost Decimal;

Update sales 
Set total_cost=(quantityOrdered* cost_price);
select * from sales;

#Sales Analysis

-- Sales Performance
SELECT 
    SUM(total_sales) Total_Revenue,
    SUM(total_cost) Toal_Cost,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit,
    SUM(quantityOrdered) Total_Orders,
    ROUND(AVG(quantityOrdered)) Averge_Order
FROM
    sales;

-- Sum of  Sales, profit by years
SELECT 
    YEAR(orderDate),
    SUM(total_sales) Total_Revenue_by_years,
    SUM(total_cost) Toal_Cost_by_years,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit_by_years
FROM
    sales
        LEFT JOIN
    orders USING (orderNumber)
GROUP BY 1;

-- Sum of Sales by Months 

SELECT 
    MONTH(orderDate),
    SUM(total_sales) Total_Revenue_by_years,
    SUM(total_cost) Toal_Cost_by_years,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit_by_years
FROM
    sales
        LEFT JOIN
    orders USING (orderNumber)
GROUP BY 1
ORDER BY 2 DESC;

-- Sum of Sales, proft by Productlines
SELECT 
    productLine,
    SUM(total_sales) Total_Revenue,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit
FROM
    sales
        LEFT JOIN
    products USING (productCode)
        JOIN
    productlines USING (productLine)
GROUP BY 1;

-- Sum of sales by Coountry

SELECT 
    country,
    SUM(total_sales) Total_Revenue,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit
FROM
    sales
        LEFT JOIN
    orders USING (orderNumber)
        JOIN
    customers USING (customerNumber)
GROUP BY 1
ORDER BY 2 DESC;

-- Sumof quantity ordered by Producline
SELECT 
    productLine,
    SUM(quantityOrdered) AS Total_order,
    (SUM(quantityOrdered) / (SELECT SUM(quantityOrdered)
							FROM
							orderdetails)) * 100 Percentage
FROM
    sales
        LEFT JOIN
    products USING (productCode)
GROUP BY 1
ORDER BY 2 DESC;

# Customer Analysis

SELECT 
    COUNT(*) No_of_Customers,
    SUM(creditLimit) Credit_limit_offered
FROM
    customers;


-- Top 5 Customers based on Profit
SELECT 
    customerName,
    SUM(total_sales) Total_Revenue,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit
FROM
    sales
        LEFT JOIN
    orders USING (orderNumber)
        JOIN
    customers USING (customerNumber)
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;


-- Bottom 5 Customers Based on Sales and Profit
SELECT 
    customerName,
    SUM(total_sales) Total_Revenue,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit
FROM
    sales
        LEFT JOIN
    orders USING (orderNumber)
        JOIN
    customers USING (customerNumber)
GROUP BY 1
ORDER BY 3 ASC
LIMIT 5;


-- Customers Distribution based on country

SELECT 
    country, COUNT(*) no_of_customers
FROM
    customers
GROUP BY 1
ORDER BY 2 DESC;   

#Products Analysis 

-- Total Poducts

SELECT 
    COUNT(*) AS NO_of_Products
FROM
    products;

-- Average PRoduct Price

SELECT 
    AVG(buyPrice) AS Average_Price
FROM
    products;

-- Most Profitable Products

SELECT 
    productName,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit,
    SUM(quantityOrdered) AS Total_order
FROM
    sales
        LEFT JOIN
    products USING (productCode)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Less Profitable products 
 
SELECT 
    productName,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit,
    SUM(quantityOrdered) AS Total_order
FROM
    sales
        LEFT JOIN
    products USING (productCode)
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5;

#Operational Analysis

-- No of Offices and Employees
Select count(*) NO_of_Employees from employees;
select count(*) No_of_Offices from offices;

-- Sales by Office 

SELECT 
    o.city,
    SUM(total_sales) Total_sales
FROM
    offices o
        LEFT JOIN
    employees e USING (officeCode)
        INNER JOIN
    customers c ON e.employeeNumber = c.salesRepEmployeeNumber
        INNER JOIN
    orders USING (customerNumber)
        INNER JOIN
    sales s USING (orderNumber)
Group by 1 
order by 2 desc;

-- Employees Count by Country 

SELECT 
    country, COUNT(*) AS No_of_Employees
FROM
    offices
        LEFT JOIN
    employees USING (officeCode)
GROUP BY 1
ORDER BY 2 DESC;

-- Employee Performance

SELECT 
    full_name,
    SUM(total_sales) Total_Revenue,
    (SUM(total_sales) - SUM(total_cost)) Total_Profit,
    SUM(quantityOrdered) Total_Orders
FROM
    employees e
        LEFT JOIN
    customers c ON e.employeeNumber = c.salesRepEmployeeNumber
        INNER JOIN
    orders USING (customerNumber)
        INNER JOIN
    sales USING (orderNumber)
GROUP BY 1
ORDER BY 2 DESC;


