USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  StoredProcedure [dbo].[procSAS2IDM_GetMissingUSIN_AllSchools]    Script Date: 1/03/2022 11:29:25 PM ******/
DROP PROCEDURE [dbo].[procSAS2IDM_GetMissingUSIN_AllSchools]
GO

/****** Object:  StoredProcedure [dbo].[procSAS2IDM_GetMissingUSIN_AllSchools]    Script Date: 1/03/2022 11:29:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Bob Bradley
-- Create date: March 2022
-- Description:	Retrieve all missing USINs across all 44 SAS schools
-- =============================================
CREATE PROCEDURE [dbo].[procSAS2IDM_GetMissingUSIN_AllSchools]
AS
BEGIN

DECLARE @rn INT = 1, @dbname varchar(MAX) = '''';
DECLARE @sql nvarchar(MAX) = '''';
DECLARE @SAS2IDMStudent TABLE (
	[SchoolCode] [varchar](20) NOT NULL,
	[NewUSIN] [varchar](20) NOT NULL,
	[MIM.SchoolID] [varchar](20) NULL,
	[MIM.FormerUSIN] [varchar](20) NULL,
	[MIM.CeIder] [varchar](50) NULL,
	[MIM.DOB] [datetime] NULL,
	[MIM.EmailPrefix] [varchar](50) NULL,
	[SchoolNumber] [varchar](20) NULL,
	[Code] [varchar](20) NOT NULL,
	[CandidateNumber] [varchar](50) NULL,
	[LockerNumber] [varchar](50) NULL,
	[Email] [varchar](100) NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[PreferredName] [varchar](50) NULL,
	[DOB] [datetime] NULL,
	[Year] [varchar](50) NOT NULL,
	[USIN] [varchar](20) NULL,
	[PreviousSchool] [varchar](50) NULL,
	[PreviousLocation] [varchar](50) NULL,
	[UpdatedWhen] [datetime] NULL
)

SET NOCOUNT ON;

WHILE @dbname IS NOT NULL 
BEGIN
    SET @dbname = (SELECT name FROM (SELECT name, ROW_NUMBER() OVER (ORDER BY name) rn 
        FROM sys.databases WHERE name NOT IN('master','tempdb')) t WHERE rn = @rn);

    IF (@dbname <> '''') AND (@dbname IS NOT NULL) AND (@dbname LIKE 'SAS2000_LIVE_S%') -- SMMCW, SOLWY
	BEGIN
		SET @sql = '
		SELECT
			REPLACE('''+@dbname+''',''SAS2000_LIVE_'','''') AS [School Code], 
			CONCAT(''281'',(Select REPLACE(Value,''281_'','''') AS [DET] from ['+@dbname+'].[dbo].[Control] where Code = ''NSWDETSchoolCode''),Student.Code) As [NewUSIN], 
			AllMIMStudents.SchoolID AS [MIM.SchoolID], 
			AllMIMStudents.USIN AS [MIM.FormerUSIN?], 
			AllMIMStudents.csoCeIder AS [MIM.CeIder], 
			FORMAT(CAST(AllMIMStudents.DOB AS Date),''d'') AS [MIM.DOB], 
			[AllMIMStudents].[accountName] AS [MIM.EmailPrefix], 
			School.SchoolNumber AS [School Number], 
			Student.Code, 
			Student.CandidateNumber AS [Candidate Number], 
			Student.LockerNumber AS [Locker Number], 
			Student.Email, 
			Student.FirstName, 
			Student.LastName, 
			Student.PreferredName AS [Preferred Name], 
			Student.DOB, 
			Student.Year, 
			Student.UniversalIdentificationNumber As [USIN], 
			School.Name As [Previous School], 
			School.Location As [Previous Location], 
			Student.UpdatedWhen AS [Updated When] 
		FROM ['+@dbname+'].[dbo].Student 
		LEFT JOIN ['+@dbname+'].[dbo].School on School.ID = Student.PrevSchoolID AND School.Active = ''Y'' 
		LEFT JOIN [MIM_SyncReplica].[dbo].[AllMIMStudents] on 1=1 
			AND AllMIMStudents.FirstName = Student.FirstName 
			AND AllMIMStudents.LastName = Student.LastName 
			AND ISNULL(FORMAT(CAST(AllMIMStudents.DOB AS Date),''d''),GETDATE()) = ISNULL(Student.DOB,GETDATE()) 
		WHERE ISNULL(Student.UniversalIdentificationNumber,''0'') = ''0'' and Student.PreEnrolment=''N''
		'
        --PRINT (@sql);
		Insert Into @SAS2IDMStudent
        EXECUTE (@sql);
	END
	SET @rn = @rn + 1;
END;

Select S.* from @SAS2IDMStudent S;

END
GO


