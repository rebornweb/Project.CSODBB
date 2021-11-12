USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  View [dbo].[GoogleGroupContacts]    Script Date: 01/29/2014 17:47:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AllSAS2IDMDuplicateUSINs]'))
DROP VIEW [dbo].[AllSAS2IDMDuplicateUSINs]
GO

Create View dbo.AllSAS2IDMDuplicateUSINs AS 

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 29 Jan 2014
-- Description:	Provides FIM admins with a report of duplicate Student IDs
-- Modification History:
--			1 Feb 2014, Initial version
-- =============================================

Select --Top 100 Percent 
	S.UniversalIdentificationNumber,
	S.Code,
	S.Year,
	S.Class,
	S.FirstName, 
	S.PreferredName, 
	S.LastName,
	S.DOB,
	S.PhysicaldeliveryOfficeName
From dbo.AllSAS2IDMStudents S With (nolock)
Inner Join (
	Select UniversalIdentificationNumber
	From dbo.AllSAS2IDMStudents With (nolock)
	Group By UniversalIdentificationNumber
	Having Count(*) > 1
) X On X.UniversalIdentificationNumber = S.UniversalIdentificationNumber
--Order By S.UniversalIdentificationNumber

GO