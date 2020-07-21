USE tlap632_AWLT -- FUNCTIONS, CURSORS, TRIGGERS

---------------------------------------------------------------------- CURSORS --------------------------------------------------------------------------
-- create a CURSOR to ITERATE (while loop) through the lastName and fullName in reverse aplhabetical order
-- use CUSTOMER table
-- fullName can be coded as LastName + ', ' + FirstName + COALESCE(' MiddleName,')
-- if the LastName in the current row is the same as the LastName in the previous row
-- then print by concatenating the FullName with a string
-- otherwise print only the fullname
-- REMEMBER to SET the lastname variable to be the same LastName as the previous row before the cursor loop ends
-- STRING = '(same LastName as above)'

DECLARE @previousLastname VARCHAR(50), @currentLastname VARCHAR(50), @fullName VARCHAR(50);
-- DECLARE CURSOR
DECLARE Customer_Cursor CURSOR
FOR

-- result table used to iterate
SELECT LastName, (LastName + ', ' + FirstName + ' ' + COALESCE(ISNULL(MiddleName, ' '), MiddleName)) AS FullName
FROM SalesLT.Customer
ORDER BY LastName DESC;

OPEN Customer_Cursor; -- can use cursor

FETCH NEXT FROM Customer_Cursor INTO @currentLastname, @fullName -- fetching first row of table
WHILE @@FETCH_STATUS = 0 -- PRINTING FULL NAME!!
	BEGIN
		IF @previousLastname LIKE @currentLastname
			BEGIN
				PRINT @fullname + ' (same LastName as above)'
				SET @previousLastname = @currentLastname
			END
		ELSE
			BEGIN
				PRINT @fullname
				SET @previousLastname = @currentLastname
			END
		FETCH NEXT FROM Customer_Cursor INTO @currentLastname, @fullName -- the increment
	END

CLOSE Customer_Cursor;

DEALLOCATE Customer_Cursor;

-- WRITE a nested cursor // eg Lab 2 Loop exercise 3

DECLARE @parentProdID INT, @prodID INT, @productName VARCHAR(50), @parentName VARCHAR(50);

DECLARE Parent_Name_Cursor CURSOR
FOR

SELECT ProductCategoryID, Name -- retrieve parent categories
FROM SalesLT.ProductCategory
WHERE ParentProductCategoryID IS NULL;

OPEN Parent_Name_Cursor;

FETCH NEXT FROM Parent_Name_Cursor INTO @parentProdID, @parentName
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @parentName
		-------------------------------- SUB CURSOR ---------------------------------------
		DECLARE Subcategory_Cursor CURSOR
		FOR

		SELECT ProductCategoryID, Name
		FROM SalesLT.ProductCategory
		WHERE ParentProductCategoryID = @parentProdID;

		OPEN Subcategory_Cursor;

		FETCH NEXT FROM Subcategory_Cursor INTO @prodID, @productName
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @productName = Name FROM SalesLT.ProductCategory WHERE ProductCategoryID = @prodID
				PRINT '		' + @productName
				FETCH NEXT FROM Subcategory_Cursor INTO @prodID, @productName
			END
		CLOSE Subcategory_Cursor;
		DEALLOCATE Subcategory_Cursor;
		-------------------------------- SUB CURSOR ---------------------------------------
		FETCH NEXT FROM Parent_Name_Cursor INTO @parentProdID, @parentName
	END
CLOSE Parent_Name_Cursor;
DEALLOCATE Parent_Name_Cursor;

---------------------------------------------------------------------- FUNCTIONS --------------------------------------------------------------------------
-- Create a function called dbo.ufnGetFullName which given a CustomerID will return their full name
-- Full Name in the format of FirstName MiddleName LastName
-- MiddleName is omitted if NULL

IF OBJECT_ID ('dbo.ufnGetFullName', N'FN') IS NOT NULL
DROP FUNCTION dbo.ufnGetFullName;
GO

CREATE FUNCTION dbo.ufnGetFullName (@CustomerID INT) -- functions only return 1 value!!!
RETURNS VARCHAR(50) -- data type returned
AS
BEGIN
	DECLARE @fullName VARCHAR(50);
	IF (SELECT MiddleName FROM SalesLT.Customer WHERE CustomerID = @CustomerID) IS NOT NULL -- return full name (meaning incl middle name)
		BEGIN
			SELECT @fullName = FirstName + ' ' + MiddleName + ' ' + LastName FROM SalesLT.Customer WHERE CustomerID = @CustomerID;
		END
	ELSE -- if there is NO middle name, return name WITHOUT middle name
		BEGIN
			SELECT @fullName = FirstName + ' ' + LastName FROM SalesLT.Customer WHERE CustomerID = @CustomerID;
		END
	RETURN @fullName
