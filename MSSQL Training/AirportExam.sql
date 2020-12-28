CREATE TABLE Planes (
  Id INT PRIMARY KEY IDENTITY,
  [Name] VARCHAR(30) NOT NULL,
  Seats INT NOT NULL,
  [Range] INT NOT NULL
)

CREATE TABLE Flights (
  Id INT PRIMARY KEY IDENTITY,
  DepartureTime DATETIME,
  ArrivalTime DATETIME,
  Origin VARCHAR(50) NOT NULL,
  Destination VARCHAR(50) NOT NULL,
  PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers (
  Id INT PRIMARY KEY IDENTITY,
  FirstName VARCHAR(30) NOT NULL,
  LastName VARCHAR(30) NOT NULL,
  Age INT NOT NULL,
  [Address] VARCHAR(30) NOT NULL,
  PassportId VARCHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes (
  Id INT PRIMARY KEY IDENTITY,
  [Type] VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages (
  Id INT PRIMARY KEY IDENTITY,
  LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
  PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets (
  Id INT PRIMARY KEY IDENTITY,
  PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
  FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
  LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
  Price DECIMAL(15, 2) NOT NULL
)

INSERT INTO Planes([Name], Seats, [Range]) VALUES
('Airbus 336', 112, 5132),
('Airbus 330', 432, 5325),
('Boeing 369', 231, 2355),
('Stelt 297', 254, 2143),
('Boeing 338', 165, 5111),
('Airbus 558', 387, 1342),
('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes([Type]) VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')

UPDATE Tickets
SET Price *= 1.13
FROM Tickets AS t
JOIN Flights AS f
ON t.FlightId = f.Id
WHERE f.Destination = 'Carlsbad'

DELETE FROM Tickets
WHERE FlightId = 30

DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'

SELECT Origin, Destination FROM Flights
ORDER BY Origin, Destination

SELECT * FROM Planes
WHERE [Name] LIKE '%tr%'

SELECT t.FlightId, SUM(t.Price) AS Price FROM Tickets AS t
JOIN Flights AS f ON t.FlightId = f.Id
GROUP BY t.FlightId
ORDER BY Price DESC, t.FlightId

SELECT TOP 10 FirstName, LastName, Price FROM Passengers AS p
JOIN Tickets AS t ON p.Id = t.PassengerId
ORDER BY Price DESC, FirstName, LastName

SELECT [Type], COUNT(l.LuggageTypeId) AS MostUsedLuggage FROM Luggages AS l
JOIN LuggageTypes AS lt ON l.LuggageTypeId = lt.Id
JOIN Passengers AS p ON l.PassengerId = p.Id
GROUP BY [Type]
ORDER BY MostUsedLuggage DESC, [Type]

SELECT FirstName + ' ' + LastName AS [Full Name], Origin, Destination FROM Passengers AS p
JOIN Tickets AS t ON p.Id = t.PassengerId
JOIN Flights AS f ON t.FlightId = f.Id
ORDER BY [Full Name], Origin, Destination

SELECT FirstName, LastName, Age FROM Passengers AS p
LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
WHERE t.Id IS NULL
ORDER BY Age DESC, FirstName, LastName

SELECT PassportId, [Address] FROM Passengers AS p
LEFT JOIN Luggages AS l ON p.Id = l.PassengerId
WHERE l.PassengerId IS NULL
ORDER BY PassportId, [Address]

SELECT FirstName, LastName, COUNT(t.PassengerId) AS [Total Trips] FROM Passengers AS p
FULL JOIN Tickets AS t ON p.Id = t.PassengerId
GROUP BY FirstName, LastName
ORDER BY [Total Trips] DESC, FirstName, LastName

SELECT FirstName + ' ' + LastName AS [Full Name],
P.[Name] AS [Plane Name], f.Origin + ' - ' + f.Destination AS Trip,
lt.[Type] AS [Luggage Type]
FROM Tickets AS t
JOIN Flights AS f ON t.FlightId = f.Id
JOIN Planes AS p ON f.PlaneId = p.Id
JOIN Passengers AS pas ON t.PassengerId = pas.Id
JOIN Luggages AS l ON t.LuggageId = l.Id
JOIN LuggageTypes AS lt ON l.LuggageTypeId = lt.Id
ORDER BY [Full Name], p.[Name], f.Origin, f.Destination, lt.[Type]

SELECT k.FirstName, k.LastName, k.Destination, k.Price
FROM (
	SELECT p.FirstName, p.LastName, f.Destination, t.Price,
		   DENSE_RANK() OVER(PARTITION BY p.FirstName, p.LastName ORDER BY t.Price DESC) As PriceRank
	  FROM Passengers AS p
	  JOIN Tickets AS t ON t.PassengerId = p.Id
	  JOIN Flights AS f ON f.Id = t.FlightId
  ) AS k 
WHERE k.PriceRank = 1
ORDER BY k.Price DESC, k.FirstName, k.LastName, k.Destination

SELECT Destination, COUNT(t.PassengerId) AS FilesCount FROM Flights AS f
FULL JOIN Tickets AS t ON f.Id = t.FlightId
GROUP BY Destination
ORDER BY FilesCount DESC, f.Destination

SELECT p.[Name], p.Seats, COUNT(t.PassengerId) AS [Passengers Count] FROM Planes AS p
FULL JOIN Flights AS f ON p.Id = f.PlaneId
FULL JOIN Tickets AS t ON f.Id = t.FlightId
GROUP BY p.[Name], p.Seats
ORDER BY [Passengers Count] DESC, p.[Name], p.Seats

CREATE FUNCTION dbo.udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @totalPrice DECIMAL(15, 2)
	DECLARE @originId INT = (SELECT f.Id FROM Flights AS f
	JOIN Tickets AS t ON f.Id = t.FlightId WHERE @origin = f.Origin AND @destination = f.Destination)

	IF(@originId IS NULL)
	BEGIN
	RETURN 'Invalid flight!'
	END

	IF(@peopleCount <= 0)
	BEGIN
	RETURN 'Invalid people count!'
	END

	SET @totalPrice = (SELECT Price FROM Tickets AS t
	JOIN Flights AS f ON t.FlightId = f.Id WHERE f.Origin = @origin AND f.Destination = @destination)
	SET @totalPrice *= @peopleCount

	RETURN 'Total price ' + CAST(@totalPrice AS VARCHAR(30))
END

CREATE PROC dbo.usp_CancelFlights
AS
UPDATE Flights
SET DepartureTime = NULL, ArrivalTime = NULL
WHERE ArrivalTime > DepartureTime

CREATE TABLE DeletedPlanes (
  Id INT PRIMARY KEY IDENTITY,
  [Name] VARCHAR(30) NOT NULL,
  Seats INT NOT NULL,
  [Range] INT NOT NULL
)

CREATE TRIGGER tr_DeletedPlanes
ON Planes
AFTER DELETE AS
INSERT INTO DeletedPlanes(Id, [Name], Seats, [Range])
(SELECT Id, [Name], Seats, [Range] FROM deleted)

