USE [BOPS2DB]
GO
/****** Object:  View [dbo].[vw_idmPerson]    Script Date: 12/24/2008 15:45:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 20 Dec 2008
-- Description:	Provides ILM with an authoritative source for a BOPS employee
-- Modification History:
--			20 Dec 2008, BBradley, modified from original version
-- =============================================

CREATE VIEW [dbo].[vw_idmPerson]
AS
SELECT
--	'person' As ObjectType, 
	dbo.Employee.EmployeeID As [EmployeeNumber], 
	[dbo].[FormatEmployeeID](dbo.Employee.EmployeeID) As [ID], 
	dbo.Employee.GivenName, 
	dbo.Employee.Surname, 
	dbo.Employee.DOB, 
	dbo.Employee.PreferredName, 
	dbo.Organisation.OrganisationName, 
	dbo.Contract.ContractStartDate, 
	dbo.Contract.ContractEndDate, 
	dbo.Contract.PositionTitle, 
	dbo.Contract.PositionLocation, 
	DATEDIFF([day], GETDATE(), dbo.Contract.ContractEndDate) AS DaysToContractEnd, 
	dbo.Contract.EmployeeStatus, 
	dbo.Contract.ContractID 
--	Null As [ADSCode]
FROM dbo.Employee 
INNER JOIN dbo.Organisation 
	ON dbo.Organisation.OrganisationID = dbo.Employee.OrganisationID
LEFT OUTER JOIN dbo.Contract 
	ON dbo.Employee.EmployeeID = dbo.Contract.EmployeeID
WHERE (
	dbo.Contract.ContractID IN 
	(
		SELECT	TOP 1 ContractID
        FROM	dbo.Contract AS [Contract_1]
        WHERE	EmployeeID = dbo.Employee.EmployeeID
        ORDER BY ContractStartDate DESC )
	) 
	OR dbo.Contract.ContractID IS NULL

/*Union All

Select  
	'group' As ObjectType, 
	Null As EmployeeID, 
	Null As GivenName, 
	Null As Surname, 
	Null As DOB, 
	Null As PreferredName, 
	Null As OrganisationName, 
	Null As ContractStartDate, 
	Null As ContractEndDate, 
	Null As PositionTitle, 
	Null As PositionLocation, 
	Null As DaysToContractEnd, 
	Null As EmployeeStatus, 
	Null As ContractID, 
	[ADSCode] 
From [dbo].[vw_idmADSCode]
*/

