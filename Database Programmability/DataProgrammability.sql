--Problem 1

GO
CREATE PROC dbo.usp_GetEmployeesSalaryAbove35000
AS
SELECT FirstName, LastName FROM Employees
WHERE Salary > 35000

EXEC usp_GetEmployeesSalaryAbove35000

--Problem 2

GO
CREATE PROC dbo.usp_GetEmployeesSalaryAboveNumber(@number DECIMAL(18, 2))
AS
SELECT FirstName, LastName FROM Employees
WHERE Salary >= @number

EXEC usp_GetEmployeesSalaryAboveNumber 48100

--Problem 3

GO
CREATE PROC dbo.usp_GetTownsStartingWith(@string NVARCHAR(50))
AS
SELECT [Name] AS Town FROM Towns
WHERE LEFT([Name], LEN(@string)) = @string

EXEC usp_GetTownsStartingWith 'sa'

--Problem 4

GO
CREATE PROC dbo.usp_GetEmployeesFromTown(@townName NVARCHAR(50))
AS
SELECT FirstName, LastName FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
WHERE t.[Name] = @townName

EXEC usp_GetEmployeesFromTown Sofia

--Problem 5

GO
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18, 4))
RETURNS VARCHAR(10)
AS
BEGIN

  DECLARE @salaryLevel VARCHAR(10)

  IF(@salary < 30000)
  BEGIN
  SET @salaryLevel = 'Low'
  END
  ELSE IF(@salary >= 30000 AND @salary <= 50000)
  BEGIN
  SET @salaryLevel = 'Average'
  END
  ELSE IF(@salary > 50000)
  BEGIN
  SET @salaryLevel = 'High'
  END
  RETURN @salaryLevel
END;
GO

SELECT Salary, dbo.ufn_GetSalaryLevel(13500) AS [Salary Level] FROM Employees

--Problem 6

GO
CREATE PROC dbo.usp_EmployeesBySalaryLevel(@salaryLevel VARCHAR(10))
AS
SELECT FirstName, LastName FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel

EXEC usp_EmployeesBySalaryLevel 'High'

--Problem 7

GO
CREATE FUNCTION dbo.ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(30))
RETURNS BIT
AS
BEGIN

	DECLARE @index INT = 1;
	
	WHILE(@index <= LEN(@word))
	BEGIN
	DECLARE @currentLetter VARCHAR(1) = SUBSTRING(@word, @index, 1);

	IF(CHARINDEX(@currentLetter, @setOfLetters)) = 0
	BEGIN
	RETURN 0;
	END

	SET @index += 1;
	END
RETURN 1;
END

--Problem 8

GO
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS

DECLARE @empIDsToBeDeleted TABLE
(
Id int
)

INSERT INTO @empIDsToBeDeleted
SELECT e.EmployeeID
FROM Employees AS e
WHERE e.DepartmentID = @departmentId

ALTER TABLE Departments
ALTER COLUMN ManagerID int NULL

DELETE FROM EmployeesProjects
WHERE EmployeeID IN (SELECT Id FROM @empIDsToBeDeleted)

UPDATE Employees
SET ManagerID = NULL
WHERE ManagerID IN (SELECT Id FROM @empIDsToBeDeleted)

UPDATE Departments
SET ManagerID = NULL
WHERE ManagerID IN (SELECT Id FROM @empIDsToBeDeleted)

DELETE FROM Employees
WHERE EmployeeID IN (SELECT Id FROM @empIDsToBeDeleted)

DELETE FROM Departments
WHERE DepartmentID = @departmentId 

SELECT COUNT(*) AS [Employees Count] FROM Employees AS e
JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE e.DepartmentID = @departmentId

--Problem 9

GO
CREATE PROC dbo.usp_GetHoldersFullName
AS
SELECT CONCAT(FirstName, + ' ' + LastName) AS [Full Name] FROM AccountHolders

EXEC dbo.usp_GetHoldersFullName

--Problem 10

GO
CREATE OR ALTER PROC dbo.usp_GetHoldersWithBalanceHigherThan(@number MONEY)
AS
SELECT FirstName AS [First Name], LastName AS [Last Name] FROM AccountHolders AS ah
JOIN Accounts AS a ON ah.Id = a.AccountHolderId
GROUP BY FirstName, LastName
HAVING SUM(a.Balance) > @number

EXEC dbo.usp_GetHoldersWithBalanceHigherThan 200

--Problem 11

GO
CREATE FUNCTION dbo.ufn_CalculateFutureValue(@sum DECIMAL(18, 2), @yearlyInterestRate FLOAT, @numbersOfYear INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN

	RETURN @sum * POWER(1 + @yearlyInterestRate, @numbersOfYear)
	
END
GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)
GO

--Problem 12

