CREATE TABLE Cities (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(20) NOT NULL,
  CountryCode VARCHAR(2) NOT NULL
)

CREATE TABLE Hotels (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(30) NOT NULL,
  CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
  EmployeeCount INT NOT NULL,
  BaseRate DECIMAL(15, 2)
)

CREATE TABLE Rooms (
  Id INT PRIMARY KEY IDENTITY,
  Price DECIMAL(15, 2) NOT NULL,
  [Type] NVARCHAR(20) NOT NULL,
  Beds INT NOT NULL,
  HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips (
  Id INT PRIMARY KEY IDENTITY,
  RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
  BookDate DATE NOT NULL,
  ArrivalDate DATE NOT NULL,
  ReturnDate DATE NOT NULL,
  CancelDate DATE,
  CONSTRAINT Chk_BookDate CHECK(BookDate > ArrivalDate),
  CONSTRAINT Chk_ArrivalDate CHECK(ArrivalDate > ReturnDate)
)

CREATE TABLE Accounts (
  Id INT PRIMARY KEY IDENTITY,
  FirstName NVARCHAR(50) NOT NULL,
  MiddleName NVARCHAR(20),
  LastName NVARCHAR(50) NOT NULL,
  CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
  BirthDate DATE NOT NULL,
  Email VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips (
  AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
  TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
  Luggage INT NOT NULL,
  CONSTRAINT PK_AccountTripId PRIMARY KEY(AccountId, TripId),
  CONSTRAINT Chk_Luggage CHECK(Luggage >= 0)
)


INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email) VALUES
('John', 'Smith', 'Smith',	34,	'1975-07-21',	'j_smith@gmail.com'),
('Gosho', NULL,	'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov',	59,	'1849-09-26',	'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate) VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN(5, 7, 9)

DELETE FROM AccountsTrips
WHERE AccountId = 47

DELETE FROM Accounts
WHERE Id = 47

SELECT FirstName, LastName, FORMAT(BirthDate, 'MM-dd-yyyy'), c.[Name] AS HomeTown, Email FROM Accounts AS a
JOIN Cities AS c ON a.CityId = c.Id
WHERE a.FirstName LIKE 'e%'
ORDER BY c.[Name]

SELECT c.[Name] AS City, COUNT(h.CityId) AS Hotels FROM Cities AS c
JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY c.[Name]
ORDER BY Hotels DESC, City

SELECT a.Id AS AccountId, FirstName + ' ' + LastName AS FullName, DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) as LongestTrip,
DENSE_RANK() OVER (PARTITION BY DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)
ORDER BY DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip FROM Accounts AS a
JOIN AccountsTrips AS [at] ON a.Id = [at].AccountId
JOIN Trips AS t ON at.TripId = t.Id
WHERE t.CancelDate IS NULL
ORDER BY LongestTrip DESC, ShortestTrip

SELECT TOP 10 c.Id, c.[Name] AS City, c.CountryCode AS Country, COUNT(a.CityId) AS Accounts FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC

SELECT a.Id, a.Email, c.[Name] AS City, COUNT(h.CityId) AS Trips FROM AccountsTrips AS at
JOIN Trips AS t ON at.TripId = t.Id
JOIN Accounts AS a ON a.Id = at.AccountId
JOIN Cities AS c ON a.CityId = c.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
WHERE h.CityId = a.CityId
GROUP BY a.Id, a.Email, c.[Name]
ORDER BY Trips DESC, a.Id

SELECT t.Id, a.FirstName + IIF(a.MiddleName IS NULL, '', ' ') + ISNULL(a.MiddleName, '') + ' ' + a.LastName AS [Full Name], cc.[Name] AS [From],
c.[Name] AS [To], IIF(t.CancelDate IS NOT NULL, 'Canceled', CONVERT(VARCHAR, DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) + ' days') AS [Duration] FROM Accounts AS a
JOIN AccountsTrips AS at ON a.Id = at.AccountId
JOIN Trips AS t ON at.TripId = t.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c ON h.CityId = c.Id
JOIN Cities AS cc ON a.CityId = cc.Id
ORDER BY [Full Name], t.Id

GO
CREATE FUNCTION dbo.udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @rate DECIMAL(15, 2) = (SELECT BaseRate FROM Hotels WHERE Id = @HotelId)
	DECLARE @roomId INT = (SELECT r.Id FROM Rooms AS r JOIN Hotels AS h ON r.HotelId = h.Id WHERE r.HotelId = @HotelId)
	DECLARE @bedsCount INT = (SELECT Beds FROM Rooms AS r JOIN Hotels AS h ON r.HotelId = h.Id WHERE r.HotelId = @HotelId)
	DECLARE @type NVARCHAR(MAX) = (SELECT r.[Type] FROM Rooms AS r JOIN Hotels AS h ON r.HotelId = h.Id WHERE r.HotelId = @HotelId)
	DECLARE @price DECIMAL(15, 2) = (SELECT r.Price FROM Rooms AS r JOIN Hotels AS h ON r.HotelId = h.Id WHERE r.HotelId = @HotelId)
	DECLARE @result DECIMAL(15, 2) = (@rate + @price) * @people
	RETURN ('Room ' + CONVERT(nVARCHAR, @roomId) + ': ' + CONVERT(NVARCHAR, @type) + '(' + CONVERT(nVARCHAR, @bedsCount) + ' beds) - $' + CONVERT(nVARCHAR, @result))
END


SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)

GO
CREATE PROC dbo.usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
	DECLARE @accounts INT = (SELECT COUNT(at.AccountId) FROM AccountsTrips AS [at] JOIN Trips AS t ON [at].TripId = t.Id
	JOIN Rooms AS r ON t.RoomId = r.Id WHERE t.Id = @TripId)
	DECLARE @beds INT = (SELECT Beds FROM Rooms WHERE Id = @TargetRoomId)
	DECLARE @hotelId INT = (SELECT h.Id FROM Hotels AS h JOIN Rooms AS r ON h.Id = r.HotelId JOIN Trips AS t ON r.Id = t.RoomId WHERE t.Id = @TargetRoomId)
	DECLARE @hotel INT = (SELECT h.Id FROM Hotels AS h JOIN Rooms AS r ON h.Id = r.HotelId WHERE r.Id = @TripId)

	IF(@hotel <> @hotelId)
	BEGIN
	RAISERROR ('Target room is in another hotel!', 16, 1) RETURN
	END

	IF(@beds < @accounts) 
	BEGIN
	RAISERROR ('Not enough beds in target room!', 16, 1) RETURN
	END

	UPDATE Trips
	SET RoomId = @TargetRoomId
	WHERE Id = @TripId

	
EXEC usp_SwitchRoom 10, 8

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

EXEC usp_SwitchRoom 10, 7


