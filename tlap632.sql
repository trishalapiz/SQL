-- Trisha Lapiz
-- 227981431
-- tlap632

-- QUESTION 2
SELECT ProductID AS 'Product ID', 
		ProductName AS 'Product Name',
		SupplierID AS 'Supplier ID',
		CategoryID AS 'Category ID',
		QuantityPerUnit AS 'Quantity Per Unit', 
		UnitPrice AS 'Unit Price', 
		UnitsInStock AS 'Units In Stock',
		UnitsOnOrder AS 'Units On Order',
		ReorderLevel AS 'Reorder Level',
		Discontinued
FROM Product;

-- QUESTION 3
SELECT ProductName, UnitPrice, UnitsInStock
FROM Product
ORDER BY UnitPrice DESC;

-- QUESTION 4
SELECT Phone
FROM Shipper
WHERE LOWER(CompanyName) = 'united package';

-- QUESTION 5
SELECT *
FROM Customer
WHERE Fax IS NOT NULL;

-- QUESTION 6
SELECT *
FROM [Order]
WHERE OrderDate BETWEEN '1996-07-01' AND '1996-07-31';

-- QUESTION 7
SELECT DISTINCT Country
FROM Customer;

-- QUESTION 8
SELECT COUNT(*) AS 'Numbers of Order'
FROM [Order];

-- QUESTION 9
SELECT ProductName
FROM Product
WHERE ProductName LIKE '_____'; -- no function

SELECT ProductName
FROM Product
WHERE LENGTH(ProductName) = 5; -- with function

-- QUESTION 10
SELECT ProductName, UnitsInStock
FROM Product
ORDER BY UnitsInStock DESC
LIMIT 10;

-- QUESTION 11
SELECT UPPER(LastName) || ', ' || FirstName AS Name, Address || ', ' || City || ' ' || PostalCode || ', ' || Country AS Address
FROM Employee;

-- QUESTION 12
SELECT OrderID, ProductID, '$' || UnitPrice AS UnitPrice, Quantity, (Discount  * 100) || '%' AS Discount, '$' || (UnitPrice * Quantity * (1-Discount)) AS 'Subtotal'
FROM OrderDetail
WHERE OrderID = '10250';

-- QUESTION 13
SELECT ProductName, CategoryID, UnitPrice, Discontinued
FROM Product
WHERE (ProductName LIKE 'C%') 
	AND (CategoryID = 1 OR CategoryID = 2)
	AND (UnitPrice > 20)
	AND Discontinued = 0;

-- QUESTION 14
INSERT INTO Shipper (CompanyName, Phone) VALUES
	('Trustworthy Delivery', '(503) 555-1122');
INSERT INTO Shipper (CompanyName, Phone) VALUES
	('Amazing Pace', '(503) 555-3421');
INSERT INTO Shipper (CompanyName, Phone) VALUES
	('Trisha Lapiz', '(503) 227-9814');

-- QUESTION 15
SELECT LastName, FirstName, CAST(ROUND(((julianday('now') - julianday(BirthDate)) / 365.25)) AS INTEGER) AS Age
FROM Employee;

-- QUESTION 16
UPDATE Employee
SET LastName = 'Fuller', TitleOfCourtesy = 'Mrs.'
WHERE UPPER(FirstName) = 'NANCY';

-- QUESTION 17
UPDATE Employee
SET Address = (SELECT Address FROM Employee WHERE UPPER(FirstName) = 'ANDREW'),
	City = (SELECT City FROM Employee WHERE UPPER(FirstName) = 'ANDREW'),
	Region = (SELECT Region FROM Employee WHERE UPPER(FirstName) = 'ANDREW'),
	PostalCode = (SELECT PostalCode FROM Employee WHERE UPPER(FirstName) = 'ANDREW'),
	HomePhone = (SELECT HomePhone FROM Employee WHERE UPPER(FirstName) = 'ANDREW')
WHERE UPPER(FirstName) = 'NANCY';

