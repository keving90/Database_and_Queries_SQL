-- MySQL

-- Relational Database Design and SQL Programming class with UCSC Extension

-- Author: Kevin Geiszler

-- This script contains various queries used to extract data from the classdb database.

-- Run the script using: SOURCE /PATH_TO_FILE/query-kgeiszler.sql

-- 1. Find the elevation and population of a place.

SELECT Elevation, Population FROM Place
	WHERE PlaceID = 100;
    
-- 2. Find a place by a partial name.

SELECT PlaceID FROM SuppliedName
	WHERE SuppliedName LIKE 'San %';
    
-- 3. Find a place in a latitude/longitude box (within a range of latitudes/longitudes).

SELECT PlaceID FROM Place
	WHERE (Latitude BETWEEN 35 AND 40)
	AND   (Longitude BETWEEN 120 AND 125);

-- 4. Find a place by any of its names, listing its type, latitude, longitude, country,
--    population, and elevation.

SELECT SuppliedName.SuppliedName, Place.PlaceID, Place.PlaceType, Place.Latitude, Place.Longitude,
		Place.Country, Place.Population, Place.Elevation
	FROM Place
	INNER JOIN SuppliedName
	ON SuppliedName.PlaceID = Place.PlaceID
    WHERE SuppliedName.SuppliedName = 'The Big Apple';
    
-- 5. List all alternate names of a place, along with language, type of name, and standard.

SELECT SuppliedName, NameLanguage, NameStatus, Standard
	FROM SuppliedName
	WHERE PlaceID = '111' AND NameStatus = 'Alternate';

-- 6. Find the supplier who supplied a particular name, along with other information about the supplier.

SELECT Supplier.SupplierID, Supplier.SupplierName, Supplier.Country,
		Supplier.ReliabilityScore, Supplier.ContactInfo, SuppliedName.SnID
	FROM Supplier
	INNER JOIN SuppliedName
	ON SuppliedName.SupplierID = Supplier.SupplierID
	WHERE SuppliedName.SnID = '234';

-- 7. Find how many more names are in each language this month
--    (you can assume none are deleted -- ever!)

SELECT NameLanguage, COUNT(DateSupplied) AS NamesAddedThisMonth
	FROM SuppliedName
	WHERE MONTH(DateSupplied) = MONTH(CURDATE()) AND YEAR(DateSupplied) = YEAR(CURDATE())
	GROUP BY SuppliedName.NameLanguage;

-- 8. Find how much was paid out to suppliers this month, total.

SELECT SUM(Amount) AS TotalPaymentsThisMonth FROM Payment
	WHERE MONTH(Paymentdate) = MONTH(CURDATE()) AND YEAR(Paymentdate) = YEAR(CURDATE());

-- 9. Find how much was paid out to suppliers this month, by supplier.

SELECT SupplierID, SUM(AMOUNT) AS TotalPaymentsThisMonth FROM Payment
	WHERE MONTH(PaymentDate) = MONTH(CURDATE()) AND YEAR(Paymentdate) = YEAR(CURDATE())
	GROUP BY SupplierID;

-- 10. Show all the employee information in a particular department.

SELECT EmpID, EmployeeName, TaxID, Country, HireDate, BirthDate, Salary, Bonus, DeptID
	FROM Employee
	WHERE DeptID = '125';

-- 11. Increase salary by 10% and set bonus to 0 for all employees in a particular department.

UPDATE Employee
	SET Salary = Salary * 1.1, Bonus = 0
    WHERE DeptID = '125';
    
-- 12. Show all current employee information sorted by manager name and employee name.

SELECT Employee.EmpID, Employee.EmployeeName, Employee.TaxID, Employee.Country,
		Employee.HireDate, Employee.BirthDate, Employee.Salary, Employee.Bonus,
		Department.DeptName, Department.DeptID,
		(SELECT Employee.EmployeeName FROM Employee WHERE Employee.EmpID = Department.DeptHeadID) AS Manager
	FROM Employee
	INNER JOIN Department
	ON Employee.DeptID = Department.DeptID
	ORDER BY Manager, Employee.EmployeeName;

-- 13. Show all supplier information sorted by country, including number of names supplied in current
-- 	   month and potential suppliers.

