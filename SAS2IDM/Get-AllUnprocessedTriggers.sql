USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  StoredProcedure [dbo].[procSAS2IDM_GetAllUnprocessedTriggers]    Script Date: 4/16/2021 3:24:22 PM ******/
DROP PROCEDURE [dbo].[procSAS2IDM_GetAllUnprocessedTriggers]
GO

/****** Object:  StoredProcedure [dbo].[procSAS2IDM_GetAllUnprocessedTriggers]    Script Date: 4/16/2021 1:48:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley
-- Create date: April 2021
-- Description:	Retrieve all unprocessed "trigger" records from the SAS2000_LIVE_<schoolID> databases, the procsssing of which is as reported on the "Process" tab of the SAS2IDM app
-- BEN        : 
-- =============================================
CREATE PROCEDURE [dbo].[procSAS2IDM_GetAllUnprocessedTriggers]
AS
BEGIN

DECLARE @SAS2IDMStudent TABLE (
	[SchoolID] [varchar](50) NOT NULL,
	[StudentID] [int] NOT NULL,
	[RecordType] [varchar](1) NULL,
	[AlumniType] [varchar](1) NULL,
	[PreEnrolment] [varchar](1) NULL,
	[Code] [varchar](20) NULL,
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[PreferredName] [varchar](50) NULL,
	[NName] [nvarchar](255) NULL,
	[FormerName] [varchar](255) NULL,
	[Sex] [varchar](1) NULL,
	[DOB] [datetime] NULL,
	[Year] [varchar](50) NULL,
	[Class] [varchar](50) NULL,
	[HomeGroup] [varchar](50) NULL,
	[House] [varchar](50) NULL,
	[AddressID] [int] NULL,
	[Email] [varchar](50) NULL,
	[PhoneFamily] [varchar](50) NULL,
	[PhoneHome] [varchar](50) NULL,
	[PhoneMobile] [varchar](50) NULL,
	[StartYear] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[Deceased] [varchar](1) NULL,
	[StudentType] [varchar](50) NULL,
	[DateLeft] [datetime] NULL,
	[ReasonLeft] [varchar](50) NULL,
	[CandidateNumber] [varchar](50) NULL,
	[Address1] [varchar](100) NULL,
	[Address2] [varchar](50) NULL,
	[Address3] [varchar](50) NULL,
	[PostCode] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Archive] [varchar](1) NULL,
	[UniversalIdentificationNumber] [varchar](20) NULL
)
DECLARE @rn INT = 1, @dbname varchar(MAX) = '';
DECLARE @sql nvarchar(MAX) = '';

WHILE @dbname IS NOT NULL 
BEGIN
    SET @dbname = (SELECT name FROM (SELECT name, ROW_NUMBER() OVER (ORDER BY name) rn 
        FROM sys.databases WHERE name NOT IN('master','tempdb')) t WHERE rn = @rn);

    IF (@dbname <> '') AND (@dbname IS NOT NULL) AND (@dbname LIKE '%SAS2000_LIVE_%') 
	BEGIN
		SET @sql = 'exec ['+@dbname+'].[dbo].procsas2idm_studentdioces_retrieve;
		'
        --PRINT (@sql);
		Insert into @SAS2IDMStudent
        EXECUTE (@sql);
	END
	SET @rn = @rn + 1;
END;

/*
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SCCSI].[dbo].procsas2idm_studentdioces_retrieve
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SHCPK].[dbo].procsas2idm_studentdioces_retrieve
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SHFPL].[dbo].procsas2idm_studentdioces_retrieve
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SMCCC].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SMCCW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SMMCW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SMRPA].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLDC].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLGF].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLHE].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLPW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLRE].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLST].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLWA].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SOLWY].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SPCSW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSAPH].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSBBH].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSBCL].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSBLM].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSCPB].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSCPW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSGPC].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSHMV].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSHPP].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJAN].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJBH].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJGE].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJPN].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJWW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJTU].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSJWW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSKDW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSKMV].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSLCW].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSMPD].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSMPM].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSMPT].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSPCM].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSPCT].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSPGE].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSPNN].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSPPA].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSRCP].[dbo].procsas2idm_studentdioces_retrieve 
Insert into @SAS2IDMStudent
exec [SAS2000_LIVE_SSTPW].[dbo].procsas2idm_studentdioces_retrieve 
*/

Select Z.SchoolID AS SchoolCode, Z.SchoolName, S.* from @SAS2IDMStudent S
inner join [SAS2IDM_SAS2IDM_LIVE].[dbo].[SAS2IDMSchool] Z
	on Z.Code = S.SchoolID

END

--GO

