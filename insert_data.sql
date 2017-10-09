-- MySQL

-- Relational Database Design and SQL Programming class with UCSC Extension

-- Author: Kevin Geiszler

-- Inserts sample data into 'classdb' created by 'provision-kgeiszler.sql'

-- Run the script using: SOURCE /PATH_TO_FILE/insert_data.sql

INSERT INTO Place
(PlaceID, Latitude, Longitude, Elevation, Population, PlaceType, Country, ASCIIName)
VALUES
('111', 37.7749, 122.4194, 16,  864816,  'City', 'USA',    'San Francisco'),
('222', 40.7128, 74.0059,  10,  8175133, 'City', 'USA',    'New York City'),
('333', 34.0522, 118.2437, 89,  3971883, 'City', 'USA',    'Los Angeles'),
('444', 38.4816, 121.4944, 30,  466488,  'City', 'USA',    'Sacramento'),
('555', 41.8781, 87.6298,  594, 2695598, 'City', 'USA',    'Chicago'),
('666', 48.8566, 2.3522,   115, 2241346, 'City', 'France', 'Paris');

INSERT INTO Supplier
(SupplierID, SupplierName, Country, ReliabilityScore, ContactInfo, ProductivityScore)
Values
('B23',  'Name Supply Inc.', 			   'USA', 'A-', '123 Fake St.',   'A-'),
('G542', 'Google Names',         		   'USA', 'A+', '555 Main St.',   'A+'),
('X5',   'Real Names and Places', 		   'UK',  'A+', '7314 First St.', 'A+'),
('D35',  'Definitely a Real Company Inc.', 'AU',  'A',  '42 Wallaby Wy.', 'A');

INSERT INTO SuppliedName
(SnID, SuppliedName, NameLanguage, NameStatus, Standard, PlaceID, SupplierID, DateSupplied, Price)
VALUES
('234', 'SF', 				  'English', 'Abbreviation', 'ISO 3166-2:US-CA', '111', 'X5',   '2017-07-16', 1000),
('235', 'The City', 		  'English', 'Alternate', 	 'ISO 3166-2:US-CA', '111', 'B23',  '2017-07-23', 1000),
('236', 'San Francisco',	  'English', 'Official', 	 'ISO 3166-2:US-CA', '111', 'G542', '2016-07-01', 1000), -- not current year, but current month

('145', 'The Big Apple', 	  'English', 'Alternate',	 'ISO 3166-2:US-NY', '222', 'B23',  '2017-07-23', 2000),
('146', 'NYC',				  'English', 'Abbreviation', 'ISO 3166-2:US-NY', '222', 'X5',   '2017-07-16', 2000),
('147', 'New York', 		  'English', 'Official', 	 'ISO 3166-2:US-NY', '222', 'G542', '2016-07-01', 2000), -- not current year, but current month

('534', 'LA',				  'English', 'Abbreviation', 'ISO 3166-2:US-CA', '333', 'X5',   '2017-07-16', 3000),
('535', 'The City of Angels', 'English', 'Alternate',    'ISO 3166-2:US-CA', '333', 'B23',  '2017-07-23', 3000),
('536', 'Los Angeles',		  'English', 'Official', 	 'ISO 3166-2:US-CA', '333', 'G542', '2016-07-01', 3000), -- not current year, but current month

('361', 'Sacramento', 		  'English', 'Official',     'ISO 3166-2:US-CA', '444', 'D35',  '2017-06-25', 1500), -- not current month

('756', 'Chicago',			  'English', 'Official',     'ISO 3166-2:US-IL', '555', 'D35',  '2016-07-01', 1500), -- not current year, but current month
('757', 'The Windy City',	  'English', 'Alternate',    'ISO 3166-2:US-IL', '555', 'D35',  '2017-06-01', 1000), -- not current month

('362', 'Paris',			  'French',  'Official',     'ISO 3166-2:FR',    '666', 'D35',  '2017-07-01', 3000);

INSERT INTO Payment
(PaymentID, SupplierID, PaymentDate, Amount)
VALUES
('X5-1',   'X5',   '2017-07-01', 1000),
('X5-2',   'X5',   '2017-06-01', 2000), -- not current month
('X5-3',   'X5',   '2017-07-01', 3000),
('B23-1',  'B23',  '2017-06-01', 1000), -- not current month
('B23-2',  'B23',  '2016-07-01', 2000), -- not current year, but current month
('B23-3',  'B23',  '2017-07-01', 3000),
('G542-1', 'G542', '2017-07-01', 1000),
('G542-2', 'G542', '2017-06-01', 2000), -- not current month
('G542-3', 'G542', '2017-05-01', 3000); -- not current month

INSERT INTO Department
(DeptID, DeptName, DeptHeadID, DeptHeadUserID, DeptAA, ParentDeptID, Location, DeptType)
VALUES
('100', 'Executives',      'X001',  'DavidX001',   'NULL', 'NULL', 'USA', 'Main Dept'),
('125', 'IT',		       'I231',  'RichardI231', 'NULL', 'NULL', 'USA', 'Main Dept'),
('101', 'Marketing',       'X431',  'AliceX431',   'NULL', 'NULL', 'USA', 'Main Dept'),
('120', 'Human Resources', 'X200',  'SusanX200',   'NULL', 'NULL', 'USA', 'Main Dept');

INSERT INTO Employee
(EmpID, EmployeeName, TaxID, Country, HireDate, BirthDate, Salary, Bonus, DeptID, AddressInfo)
VALUES
('X431',  'Alice',   '4867385', 'USA', '2010-08-09', '1980-10-01', 90000,   2500,  '100', '384 Pine Dr.'),
('S433',  'Carol',   '3769275', 'USA', '2012-11-30', '1981-10-31', 65000,   1500,  '125', '8736 Willow Ln.'),
('B432',  'Bob',     '3194064', 'USA', '2008-02-15', '1979-10-17', 80000,   2000,  '125', '332 Fox Rd.'),
('X001',  'David',   '9385723', 'USA', '2006-04-01', '1960-10-20', 1000000, 10000, '100', '431 Expensive Dr.'),
('M567',  'Ashley',  '8372059', 'USA', '2016-05-05', '1990-03-25', 40000,   500,   '101', '234 Ross Ave.'),
('X284',  'Richard', '5827492', 'USA', '2010-06-15', '1983-09-01', 100000,  3000,  '100', '525 Sixth St.'),
('X200',  'Susan',   '8928572', 'USA', '2008-02-28', '1980-05-08', 85000,   2250,  '100', '525 Hill Rd.'),
('HR123', 'Sam',     '6729485', 'USA', '2015-12-01', '1991-03-15', 50000,   1000,  '120', '421 Long St.');











































