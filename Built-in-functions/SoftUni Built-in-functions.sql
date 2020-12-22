USE SoftUniBuilt

--Problem 1

SELECT FirstName, LastName FROM Employees
WHERE FirstName LIKE 'SA%'

--Problem 2

SELECT FirstName, LastName FROM Employees
WHERE LastName LIKE '%ei%'

--Problem 3

SELECT FirstName FROM Employees
WHERE DepartmentID IN(3, 10) AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005

--Problem 4

SELECT FirstName, LastName FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

--Problem 5

SELECT [Name] FROM Towns
WHERE LEN([Name]) = 5 OR LEN([Name]) = 6
ORDER BY [Name] ASC

----Problem 6

SELECT TownId, [Name]
  FROM Towns
 WHERE LEFT([Name], 1) = 'M'
    OR LEFT([Name], 1) = 'K'
    OR LEFT([Name], 1) = 'B'
	OR LEFT([Name], 1) = 'E'
ORDER BY [Name] ASC

--Problem 7

SELECT TownId, [Name] FROM Towns
WHERE LEFT([Name], 1) NOT LIKE '[RBD]'
ORDER BY [Name] ASC

--Problem 8

CREATE VIEW v_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM Employees
WHERE DATEPART(YEAR, HireDate) > 2000

SELECT * FROM v_EmployeesHiredAfter2000

--Problem 9

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5

--Problem 10

SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER(PARTITION BY Salary ORDER BY EmployeeId) 'Rank'
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

--Problem 11

SELECT * FROM  (
SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER(PARTITION BY Salary ORDER BY EmployeeId) AS Rank
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000)
AS TableRank2
WHERE Rank = 2
ORDER BY Salary DESC