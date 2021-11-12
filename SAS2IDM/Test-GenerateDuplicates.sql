-- The following will remove duplicate "trigger" records from the SAS2000_LIVE_<schoolID> database in context
-- Bob Bradley, 15/4/2021

USE SAS2000_LIVE_SHCPK -- Replace this with the relevant school code as identified via 
GO

--DEV ONLY>>
-- Set the polling flag
exec [dbo].[procSAS2IDM_StudentDioces_Update]
-- fake the problem:
update SAS2IDMStudentDioces
set RecordType = 'I'
where RecordType = 'D'

GO

Select * FROM SAS2IDMStudentDioces
GO
