USE [SAS2000_LIVE_SHCPK] -- Kinkumber = SHCPK
GO

Select Control.Value FROM Control WHERE Control.Code = 'SchoolNumber' -- 2348

-- 1. Count should be zero:
select count(*) from SAS2IDMStudentDioces
-- 2. Fetch all Student records into the sas2IDMStudentDioces table from this school
exec [dbo].[procSAS2IDM_StudentDioces_TOTUpdate]
-- 3. Update USIN
Update [dbo].[SAS2IDMStudentDioces]
Set SAS2IDMStudentDioces.UniversalIdentificationNumber = Student.UniversalIdentificationNumber
from [dbo].[Student]
Where Student.ID = SAS2IDMStudentDioces.StudentID
-- 4. Mark all SAS2IDMStudentDioces records with no USIN as record type = 'D'
Update [dbo].[SAS2IDMStudentDioces]
Set RecordType = 'D'
Where UniversalIdentificationNumber is null
-- 5. Set the polling flag
exec [dbo].[procSAS2IDM_StudentDioces_Update]
-- 6. See what it looks like now ...
select * from SAS2IDMStudentDioces


/*

SELECT 
	[Alumni].StudentType, 
	[Alumni].ID, 
	[Alumni].Code, 
	[Alumni].PreEnrolment,
	[Alumni].UniversalIdentificationNumber,
	[Alumni].CreatedWhen,
	[Alumni].FirstName,
	[Alumni].LastName,
	[Alumni].ReasonLeft
FROM [dbo].[Alumni]
Where PreEnrolment = 'N'
and [Alumni].UniversalIdentificationNumber in ('2812835400604','2812835400373')

SELECT 
	Student.StudentType, 
	Student.ID, 
	Student.Code, 
	Student.Archive, 
	Student.Inactive, 
	Student.InactiveFrom, 
	Student.InactiveReason,
	Student.PreEnrolment,
	Student.UniversalIdentificationNumber,
	Student.CreatedWhen
FROM [dbo].[Student]
Where PreEnrolment = 'N'
and Student.UniversalIdentificationNumber in ('2812835400604','2812835400373')

SELECT 
	Student.StudentType, 
	Student.ID, 
	Student.Code, 
	Student.PreEnrolment,
	Student.UniversalIdentificationNumber,
	Student.CreatedWhen
FROM [dbo].[Alumni] Student
Where PreEnrolment = 'N'
and Student.UniversalIdentificationNumber in ('2812835400604','2812835400373')

GO



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

*/

