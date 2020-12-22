USE GeographyBuilt

--Problem 12

SELECT CountryName, IsoCode FROM Countries
WHERE CountryName LIKE '%A%A%A%'
ORDER BY IsoCode ASC

--Problem 13

SELECT PeakName, RiverName, CONCAT(LOWER(PeakName), '', SUBSTRING(LOWER(RiverName), 2, LEN(RiverName)))
AS Mix FROM Peaks, Rivers
WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER BY mix;