SET STATISTICS TIME ON;

-- Your SQL Query
Select * from category
Select * from products
Select * from sales
Select * from stores
Select * from warranty

SET STATISTICS TIME OFF;   

------------EDA(EXPLORATORY DATA ANALYSIS)
Select * from category
Select Distinct Product_Name from products
Select count(*) from products
Select Distinct repair_status status from warranty
Select count(*) from Sales ---10,40,200 
Select Distinct Count(Product_id) from Sales 

------------Query Optimization
SET STATISTICS TIME ON;
Select * from sales
SET STATISTICS TIME OFF;

---(1040200 rows affected)
---Execution Time
---SQL Server Execution Times:
---CPU time = 1578 ms,  elapsed time = 7290 ms

SET STATISTICS TIME on;   
Select Product_id 
from Sales 
where Product_id = 'P-78'
SET STATISTICS TIME OFF;   
 
----------(11686 rows affected)
----------SQL Server Execution Times:
----------CPU time = 203 ms,  elapsed time = 326 ms.

(Select 1,Count(1) from sales where product_id = 'P-70')

-------------------Index creation on sales table
Create index sales_product_id on Sales(product_id)
--------------------Query Time after optimization
SET STATISTICS TIME on;   
Select Product_id 
from Sales 
where Product_id = 'P-78'
SET STATISTICS TIME OFF; 
-----(11686 rows affected)
-----SQL Server Execution Times:
------CPU time = 31 ms,  elapsed time = 103 ms.

create index sales_store_id on sales(store_id);

create index sales_quantity on sales(quantity);

create index sale_date on sales(sale_date);

create index sales_product_id_store_id on sales(product_id, store_id);

----------------Business Problems 
--1. Find the number of stores in each country.

Select Country,Count(Store_id) as total_Stores 
from Stores
group by Country
Order by total_Stores

--2.calculate the total number of units sold by each store.

---Total number of quantity sold by each store

Select st.Store_id,Sum(sa.quantity) as Total_units,st.store_name
from stores st
Left join Sales sa
on st.store_id = sa.store_id
group by st.store_id,st.store_name
order by Total_units Desc

-- As all the unique store_id present in stores table , hence used the Left Join.

--3.Identify how many sates occurred in December 2023?

select Sum(Quantity) as total_sales
from sales
where  Sale_date Between '2023-11-1' AND '2023-11-30'

--4 Find the number of  sales  each year ?
-------Yearly sales 
Select Year(Sale_date) as Years,Sum(Quantity)as Yearly_sale
from sales
Group by Year(Sale_date)
Order by 2 DESC
--5.Determine how many stores have never had a warranty claim filed.

Select * from Stores
Select Count(*) 
from Stores
Where Store_id not in (Select Distinct store_id from Sales s right join warranty w  on s.sale_id = w.sale_id)

select count(*) from stores
where store_id not in (
select distinct store_id from sales as s right join warranty as w on s.sale_id = w.sale_id);


--6.Calcutate the percentage of warranty claims marked as "Rejected" .

Select Distinct repair_status from warranty
Select * from warranty

Select Count(repair_status) as Total_claims from warranty --- 30,000
Select Count(repair_status) as Total_rejected
from warranty 
where repair_status = 'rejected' --- 7,357

 select 30000-7325 --- 22,675

--7.Identify which store had the highest total units sold in the last year.

SELECT 
    Top 1
    s.store_id, 
    st.store_name, 
    SUM(s.quantity) AS Total_sales
FROM Sales s
LEFT JOIN Stores st 
ON s.store_id = st.store_id
WHERE s.sale_date >= DATEADD(YEAR, -1, GETDATE()) 
GROUP BY s.store_id, st.store_name
ORDER BY Total_sales DESC; 

--8.Count the number of unique products sold in the last year.

Select p.Product_ID,p.Product_Name,Sum(s.Quantity) as Totalsales
from products p
Left join sales s
on p.Product_ID=s.product_id
where s.sale_date >= DATEADD(YEAR, -1, GETDATE()) 
Group by p.Product_ID,p.Product_Name
Order by Totalsales Desc

--9.Find the average price of products in each category.

Select c.category_id,Round(AVG(p.Price),2) as average_price
from Category c
Left join products p
on c.category_id=p.Category_ID
group by c.category_id 
order by 2 Desc

--10.How many warranty claims were filed in 2024?

Select Count(claim_id) 
from warranty
where Year(Claim_date) = 2024

