USE [IdM]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByType]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByType]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MultivalueObjects]') AND type in (N'U'))
DROP TABLE [dbo].[MultivalueObjects]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[ObjectsByType](
	[ObjectType] [varchar](20) NOT NULL,
	[ID] [nvarchar](50) NOT NULL,
	[BaseID] [nvarchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[physicalDeliveryOfficeName] [nvarchar](50) NULL,
	--[physicalDeliveryOfficeName] [nvarchar](50) NULL CONSTRAINT [DF_ObjectsByType_physicalDeliveryOfficeName]  DEFAULT (N'OCCCP'),
 CONSTRAINT [PK_ObjectsByType] PRIMARY KEY CLUSTERED 
(
	[ObjectType] ASC, 
	[ID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

go

CREATE TABLE [dbo].[MultivalueObjects](
	[ID] [nvarchar](50) NOT NULL,
	[ObjectType] [varchar](6) NOT NULL,
	[StringValue] [nvarchar](50) NOT NULL
 CONSTRAINT [PK_MultivalueObjects] PRIMARY KEY CLUSTERED 
(
	[ID] ASC, 
	[ObjectType] ASC, 
	[StringValue] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveADSCodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[DeriveADSCodes]
GO

Create Function DeriveADSCodes() 
Returns table --( ADSCode nvarchar(50), DerivedADSCode nvarchar(50))
As Return
(
--	-- add raw ADS code
--	Select Distinct [ID], [ID] As [DerivedADSCode]
--	From dbo.[ObjectsByType]
--	Where [ObjectType] = 'group'
--
--	Union All
	-- add Level 1
	Select Distinct 
		[ID], 
		Left([ID],6)+'Z' As [DerivedADSCode], 
		[Name],
		[physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And Right([ID],1) = '1'

	Union All
	-- add Level 2
	Select Distinct [ID], 
		Case CharIndex('0', [ID])
			When 0 Then Left([ID],5)+'0Z'
			Else
			Left([ID],CharIndex('0', [ID])-2) + Right('00000Z',8-CharIndex('0', [ID])+1)
		End As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And Right([ID],1) = '1'

	Union All
	-- add ADS Group code
	Select Distinct 
		[ID], 
		Left([ID],6)+'0' As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And Right([ID],1) = '1'

	Union All
	-- add Internet Users
	Select 
		'Internet Users', 
		[ID], 
		'Internet Users' As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'

)
go

/*
truncate table dbo.ObjectsByType
insert into dbo.ObjectsByType
select ObjectType, ID, ID
from [OCCCP-DB003].[BOPS2DB].[dbo].[vw_idmADSCode]
where ObjectType = 'person'
or ID in (
	select ID from [OCCCP-DB003].[BOPS2DB].[dbo].[vw_idmADSCodeEmployees]
	where ObjectType = 'person' 
)
--where ObjectType = 'person' Or Right([ID],1) = '1'

truncate table dbo.MultivalueObjects
insert into dbo.MultivalueObjects
select ID, ObjectType, StringValue
from [OCCCP-DB003].[BOPS2DB].[dbo].[vw_idmADSCodeEmployees]
--where ObjectType = 'person'

--exec [dbo].[DeriveObjectsByType]
--exec [dbo].[DeriveMultivalueObjects]

select count(*) from dbo.ObjectsByType
select count(*) from dbo.MultivalueObjects

*/

/****** Object:  View [dbo].[vw_idmObjectsByType]    Script Date: 12/24/2008 02:02:34 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByType]'))
DROP VIEW [dbo].[vw_idmObjectsByType]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode collection
-- Modification History:
-- =============================================

Create View [dbo].[vw_idmObjectsByType] As 

SELECT [ObjectType]
      ,[ID]
      ,[BaseID]
      ,[Name]
	  ,Case [ObjectType]
		When 'person' Then [physicalDeliveryOfficeName]
		Else Null
		End As [physicalDeliveryOfficeName]
	  ,Case 
		When [ObjectType] ='group' Then 'base' 
		Else Null 
		End As [GroupType]
  FROM [IdM].[dbo].[ObjectsByType]

UNION ALL

SELECT Distinct 
	o.ObjectType, 
	a.DerivedADSCode As [ID], 
	Null As [BaseID], 
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	'derived' As [GroupType]
FROM [dbo].[ObjectsByType] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where o.ObjectType = 'group'
And a.DerivedADSCode Not In (
	Select [ID] From [dbo].[ObjectsByType]
)

UNION ALL 

SELECT Distinct 
	'group' As [ObjectType], 
	[physicalDeliveryOfficeName] As [ID], 
	Null As [BaseID], 
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	'homeFolderGroup' As [GroupType]
FROM [dbo].[ObjectsByType] 
Where ObjectType = 'person'
And [physicalDeliveryOfficeName] Is Not Null
And Not Exists (
	Select 1 From [dbo].[ObjectsByType] o2
	Where o2.[ID] = [dbo].[ObjectsByType].[physicalDeliveryOfficeName] 
	And o2.ObjectType = 'group'
)

Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveObjectsByType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeriveObjectsByType]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode collection
-- Modification History:
-- =============================================

Create Procedure [dbo].[DeriveObjectsByType] As 
Insert Into [dbo].[ObjectsByType] 
SELECT Distinct 
	o.ObjectType, 
	a.DerivedADSCode As [ID], 
	Null As [BaseID],
	Null As [physicalDeliveryOfficeName],
	a.Name
FROM [dbo].[ObjectsByType] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[ObjectsByType]
)

/*
Select * 
--Delete 
From [dbo].[ObjectsByType]
Where ObjectType = 'group'
And Right([ID],1) = '1'
And [ID] Not In (
	Select count(*)
	From [dbo].[DeriveADSCodes]() a
	Where a.[ID] = [dbo].[ObjectsByType].[ID]
)
*/

Go

/****** Object:  View [dbo].[vw_idmMultivalueObjects]    Script Date: 12/24/2008 02:05:05 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmMultivalueObjects]'))
DROP VIEW [dbo].[vw_idmMultivalueObjects]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode/employee relationship
-- Modification History:
-- =============================================

Create View [dbo].[vw_idmMultivalueObjects] As 

SELECT [ID]
      ,[ObjectType]
      ,[StringValue]
  FROM [IdM].[dbo].[MultivalueObjects]

UNION ALL

SELECT Distinct a.DerivedADSCode As [ID]
      ,[ObjectType]
      ,[StringValue]
  FROM [dbo].[MultivalueObjects] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[MultivalueObjects]
)

UNION ALL 

SELECT Distinct [physicalDeliveryOfficeName] As [ID]
      ,[ObjectType]
      ,[ID] As [StringValue]
  FROM [IdM].[dbo].[ObjectsByType]
Where ObjectType = 'person'
And [physicalDeliveryOfficeName] Is Not Null 

go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveMultivalueObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeriveMultivalueObjects]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode/employee relationship
-- Modification History:
-- =============================================

Create Procedure [dbo].[DeriveMultivalueObjects] As 
Insert Into [dbo].[MultivalueObjects]
SELECT Distinct a.DerivedADSCode As [ID]
      ,[ObjectType]
      ,[StringValue]
  FROM [dbo].[MultivalueObjects] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[MultivalueObjects]
)

go

select * from [ObjectsByType]
select * from [MultivalueObjects]
--select * from [dbo].[DeriveADSCodes]()
--where DerivedADSCode = 'O25600Z'
--where ID = 'O256101'

select * from [ObjectsByType]
--where ID = 'O256101'
