USE [BOPS2DB]
GO
/****** Object:  StoredProcedure [dbo].[spNASSData]    Script Date: 10/31/2013 14:43:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[spNASSData] As 

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 1 Apr 2012
-- Description:	Provides FIM with an authoritative source for NASS data (supersedes ILM)
-- Modification History:
--			27 Feb 2013, BBradley, modified to simply use the db OrganisationName
--			15 May 2013, BBradley, modified to ensure DOB is no longer imported as null if 1/1/1900
--			31 Oct 2013, BBradley, removed entitlements node post migration
-- =============================================

SET NOCOUNT ON
/*
http://richarddingwall.name/2008/08/26/nested-xml-results-from-sql-server-with-for-xml-path/
*/

SELECT
(
	SELECT DISTINCT 'site' As [@ObjectType],
		[SiteLocation] AS '@ID',
		--[ContractID] AS '@ContractID',
		[SiteLocation] AS '@SiteName'
	FROM [BOPS2DB].[dbo].[ContractSiteLocation]
	FOR XML PATH('object'), TYPE
),-- AS 'sites',
(
	SELECT 
		'organisation' As [@ObjectType], 
		[OrganisationID] AS '@ID',
		dbo.Organisation.OrganisationName AS '@OrganisationName',
		[AllowCustomEmployeeCode] AS '@AllowCustomEmployeeCode',
		[EmployeeCodeRangeFrom] AS '@EmployeeCodeRangeFrom',
		[EmployeeCodeRangeTill] AS '@EmployeeCodeRangeTill',
		[EmployeeCodeLastValue] AS '@EmployeeCodeLastValue'
	FROM [BOPS2DB].[dbo].[Organisation]
	FOR XML PATH('object'), TYPE
),-- AS 'organisationa',
(
	SELECT 
		'department' As [@ObjectType], 
		[DepartmentID] AS '@ID',
		[DepartmentName] AS '@DepartmentName'
	FROM [BOPS2DB].[dbo].[Department]
	FOR XML PATH('object'), TYPE
),-- AS 'departments',
(
	SELECT DISTINCT 
		'role' As [@ObjectType], 
		ADSCode As '@ID',
		(
			SELECT TOP 1 ADSDescription
			FROM dbo.ADSRole A2
			WHERE A2.ADSCode = A1.ADSCode
			Order By A2.[ADSDescription]
		) as '@ADSDescription'
	FROM dbo.ADSRole A1
	FOR XML PATH('object'), TYPE
),-- AS 'roles',
(
	SELECT
		'person' As [@ObjectType], 
		RTrim(dbo.Employee.EmployeeCode) As [@ID], 
		'B' + RTrim(dbo.Employee.EmployeeCode) As [@EmployeeNumber], 
		RTrim(dbo.Employee.GivenName) As [@GivenName], 
		RTrim(dbo.Employee.Surname) As [@Surname], 
		RTrim(dbo.Employee.Surname) + IsNull(', '+RTrim(dbo.Employee.PreferredName),'') As [@DisplayName], 
		dbo.Employee.Gender As [@Gender], 
		dbo.Employee.Title As [@Title], 
		dbo.Employee.Initials As [@Initials], 
		RTrim(dbo.Employee.MobileNumber) As [@MobileNumber], 
		RTrim(dbo.Employee.ContactNumber) As [@ContactNumber], 
		RTrim(dbo.Employee.Email) As [@Email], 
		dbo.Contract.EmailAccess As [@EmailAccess], 
		dbo.EmploymentType.EmploymentTypeName As [@EmploymentTypeName],
		dbo.Department.DepartmentID As [@DepartmentID],
		dbo.Department.DepartmentName As [@DepartmentName],
		/*Case Convert(varchar(10), dbo.Employee.DOB, 103) 
			When '01/01/1900' then Null 
			Else Convert(varchar,dbo.Employee.DOB,127) + '.000' 
		End As [@DOB], */
		Convert(varchar,dbo.Employee.DOB,127) + '.000' [@DOB], 
		RTrim(dbo.Employee.PreferredName) As [@PreferredName],
		dbo.Organisation.OrganisationID As [@OrganisationID],
		/*Case dbo.Organisation.OrganisationName When 'Office of the Bishop' Then 'Bishops Office' 
			Else dbo.Organisation.OrganisationName 
		End As [@OrganisationName], */
		dbo.Organisation.OrganisationName As [@OrganisationName],
		Convert(varchar,dbo.Contract.ContractStartDate,127) + '.000'  As [@ContractStartDate], 
		Convert(varchar,dbo.Contract.ContractEndDate,127) + '.000'  As [@ContractEndDate], 
		RTrim(dbo.Contract.PositionTitle) As [@PositionTitle], 
		dbo.ContractSiteLocation.SiteLocation As '@SiteID',
		dbo.ContractSiteLocation.SiteLocation As [@SiteName], 
		DATEDIFF([day], GETDATE(), dbo.Contract.ContractEndDate) AS [@DaysToContractEnd], 
		dbo.Contract.EmployeeStatus As [@EmployeeStatus],
		dbo.Contract.ContractID As [@ContractID], 
		'S' + RTrim(dbo.Contract.CapsPin) As [@CapsPin], 
		(
			SELECT DISTINCT ADSCode AS '@RoleID'
			FROM dbo.ADSRole A1
			WHERE A1.ContractID = Contract.ContractID
			FOR XML PATH('role'), TYPE
		) AS 'roles'
	FROM dbo.Employee 
	LEFT OUTER JOIN dbo.Organisation 
		ON dbo.Organisation.OrganisationID = dbo.Employee.OrganisationID
	LEFT OUTER JOIN dbo.Contract 
		ON dbo.Employee.EmployeeID = dbo.Contract.EmployeeID
		--AND GETDATE() BETWEEN dbo.Contract.ContractStartDate AND dbo.Contract.ContractEndDate
		LEFT OUTER JOIN dbo.ContractSiteLocation
			ON dbo.ContractSiteLocation.ContractID = dbo.Contract.ContractID
		LEFT OUTER JOIN dbo.EmploymentType
			ON dbo.EmploymentType.EmploymentTypeID = dbo.Contract.EmploymentTypeID
		LEFT OUTER JOIN dbo.Department
			ON dbo.Department.DepartmentID = dbo.Contract.DepartmentID
	WHERE (
		dbo.Contract.ContractID IN 
		(
			SELECT	TOP 1 [Contract_1].ContractID
			FROM	dbo.Contract AS [Contract_1]
			WHERE	EmployeeID = dbo.Employee.EmployeeID
			ORDER BY ContractStartDate DESC 
		) 
		OR dbo.Contract.ContractID IS NULL
	) 
	And dbo.ContractSiteLocation.SiteLocation <> 'ZZZZZ'
--and dbo.Employee.EmployeeCode = '500091'
	FOR XML PATH('object'), TYPE
)-- AS 'employees',
--(
--    SELECT  
--		'entitlement' As [@ObjectType], 
--		Employee.EmployeeCode 
--			+ ISNULL(':' + Convert(varchar,ADSRoleStartDate,126),'') 
--			+ ISNULL(':' + Convert(varchar,ADSRoleEndDate,126),'') As '@ID',
--		Employee.EmployeeCode As '@EmployeeID',
--		--entitlement.ContractID As '@ContractID',
--		Convert(varchar,ADSRoleStartDate,127) + '.000' As '@ADSRoleStartDate',
--		Convert(varchar,ADSRoleEndDate,127) + '.000' As '@ADSRoleEndDate',
--		(
--			SELECT DISTINCT ADSCode AS '@RoleID'
--			FROM dbo.ADSRole A1
--			WHERE A1.ContractID = entitlement.ContractID
--			AND ISNULL(A1.ADSRoleStartDate,getDate()) = ISNULL(entitlement.ADSRoleStartDate,getDate())
--			AND ISNULL(A1.ADSRoleEndDate,getDate()) = ISNULL(entitlement.ADSRoleEndDate,getDate())
--			FOR XML PATH('role'), TYPE
--		) AS 'roles'
--    FROM
--        dbo.ADSRole entitlement
--    INNER JOIN
--		dbo.Contract ON Contract.ContractID = entitlement.ContractID
--		LEFT OUTER JOIN dbo.ContractSiteLocation
--			ON dbo.ContractSiteLocation.ContractID = dbo.Contract.ContractID
--	INNER JOIN
--		dbo.Employee ON Employee.EmployeeID = Contract.EmployeeID
--	WHERE (
--		dbo.Contract.ContractID IN 
--		(
--			SELECT	TOP 1 [Contract_1].ContractID
--			FROM	dbo.Contract AS [Contract_1]
--			WHERE	EmployeeID = dbo.Contract.EmployeeID
--			ORDER BY ContractStartDate DESC 
--		) 
--		OR dbo.Contract.ContractID IS NULL
--	) 
--	And dbo.ContractSiteLocation.SiteLocation <> 'ZZZZZ'
----and dbo.Employee.EmployeeCode = '500091'
--    GROUP BY Employee.EmployeeCode, entitlement.ContractID, ADSRoleStartDate, ADSRoleEndDate
--    FOR
--        XML PATH('object'), TYPE
--) -- AS 'entitlements'
 FOR XML PATH(''), ROOT ('nassData')
 

GO
GRANT EXECUTE ON [dbo].[spNASSData] TO [ILMChangeManager] AS [dbo]