--Problem 1

CREATE DATABASE Minions

USE Minions

--Problem 2

CREATE TABLE Minions (
  Id INT PRIMARY KEY,
  [Name] NVARCHAR(50) NOT NULL,
  Age SMALLINT NOT NULL
)

CREATE TABLE Towns (
  Id INT PRIMARY KEY,
  [Name] NVARCHAR(30) NOT NULL
)

--Problem 3

ALTER TABLE Minions
ADD TownId INT

ALTER TABLE Minions
ADD CONSTRAINT FK_TownId
FOREIGN KEY(TownId) REFERENCES Towns(Id)

ALTER TABLE Minions ALTER COLUMN Age INT Null

--Problem 4

INSERT INTO Towns (Id, Name) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions (Id, Name, Age, TownId) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

--Problem 5

TRUNCATE TABLE Minions

--Problem 6

DROP TABLE Towns

--Problem 7

DROP TABLE Minions

--Problem 8

CREATE TABLE People (
  Id INT UNIQUE IDENTITY,
  [Name] NVARCHAR(200) NOT NULL,
  Picture VARBINARY(MAX),
  CHECK(DATALENGTH(Picture) <= 2048000),
  Height DECIMAL(15, 2),
  [Weight] DECIMAL(15, 2),
  Gender CHAR(1) NOT NULL,
  Birthdate DATETIME NOT NULL,
  Biography NVARCHAR(MAX)
)

ALTER TABLE People
ADD PRIMARY KEY(Id)

