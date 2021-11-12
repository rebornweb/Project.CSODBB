--USE [SAS2000_LIVE_SCCSI] --SAS2000_LIVE_SHCPK -- Replace this with the relevant school code as identified via 
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

IF (ISNULL(OBJECT_ID('DF_SAS2IDMStudentDioces_CreateDate'),0) = 0)
BEGIN
	BEGIN TRANSACTION
		ALTER TABLE dbo.SAS2IDMStudentDioces ADD
			CreateDate datetime NOT NULL CONSTRAINT DF_SAS2IDMStudentDioces_CreateDate DEFAULT GetDate();
		ALTER TABLE dbo.SAS2IDMStudentDioces SET (LOCK_ESCALATION = TABLE);
	COMMIT
END
GO

ALTER PROCEDURE [dbo].[procSAS2IDM_StudentDioces_Retrieve]						
AS
-- =============================================
-- Author	  :	Rameshkumar
-- Create date: Sep 2010
-- Description:	
-- Modified by : ASD 04/08/2011 Dev Ticket# 463 -  
-- Description : add UniversalIdentificationNumber
-- Modified by : Bob Bradley, UNIFY Solutions, 25/05/2021
-- Description : use new CreateDate column to retrieve only the latest triggers
-- =============================================
BEGIN

	Select  S.SchoolID,
			S.StudentID,					
			S.RecordType,
			S.AlumniType,
			S.PreEnrolment,
			S.Code,
			S.FirstName,
			S.MiddleName,
			S.LastName,
			S.PreferredName,
			S.NName,
			S.FormerName,
			S.Sex,
			S.DOB,
			S.Year,
			S.Class,
			S.HomeGroup,
			S.House,
			S.AddressID,
			S.Email,
			S.PhoneFamily,
			S.PhoneHome,
			S.PhoneMobile,
			S.StartYear,
			S.StartDate,
			S.Deceased,
			S.StudentType,
			S.DateLeft,
			S.ReasonLeft,
			S.CandidateNumber,
			S.Address1,
			S.Address2,
			S.Address3,
			S.PostCode,
			S.Country,
			S.Archive,
			S.UniversalIdentificationNumber	
	from SAS2IDMStudentDioces S
		inner join (
			Select UniversalIdentificationNumber, Max(CreateDate) as [MaxCreateDate]
			From SAS2IDMStudentDioces
			Where PollFlag = 'Y'
			And RecordType = 'I'
			Group By UniversalIdentificationNumber
		) S2 
		on S2.UniversalIdentificationNumber = S.UniversalIdentificationNumber
		and S2.MaxCreateDate = S.CreateDate
	where S.PollFlag = 'Y'	and S.RecordType = 'I'
	
	Union 
	
	Select  S.SchoolID,
			S.StudentID,					
			S.RecordType,
			S.AlumniType,
			S.PreEnrolment,
			S.Code,
			S.FirstName,
			S.MiddleName,
			S.LastName,
			S.PreferredName,
			S.NName,
			S.FormerName,
			S.Sex,
			S.DOB,
			S.Year,
			S.Class,
			S.HomeGroup,
			S.House,
			S.AddressID,
			S.Email,
			S.PhoneFamily,
			S.PhoneHome,
			S.PhoneMobile,
			S.StartYear,
			S.StartDate,
			S.Deceased,
			S.StudentType,
			S.DateLeft,
			S.ReasonLeft,
			S.CandidateNumber,
			S.Address1,
			S.Address2,
			S.Address3,
			S.PostCode,
			S.Country,
			S.Archive,
			S.UniversalIdentificationNumber	
	from SAS2IDMStudentDioces S
		inner join (
			Select UniversalIdentificationNumber, Max(CreateDate) as [MaxCreateDate]
			From SAS2IDMStudentDioces
			Where PollFlag = 'Y'
			And RecordType = 'D'
			Group By UniversalIdentificationNumber
		) S2 
		on S2.UniversalIdentificationNumber = S.UniversalIdentificationNumber
		and S2.MaxCreateDate = S.CreateDate
	Where S.PollFlag = 'Y'	and S.RecordType = 'D'
	and S.StudentID not in (Select Distinct StudentID from SAS2IDMStudentDioces  where PollFlag = 'Y'	and RecordType = 'I')
	
   RETURN 0
END

GO
