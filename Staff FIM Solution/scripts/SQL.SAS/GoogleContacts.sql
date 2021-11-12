USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  View [dbo].[GoogleGroupContacts]    Script Date: 01/29/2014 17:47:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GoogleGroupContacts]'))
DROP VIEW [dbo].[GoogleGroupContacts]
GO

Create View dbo.GoogleGroupContacts AS 

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 29 Jan 2014
-- Description:	Provides FIM with an authoritative source for Google Group Contacts
-- Modification History:
--			27 Jan 2014, BBradley, initial version
--			25 Feb 2014, BBradley, extended for staff groups and OCCCP
-- =============================================

-- Diocese contacts
SELECT 
	'GG.Staff' AS [contactID],
	'GG All Staff' AS [contactName],
	'dbballstaff@groups.dbb.catholic.edu.au' AS contactEmailStaff,
	null AS [schoolID],
	1 AS [contactCount]

UNION ALL

SELECT 
	'GG.Students' AS [contactID],
	'GG All Students' AS [contactName],
	'dbballstudents@groups.dbb.catholic.edu.au' AS contactEmailStaff,
	null AS [schoolID],
	1 AS [contactCount]

UNION ALL

-- OCCCP contacts
SELECT 
	'GG.School.OCCCP.Staff' AS [contactID],
	'GG OCCCP Staff' AS [contactName],
	'dbbocccpstaff@groups.dbb.catholic.edu.au' AS contactEmailStaff,
	'OCCCP' AS [schoolID],
	1 AS [contactCount]

UNION ALL

-- Site contacts
SELECT 
	'GG.School.' + [School].SchoolID + '.Students' As [contactID], 
	'GG ' + UPPER(SUBSTRING([School].SchoolName,9,50)) + ' Students' As [contactName], 
	'dbb' + LOWER([School].SchoolID) + 'students@groups.dbb.catholic.edu.au' AS contactEmailStaff,
	[School].SchoolID AS [schoolID],
	COUNT(DISTINCT [Student].UniversalIdentificationNumber) AS [contactCount]
FROM dbo.SAS2IDMSchool [School] with (nolock)
INNER JOIN dbo.AllSAS2IDMStudents [Student] with (nolock)
ON [School].Code = [Student].SchoolID
GROUP BY [School].SchoolID, [School].SchoolName

UNION ALL

SELECT 
	'GG.School.' + [School].SchoolID + '.Staff' As [contactID], 
	'GG ' + UPPER(SUBSTRING([School].SchoolName,9,50)) + ' Staff' As [contactName], 
	'dbb' + LOWER([School].SchoolID) + 'staff@groups.dbb.catholic.edu.au' AS contactEmailStaff,
	[School].SchoolID AS [schoolID],
	COUNT(DISTINCT [Student].UniversalIdentificationNumber) AS [contactCount]
FROM dbo.SAS2IDMSchool [School] with (nolock)
INNER JOIN dbo.AllSAS2IDMStudents [Student] with (nolock)
ON [School].Code = [Student].SchoolID
GROUP BY [School].SchoolID, [School].SchoolName

UNION ALL

-- Site contacts
SELECT 
	'GG.School.' + [School].SchoolID + '.Students.Year' + Y.YearChar As [contactID], 
	'GG ' + UPPER(SUBSTRING([School].SchoolName,9,50)) + ' Year ' + Y.YearChar + ' Students' As [contactName], 
	'dbb' + LOWER([School].SchoolID) + 'yr' + Y.YearChar + '@groups.dbb.catholic.edu.au' AS contactEmailStaff,
	[School].SchoolID AS [schoolID],
	COUNT(DISTINCT [Student].UniversalIdentificationNumber) AS [contactCount]
FROM dbo.SAS2IDMSchool [School] with (nolock)
INNER JOIN dbo.AllSAS2IDMStudents [Student] with (nolock)
INNER JOIN (
	SELECT DISTINCT [Student].[Year],
		CASE CAST([Student].[Year] AS SMALLINT)
			WHEN 0 THEN 'K'
			ELSE CAST(CAST([Student].[Year] AS SMALLINT) AS VARCHAR(2))
		END AS [YearChar]
	FROM dbo.AllSAS2IDMStudents [Student]
) Y ON Y.[Year] = [Student].[Year]
ON [School].Code = [Student].SchoolID
GROUP BY [School].SchoolID, [Student].[Year], Y.YearChar, [School].SchoolName

GO