INSERT INTO People (Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES
('Ivan', NULL, 1.87, 110.21, 'm', CONVERT(datetime, '02-01-1999', 103), 'bio'),
('Gosho', NULL, 1.78, 85.12, 'm', CONVERT(datetime, '03-04-2001', 103), 'biography'),
('Mimi', NULL, 1.75, 60.34, 'f', CONVERT(datetime, '03-04-2004', 103), 'biogr'),
('Pesho', NULL, 1.79, 85.47, 'm', CONVERT(datetime, '03-04-2011', 103), 'bio'),
('Nadq', NULL, 1.60, 55.78, 'f', CONVERT(datetime, '03-04-2005', 103), NULL)

--Problem 8

CREATE TABLE Users (
  Id BIGINT UNIQUE IDENTITY,
  Username VARCHAR(30) UNIQUE NOT NULL,
  [Password] VARCHAR(26) NOT NULL,
  ProfilePicture VARBINARY(MAX)
  CHECK (DATALENGTH(ProfilePicture) <= 921600),
  LastLoginTime DATETIME,
  IsDeleted BIT
)

ALTER TABLE Users
ADD PRIMARY KEY(Id)

INSERT INTO Users (Username, Password, ProfilePicture, LastLoginTime, IsDeleted) VALUES
('Ivan', '123', NULL, CONVERT(datetime, '01-02-2004', 103), 0),
('Gosho', '456', NULL, CONVERT(datetime, '04-05-2001', 103), 1),
('Mimi', '789', NULL, CONVERT(datetime, '05-02-2002', 103), 0),
('Bobo', '123', NULL, CONVERT(datetime, '08-02-2004', 103), 0),
('Nadq', '456', NULL, CONVERT(datetime, '04-02-2008', 103), 1)

--Problem 9

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07CE3E32CF

ALTER TABLE Users
ADD CONSTRAINT PK_IdAndUsername
PRIMARY KEY(Id, Username)

--Problem 10

ALTER TABLE Users
ADD CHECK (Password >= 5)

--Problem 11

ALTER TABLE Users
ADD CONSTRAINT DF_LastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

--Problem 12

ALTER TABLE Users
DROP CONSTRAINT PK_IdAndUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Id
PRIMARY KEY(Id)

ALTER TABLE Users
ADD CONSTRAINT Uq_Username
CHECK (DATALENGTH(Username) >= 3)

--Problem 13

CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors (
  Id INT PRIMARY KEY NOT NULL,
  DirectorName NVARCHAR(50) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Genres (
  Id INT PRIMARY KEY NOT NULL,
  GenreName NVARCHAR(30) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Categories (
  Id INT PRIMARY KEY NOT NULL,
  CategoryName NVARCHAR(30) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Movies (
  Id INT PRIMARY KEY NOT NULL,
  Title NVARCHAR(30) NOT NULL,
  DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
  CopyRightYear DATETIME,
  [Length] INT NOT NULL,
  GenreId INT FOREIGN KEY REFERENCES Genres(Id),
  CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
  Rating DECIMAL(2, 1),
  Notes NVARCHAR(MAX)
)

INSERT INTO Directors (Id, DirectorName, Notes) VALUES
(1, 'Ivan', NULL),
(2, 'Gosho', 'fhdfhsk'),
(3, 'Mimi', NULL),
(4, 'Nadq', NULL),
(5, 'Bobo', 'fuyugf')

INSERT INTO Genres (Id, GenreName, Notes) VALUES
(1, 'Action', NULL),
(2, 'Comedy', 'fnksdhf'),
(3, 'Horror', NULL),
(4, 'Adventure', 'fsodhfiu'),
(5, 'Drama', NULL)

INSERT INTO Categories (Id, CategoryName, Notes) VALUES
(1, 'RIR', NULL),
(2, 'DFHJKS', 'KFJK'),
(3, 'DAHDJ', NULL),
(4, 'REOH', NULL),
(5, 'DJLASK', 'AKKLA')

INSERT INTO Movies (Id, Title, CopyRightYear, Length, Rating, Notes) VALUES
(1, 'LOTR', NULL, 120, 9.9, NULL),
(2, 'IT', NULL, 90, 7.7, NULL),
(3, 'KDFS', NULL, 60, 6.5, NULL),
(4, 'JKDFH', NULL, 90, 5.5, NULL),
(5, 'FDJS', NULL, 120, 4.5, NULL)

--Problem 14

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories (
  Id INT PRIMARY KEY NOT NULL,
  CategoryName NVARCHAR(30) NOT NULL,
  DailyRate DECIMAL(2, 1) NOT NULL,
  WeeklyRate DECIMAL(2, 1) NOT NULL,
  MonthlyRate DECIMAL(2, 1) NOT NULL,
  WeekendRate DECIMAL(2, 1) NOT NULL
)

CREATE TABLE Cars (
  Id INT PRIMARY KEY NOT NULL,
  PlateNumber NVARCHAR(10) NOT NULL,
  Manufacturer NVARCHAR(10) NOT NULL,
  Model NVARCHAR(20) NOT NULL,
  CarYear INT NOT NULL,
  CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
  Doors INT NOT NULL,
  Picture VARBINARY(MAX),
  Condition NVARCHAR(MAX),
  Available BIT NOT NULL
)

CREATE TABLE Employees (
  Id INT PRIMARY KEY NOT NULL,
  FirstName NVARCHAR(20) NOT NULL,
  LastName NVARCHAR(20) NOT NULL,
  Title NVARCHAR(20) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Customers (
  Id INT PRIMARY KEY NOT NULL,
  DriverLicenseNumber INT NOT NULL,
  FullName NVARCHAR(30) NOT NULL,
  [Address] NVARCHAR(100),
  City NVARCHAR(20) NOT NULL,
  ZipCode NVARCHAR(10) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE RentalOrders (
  Id INT PRIMARY KEY NOT NULL,
  EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
  CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
  CarId INT FOREIGN KEY REFERENCES Cars(Id),
  TankLevel DECIMAL(4, 1) NOT NULL,
  KilometrageStart INT NOT NULL,
  KilometrageEnd INT NOT NULL,
  TotalKilometrage INT NOT NULL,
  StartDate DATETIME,
  ENDDATE DATETIME,
  TotalDays INT NOT NULL,
  RateApplied DECIMAL(2, 1),
  TaxRate DECIMAL(2, 1),
  OrderStatus BIT NOT NULL,
  Notes NVARCHAR(MAX)
)

INSERT INTO Categories (Id, CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
(1, 'truck', 3.2, 4.3, 4.5, 3.4),
(2, 'CAR', 5.4, 6.5, 4.2, 4.6),
(3, 'JEEP', 4.8, 7.6, 5.3, 4.8)

INSERT INTO Cars (Id, PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available) VALUES
(1, '1345', 'Mercedes', 'McLaren', 2005, 2, 2, NULL, NULL, 1),
(2, '1234', 'SCANIA', 'DASD', 2001, 1, 2, NULL, NULL, 0),
(3, '4987', 'BMW', 'X6', 2018, 3, 4, NULL, NULL, 1)

INSERT INTO Employees (Id, FirstName, LastName, Title, Notes) VALUES
(1, 'Gosho', 'Ivanov', 'IT', NULL),
(2, 'Ivan', 'Georgiev', 'CEO','FHDJ'),
(3, 'Mimi', 'Ivanova', 'CTO', NULL)

INSERT INTO Customers (Id, DriverLicenseNumber, FullName, Address, City, ZipCode, Notes) VALUES
(1, 21315, 'KJFHLSDFLSK', 'FKSDFKLSJDHL', 'Sofia', 1546, NULL),
(2, 46478, 'FKSDHFJSKJDHFK', 'HDSHFKJS', 'Varna', 46489, NULL),
(3, 79745, 'hdfshfkdhfk', 'fjksdjfkj', 'Plovdiv', 78979, NULL)

INSERT INTO RentalOrders (Id, EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd,
 TotalKilometrage, StartDate, ENDDATE, TotalDays, RateApplied, TaxRate, OrderStatus, Notes) VALUES
(1, 1, 1, 1, 20, 456, 564, 564, NULL, NULL, 10, 3, 2.3, 0, NULL),
(2, 2, 2, 2, 30, 123, 321, 321, NULL, NULL, 5, 3.6, 2.1, 1, NULL),
(3, 3, 3, 3, 50, 789, 978, 978, NULL, NULL, 4, 4.5, 6.1, 0, NULL)

--Problem 15

CREATE DATABASE Hotel

USE Hotel

CREATE TABLE Employees (
  Id INT PRIMARY KEY NOT NULL,
  FirstName NVARCHAR(30) NOT NULL,
  LastName NVARCHAR(30) NOT NULL,
  Title NVARCHAR(20) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Customers (
  AccountNumber INT PRIMARY KEY NOT NULL,
  FirstName NVARCHAR(30) NOT NULL,
  LastName NVARCHAR(30) NOT NULL,
  PhoneNumber NVARCHAR(20) NOT NULL,
  EmergencyName NVARCHAR(20),
  EmergencyNumber NVARCHAR(20),
  Notes NVARCHAR(MAX)
)

CREATE TABLE RoomStatus (
  RoomStatus CHAR PRIMARY KEY NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE RoomTypes (
  RoomType CHAR PRIMARY KEY NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE BedTypes (
  BedType CHAR PRIMARY KEY NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Rooms (
  RoomNumber INT PRIMARY KEY NOT NULL,
  RoomType CHAR FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
  BedType CHAR FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
  Rate DECIMAL(2, 1) NOT NULL,
  RoomStatus CHAR FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Payments (
  Id INT PRIMARY KEY NOT NULL,
  EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
  PaymentDate DATETIME,
  AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
  FirstDateOccupied DATETIME,
  LastDateOccupied DATETIME,
  TotalDays INT NOT NULL,
  AmountCharged DECIMAL(7, 2) NOT NULL,
  TaxRate DECIMAL(3, 1) NOT NULL,
  TaxAmount DECIMAL(3, 1) NOT NULL,
  PaymentTotal DECIMAL(8, 2) NOT NULL,
  Notes NVARCHAR(MAX)
)

CREATE TABLE Occupancies (
  Id INT PRIMARY KEY NOT NULL,
  EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
  DateOccupied DATETIME,
  AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
  RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL,
  RateApplied DECIMAL(2, 1),
  PhoneCharge NVARCHAR(20),
  Notes NVARCHAR(MAX)
)

INSERT INTO Employees (Id, FirstName, LastName, Title, Notes) VALUES
(1, 'Gosho', 'Ivanov', 'HR', NULL),
(2, 'Ivan', 'Ivanov', 'CEO', NULL),
(3, 'Mimi', 'Ivanova', 'IT', NULL)

INSERT INTO Customers (AccountNumber, FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes) VALUES
(1, 'DFS', 'DFGFD', '0899856445', 'Police', '22221', NULL),
(2, 'FDKDHF', 'FKJSDF', '0899465466', 'FireStation', '1316', NULL),
(3, 'DJFHSK', 'FGFOU', '0894611332', 'DFSDFSD', '79874', NULL)

INSERT INTO RoomStatus (RoomStatus, Notes) VALUES
('O', NULL),
('N', NULL),
('R', NULL)

INSERT INTO RoomTypes (RoomType, Notes) VALUES
('S', NULL),
('D', NULL),
('B', NULL)

INSERT INTO BedTypes (BedType, Notes) VALUES
('S', NULL),
('D', NULL),
('B', NULL)

INSERT INTO Rooms (RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes) VALUES
(12, 'S', 'S', 5, 'O', NULL),
(21, 'D', 'D', 4.2, 'N', NULL),
(5, 'B', 'B', 6.4, 'R', NULL)

INSERT INTO Payments (Id, EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, 
TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal, Notes) VALUES
(1, 1, NULL, 1, NULL, NULL, 3, 200, 20, 40, 240, NULL),
(2, 2, NULL, 2, NULL, NULL, 2, 120, 20, 24, 144, NULL),
(3, 3, NULL, 3, NULL, NULL, 4, 240, 20, 48, 288, NULL)

INSERT INTO Occupancies (Id, EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge, Notes) VALUES
(1, 1, NULL, 1, 12, 3, '084132165', NULL),
(2, 2, NULL, 2, 21, 4.5, '085465431', NULL),
(3, 3, NULL, 3, 5, 5.6, '089654613', NULL)

--Problem 16

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Addresses (
  Id INT PRIMARY KEY IDENTITY,
  AddressText NVARCHAR(50) NOT NULL,
  TownId INT FOREIGN KEY REFERENCES Towns(Id),
)

CREATE TABLE Departments (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Employees (
  Id INT PRIMARY KEY IDENTITY,
  FirstName NVARCHAR(20) NOT NULL,
  MiddleName NVARCHAR(20),
  LastName NVARCHAR(20) NOT NULL,
  JobTitle NVARCHAR(20) NOT NULL,
  DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
  HireDate DATETIME,
  Salary DECIMAL(7, 2) NOT NULL,
  AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

DROP DATABASE SoftUni

--Problem 17

INSERT INTO Towns (Name) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments (Name) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, CONVERT(datetime, '01/02/2013', 103), 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, CONVERT(datetime, '02/03/2004', 103), 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, CONVERT(datetime, '28/08/2016', 103), 525.25),
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2,  CONVERT(datetime, '09/12/2007', 103), 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, CONVERT(datetime, '28/08/2019', 103), 599.88)

--Problem 18

SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

--Problem 19

SELECT * FROM Towns
ORDER BY Name ASC

SELECT * FROM Departments
ORDER BY Name ASC

SELECT * FROM Employees
ORDER BY Salary DESC

--Problem 20

SELECT Name
FROM Towns
ORDER BY Name ASC

SELECT NAME
FROM Departments
ORDER BY NAME ASC

SELECT FirstName, LastName, JobTitle, Salary
FROM Employees
ORDER BY Salary DESC

--Problem 21

UPDATE Employees
SET Salary += (Salary * 0.1)

SELECT Salary FROM Employees

--Problem 22

USE Hotel

UPDATE Payments
SET TaxRate -= (TaxRate * 0.03)

SELECT TaxRate FROM Payments

--Problem 23

TRUNCATE TABLE Occupancies
