In this lab, we had to demonstrate our knowledge on Cursors, Functions and Triggers.

The tasks were:

**Cursors:**

* Create a cursor to iterate through the last name and full name of the rows in the Customer table in *reverse alphabetical order*.
* Write a nested cursor iterating through the product categories placed under their parent categories.

**Functions:**

* Create a function called dbo.ufnGetFullName, which, given a CustomerID, will return their full name.
* Modify the basic function so its body returns a single return statement.

**Triggers**

* Create an INSTEAD OF UPDATE, DELETE on SalesLT.ProductDescription to print the number of rows attempted to be updated/deleted.
* Modify the above trigger to prevent updates or deletes on rows which currently describe SalesLT.ProductModels. 
  * Exclude these rows from the update/delete, 
  * Allow all other rows to be updated/deleted as usual.
  * For rows updated, the ModifiedDate must be set to the time of the update, using GETDATE().