--11.For each store, identify the best-selling day based on highest quantity sold.
WITH DailySales AS (
    SELECT 
        store_id,
        sale_date,
        SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY store_id, sale_date
),
RankedSales AS (
    SELECT 
        ds.store_id,
        s.Store_Name,
        ds.sale_date,
        ds.total_quantity,
        RANK() OVER (PARTITION BY ds.store_id ORDER BY ds.total_quantity DESC) AS rank
    FROM DailySales ds
    JOIN stores s ON ds.store_id = s.Store_ID
)
SELECT store_id, Store_Name, sale_date, total_quantity
FROM RankedSales
WHERE rank = 1;

---12.Identify the least selling product in each country for each year based on total units sold.




 WITH Product_Sold AS (
    SELECT 
        p.Product_ID, 
        p.Product_Name, 
        s.store_id, 
        SUM(s.Quantity) AS Total
    FROM products p 
    LEFT JOIN sales s ON p.Product_ID = s.product_id 
    GROUP BY p.Product_ID, p.Product_Name, s.store_id
),
Ranking AS (
    SELECT 
        ps.Product_ID, 
        ps.Product_Name, 
        ps.Total, 
        st.Store_Name, 
        st.Country,
        ROW_NUMBER() OVER (PARTITION BY st.Country ORDER BY ps.Total DESC) AS rank
    FROM Product_Sold ps
    RIGHT JOIN stores st ON ps.store_id = st.Store_ID
)
SELECT 
    Country, 
    Product_Name, 
    Total AS Quantity
FROM Ranking 
WHERE rank = 1;

--12.Calculate how many warranty claims were filed within 180 days of a product sale.

SELECT COUNT(*) AS Warranty_Claims_Within_180_Days
FROM warranty AS w
JOIN sales AS s
ON w.sale_id = s.sale_id
WHERE DATEDIFF(DAY, s.sale_date, w.claim_date) BETWEEN 1 AND 180;


--13.Determin how many warranty claims were filed for products launched in the last two years
SELECT 
    p.product_name,
    COUNT(w.claim_id) AS Total_Warranty_Claims,
    COUNT(s.sale_id) AS Total_Sales
FROM sales AS s
LEFT JOIN warranty AS w 
    ON w.sale_id = s.sale_id
JOIN products AS p 
    ON p.product_id = s.product_id
WHERE p.launch_date >= DATEADD(YEAR, -2, GETDATE())  -- Adjusts for 2 years back
GROUP BY p.product_name
HAVING COUNT(w.claim_id) > 0;

--14.List the months in the last three years where sales exceeded 5,000 units in the USA.

---sales exceeds 5000/month in last 3 years in usa

---Sales in USA
Select FORMAT(s.sale_date, 'MM-yyyy') AS Formatted_Date, Sum(s.Quantity) as Total
from sales s
Right join stores st
on s.store_id=st.Store_ID
Where st.Country = 'United States' And s.sale_date Between Dateadd(Year,-3,Getdate()) and Getdate()
Group by FORMAT(s.sale_date, 'MM-yyyy')
having Sum(s.Quantity) > 5000

--15.Identify the product category with the most warranty claims filed in the last two years.

WITH warranty_claims AS (
    SELECT 
        w.claim_id,
        w.sale_id,
        w.claim_date
    FROM warranty w
    WHERE w.claim_date >= DATEADD(YEAR, -2, GETDATE()) -- Last 2 years
),
category_warranty_count AS (
    SELECT 
        c.Category_ID,
        c.Category_Name,
        COUNT(wc.claim_id) AS Total_Warranty_Claims
    FROM products p
    JOIN sales s ON p.Product_ID = s.product_id
    JOIN category c ON p.Category_ID = c.category_id
    JOIN warranty_claims wc ON wc.sale_id = s.sale_id
    GROUP BY c.Category_ID, c.Category_Name
)
SELECT TOP 1 
    Category_ID,
    Category_Name,
    Total_Warranty_Claims
FROM category_warranty_count
ORDER BY Total_Warranty_Claims DESC;  

--16.Determine the percentage chance of receiving warranty claims after each purchase for each country.

--- percentage chance of warranty claims

WITH CountryWiseSales AS (
    SELECT 
        st.Country, 
        SUM(s.quantity) AS Total_sum, 
        COUNT(w.claim_id) AS Total_Quantity
    FROM warranty w
    JOIN sales s ON w.sale_id = s.sale_id
    RIGHT JOIN stores st ON st.store_id = s.store_id
    RIGHT JOIN products p ON p.product_id = s.product_id
    GROUP BY st.Country
)
SELECT *,
       (Total_sum / NULLIF(Total_Quantity, 0)) * 100 AS Percentage
FROM CountryWiseSales;