/*
This is the original query. The new query uses a LEFT JOIN to ensure that companies with
0 supplied names (potential suppliers) in that moth are included. Also, the CASE statement
is changed because there is no data for the current month and year.

SELECT Supplier.SupplierID, Supplier.SupplierName, Supplier.Country, Supplier.ReliabilityScore,
		Supplier.ContactInfo,
	COUNT(CASE
			WHEN MONTH(SuppliedName.DateSupplied) = MONTH(CURDATE()) AND YEAR(SuppliedName.DateSupplied) = YEAR(CURDATE())
				THEN SuppliedName.DateSupplied
			ELSE NULL
		END) AS NamesSuppliedThisMonth
	FROM Supplier
	INNER JOIN SuppliedName
	ON SuppliedName.SupplierID = Supplier.SupplierID
	GROUP BY 'DatesTest', Supplier.SupplierID
	ORDER BY Supplier.Country ASC;
	
*/	

-- Updated query

SELECT Supplier.SupplierID, Supplier.SupplierName, Supplier.Country, Supplier.ReliabilityScore,
		Supplier.ContactInfo,
	COUNT(CASE
			WHEN MONTH(SuppliedName.DateSupplied) = '7' AND YEAR(SuppliedName.DateSupplied) = '2017'
				THEN SuppliedName.DateSupplied
			ELSE NULL
		END) AS NamesSuppliedThisMonth
	FROM Supplier
	LEFT JOIN SuppliedName
	ON SuppliedName.SupplierID = Supplier.SupplierID
	GROUP BY 'DatesTest', Supplier.SupplierID
	ORDER BY Supplier.Country ASC;

-- 14. Describe how you implemented the access restrictions on the previous page.

/*

-- All employees can see place and name information:

GRANT SELECT ON Place TO ''@'%.namesinc.com';
GRANT SELECT ON SuppliedName TO ''@'%.namesinc.com';

-- Only HR employees can access all HR info:

CREATE VIEW hr_view
AS
SELECT * FROM Employee;

GRANT SELECT ON hr_view TO 'SamHR123'@'SamHR123.namesinc.com'; -- "Low level" HR employee example

-- Only some HR employees can change the information in the HR portion of the DB:

GRANT SELECT, UPDATE, INSERT, DELETE ON hr_view TO 'SusanX200'@'SusanX200.namesinc.com';

-- Managers can see their employee information:

CREATE VIEW it_manager_view -- IT manager example
AS
SELECT * FROM Employee
WHERE Employee.DeptID = '125';

GRANT SELECT ON manager_view TO 'RichardI231'@'RichardI231.namesinc.com';

-- Managers can update their employee compensation:

GRANT UPDATE(Salary) ON manager_view TO 'RichardI231'@'RichardI231.namesinc.com'; -- IT manager example

*/

-- 15. Describe how you implement the constraints shown in the ERD and on the employee info.

/*

All foreign keys are set to CASCADE on DELETE and UPDATE.

Place Table:
-----------

The Place table allows Elevation, Population, Country, and ACSIIName to be NULL. Latitude only allows values
between -90 and 90. Longitude only allows values between -180 and 180. Since MySQL does not support CHECK constraints, 
there are several triggers in the provision file for Latitude and Longitude after all of the CREATE statements. These 
triggers go off if invalid values are entered for Latitude and Longitude upon data insertion or updating.

Supplier Table:
---------------

ReliabilityScore and ProductivityScore allow NULL values because it may take some time to determine these scores after 
a name has been supplied.

SuppliedName Table:
-------------------

A supplied name refers to exactly one place. Therefore, the SuppliedName.PlaceID foreign key does not allow NULL
values.

A supplied name can have 0 to 1 suppliers. Therefore, SuppliedName.SupplierID allows NULL values.

NameStatus, Standard, DateSupplied, and Price allow NULL values.

Payment Table:
--------------

A single payment is always made to exactly one supplier. Therefore, Payment.SupplierID cannot be NULL.

Department Table:
-----------------

A department has 0 to many employees working for it. Since it's possible for the department to have 0 employees,
DeptHeadID, DeptHeadUserID, and DeptAA allow NULL values.

Employee Table:
---------------

Each employee works for exactly one department. Therefore, Employee.DeptID does not allow NULL values. 
All other fields in Employee are NOT NULL.

An employee's salary must be greater than 0. Also, an employee's bonus must be less than or equal to their salary.
Since MySQL does not support CHECK constraints, several tiggers have been added to the provision file after all of the
CREATE statements. These triggers go off if Salary <= 0 and if Salary < Bonus upon data insertion or updating.

*/



































