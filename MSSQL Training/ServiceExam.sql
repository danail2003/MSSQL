CREATE TABLE Users (
  Id INT PRIMARY KEY IDENTITY,
  Username VARCHAR(30) UNIQUE NOT NULL,
  [Password] VARCHAR(50) NOT NULL,
  [Name] VARCHAR(50),
  Birthdate DATETIME,
  Age INT CHECK(Age >= 14 AND Age <= 110),
  Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments (
  Id INT PRIMARY KEY IDENTITY,
  [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees (
  Id INT PRIMARY KEY IDENTITY,
  FirstName VARCHAR(25),
  LastName VARCHAR(25),
  Birthdate DATETIME,
  Age INT CHECK(Age >= 18 AND Age <= 110),
  DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories (
  Id INT PRIMARY KEY IDENTITY,
  [Name] VARCHAR(50) NOT NULL,
  DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE [Status] (
  Id INT PRIMARY KEY IDENTITY,
  Label VARCHAR(30) NOT NULL
)

CREATE TABLE Reports (
  Id INT PRIMARY KEY IDENTITY,
  CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
  StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
  OpenDate DATETIME NOT NULL,
  CloseDate DATETIME,
  [Description] VARCHAR(200) NOT NULL,
  UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
  EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

INSERT INTO Employees(FirstName, LastName, Birthdate, DepartmentId) VALUES
('Marlo', 'O''Malley', 1958-9-21, 1),
('Niki', 'Stanaghan', 1969-11-26, 4),
('Ayrton', 'Senna',	1960-03-21,	9),
('Ronnie', 'Peterson', 1944-02-14, 9),
('Giovanna', 'Amati', 1959-07-20, 5)

INSERT INTO Reports(CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId) VALUES
(1, 1, 2017-04-13, NULL, 'Stuck Road on Str.133', 6, 2),
(6,	3, 2015-09-05, 2015-12-06, 'Charity trail running' ,3, 5),
(14, 2,	2015-09-07,	NULL, 'Falling bricks on Str.58', 5, 2),
(4,	3, 2017-07-03, 2017-07-06, 'Cut off streetlight on Str.11',	1, 1)

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

DELETE FROM Reports
WHERE StatusId = 4

SELECT [Description], CONVERT(VARCHAR, OpenDate, 105) FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

SELECT [Description], [Name] AS CategoryName FROM Reports AS r
JOIN Categories AS c ON r.CategoryId = c.Id
WHERE r.CategoryId IS NOT NULL
ORDER BY [Description], CategoryName

SELECT TOP 5 [Name] AS CategoryName, COUNT(r.CategoryId) AS ReportsNumber FROM Categories AS c
JOIN Reports AS r ON c.Id = r.CategoryId
GROUP BY [Name]
ORDER BY ReportsNumber DESC, CategoryName

SELECT Username, c.[Name] AS CategoryName FROM Users AS u
JOIN Reports AS r ON u.Id = r.UserId
JOIN Categories AS c ON r.CategoryId = c.Id
WHERE DATEPART(DAY, Birthdate) = DATEPART(DAY, OpenDate) AND DATEPART(MONTH, Birthdate) = DATEPART(MONTH, OpenDate)
ORDER BY Username, CategoryName

SELECT FirstName + ' ' + LastName AS FullName, COUNT(u.Id) AS UsersCount FROM Employees AS e
LEFT JOIN Reports AS r ON e.Id = r.EmployeeId
LEFT JOIN Users AS u ON r.UserId = u.Id
GROUP BY FirstName, LastName
ORDER BY UsersCount DESC, FullName

SELECT ISNULL(FirstName, 'None') + ' ' + IIF(FirstName IS NULL, '', ISNULL(LastName, 'None')) AS Employee,
ISNULL(d.[Name], 'None') AS Department, ISNULL(c.[Name], 'None') AS Category,
ISNULL(r.[Description], 'None') AS [Description], ISNULL(CONVERT(VARCHAR, r.OpenDate, 104), 'None') AS OpenDate,
ISNULL(s.Label, 'None') AS [Status], ISNULL(u.[Name], 'None') AS [User] FROM Reports AS r
LEFT JOIN Employees AS e ON r.EmployeeId = e.Id
LEFT JOIN Users AS u ON r.UserId = u.Id
LEFT JOIN Departments AS d ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
LEFT JOIN [Status] AS s ON r.StatusId = s.Id
ORDER BY FirstName DESC, LastName DESC, d.[Name], c.[Name], r.[Description], r.OpenDate, s.Label, u.[Name]

CREATE FUNCTION dbo.udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS VARCHAR(MAX)
BEGIN
	DECLARE @hours INT

	IF(@StartDate IS NULL)
	BEGIN
		SET @hours = 0
	END
	ELSE IF(@EndDate IS NULL)
	BEGIN
		SET @hours = 0
	END
	ELSE
	BEGIN
		SET @hours = DATEDIFF(HOUR, @StartDate, @EndDate)
	END
	RETURN CAST(@hours AS VARCHAR(MAX))
END

CREATE PROCEDURE usp_assign_employee_to_report(employee_id INT, report_id INT)
BEGIN
	DECLARE employee_department_id INT DEFAULT (SELECT e.department_id FROM `employees` AS e WHERE e.id = employee_id);
	DECLARE report_category_id INT DEFAULT (SELECT r.category_id FROM `reports` AS r WHERE r.id = report_id);
	DECLARE category_department_id INT DEFAULT (SELECT c.department_id FROM `categories` AS c WHERE c.id = report_category_id);
	
	START TRANSACTION;
    IF(employee_department_id != category_department_id) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Employee doesn\'t belong to the appropriate department!';
        ROLLBACK;
    ELSE
        UPDATE `reports` AS r
            SET r.employee_id = employee_id
            WHERE r.id = report_id;
        COMMIT;