-- QUESTION 18 create ProductHistory table
CREATE TABLE ProductHistory
(ProductID INTEGER NOT NULL, 
EntryDate DATETIME NOT NULL, 
UnitPrice REAL DEFAULT 0, 
UnitsInStock INTEGER DEFAULT 0, 
UnitsOnOrder INTEGER DEFAULT 0, 
ReorderLevel INTEGER DEFAULT 0, 
Discontinued INTEGER NOT NULL DEFAULT 0, 
	CHECK (UnitPrice >= 0), 
	CHECK (UnitsInStock>= 0), 
	CHECK (UnitsOnOrder >= 0), 
	CHECK (ReorderLevel >= 0),
	PRIMARY KEY (ProductID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID) ON DELETE NO ACTION ON UPDATE NO ACTION);

-- QUESTION 19
INSERT INTO ProductHistory
SELECT ProductID, STRFTIME('%Y-%m-%d  %H:%M:%S', 'now'), UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
FROM Product;

-- QUESTION 20
SELECT [Day of Week] , COUNT(*) as Hired
FROM (SELECT CASE
	WHEN STRFTIME('%w', HireDate) == '0' 
		THEN 'Sunday'
	WHEN STRFTIME('%w', HireDate) == '1' 
		THEN 'Monday'
	WHEN STRFTIME('%w', HireDate) == '2' 
		THEN 'Tuesday'
	WHEN STRFTIME('%w', HireDate) == '3' 
		THEN 'Wednesday'
	WHEN STRFTIME('%w', HireDate) == '4' 
		THEN 'Thursday'
	WHEN STRFTIME('%w', HireDate) == '5' 
		THEN 'Friday'
	WHEN STRFTIME('%w', HireDate) == '6' 
		THEN 'Saturday'
	END AS [Day of Week]
	FROM Employee)
GROUP BY [Day of Week];

-- QUESTION 21
SELECT aTemp.LastName, aTemp.FirstName, '$' || MAX(aTemp.someTotal) AS 'Total'
FROM (SELECT e.LastName, e.FirstName, SUM((UnitPrice * Quantity * (1-Discount))) as [someTotal]
FROM Employee e, OrderDetail od, [Order] o
WHERE e.EmployeeID = o.EmployeeID AND od.OrderID = o.OrderID
GROUP BY e.EmployeeID) AS aTemp;

-- QUESTION 22
SELECT e1.FirstName AS [Employee], IFNULL(e2.FirstName, 'No manager') AS Manager
FROM Employee e1
LEFT OUTER JOIN Employee e2
ON e1.ReportsTo = e2.EmployeeID;

-- QUESTION 23
SELECT c.CompanyName AS [Company], 
			'$' || ROUND(SUM(od.quantity * p.UnitPrice), 2) AS [Recommended], 
			'$' || ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)), 2) AS [Ordered], 
			'$' || ABS((ROUND(SUM(od.quantity * p.UnitPrice), 2)-ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount))),2)) AS [Discount], 
			ROUND(((SUM(od.quantity * p.UnitPrice)-SUM(od.UnitPrice * od.Quantity * (1-od.Discount))) / (SUM(od.quantity * p.UnitPrice) * 100), 2) || '%' AS [Percentage]
FROM OrderDetail od, Product p, [Order] o, Customer c
WHERE (od.ProductID = p.ProductID) AND (o.OrderID = od.OrderID) AND (o.CustomerID = c.CustomerID)
GROUP BY c.CompanyName
ORDER BY ROUND(((SUM(od.quantity * p.UnitPrice)-SUM(od.UnitPrice * od.Quantity * (1-od.Discount))) / (SUM(od.quantity * p.UnitPrice) * 100), 2) DESC;

-- QUESTION 24
SELECT someTemp.ShipCountry AS 'Ship Country', someTemp.CompanyName AS 'Shipper'
FROM (SELECT o.ShipCountry, s.CompanyName, SUM(o.Freight) as 'Freight'
		FROM [Order] o, Shipper s
		WHERE o.ShipVia = s.ShipperID
		GROUP BY o.ShipCountry, o.ShipVia) as someTemp
GROUP BY someTemp.ShipCountry
HAVING MAX(someTemp.Freight)
ORDER BY someTemp.CompanyName;
