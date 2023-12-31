/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  
	Replace([csoLegacyEmployeeID],'S','') as [csoLegacyEmployeeID],
	[displayName],
	IsNull([email],'default@dbb.local') as [email]
	,[accountName] 
	--,[employeeID]
  FROM [FIMSynchronizationService].[dbo].[mms_metaverse] with (nolock)
WHERE [csoLegacyEmployeeID] like 'S%'
And [employeeStatus] = 'Active'
And [PersonType] = 'Staff'
Order By [csoLegacyEmployeeID]
