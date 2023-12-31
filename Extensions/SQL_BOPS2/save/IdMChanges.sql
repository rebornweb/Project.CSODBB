USE [IdM]
GO
/****** Object:  View [dbo].[vw_idmObjectsByTypeChanges]    Script Date: 01/09/2009 11:50:16 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByTypeChanges]'))
DROP VIEW [dbo].[vw_idmObjectsByTypeChanges]
GO
/****** Object:  View [dbo].[vw_idmObjectsByTypeChanges]    Script Date: 01/09/2009 11:46:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode collection CHANGES
-- Modification History:
-- =============================================

Create View [dbo].[vw_idmObjectsByTypeChanges] As 

SELECT [ObjectType]
      ,[ID]
      ,[BaseID]
      ,[Name]
      ,[changeIndicator]
  FROM [IdM].[dbo].[ObjectsByTypeChanges]
WHERE changeProcessingIndicator = 'Y'

UNION ALL

SELECT Distinct 
	o.ObjectType, 
	a.DerivedADSCode As [ID], 
	a.DerivedADSCode As [BaseID], 
	a.Name, 
    o.[changeIndicator]
FROM [dbo].[ObjectsByTypeChanges] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[ObjectsByTypeChanges]
)
And o. changeProcessingIndicator = 'Y'
GO

/****** Object:  View [dbo].[vw_idmMultivalueObjectsChanges]    Script Date: 01/09/2009 11:49:56 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmMultivalueObjectsChanges]'))
DROP VIEW [dbo].[vw_idmMultivalueObjectsChanges]
GO
/****** Object:  View [dbo].[vw_idmMultivalueObjectsChanges]    Script Date: 01/09/2009 11:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode/employee relationship CHANGES
-- Modification History:
-- =============================================

Create View [dbo].[vw_idmMultivalueObjectsChanges] As 

SELECT [ID]
      ,[ObjectType]
      ,[StringValue]
      ,[changeIndicator]
  FROM [IdM].[dbo].[MultivalueObjectsChanges]
WHERE changeProcessingIndicator = 'Y'

UNION ALL

SELECT Distinct a.DerivedADSCode As [ID]
      ,o.[ObjectType]
      ,o.[StringValue]
      ,o.[changeIndicator]
  FROM [dbo].[MultivalueObjectsChanges] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[MultivalueObjectsChanges]
)
And o.changeProcessingIndicator = 'Y'

GO

