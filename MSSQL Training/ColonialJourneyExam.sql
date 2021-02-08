CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id)
)

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) UNIQUE NOT NULL,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) NOT NULL CHECK(Purpose = 'Medical' OR Purpose = 'Technical' OR Purpose = 'Military' OR Purpose = 'Educational'),
	DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney = 'Pilot' OR JobDuringJourney = 'Engineer' OR JobDuringJourney = 'Trooper' OR JobDuringJourney = 'Cleaner' OR JobDuringJourney = 'Cook'),
	ColonistId INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId INT NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
)

INSERT INTO Planets([Name]) VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships([Name], Manufacturer, LightSpeedRate) VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3

SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart, FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart ASC

SELECT c.Id AS id, FirstName + ' ' + LastName AS full_name FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id=tc.ColonistId
WHERE JobDuringJourney = 'Pilot'
ORDER BY c.Id ASC

SELECT COUNT(c.Id) AS [count] FROM Journeys AS j
JOIN TravelCards AS tc ON j.Id = tc.JourneyId
JOIN Colonists AS c ON tc.ColonistId = c.Id
WHERE j.Purpose = 'Technical'

SELECT [Name], Manufacturer FROM Spaceships AS s
JOIN Journeys AS j ON s.Id = j.SpaceshipId
JOIN TravelCards AS tc ON j.Id = tc.JourneyId
JOIN Colonists AS c ON tc.ColonistId = c.Id
WHERE tc.JobDuringJourney = 'Pilot' AND DATEDIFF(YEAR, c.BirthDate, '01/01/2019') < 30 
ORDER BY [Name] ASC

SELECT p.[Name] AS PlanetName, COUNT(j.Id) AS JorneysCount FROM Planets AS p
JOIN Spaceports AS s ON p.Id = s.PlanetId
JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
GROUP BY p.[Name]
ORDER BY JorneysCount DESC, PlanetName ASC

SELECT * FROM(
SELECT tc.JobDuringJourney, FirstName + ' ' + LastName AS FullName, DENSE_RANK() OVER(PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS JobRank FROM TravelCards AS tc
JOIN Colonists AS c ON tc.ColonistId = c.Id)
AS TableRank2
WHERE JobRank = 2

CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
BEGIN
	DECLARE @count INT = (SELECT COUNT(c.Id) FROM Planets AS p
	JOIN Spaceports AS s ON p.Id = s.PlanetId
	JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
	JOIN TravelCards AS tc ON j.Id = tc.JourneyId
	JOIN Colonists AS c ON tc.ColonistId = c.Id
	WHERE p.[Name] = @PlanetName)

	RETURN @count
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
	DECLARE @Id INT = (SELECT Id FROM Journeys WHERE Id = @JourneyId)

	IF(@Id IS NULL)
	BEGIN
	RAISERROR ('The journey does not exist!', 16, 1) RETURN
	END

	DECLARE @Purpose VARCHAR(11) = (SELECT Purpose FROM Journeys WHERE Id = @JourneyId AND Purpose = @NewPurpose)

	IF(@Purpose IS NOT NULL)
	BEGIN
	RAISERROR('You cannot change the purpose!', 16, 1) RETURN
	END

	UPDATE Journeys
	SET Purpose = @NewPurpose
	WHERE Id = @JourneyId

EXEC usp_ChangeJourneyPurpose 4, 'Technical'
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'
