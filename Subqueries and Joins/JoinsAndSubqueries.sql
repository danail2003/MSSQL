--Problem 1

SELECT TOP 5 e.EmployeeID, JobTitle, e.AddressID, AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY e.AddressID ASC

--Problem 2

SELECT TOP 50 e.FirstName, e.LastName, t.[Name] AS Town, a.AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

--Problem 3

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] AS DepartmentName FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID AND d.[Name] = 'Sales'
ORDER BY EmployeeID ASC

--Problem 4

SELECT TOP 5 e.EmployeeID, e.FirstName, e.Salary, d.[Name] AS DepartmentName FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID AND e.Salary > 15000
ORDER BY d.DepartmentID ASC

--Problem 5

SELECT TOP 3 e.EmployeeID, e.FirstName FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID ASC

--Problem 6

SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] AS DeptName FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID AND e.HireDate > '1.1.1999 ' AND d.[Name] IN ('Sales', 'Finance')
ORDER BY HireDate ASC

--Problem 7

SELECT TOP 5 e.EmployeeID, e.FirstName, p.[Name] AS ProjectName FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '08/13/2002' AND p.EndDate IS NULL
ORDER BY e.EmployeeID ASC

--Problem 8

SELECT e.EmployeeID, e.FirstName,
CASE
WHEN p.StartDate > '01/01/2005'
THEN NULL
ELSE p.[Name]
END 
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

--Problem 9

SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS ManagerName FROM Employees AS e
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID ASC

--Problem 10

SELECT TOP 50 e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName,
m.FirstName + ' ' + m.LastName AS ManagerName,
d.[Name] AS DepartmentName FROM Employees AS e
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY EmployeeID ASC

--Problem 11

Select MIN(a.AverageSalary) AS MinAverageSalary FROM
(SELECT e.DepartmentId, AVG(e.Salary) AS AverageSalary FROM Employees AS e GROUP BY e.DepartmentID) AS a

--Problem 12

USE GeographyBuilt

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM Mountains AS m
JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
JOIN Countries AS c ON mc.CountryCode = c.CountryCode
JOIN Peaks AS p ON mc.MountainId = p.MountainId
WHERE c.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

--Problem 13

SELECT mc.CountryCode, COUNT(mc.CountryCode) AS MountainRanges FROM MountainsCountries AS mc
JOIN Mountains AS m ON mc.MountainId = m.Id
WHERE mc.CountryCode IN ('US', 'BG', 'RU')
GROUP BY mc.CountryCode

--Problem 14

SELECT TOP 5 c.CountryName, r.RiverName FROM CountriesRivers AS cr
FULL JOIN Countries AS c ON cr.CountryCode = c.CountryCode
FULL JOIN Rivers AS r ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName ASC

--Problem 15

SELECT rankedCurrencies.ContinentCode, rankedCurrencies.CurrencyCode, rankedCurrencies.Count
FROM (
SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS [Count], DENSE_RANK() OVER (PARTITION BY c.ContinentCode ORDER BY COUNT(c.CurrencyCode) DESC) AS [rank] 
FROM Countries AS c
GROUP BY c.ContinentCode, c.CurrencyCode) AS rankedCurrencies
WHERE rankedCurrencies.rank = 1 and rankedCurrencies.Count > 1

--Problem 16

SELECT COUNT(c.CountryCode) AS [Count] FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL

--Problem 17

SELECT TOP 5 c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.[Length]) AS LongestRiverLength FROM Countries AS c
FULL JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
FULL JOIN Peaks AS p ON mc.MountainId = p.MountainId
FULL JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
FULL JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName

--Problem 18

SELECT TOP 5 WITH TIES c.CountryName, ISNULL(p.PeakName, '(no highest peak)') AS [Highest Peak Name],
ISNULL(MAX(p.Elevation), 0) AS [Highest Peak Elevation],
ISNULL(m.MountainRange, '(no mountain)') AS Mountain FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName, p.PeakName, m.MountainRange
ORDER BY c.CountryName, p.PeakName ASC