CREATE PROC dbo.usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT)
AS
SELECT ah.Id AS [Account ID], FirstName AS [First Name], LastName AS [Last Name],
a.Balance AS [Current Balance], dbo.ufn_CalculateFutureValue(Balance, @interestRate, 5) AS [Balance in 5 years]  FROM AccountHolders AS ah
JOIN Accounts AS a ON ah.Id = a.Id
WHERE a.Id = @accountId

EXEC dbo.usp_CalculateFutureValueForAccount 1, 0.1

--Problem 13

GO 
CREATE FUNCTION ufn_CashInUsersGames(@gameName varchar(max))
RETURNS @returnedTable TABLE
(
SumCash money
)
AS
BEGIN
	DECLARE @result money

	SET @result = 
	(SELECT SUM(ug.Cash) AS Cash
	FROM
		(SELECT Cash, GameId, ROW_NUMBER() OVER (ORDER BY Cash DESC) AS RowNumber
		FROM UsersGames
		WHERE GameId = (SELECT Id FROM Games WHERE Name = @gameName)
		) AS ug
	WHERE ug.RowNumber % 2 != 0
	)

	INSERT INTO @returnedTable SELECT @result
	RETURN
END
GO

--Problem 14

CREATE TABLE Logs(
  LogId INT PRIMARY KEY IDENTITY,
  AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
  OldSum MONEY,
  NewSum MONEY
)

GO
CREATE TRIGGER tr_UpdateBalance ON Accounts AFTER UPDATE
AS
BEGIN
INSERT INTO Logs(AccountId, OldSum, NewSum)
SELECT i.Id, d.Balance, i.Balance
FROM inserted AS i
JOIN deleted AS d ON i.Id = d.Id
END

--Problem 15

CREATE TABLE NotificationEmail(
  Id INT PRIMARY KEY IDENTITY,
  Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
  [Subject] VARCHAR(50),
  Body TEXT
)

GO
CREATE TRIGGER tr_EmailsNotificationsAfterInsert
ON Logs AFTER INSERT 
AS
BEGIN
INSERT INTO NotificationEmails(Recipient,Subject,Body)
SELECT i.AccountID, 
CONCAT('Balance change for account: ', i.AccountId),
CONCAT('On ',GETDATE(),' your balance was changed from ', i.NewSum,' to ', i.OldSum)
FROM inserted AS i
END
GO

--Problem 16

CREATE PROC dbo.usp_DepositMoney(@accountId INT, @moneyAmount MONEY)
AS
BEGIN TRANSACTION
UPDATE Accounts SET Balance += @moneyAmount
WHERE Id = @accountId
COMMIT

EXEC dbo.usp_DepositMoney 1, 10

--Problem 17

GO
CREATE PROC dbo.usp_WithdrawMoney(@accountId INT, @moneyAmount MONEY)
AS
BEGIN TRANSACTION
UPDATE Accounts SET Balance -= @moneyAmount
WHERE Id = @accountId
DECLARE @leftBalance MONEY = (SELECT Balance FROM Accounts WHERE Id = @accountId - @moneyAmount)
IF(@leftBalance < 0)
BEGIN
ROLLBACK
RETURN
END
COMMIT
GO

----Problem 18

DECLARE @UserName VARCHAR(50) = 'Stamat'
DECLARE @GameName VARCHAR(50) = 'Safflower'
DECLARE @UserID int = (SELECT Id FROM Users WHERE Username = @UserName)
DECLARE @GameID int = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney money = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
DECLARE @ItemsTotalPrice money
DECLARE @UserGameID int = (SELECT Id FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)

BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SELECT Name AS [Item Name]
FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @userGameID)
ORDER BY [Item Name]
GO

----Problem 21

CREATE PROC dbo.usp_AssignProject(@employeeId INT, @projectId INT)
AS
BEGIN TRANSACTION
DECLARE @projectsCount INT
SET @projectsCount = (SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeId = @employeeId)
IF(@projectsCount >= 3)
BEGIN
ROLLBACK
RAISERROR('The employee has too many projects!', 16, 1)
RETURN
END
INSERT INTO EmployeesProjects VALUES
(@employeeId, @projectId)
COMMIT
GO

CREATE TABLE Deleted_Employees (
  EmployeeId INT PRIMARY KEY IDENTITY,
  FirstName VARCHAR(30),
  LastName VARCHAR(30),
  MiddleName VARCHAR(30),
  JobTitle VARCHAR(20),
  DepartmentId INT,
  Salary MONEY
)
GO

--Problem 22

ALTER TABLE Deleted_Employees
ADD CONSTRAINT FK_Deleted_Employees FOREIGN KEY(DepartmentId) REFERENCES Departments(DepartmentId)
GO

CREATE TRIGGER tr_FiredEmployees ON Employees AFTER DELETE
AS
BEGIN
INSERT INTO Deleted_Employees
SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary
FROM deleted
END

SELECT * FROM Deleted_Employees
DELETE FROM Employees
WHERE EmployeeId = 1
GO