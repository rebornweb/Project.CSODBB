USE [SAS2IDM_SAS2IDM_LIVE]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

/****** Object:  Table [dbo].[SAS2IDMSchoolEx]    Script Date: 23/09/2022 4:37:45 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAS2IDMSchoolEx]') AND type in (N'U'))
DROP TABLE [dbo].[SAS2IDMSchoolEx]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAS2IDMSchoolEx]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAS2IDMSchoolEx](
	[SchoolID] [varchar](20) NOT NULL,
	[IsPromoted] [bit] NOT NULL,
 CONSTRAINT [PK_SAS2IDMSchoolEx] PRIMARY KEY CLUSTERED 
(
	[SchoolID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'SAS2IDMSchoolEx', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL SAS2IDM School Table Extensions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAS2IDMSchoolEx'
GO

-- Set permissions

--use [SAS2IDM_SAS2IDM_LIVE]
GO
GRANT SELECT ON [dbo].[SAS2IDMSchoolEx] TO [SAS2IDM_Write]
GO
GRANT UPDATE ON [dbo].[SAS2IDMSchoolEx] TO [SAS2IDM_Write]
GO
GRANT VIEW DEFINITION ON [dbo].[SAS2IDMSchoolEx] TO [SAS2IDM_Write]
GO

-- Load with data from 

INSERT INTO dbo.SAS2IDMSchoolEx
SELECT [SchoolID],0
FROM dbo.SAS2IDMSchool
WHERE Archived = 'N'
GO

/****** Object:  View [dbo].[AllSAS2IDMStudents]    Script Date: 23/09/2022 5:22:09 PM ******/

ALTER VIEW [dbo].[AllSAS2IDMStudents]
AS
SELECT     TOP (100) PERCENT dbo.SAS2IDMStudent.SchoolID, dbo.SAS2IDMStudent.StudentID, dbo.SAS2IDMStudent.Code, RTRIM(dbo.SAS2IDMStudent.FirstName) AS [FirstName], 
                      dbo.SAS2IDMStudent.MiddleName, RTRIM(dbo.SAS2IDMStudent.LastName) AS [LastName], RTRIM(dbo.SAS2IDMStudent.PreferredName) AS [PreferredName], dbo.SAS2IDMStudent.NName, 
                      dbo.SAS2IDMStudent.FormerName, dbo.SAS2IDMStudent.Sex, dbo.SAS2IDMStudent.DOB, dbo.SAS2IDMStudent.Year, dbo.SAS2IDMStudent.Class, 
                      dbo.SAS2IDMStudent.HomeGroup, dbo.SAS2IDMStudent.House, dbo.SAS2IDMStudent.AddressID, dbo.SAS2IDMStudent.Address1, dbo.SAS2IDMStudent.Address2, 
                      dbo.SAS2IDMStudent.Address3, dbo.SAS2IDMStudent.PostCode, dbo.SAS2IDMStudent.Country, dbo.SAS2IDMStudent.Email, dbo.SAS2IDMStudent.PhoneFamily, 
                      dbo.SAS2IDMStudent.PhoneHome, dbo.SAS2IDMStudent.PhoneMobile, dbo.SAS2IDMStudent.StartYear, dbo.SAS2IDMStudent.StartDate, 
                      dbo.SAS2IDMStudent.Deceased, dbo.SAS2IDMStudent.StudentType, dbo.SAS2IDMStudent.DateLeft, dbo.SAS2IDMStudent.ReasonLeft, 
                      dbo.SAS2IDMStudent.CandidateNumber, dbo.SAS2IDMStudent.AlumniType, 
					  dbo.SAS2IDMStudent.PreEnrolment, dbo.SAS2IDMStudent.Archive, 
                      dbo.SAS2IDMStudent.UniversalIdentificationNumber, dbo.SAS2IDMSchool.Email AS Mailsuffix, dbo.SAS2IDMSchool.SchoolID AS PhysicaldeliveryOfficeName,
                      dbo.SAS2IDMStudentEx.CeIder
FROM         dbo.SAS2IDMStudent INNER JOIN
                      dbo.SAS2IDMSchool ON dbo.SAS2IDMStudent.SchoolID = dbo.SAS2IDMSchool.Code LEFT JOIN
                      dbo.SAS2IDMStudentEx ON dbo.SAS2IDMStudentEx.SchoolID = dbo.SAS2IDMStudent.SchoolID AND dbo.SAS2IDMStudentEx.StudentID = dbo.SAS2IDMStudent.StudentID INNER JOIN
					  dbo.SAS2IDMSchoolEx ON dbo.SAS2IDMSchoolEx.SchoolID = dbo.SAS2IDMSchool.SchoolID and dbo.SAS2IDMSchoolEx.IsPromoted = 0
WHERE     (dbo.SAS2IDMStudent.AlumniType = 's') AND (dbo.SAS2IDMStudent.PreEnrolment = 'n' OR
                      dbo.SAS2IDMStudent.PreEnrolment = '0') AND (dbo.SAS2IDMStudent.UniversalIdentificationNumber LIKE '2%') AND (dbo.SAS2IDMStudent.Archive = 'n') AND 
                      (dbo.SAS2IDMSchool.Archived = 'n')
ORDER BY dbo.SAS2IDMStudent.UniversalIdentificationNumber

GO

-- Check total - should be approx 16885 when all schools are yet to be migrated
Select count(*) from [dbo].[AllSAS2IDMStudents]
WHERE AlumniType = 'S'
GO


GO

