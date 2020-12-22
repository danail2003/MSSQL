USE [Diablo-Built]

--Problem 14

SELECT TOP(50) [Name], FORMAT(CAST([Start] AS DATE), 'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR, [Start]) BETWEEN 2011 AND 2012
ORDER BY [Start], [Name]

--Problem 15

SELECT Username, RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS 'Email Provider'
FROM Users
ORDER BY [Email Provider], Username

--Problem 16

SELECT Username, IpAddress AS 'IP Address' FROM Users
WHERE IpAddress LIKE '___.1_%.%_.___'
ORDER BY Username

--Problem 17

SELECT [Name] AS 'Game',
CASE
WHEN DATEPART(HOUR, START) BETWEEN 0 AND 11
THEN 'Morning'
WHEN DATEPART(HOUR, START) BETWEEN 12 AND 17
THEN 'Afternoon'
WHEN DATEPART(HOUR, START) BETWEEN 18 AND 23
THEN 'Evening'
END AS 'Part of the Day',
CASE
WHEN Duration <= 3
THEN 'Extra Short'
WHEN Duration BETWEEN 4 AND 6
THEN 'Short'
WHEN Duration > 6
THEN 'Long'
WHEN Duration IS NULL
THEN 'Extra Long'
END AS 'Duration'
FROM Games
ORDER BY [Name], [Duration], [Part of the Day]


