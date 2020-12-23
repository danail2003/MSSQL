USE Gringotts

--Problem 1

SELECT COUNT(Id) AS[Count]
FROM WizzardDeposits

--Problem 2

SELECT MAX(MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits

--Problem 3

SELECT DepositGroup, MAX(MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits
GROUP BY DepositGroup

--Problem 4

SELECT DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
HAVING AVG(MagicWandSize) =
(
  SELECT MIN(e.averageWandSize)
  FROM
  (
    SELECT AVG(MagicWandSize) AS averageWandSize
	FROM WizzardDeposits
	GROUP BY DepositGroup
  ) AS e
)

--Problem 5

SELECT DepositGroup,
SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup

--Problem 6

SELECT DepositGroup,
SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

--Problem 7

SELECT DepositGroup,
SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--Problem 8

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS [MinDepositCharge]
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--Problem 9

SELECT grouped.AgeGroup,
COUNT(*) AS [WizardCount]
FROM
(
  SELECT CASE
  WHEN Age BETWEEN 0 AND 10
  THEN '[0-10]'
  WHEN Age BETWEEN 11 AND 20
  THEN '[11-20]'
  WHEN Age BETWEEN 21 AND 30
  THEN '[21-30]'
  WHEN Age BETWEEN 31 AND 40
  THEN '[31-40]'
  WHEN Age BETWEEN 41 AND 50
  THEN '[41-50]'
  WHEN Age BETWEEN 51 AND 60
  THEN '[51-60]'
  WHEN Age > 60
  THEN '[61+]'
  END AS [AgeGroup]
  FROM WizzardDeposits
) AS grouped
GROUP BY grouped.AgeGroup

--Problem 10

SELECT LEFT(FirstName, 1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
ORDER BY FirstLetter

--Problem 11

SELECT DepositGroup, IsDepositExpired, AVG(1.0 * DepositInterest) AS [AverageInterest]
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--Problem 12

SELECT SUM(ws.Difference)
FROM
(
  SELECT DepositAmount - 
  ( 
    SELECT DepositAmount
	FROM WizzardDeposits AS wsd
	WHERE wsd.Id = wd.Id + 1
  ) AS Difference
  FROM WizzardDeposits AS wd
) AS ws

--Problem 13

USE SoftUniBuilt

SELECT DepartmentId, SUM(Salary) AS [TotalSalary]
FROM Employees
GROUP BY DepartmentId
ORDER BY DepartmentId

--Problem 14

SELECT DepartmentID, MIN(Salary) AS [MinimumSalary]
FROM Employees
WHERE DepartmentID IN (2, 5, 7) AND HireDate > '01/01/2000'
GROUP BY DepartmentID

--Problem 15

SELECT * 
INTO NewTable
FROM Employees
WHERE Salary > 30000

DELETE FROM NewTable
WHERE ManagerID = 42

UPDATE NewTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS [AverageSalary]
FROM NewTable
GROUP BY DepartmentID

--Problem 16

SELECT DepartmentID, MAX(Salary) AS [MaxSalary]
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--Problem 17

SELECT COUNT(Salary) AS [Count]
FROM Employees
WHERE ManagerID IS NULL

--Problem 18

SELECT salaries.DepartmentID,
       salaries.Salary
FROM
(
    SELECT DepartmentID,
           Salary,
           DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Rank
    FROM Employees
    GROUP BY DepartmentID,
             Salary
) AS salaries
WHERE Rank = 3
GROUP BY salaries.DepartmentID,
         salaries.Salary

--Problem 19

SELECT TOP 10 FirstName, LastName, DepartmentID
FROM Employees AS e
WHERE Salary > 
(
  SELECT AVG(Salary)
  FROM Employees AS em
  WHERE e.DepartmentID = em.DepartmentID
)