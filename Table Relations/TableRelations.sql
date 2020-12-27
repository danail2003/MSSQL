--Problem 1

CREATE DATABASE TableRelations

USE TableRelations

CREATE TABLE Persons (
  PersonID INT NOT NULL,
  FirstName VARCHAR(30),
  Salary DECIMAL(8, 2),
  PassportID INT
)

CREATE TABLE Passports (
  PassportID INT NOT NULL,
  PassportNumber VARCHAR(30)
)

INSERT INTO Persons (PersonID, FirstName, Salary, PassportID) VALUES
(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3, 'Yana', 60200.00, 101)

INSERT INTO Passports (PassportID, PassportNumber) VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')

ALTER TABLE Persons 
ADD CONSTRAINT PK_PersonID PRIMARY KEY(PersonID)

ALTER TABLE Passports
ADD CONSTRAINT PK_PassportID PRIMARY KEY(PassportID)

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passport FOREIGN KEY(PassportID) REFERENCES Passports(PassportID)

--Problem 2

CREATE TABLE Models (
  ModelID INT NOT NULL,
  [Name] NVARCHAR(20),
  ManufacturerID INT
)

CREATE TABLE Manufacturers (
  ManufacturerID INT NOT NULL,
  [Name] NVARCHAR(20),
  EstablishedOn DATETIME
)

INSERT INTO Models (ModelID, [Name], ManufacturerID) VALUES
(101, 'X1',	1),
(102, 'i6',	1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)

INSERT INTO Manufacturers (ManufacturerID, [Name], EstablishedOn) VALUES
(1, 'BMW', '07/03/1916'),
(2,	'Tesla', '01/01/2003'),
(3,	'Lada',	'01/05/1966')

ALTER TABLE Models
ADD CONSTRAINT PK_ModelId PRIMARY KEY(ModelID)

ALTER TABLE Manufacturers
ADD CONSTRAINT PK_ManufacturerId PRIMARY KEY(ManufacturerID)

ALTER TABLE Models
ADD CONSTRAINT FK_Models_Manufacturers FOREIGN KEY(ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

--Problem 3

CREATE TABLE Students (
  StudentID INT PRIMARY KEY,
  [Name] NVARCHAR(50)
)

CREATE TABLE Exams (
  ExamID INT PRIMARY KEY,
  [Name] NVARCHAR(50)
)

CREATE TABLE StudentsExams (
  StudentID INT,
  ExamID INT
  CONSTRAINT PK_StudentID_ExamID PRIMARY KEY (StudentID, ExamID)
)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Students FOREIGN KEY(StudentID) REFERENCES Students(StudentID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Exams FOREIGN KEY(ExamID) REFERENCES Exams(ExamID)

INSERT INTO Students VALUES
(1, 'Mila'),
(2, 'Toni'),
(3, 'Ron')

INSERT INTO Exams VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')

INSERT INTO StudentsExams VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)

--Problem 4

CREATE TABLE Teachers (
  TeacherID INT PRIMARY KEY NOT NULL,
  [Name] NVARCHAR(50),
  ManagerID INT,
  CONSTRAINT FK_ManagerID FOREIGN KEY(ManagerID) REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)

--Problem 5

CREATE TABLE Cities (
  CityID INT PRIMARY KEY,
  [Name] VARCHAR(50)
)

CREATE TABLE Customers (
  CustomerID INT PRIMARY KEY,
  [Name] VARCHAR(50),
  Birthday DATE,
  CityID INT,
  CONSTRAINT FK_CityID FOREIGN KEY(CityID) REFERENCES Cities(CityID)
)

CREATE TABLE Orders (
  OrderID INT PRIMARY KEY,
  CustomerID INT,
  CONSTRAINT FK_CustomerID FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes (
  ItemTypeID INT PRIMARY KEY,
  [Name] VARCHAR(50)
)

CREATE TABLE Items (
  ItemID INT PRIMARY KEY,
  [Name] VARCHAR(50),
  ItemTypeID INT
  CONSTRAINT FK_ItemTypeID FOREIGN KEY(ItemTypeID) REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems (
  OrderID INT,
  ItemID INT
  CONSTRAINT PK_Order_Item PRIMARY KEY(OrderID, ItemID),
  CONSTRAINT FK_ItemID FOREIGN KEY(ItemID) REFERENCES Items(ItemID),
  CONSTRAINT FK_OrderID FOREIGN KEY(OrderID) REFERENCES Orders(OrderID)
)

--Problem 6

CREATE TABLE Subjects (
  SubjectID INT PRIMARY KEY,
  SubjectName VARCHAR(50)
)

CREATE TABLE Majors (
  MajorID INT PRIMARY KEY,
  [Name] VARCHAR(50)
)

CREATE TABLE Students (
  StudentID INT PRIMARY KEY,
  StudentNumber VARCHAR(50),
  StudentName VARCHAR(50),
  MajorID INT,
  CONSTRAINT FK_MajorID FOREIGN KEY(MajorID) REFERENCES Majors(MajorID)
)

CREATE TABLE Payments (
  PaymentID INT PRIMARY KEY,
  PaymentDate DATE,
  PaymentAmount DECIMAL(15, 2),
  StudentID INT,
  CONSTRAINT FK_StudentID FOREIGN KEY(StudentID) REFERENCES Students(StudentID)
)

CREATE TABLE Agenda (
  StudentID INT,
  SubjectID INT,
  CONSTRAINT PK_StudentSubject_ID PRIMARY KEY(StudentID, SubjectID),
  CONSTRAINT FK_Student_AgendaID FOREIGN KEY(StudentID) REFERENCES Students(StudentID),
  CONSTRAINT FK_SubjectID FOREIGN KEY(SubjectID) REFERENCES Subjects(SubjectID)
)

--Problem 7

USE GeographyBuilt

SELECT m.MountainRange, p.PeakName, p.Elevation FROM Mountains AS m
JOIN Peaks AS p ON p.MountainId = m.Id
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC