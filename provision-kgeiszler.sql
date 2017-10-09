-- MySQL

-- Relational Database Design and SQL Programming class with UCSC Extension

-- Author: Kevin Geiszler

-- This script creates each table. It also creates several triggers that constrain certain
-- fields to a given range of values.

-- Run the script using: SOURCE /PATH_TO_FILE/provision-kgeiszler.sql

CREATE TABLE Place
(
	PlaceID VARCHAR(50) NOT NULL PRIMARY KEY, -- Primary Key
    Latitude DECIMAL(8, 6) NOT NULL -- 6 decimal places allows a 10cm difference in each .000001 https://stackoverflow.com/questions/15965166/what-is-the-maximum-length-of-latitude-and-longitude
		CHECK(Latitude >= -90 AND Latitude <= 90), -- BTree; restrict to between -90 and +90; CHECK not supported by MySQL, see triggers below
    Longitude DECIMAL(9, 6) NOT NULL -- 6 decimal places allows a 10cm difference in each .000001
		CHECK(Longitude >= -180 AND Longitude <= 180), -- BTree; restrict to between -180 and +180; CHECK not supported by MySQL, see triggers below
    Elevation INT NOT NULL,
    Population INT,
    PlaceType VARCHAR(25) NOT NULL, -- 'Type' is a keyword
    Country VARCHAR(50),
    ASCIIName VARCHAR(50),
    
    INDEX(Latitude), -- Make Latitude a BTree index
    INDEX(Longitude) -- Make Longitude a BTree index
);

