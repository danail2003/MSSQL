--Problem 1

CREATE DATABASE Bank

--Problem 2

CREATE TABLE Clients(
  Id INT PRIMARY KEY IDENTITY,
  FirstName NVARCHAR(50) NOT NULL,
  LastName NVARCHAR(50) NOT NULL
)

CREATE TABLE AccountType(
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Accounts(
  Id INT PRIMARY KEY IDENTITY,
  AccountTypeID INT FOREIGN KEY REFERENCES AccountType(Id),
  Balance DECIMAL(15, 2) NOT NULL DEFAULT(0),
  ClientId INT FOREIGN KEY REFERENCES Clients(Id)
)

--Problem 3

INSERT INTO Clients (FirstName, LastName) VALUES
('Gosho', 'Ivanov'),
('Pesho', 'Petrov'),
('Ivan', 'Iliev'),
('Merry', 'Ivanova')

INSERT INTO AccountType (Name) VALUES
('Checking'),
('Savings')

INSERT INTO Accounts (ClientId, AccountTypeID, Balance) VALUES
(1, 1, 175),
(2, 1, 275.56),
(3, 1, 138.01),
(4, 1, 40.30),
(4, 2, 375.50)
GO

--Problem 4

CREATE FUNCTION f_CalculateTotalBalance (@ClientID INT)
RETURNS DECIMAL(15, 2)
BEGIN
	DECLARE @result AS DECIMAL(15, 2) = (
	SELECT SUM(Balance)
	FROM Accounts WHERE ClientId = @ClientID
	)
	RETURN @result
END
GO

SELECT dbo.f_CalculateTotalBalance(4) AS Balance
GO

--Problem 5

CREATE PROC p_AddAcount @ClientId INT, @AccountTypeId INT AS
INSERT INTO Accounts (ClientId, AccountTypeID)
VALUES (@ClientId, @AccountTypeId)
GO

p_AddAcount 2, 2

SELECT * FROM Accounts
GO

CREATE PROC p_Deposit @AccountId INT, @Amount DECIMAL(15, 2) AS
UPDATE Accounts
SET Balance += @Amount
WHERE Id = @AccountId
GO

CREATE PROC p_Withdraw @AccountId INT, @Amount DECIMAL(15, 2) AS
BEGIN
  DECLARE @OldBalance DECIMAL(15, 2)
  SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
  IF(@OldBalance - @Amount >= 0)
  BEGIN
    UPDATE Accounts
	SET Balance -= @Amount
	WHERE Id = @AccountId
  END
  ELSE
  BEGIN
  RAISERROR('Insufficient funds', 10, 1)
  END
END

--Problem 6

CREATE TABLE Transactions (
  Id INT PRIMARY KEY IDENTITY,
  AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
  OldBalance DECIMAL (15, 2) NOT NULL,
  NewBalance DECIMAL (15, 2) NOT NULL,
  Amount AS NewBalance - OldBalance,
  [DateTime] DATETIME2
  )
GO

CREATE TRIGGER tr_Transaction ON Accounts
AFTER UPDATE
AS
  INSERT INTO Transactions (AccountId, OldBalance, NewBalance, [DateTime])
  SELECT inserted.Id, deleted.Balance, inserted.Balance, GETDATE() FROM inserted
  JOIN deleted ON inserted.Id = deleted.Id
GO

p_Deposit 1, 25.00
GO

p_Deposit 1, 40.00
GO

p_Withdraw 2, 200.00
GO

p_Deposit 4, 180.00
GO

SELECT * FROM Transactions