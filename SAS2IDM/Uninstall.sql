--USE [SAS2000_LIVE_SCCSI] --SAS2000_LIVE_SHCPK
--GO

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
	SET QUOTED_IDENTIFIER ON
	SET ARITHABORT ON
	SET NUMERIC_ROUNDABORT OFF
	SET CONCAT_NULL_YIELDS_NULL ON
	SET ANSI_NULLS ON
	SET ANSI_PADDING ON
	SET ANSI_WARNINGS ON
COMMIT
GO

IF (ISNULL(OBJECT_ID('DF_SAS2IDMStudentDioces_CreateDate'),0) > 0)
BEGIN
	BEGIN TRANSACTION
		ALTER TABLE dbo.SAS2IDMStudentDioces
			DROP CONSTRAINT DF_SAS2IDMStudentDioces_CreateDate;
		ALTER TABLE dbo.SAS2IDMStudentDioces
			DROP COLUMN CreateDate;
		ALTER TABLE dbo.SAS2IDMStudentDioces SET (LOCK_ESCALATION = TABLE);
	COMMIT
END
GO


/****** Object:  StoredProcedure [dbo].[procSAS2IDM_StudentDioces_Retrieve]    Script Date: 28/05/2021 8:55:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[procSAS2IDM_StudentDioces_Retrieve]						
AS
-- =============================================
-- Author	  :	Rameshkumar
-- Create date: Sep 2010
-- Description:	
-- Modified by : ASD 04/08/2011 Dev Ticket# 463 -  
-- Description : add UniversalIdentificationNumber
-- =============================================
BEGIN

	Select Distinct SchoolID,
					StudentID,					
					RecordType,
					AlumniType,
					PreEnrolment,
					Code,
					FirstName,
					MiddleName,
					LastName,
					PreferredName,
					NName,
					FormerName,
					Sex,
					DOB,
					Year,
					Class,
					HomeGroup,
					House,
					AddressID,
					Email,
					PhoneFamily,
					PhoneHome,
					PhoneMobile,
					StartYear,
					StartDate,
					Deceased,
					StudentType,
					DateLeft,
					ReasonLeft,
					CandidateNumber,
					Address1,
					Address2,
					Address3,
					PostCode,
					Country,
					Archive,
					UniversalIdentificationNumber	
	from SAS2IDMStudentDioces  where PollFlag = 'Y'	and RecordType = 'I'
	
	Union 
	
	Select Distinct SchoolID,
					StudentID,					
					RecordType,
					AlumniType,
					PreEnrolment,
					Code,
					FirstName,
					MiddleName,
					LastName,
					PreferredName,
					NName,
					FormerName,
					Sex,
					DOB,
					Year,
					Class,
					HomeGroup,
					House,
					AddressID,
					Email,
					PhoneFamily,
					PhoneHome,
					PhoneMobile,
					StartYear,
					StartDate,
					Deceased,
					StudentType,
					DateLeft,
					ReasonLeft,
					CandidateNumber,
					Address1,
					Address2,
					Address3,
					PostCode,
					Country,
					Archive,
					UniversalIdentificationNumber
	from SAS2IDMStudentDioces  where PollFlag = 'Y'	and RecordType = 'D'
	and StudentID not in (Select Distinct StudentID from SAS2IDMStudentDioces  where PollFlag = 'Y'	and RecordType = 'I')
	
   RETURN 0
END

GO


