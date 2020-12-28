CREATE TABLE Users (
  Id INT PRIMARY KEY IDENTITY,
  Username VARCHAR(30) NOT NULL,
  [Password] VARCHAR(30) NOT NULL,
  Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories (
  Id INT PRIMARY KEY IDENTITY,
  [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors (
  RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
  ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
  CONSTRAINT PK_RepositoryContributorId PRIMARY KEY(RepositoryId, ContributorId),
)

CREATE TABLE Issues (
  Id INT PRIMARY KEY IDENTITY,
  Title VARCHAR(255) NOT NULL,
  IssueStatus VARCHAR(6) NOT NULL,
  RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
  AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits (
  Id INT PRIMARY KEY IDENTITY,
  [Message] VARCHAR(255) NOT NULL,
  IssueId INT FOREIGN KEY REFERENCES Issues(Id),
  RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
  ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
) 

CREATE TABLE Files (
  Id INT PRIMARY KEY IDENTITY,
  [Name] VARCHAR(100) NOT NULL,
  Size DECIMAL(15, 2) NOT NULL,
  ParentId INT FOREIGN KEY REFERENCES Files(Id),
  CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
)

INSERT INTO Files([Name], Size, ParentId, CommitId) VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId) VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)

UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

SELECT RepositoryId, ContributorId, Name FROM RepositoriesContributors AS rc
JOIN Repositories AS r ON rc.RepositoryId = r.Id

DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3

SELECT Id, [Message], RepositoryId, ContributorId FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

SELECT Id,[Name], Size FROM Files
WHERE Size > 1000 AND [Name] LIKE '%html'
ORDER BY Size DESC, Id, [Name]

SELECT f.Id, [Name], CONCAT(Size, 'KB') AS Size FROM Files AS f
WHERE NOT EXISTS(SELECT 1 FROM Files AS f1 WHERE f1.parentid = f.id)

SELECT TOP(5) r.Id, r.[Name], COUNT(c.RepositoryId) AS [Commits] FROM Repositories AS r
JOIN Commits AS c
ON c.RepositoryId = r.Id
LEFT JOIN RepositoriesContributors AS rc
ON rc.RepositoryId = r.Id
GROUP BY r.Id, r.[Name]
ORDER BY [Commits] DESC, r.Id, r.[Name]

SELECT Username, AVG(Size) AS Size FROM Users AS u
JOIN Commits AS c ON u.Id = c.ContributorId
JOIN Files AS f ON f.CommitId = c.Id
GROUP BY Username
ORDER BY Size DESC, Username

GO
CREATE FUNCTION dbo.udf_UserTotalCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN	
	DECLARE @counts INT
	SELECT @counts = COUNT(ContributorId) FROM Commits AS c
	JOIN Users AS u ON c.ContributorId = u.Id
	WHERE u.Username = @username
	RETURN @counts
END

SELECT dbo.udf_UserTotalCommits('UnderSinduxrein')

CREATE PROCEDURE usp_FindByExtension(@extension VARCHAR(50))
AS
BEGIN
	SELECT [f].[Id],
	       [f].[Name],
		   CONCAT([f].[Size], 'KB') AS [Size]
	  FROM [dbo].[Files] AS f
	 WHERE CHARINDEX(@extension, [f].[Name]) > 0
  ORDER BY [f].[Id], [f].[Name], [f].[Size] DESC
END

EXEC usp_FindByExtension 'txt'