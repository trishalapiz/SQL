CREATE PROCEDURE uspAddNewCategory
	@categoryName VARCHAR(20), 
	@parentCategoryID INT
AS
	BEGIN
		
		IF (@categoryName IS NOT NULL) -- if a name is entered
			
			IF (@parentCategoryID IN (SELECT ProductCategoryID FROM dbo.Lab_ProductCategory WHERE ProductCategoryID > 0 AND ProductCategoryID < 5))
				
				-- insert new cateogry
				INSERT INTO dbo.Lab_ProductCategory (ParentProductCategoryID, Name)
				VALUES (@parentCategoryID, @categoryName)

			ELSE -- if ID is 0 or 5 and above
				PRINT 'Sorry this action cannot be performed, Parent Category ID needs to be between 1 and 4'
		
		ELSE -- if no name given
			PRINT 'Category Name cannot be a NULL value, please state a name'
		
	END;

	GO

--DROP PROC uspAddNewCategory

EXECUTE uspAddNewCategory @categoryName = NULL, @parentCategoryID = 4; --inserting without a name
EXECUTE uspAddNewCategory @categoryName = 'Shoes', @parentCategoryID = NULL; --inserting without a categoryID
EXECUTE uspAddNewCategory @categoryName = 'Shoes', @parentCategoryID = 4; --inserting a new record (for q1)
EXECUTE uspAddNewCategory @categoryName = 'Scarves', @parentCategoryID = 4; --inserting a new record (for q2)

/** QUESTION ONE
CREATE PROCEDURE uspAddNewCategory
	@categoryName VARCHAR(20), 
	@parentCategoryID INT
AS
	BEGIN
		IF (@categoryName IS NOT NULL) -- if a name is entered
			IF (@parentCategoryID >= 1 AND @parentCategoryID <= 4) -- if the parent category ID entered is either 1, 2, 3 or 4
				
				-- insert new cateogry
				INSERT INTO dbo.Lab_ProductCategory (ParentProductCategoryID, Name)
				VALUES (@parentCategoryID, @categoryName)
		
			ELSE -- if ID is 0 or 5 and above
				PRINT 'Sorry this action cannot be performed, Parent Category ID needs to be between 1 and 4'
		ELSE -- if no name given
			PRINT 'Category Name cannot be a NULL value, please state a name'
	END;

	GO
**/
