CREATE TABLE Students (
  Id INT PRIMARY KEY IDENTITY,
  FirstName NVARCHAR(30) NOT NULL,
  MiddleName NVARCHAR(25),
  LastName NVARCHAR(30) NOT NULL,
  Age SMALLINT CHECK(Age > 0),
  [Address] NVARCHAR(50),
  Phone NVARCHAR(10)
)

CREATE TABLE Subjects (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(20) NOT NULL,
  Lessons INT NOT NULL
)

CREATE TABLE StudentsSubjects (
  Id INT PRIMARY KEY IDENTITY,
  StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
  SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
  Grade DECIMAL(15, 2) CHECK(Grade >= 2 AND GRADE <= 6) NOT NULL
)

CREATE TABLE Exams (
  Id INT PRIMARY KEY IDENTITY,
  [Date] DATETIME,
  SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams (
  StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
  ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
  Grade DECIMAL(15, 2) CHECK(Grade >= 2 AND Grade <= 6) NOT NULL,
  CONSTRAINT PK_StudentExamId PRIMARY KEY(StudentId, ExamId)
)

CREATE TABLE Teachers (
  Id INT PRIMARY KEY IDENTITY,
  FirstName NVARCHAR(20) NOT NULL,
  LastName NVARCHAR(20) NOT NULL,
  [Address] NVARCHAR(20) NOT NULL,
  Phone VARCHAR(10),
  SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers (
  StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
  TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
  CONSTRAINT PK_StudentTeacherId PRIMARY KEY(StudentId, TeacherId)
)

INSERT INTO Teachers(FirstName, LastName, [Address], Phone, SubjectId) VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146',	6),
('Gerrard',	'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile',	'Lambdin', '81 Dahle Plaza', '4373065154', 5),
('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects([Name], Lessons) VALUES
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)

UPDATE StudentsSubjects
SET Grade = 6.00
WHERE SubjectId IN(1, 2) AND Grade >= 5.50

DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')

DELETE FROM Teachers
WHERE Phone LIKE '%72%'

SELECT FirstName, LastName, Age FROM Students
WHERE Age >= 12
ORDER BY FirstName, LastName

SELECT CONCAT(FirstName + ' ' + ISNULL(MiddleName, '') + ' ', LastName) AS [Full Name], [Address] FROM Students
WHERE [Address] LIKE '%road%'
ORDER BY FirstName, LastName, [Address]

SELECT FirstName, [Address], Phone FROM Students
WHERE MiddleName IS NOT NULL AND Phone LIKE '42%'
ORDER BY FirstName

SELECT s.FirstName, s.LastName, COUNT(st.TeacherId) AS TeachersCount FROM Students AS s
JOIN StudentsTeachers AS st ON s.Id = st.StudentId
GROUP BY s.FirstName, s.LastName

SELECT FirstName + ' ' + LastName AS FullName, s.[Name] + '-' + CAST(s.Lessons AS nvarchar(5)) AS Subjects,
COUNT(st.StudentId) AS Students FROM Teachers AS t
JOIN Subjects AS s ON s.Id = t.SubjectId
JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName, s.Name, s.Lessons
ORDER BY COUNT(st.StudentId) DESC, FullName, Subjects

SELECT FirstName + ' ' + LastName AS [Full Name] FROM Students AS s
FULL JOIN StudentsExams AS se ON s.Id = se.StudentId
WHERE se.ExamId IS NULL
ORDER BY [Full Name]

SELECT TOP 10 FirstName, LastName, COUNT(st.StudentId) AS StudentsCount FROM Teachers AS t
JOIN StudentsTeachers AS st ON t.Id = st.TeacherId
GROUP BY FirstName, LastName
ORDER BY StudentsCount DESC, FirstName, LastName

SELECT TOP 10 FirstName, LastName, CAST(AVG(Grade) AS DECIMAL(15, 2)) AS Grade FROM Students AS s
JOIN StudentsExams AS se ON s.Id = se.StudentId
GROUP BY FirstName, LastName
ORDER BY Grade DESC, FirstName, LastName

SELECT k.FirstName, k.LastName, k.Grade
  FROM (
   SELECT FirstName, LastName, Grade, 
          ROW_NUMBER() OVER (PARTITION BY FirstName, LastName ORDER BY Grade DESC) AS RowNumber
     FROM Students AS s
	 JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
 ) AS k
 WHERE k.RowNumber = 2
 ORDER BY FirstName, LastName

SELECT FirstName + IIF(MiddleName IS NULL, '', ' ') + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name] FROM Students AS s
FULL JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
WHERE ss.StudentId IS NULL
ORDER BY [Full Name]

SELECT j.[Teacher Full Name], j.SubjectName ,j.[Student Full Name], FORMAT(j.TopGrade, 'N2') AS Grade
  FROM (
SELECT k.[Teacher Full Name],k.SubjectName, k.[Student Full Name], k.AverageGrade  AS TopGrade,
	   ROW_NUMBER() OVER (PARTITION BY k.[Teacher Full Name] ORDER BY k.AverageGrade DESC) AS RowNumber
  FROM (
  SELECT t.FirstName + ' ' + t.LastName AS [Teacher Full Name],
  	   s.FirstName + ' ' + s.LastName AS [Student Full Name],
  	   AVG(ss.Grade) AS AverageGrade,
  	   su.Name AS SubjectName
    FROM Teachers AS t 
    JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
    JOIN Students AS s ON s.Id = st.StudentId
    JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
    JOIN Subjects AS su ON su.Id = ss.SubjectId AND su.Id = t.SubjectId
GROUP BY t.FirstName, t.LastName, s.FirstName, s.LastName, su.Name
) AS k
) AS j
   WHERE j.RowNumber = 1 
ORDER BY j.SubjectName,j.[Teacher Full Name], TopGrade DESC

SELECT [Name], AVG(ss.Grade) AS AverageGrade FROM Subjects AS s
JOIN StudentsSubjects AS ss ON s.Id = ss.SubjectId
GROUP BY [Name], ss.SubjectId
ORDER BY ss.SubjectId

SELECT  k.[Quarter], k.SubjectName, COUNT(k.StudentId) AS StudentsCount
  FROM (
  SELECT s.[Name] AS SubjectName,
		 se.StudentId,
		 CASE
		 WHEN DATEPART(MONTH, [Date]) BETWEEN 1 AND 3 THEN 'Q1'
		 WHEN DATEPART(MONTH, [Date]) BETWEEN 4 AND 6 THEN 'Q2'
		 WHEN DATEPART(MONTH, [Date]) BETWEEN 7 AND 9 THEN 'Q3'
		 WHEN DATEPART(MONTH, [Date]) BETWEEN 10 AND 12 THEN 'Q4'
		 WHEN Date IS NULL THEN 'TBA'
		 END AS [Quarter]
    FROM Exams AS e
	JOIN Subjects AS s ON s.Id = e.SubjectId 
	JOIN StudentsExams AS se ON se.ExamId = e.Id
	WHERE se.Grade >= 4
) AS k
GROUP BY k.[Quarter], k.SubjectName
ORDER BY k.[Quarter]

CREATE FUNCTION dbo.udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15, 2))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @id INT
	SELECT @id = Id FROM Students WHERE Id = @studentId
	IF(@id IS NULL)
	BEGIN
	RETURN('The student with provided id does not exist in the school!')
	END
	IF(@grade > 6)
	BEGIN
	RETURN('Grade cannot be above 6.00!')
	END
	DECLARE @name NVARCHAR(10) = (SELECT FirstName FROM Students WHERE Id = @studentId)
	DECLARE @biggestGrade DECIMAL(15, 2) = @grade + 0.50
	DECLARE @count INT = (SELECT COUNT(se.Grade) FROM StudentsExams AS se JOIN Students AS s ON se.StudentId = s.Id
	WHERE s.Id = @studentId AND Grade >= @grade AND Grade <= @biggestGrade)
	RETURN('You have to update' + ' ' + CAST(@count AS NVARCHAR(10)) + ' ' + 'grades for the student' + ' ' + @name)
END

CREATE PROC dbo.usp_ExcludeFromSchool(@StudentId INT) AS
DECLARE @id INT = (SELECT Id FROM Students WHERE Id = @StudentId)
IF(@id IS NULL)
BEGIN
RAISERROR('This school has no student with the provided id!', 16, 1)
RETURN
END

DELETE FROM StudentsSubjects
WHERE StudentId = @StudentId

DELETE FROM StudentsExams
WHERE StudentId = @StudentId

DELETE FROM StudentsTeachers
WHERE StudentId = @StudentId

DELETE FROM Students
WHERE Id = @StudentId

CREATE TABLE ExcludedStudents (
  StudentId INT PRIMARY KEY,
  StudentName NVARCHAR(30)
)

CREATE TRIGGER tr_ExcludeStudent ON Students
INSTEAD OF DELETE
AS
INSERT INTO ExcludedStudents(StudentId, StudentName)
SELECT Id, FirstName + ' ' + LastName FROM deleted



