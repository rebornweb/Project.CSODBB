USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  View [dbo].[AllSAS2IDMStudents]    Script Date: 04/10/2017 15:29:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[AllSAS2IDMStudents]
AS
SELECT     TOP (100) PERCENT dbo.SAS2IDMStudent.SchoolID, dbo.SAS2IDMStudent.StudentID, dbo.SAS2IDMStudent.Code, RTRIM(dbo.SAS2IDMStudent.FirstName) AS [FirstName], 
                      dbo.SAS2IDMStudent.MiddleName, RTRIM(dbo.SAS2IDMStudent.LastName) AS [LastName], RTRIM(dbo.SAS2IDMStudent.PreferredName) AS [PreferredName], dbo.SAS2IDMStudent.NName, 
                      dbo.SAS2IDMStudent.FormerName, dbo.SAS2IDMStudent.Sex, dbo.SAS2IDMStudent.DOB, dbo.SAS2IDMStudent.Year, dbo.SAS2IDMStudent.Class, 
                      dbo.SAS2IDMStudent.HomeGroup, dbo.SAS2IDMStudent.House, dbo.SAS2IDMStudent.AddressID, dbo.SAS2IDMStudent.Address1, dbo.SAS2IDMStudent.Address2, 
                      dbo.SAS2IDMStudent.Address3, dbo.SAS2IDMStudent.PostCode, dbo.SAS2IDMStudent.Country, dbo.SAS2IDMStudent.Email, dbo.SAS2IDMStudent.PhoneFamily, 
                      dbo.SAS2IDMStudent.PhoneHome, dbo.SAS2IDMStudent.PhoneMobile, dbo.SAS2IDMStudent.StartYear, dbo.SAS2IDMStudent.StartDate, 
                      dbo.SAS2IDMStudent.Deceased, dbo.SAS2IDMStudent.StudentType, dbo.SAS2IDMStudent.DateLeft, dbo.SAS2IDMStudent.ReasonLeft, 
                      dbo.SAS2IDMStudent.CandidateNumber, dbo.SAS2IDMStudent.AlumniType, dbo.SAS2IDMStudent.PreEnrolment, dbo.SAS2IDMStudent.Archive, 
                      dbo.SAS2IDMStudent.UniversalIdentificationNumber, dbo.SAS2IDMSchool.Email AS Mailsuffix, dbo.SAS2IDMSchool.SchoolID AS PhysicaldeliveryOfficeName,
                      dbo.SAS2IDMStudentEx.CeIder
FROM         dbo.SAS2IDMStudent INNER JOIN
                      dbo.SAS2IDMSchool ON dbo.SAS2IDMStudent.SchoolID = dbo.SAS2IDMSchool.Code LEFT JOIN
                      dbo.SAS2IDMStudentEx ON dbo.SAS2IDMStudentEx.SchoolID = dbo.SAS2IDMStudent.SchoolID AND dbo.SAS2IDMStudentEx.StudentID = dbo.SAS2IDMStudent.StudentID
WHERE     (dbo.SAS2IDMStudent.AlumniType = 's') AND (dbo.SAS2IDMStudent.PreEnrolment = 'n' OR
                      dbo.SAS2IDMStudent.PreEnrolment = '0') AND (dbo.SAS2IDMStudent.UniversalIdentificationNumber LIKE '2%') AND (dbo.SAS2IDMStudent.Archive = 'n') AND 
                      (dbo.SAS2IDMSchool.Archived = 'n')
--and dbo.SAS2IDMStudent.SchoolID <> 1460 -- temporary test
--and dbo.SAS2IDMStudent.SchoolID in (00001,01617)
--and dbo.SAS2IDMStudent.SchoolID in (00001,01617,01460)
ORDER BY dbo.SAS2IDMStudent.UniversalIdentificationNumber


GO

GRANT SELECT ON [dbo].[AllSAS2IDMStudents] TO [SAS2IDM_View] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[AllSAS2IDMStudents] TO [SAS2IDM_View] AS [dbo]
GO


