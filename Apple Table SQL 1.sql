--- Creating Databases
Create Database AppleDB
USe  Appledb

--- Importing data through SQL WIZARD
Select * from category
Select * from products
Select * from sales
Select * from stores
Select * from warranty

--- Sanity checks
--sp_help of sales,products,stores,warranty,products

---Modifying colums for better efficiency
--Altering stores table
Alter Table stores
Alter column store_id varchar(10) not null
Alter Table stores
Alter column store_Name varchar(30) 
Alter Table stores
Alter column city varchar(30) 
Alter Table stores
Alter column country varchar(30) 
--Altering category table
Alter Table category
Alter column category_id varchar(10) not null
Alter Table category
Alter column category_Name varchar(30)
--Altering products table
Alter Table products
Alter column product_id varchar(10) not null 
Alter Table products
Alter column product_Name varchar(35) 
Alter Table products
Alter column category_id varchar(10) not null
Alter Table products
Alter column Launch_date Date 
Alter Table products
Alter column price money 
--Altering Sales table
Alter Table sales
Alter column sale_id varchar(15) not null
Alter Table sales
Alter column sale_date date 
Alter Table sales
Alter column store_id varchar(10) not null
Alter Table sales
Alter column Product_id varchar(10) not null
Alter Table sales
Alter column Quantity int
--Altering warranty table
Alter Table warranty
Alter column claim_id varchar(20) not null
Alter Table warranty
Alter column claim_date date
Alter Table warranty
Alter column sale_id varchar(15) not null
Alter Table warranty
Alter column repair_status varchar(15)

/*Assigning primary & foreign key constraints*/
--------------category
Alter Table Category
Add constraint PK_category  Primary Key (category_id)
--------------Product
Alter Table products
Add constraint PK_products  Primary Key (product_id)
Alter Table products
Add constraint fk_category foreign key (category_id) references category(category_id)
--------------Stores
Alter Table stores
Add constraint PK_stores  Primary Key (store_id)
--------------Sales 
Alter Table Sales
Add constraint PK_sales  Primary Key (sale_id)
Alter Table Sales
Add constraint fk_store foreign Key(Store_id) references Stores (store_id)
Alter Table Sales
Add constraint fk_product foreign Key(product_id) references products (product_id)
--------------Warranty 
Alter Table Warranty
Add constraint PK_Warranty primary Key(Claim_id)
Alter Table Warranty
Add constraint fk_Warranty foreign Key(sale_id) references Sales (sale_id)










