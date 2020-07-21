-- initialise Lab_Product and LabProductCategory
use tlap632_AWLT;
SELECT [ProductID]      
		,[Name]      
		,[StandardCost]      
		,[ListPrice]  
		,[Size]      
		,[ProductCategoryID]      
		,[SellStartDate]      
		,[SellEndDate]
INTO dbo.Lab_Product
FROM tlap632_AWLT.[SalesLT].[Product]
GO
SELECT [ProductCategoryID]      
		,[ParentProductCategoryID]      
		,[Name]
INTO dbo.Lab_ProductCategory
FROM tlap632_AWLT.[SalesLT].[ProductCategory]
GO

-- obtain the Category IDs of all parent products
USE tlap632_AWLT

SELECT ProductCategoryID, ParentProductCategoryID, Name
FROM dbo.Lab_ProductCategory
WHERE ProductCategoryID > 0 AND ProductCategoryID < 5;

SELECT *
		FROM (SELECT ProductCategoryID
				FROM dbo.Lab_ProductCategory
				WHERE ProductCategoryID > 0 AND ProductCategoryID < 5) ParentCategory;

SELECT ProductCategoryID, ParentProductCategoryID, Name
FROM dbo.Lab_ProductCategory
WHERE ParentProductCategoryID = NULL;


-----------------------------------------------------------------------

-- select the product category with maximum amount of products in database
SELECT MAX(ProductCount.[Number of products])
FROM (SELECT pc.name AS 'Product Category', COUNT(p.ProductCategoryID) AS 'Number of products'
FROM SalesLT.Product p INNER JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.name) ProductCount;

--subquery
USE tlap632_AWLT
-- select the product category with maximum amount of products in database
SELECT pc.name AS 'Product Category', COUNT(p.ProductCategoryID) AS 'Number of products'
FROM SalesLT.Product p INNER JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.name
HAVING COUNT(p.ProductCategoryID) = (SELECT MAX(ProductCount.[Number of products]) -- find the max number of products
									FROM (SELECT pc.name AS 'Product Category', COUNT(p.ProductCategoryID) AS 'Number of products'
											FROM SalesLT.Product p INNER JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
											GROUP BY pc.name) ProductCount) -- count total number of products per category


SELECT COUNT(p.ProductCategoryID) AS 'Number of products'
FROM SalesLT.Product p INNER JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.name;




-- Adventure Works managers are doing a marketing promotion on Tuesdays and Thursdays in state provinces with even numbers
-- Write a query to list the provinces with even numbers
SELECT AddressID AS 'Address', StateProvince AS 'Province'
FROM SalesLT.Address
WHERE AddressID % 2 = 0
ORDER BY AddressID;


-----------------------------------------------------------COMMENT EXERCISE---------------------------------------------------------------------
DECLARE @a INT = 5,
		@b INT = 10;

IF (@a > 4) -- since @a = 5, this IF statement is executed, and '@a > 4' is printed
	BEGIN
		PRINT '@a > 4'

		IF (@b < 10) -- this condition is not met, so the ELSE statement is executed and '@b >= 10' is printed out
			PRINT '@b < 10'
		ELSE
			PRINT'@b >= 10'
	END

-- this IF statement is not executed as ALL conditions are not met.
-- @a = 5, so the '@a > 4' condition is met.
-- @b = 10 and a number cannot be less than itself, therefore this condition is false.
-- therefore, the print statements inside this IF statement block are not executed.
IF (@a > 4 AND @b < 10)
	BEGIN
		PRINT '@a > 4'
		PRINT '@b < 10'
	END

-- both conditions are met this time, as 10 >= 10 evaluates to TRUE.
-- the PRINT statements inside the IF statement are executed.
IF (@a > 4 AND @b >= 10)
	BEGIN
		PRINT '@a > 4'
		PRINT'@b >= 10'
	END


USE AdventureWorks2014

GO

-- the WHILE loop is NOT EXECUTED as the average list price is $438.67 (rounded to 2dp), which is NOT less than $300
-- therefore, the PRINT statement at the end of the loop is executed 'This is too much for the market to bear'
WHILE (SELECT AVG(ListPrice) FROM Production.Product) < 300
BEGIN 
	UPDATE Production.Product 
	SET ListPrice = ListPrice * 2

	SELECT MAX(ListPrice) FROM Production.Product
	IF (SELECT MAX(ListPrice) FROM Production.Product) > 500
		BREAK
	ELSE	
		CONTINUE
END
PRINT 'This is too much for the market to bear'
---------------------------------------------------------
USE AdventureWorks2014
SELECT MAX(ListPrice) FROM Production.Product;