-- Can foreign keys be NULL?
-- According to the ERD, there's exactly one Place per SuppliedName. This means each name refers to
-- exactly one place. Therefore, PlaceID must be NOT NULL (it's also a foreign key).
-- PlaceID is ON DELETE SET NULL, so when Place.PlaceID is deleted, then SuppliedName.PlaceID becomes
-- NULL

CREATE TABLE Supplier
(
	SupplierID VARCHAR(50) NOT NULL PRIMARY KEY, -- Primary Key
    SupplierName VARCHAR(50) NOT NULL, -- 'Name' is a keyword
    Country VARCHAR(50) NOT NULL,
    ReliabilityScore VARCHAR(2), -- A-F with '+' or '-' option
    ContactInfo VARCHAR(200) NOT NULL,
    ProductivityScore VARCHAR(2) -- A-F with '+' or '-' option
);

-- 0-to-1 Suppliers per supplied name implies SuppliedName.SupplierID can be NULL
-- Exactly one Place per SuppliedName implies SuppliedName.PlaceID cannot be NULL

CREATE TABLE SuppliedName
(
	SnID VARCHAR(50) NOT NULL PRIMARY KEY, -- Primary Key
    SuppliedName VARCHAR(50) NOT NULL, -- BTree, 'Name' is a keyword
    NameLanguage VARCHAR(25) NOT NULL, -- 'Language' is a keyword
    NameStatus VARCHAR(25), -- 'Status' is a keyword
    Standard VARCHAR(25),
    
	PlaceID VARCHAR(50) NOT NULL, -- Foreign Key
    FOREIGN KEY(PlaceID) REFERENCES Place(PlaceID)
		ON DELETE CASCADE ON UPDATE CASCADE,
    
	SupplierID VARCHAR(50), -- Foreign Key
    FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
		ON DELETE CASCADE ON UPDATE CASCADE,
        
    DateSupplied DATE, -- 'Date' is a keyword
    Price DECIMAL(12, 2),
    
    INDEX(SuppliedName) -- Make SuppliedName a BTree index
);

-- According to the ERD, there is exactly one Supplier per payment. Therefore, PaymentID
-- must be NOT NULL. Also, if a payment is in the Payment table, then the payment has occurred.
-- Therefore, the PaymentDate is NOT NULL. Take note of SupplierID's "ON DELETE SET NULL".

CREATE TABLE Payment
(
	PaymentID VARCHAR(50) NOT NULL PRIMARY KEY, -- Primary Key
    
	SupplierID VARCHAR(50) NOT NULL, -- Foreign Key
    FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
		ON DELETE CASCADE ON UPDATE CASCADE,

    PaymentDate DATE NOT NULL, -- 'Date' is a keyword
    Amount DECIMAL(12, 2) NOT NULL
);

-- According to the ERD, there are 0-to-many employees per department. Therefore, I'm going to say it's possible
-- for a department to have NULL values for DeptHeadID, DeptHeadUserID, and DeptAA

CREATE TABLE Department
(
	DeptID VARCHAR(50) NOT NULL PRIMARY KEY, -- Primary Key
    DeptName VARCHAR(50) NOT NULL,
    DeptHeadID VARCHAR(50),
    DeptHeadUserID VARCHAR(50),
    DeptAA VARCHAR(50),
    ParentDeptID VARCHAR(50),
    Location VARCHAR(100) NOT NULL,
    DeptType VARCHAR(50) NOT NULL
);

-- According to the ERD, there is exactly one department per employee. Therefore, the DeptID field cannot contain
-- NULL values

CREATE TABLE Employee
(
	EmpID VARCHAR(50) NOT NULL PRIMARY KEY, -- Primary Key
    EmployeeName VARCHAR(50) NOT NULL,
    TaxID VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    BirthDate DATE NOT NULL,
    Salary DECIMAL(12,2) NOT NULL
		CHECK(Salary > 0), -- constraint; CHECK not supported by MySQL, see triggers below
    Bonus DECIMAL(12, 2) NOT NULL
		CHECK(Bonus <= Salary), -- constraint; CHECK not supported by MySQL, see triggers below
        
	DeptID VARCHAR(50) NOT NULL, -- Foreign Key
	FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
		ON DELETE CASCADE ON UPDATE CASCADE,
    
    AddressInfo VARCHAR(100) NOT NULL
);



-- Several triggers can be found below:
-- -------------------------------------

DELIMITER $$ -- Change the delimiter so triggers can be used

-- Must have -90 <= Latitude <= 90 on INSERT:
CREATE TRIGGER check_latitude_insert BEFORE INSERT ON Place
FOR EACH ROW
BEGIN
    IF NEW.Latitude NOT BETWEEN -90 AND 90 THEN
    SIGNAL SQLSTATE '10000'
		SET MESSAGE_TEXT = 'check constraint on Latitude in Place table failed during insert (must have: -90 <= Latitude <= 90)';
	END IF;
END; $$

-- Must have -90 <= Latitude <= 90 on UPDATE:
CREATE TRIGGER check_latitude_update BEFORE UPDATE ON Place
FOR EACH ROW BEGIN
	IF NEW.Latitude NOT BETWEEN -90 AND 90 THEN
    SIGNAL SQLSTATE '10000'
		SET MESSAGE_TEXT = 'check constraint on Latitude in Place table failed during update (must have: -90 <= Latitude <= 90)';
	END IF;
END; $$

-- Must have -180 <= Longitude <= 180 on INSERT:
CREATE TRIGGER check_longitude_insert BEFORE INSERT ON Place
FOR EACH ROW BEGIN
	IF NEW.Longitude NOT BETWEEN -180 AND 180 THEN
    SIGNAL SQLSTATE '10000'
		SET MESSAGE_TEXT = 'check constraint on Longitude in Place table failed during insert (must have: -180 <= Longitude <= 180)';
	END IF;
END; $$

-- Must have -180 <= Longitude <= 180 on UPDATE:
CREATE TRIGGER check_longitude_update BEFORE UPDATE ON Place
FOR EACH ROW BEGIN
	IF NEW.Longitude NOT BETWEEN -180 AND 180 THEN
    SIGNAL SQLSTATE '10000'
		SET MESSAGE_TEXT = 'check constraint on Longitude in Place table failed during update (must have: -180 <= Longitude <= 180)';
	END IF;
END; $$

-- Must have Salary > 0 on INSERT:
CREATE TRIGGER check_salary_insert BEFORE INSERT ON Employee 
FOR EACH ROW 
BEGIN 
	IF NEW.Salary <= 0 THEN 
	SIGNAL SQLSTATE '10000' 
		SET MESSAGE_TEXT = 'check constraint on Salary in Employee table failed during insert (must have: Employee.Salary > 0)';
	END IF;
END; $$

-- Must have Salary > 0 on UPDATE:
CREATE TRIGGER check_salary_update BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
	IF NEW.Salary <= 0 THEN
	SIGNAL SQLSTATE '10000' 
		SET MESSAGE_TEXT = 'check constraint on Salary in Employee table failed during update (must have: Employee.Salary > 0)';
	END IF;
END; $$

-- Must have Bonus <= Salary on INSERT:
CREATE TRIGGER check_bonus_insert BEFORE INSERT ON Employee
FOR EACH Row
BEGIN
	IF NEW.Salary < NEW.Bonus THEN
    SIGNAL SQLSTATE '10000'
		SET MESSAGE_TEXT = 'check constraint on Bonus in Employee table failed during insert (must have: Employee.Bonus <= Employee.Salary)';
	END IF;
END; $$

-- Must have Bonus <= Salary on UPDATE:
CREATE TRIGGER check_bonus_update BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
	IF NEW.Salary < NEW.Bonus THEN
    SIGNAL SQLSTATE '10000'
		SET MESSAGE_TEXT = 'check constraint on Bonus in Employee table failed during update (must have: Employee.Bonus <= Employee.Salary)';
	END IF;
END; $$

DELIMITER ; -- Change the delimiter back to the original

-- End Triggers ------------------------





