END
GO

SELECT dbo.ufnGetFullName(3); -- should return Donna F. Carreras
SELECT dbo.ufnGetFullName(5); -- should return Lucy Harrington


-- then modify the basic function example so its body is a single return statement

/** MODIFIED VERSION OF PREVIOUS FUNCTION **/
IF OBJECT_ID ('dbo.ufnGetParentName', N'FN') IS NOT NULL
DROP FUNCTION dbo.ufnGetParentName;
GO

-- RETURN AS A SINGLE RETURN STATEMENT
CREATE FUNCTION dbo.ufnGetParentName (@id INT) 
RETURNS VARCHAR(50) -- data type returned
AS
BEGIN
	RETURN (SELECT Name 
			FROM dbo.Lab_ProductCategory
			WHERE ProductCategoryID = (SELECT ParentProductCategoryID FROM dbo.Lab_ProductCategory WHERE ProductCategoryID = @id));
END
GO
SELECT dbo.ufnGetParentName(1); -- NULL
SELECT dbo.ufnGetParentName(5); -- Bikes

---------------------------------------------------------------------- TRIGGERS ---------------------------------------------------------------------------
/*
QUESTION ONE
	-  Create an INSTEAD OF UPDATE / DELETE on SalesLt.ProductDescription to PRINT the NUMBER of rows attempted to be updated / deleted
	-  In the case of an update, also print the IF the ModifiedDate is being updated
*/

IF OBJECT_ID ('NEWUPDATEDELETE_Trigger', 'TR') IS NOT NULL
DROP TRIGGER NEWUPDATEDELETE_Trigger;
GO

-- print the number of rows being updated or deleted
CREATE TRIGGER NEWUPDATEDELETE_Trigger on SalesLT.ProductDescription
INSTEAD OF UPDATE, DELETE
AS
BEGIN

	DECLARE @rowCount INT = 0;
	DECLARE @prodDescID INT = 0;

	IF UPDATE(ModifiedDate)
		BEGIN
			SELECT @prodDescID = ProductDescriptionID FROM INSERTED;
			PRINT 'ModifiedDate for ProductDescriptionID = ' + CAST(@prodDescID AS VARCHAR(30)) + ' attempted to be updated';
		END
	ELSE IF EXISTS (SELECT 1 FROM DELETED) -- prevent delete on rows with model descriptions --> FIRST ROW IN DELETED TABLE EXISTS
		BEGIN
			SELECT @rowCount = COUNT(*) FROM DELETED;
			PRINT CAST(@rowCount AS VARCHAR(50)) + ' rows were attempted to be deleted'
		END
	ELSE
		BEGIN
			SELECT @rowCount = COUNT(*) FROM INSERTED;
			PRINT CAST(@rowCount AS VARCHAR(50)) + ' rows were attempted to be updated'
		END
END

/*
QUESTION TWO
	-  Modify the above trigger to PREVENT updates / deletes on rows which currently describe ProductModels
	-  Exclude these rows from the update / delete, allow all other rows to be updated / excluded as usual
	-  For rows updated, the ModifiedDAte must be set the time of the update [GETDATE()]
*/

ALTER TRIGGER [SalesLT].[NEWUPDATEDELETE_Trigger] on [SalesLT].[ProductDescription]
INSTEAD OF UPDATE, DELETE
AS
BEGIN

	DECLARE @rowCount INT = 0;
	DECLARE @prodDescID INT = 0;

	IF EXISTS (SELECT 1 FROM DELETED) -- FIRST ROW IN DELETED TABLE EXISTS where it has a description
		BEGIN
			SELECT @rowCount = COUNT(*) FROM DELETED WHERE Description IS NOT NULL;
			PRINT CAST(@rowCount AS VARCHAR(50)) + ' rows with model descriptions were attempted to be updated'
		END
	ELSE -- if updated
		BEGIN
			SELECT @rowCount = COUNT(*) FROM INSERTED WHERE Description IS NOT NULL;
			PRINT CAST(@rowCount AS VARCHAR(50)) + ' rows with model descriptions were attempted to be updated'
		
		IF UPDATE(ModifiedDate)
			BEGIN
				UPDATE SalesLT.ProductDescription
				SET ModifiedDate = GETDATE();
			END
		
		END
		
END