USE [BOPS2DB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ILMChangeManager' AND type = 'R')
BEGIN
	EXEC sp_droprolemember N'ILMChangeManager', N'dbb\svcilm'
	EXEC sp_droprolemember N'ILMChangeManager', N'DBB\svcma_sql'
	DROP ROLE [ILMChangeManager]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsChanges]') AND type in (N'U'))
DROP TABLE [dbo].[idmBOPSObjectsChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsHistory]') AND type in (N'U'))
DROP TABLE [dbo].[idmBOPSObjectsHistory]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[idmBOPSObjectsHistory](
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL, 
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL,
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_idmBOPSObjectsHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ID] ASC, 
		[ObjectType] ASC, 
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[idmBOPSObjectsChanges](
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL, 
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL,
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_idmBOPSObjectsChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_idmBOPSObjectsChanges_changeIndicator]  DEFAULT ('M'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_idmBOPSObjectsChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_idmBOPSObjectsChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ID] ASC, 
		[ObjectType] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[unifynow_ADSRole_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ADSRole_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[unifynow_ADSRole_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ADSRole_clearChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[unifynow_BOPS2_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_BOPS2_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[unifynow_BOPS2_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_BOPS2_clearChanges]
go

/****** Object:  StoredProcedure [dbo].[unifynow_Employee_getChanges]    Script Date: 01/15/2009 00:46:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Employee_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Employee_getChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Employee_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Employee_clearChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[unifynow_Contract_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Contract_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[unifynow_Contract_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Contract_clearChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_idmBOPSObjects_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_idmBOPSObjects_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_idmBOPSObjects_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_idmBOPSObjects_clearChanges]
go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect idmBOPSObjects changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_idmBOPSObjects_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.idmBOPSObjectsChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.idmBOPSObjectsChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.idmBOPSObjectsChanges
where changeProcessingIndicator = 'Y' -- processing

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear idmBOPSObjects changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_idmBOPSObjects_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.idmBOPSObjectsChanges
	where changeProcessingIndicator = 'Y' -- processing
) BEGIN
	insert into dbo.idmBOPSObjectsHistory
	select * from dbo.idmBOPSObjectsChanges
	where changeProcessingIndicator = 'Y' -- processing

	delete from dbo.idmBOPSObjectsChanges
	where changeProcessingIndicator = 'Y' -- processing

	select 1
END
ELSE
	select 0

go

/****** Object:  UserDefinedFunction [dbo].[FormatEmployeeID]    Script Date: 01/15/2009 00:39:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FormatEmployeeID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FormatEmployeeID]
GO

/****** Object:  View [dbo].[vw_idmADSCode]    Script Date: 01/15/2009 00:34:13 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmADSCode]'))
DROP VIEW [dbo].[vw_idmADSCode]
GO

/****** Object:  View [dbo].[vw_idmADSCodeEmployees]    Script Date: 01/15/2009 00:33:29 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmADSCodeEmployees]'))
DROP VIEW [dbo].[vw_idmADSCodeEmployees]
GO

/****** Object:  View [dbo].[vw_idmEmployeeADSCodes]    Script Date: 01/15/2009 00:34:50 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmEmployeeADSCodes]'))
DROP VIEW [dbo].[vw_idmEmployeeADSCodes]
GO

/****** Object:  View [dbo].[vw_idmPersonXXX]    Script Date: 01/15/2009 00:35:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmPersonXXX]'))
DROP VIEW [dbo].[vw_idmPersonXXX]
GO

/****** Object:  View [dbo].[vw_idmBOPSObjects]    Script Date: 01/15/2009 00:30:32 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmBOPSObjects]'))
DROP VIEW [dbo].[vw_idmBOPSObjects]
GO

/****** Object:  View [dbo].[vw_idmBOPSMultivalueObjects]    Script Date: 01/15/2009 00:30:54 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmBOPSMultivalueObjects]'))
DROP VIEW [dbo].[vw_idmBOPSMultivalueObjects]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 20 Dec 2008
-- Description:	Provides ILM with an authoritative source for BOPS data
-- Modification History:
--			24 Dec 2008, BBradley, modified from original dbo.vw_idmPerson version
-- =============================================

CREATE VIEW [dbo].[vw_idmBOPSObjects]
AS
SELECT
	'person' As ObjectType, 
	'B' + dbo.Employee.EmployeeCode COLLATE SQL_Latin1_General_CP1_CI_AS As [ID], 
	dbo.Employee.EmployeeCode As [EmployeeNumber], 
	dbo.Employee.GivenName, 
	dbo.Employee.Surname, 
	dbo.Employee.Gender, 
	dbo.Employee.Title, 
	dbo.Employee.MobileNumber, 
	dbo.Employee.ContactNumber, 
	dbo.Employee.Email, 
	dbo.Contract.EmailAccess, 
	dbo.EmploymentType.EmploymentTypeName,
	dbo.Department.DepartmentName,
	--dbo.Employee.DOB, 
	Case Convert(varchar(10), dbo.Employee.DOB, 103) 
		When '01/01/1900' then Null 
		Else dbo.Employee.DOB  
	End As [DOB], 
	dbo.Employee.PreferredName, 
	dbo.Organisation.OrganisationName, 
	dbo.Contract.ContractStartDate, 
	dbo.Contract.ContractEndDate, 
	dbo.Contract.PositionTitle, 
	--dbo.Contract.PositionLocation, 
	dbo.ContractSiteLocation.SiteLocation As [PositionLocation], 
	DATEDIFF([day], GETDATE(), dbo.Contract.ContractEndDate) AS DaysToContractEnd, 
	dbo.Contract.EmployeeStatus,
	dbo.Contract.ContractID, 
	'S' + dbo.Contract.CapsPin As [CapsPin], 
	dbo.Organisation.OrganisationID, 
	--dbo.ContractSiteLocation.ContractSiteLocationID, 
	dbo.Employee.EmployeeID, 
	Null As [ADSCode], 
	Null As [ADSDescription]
FROM dbo.Employee 
LEFT OUTER JOIN dbo.Organisation 
	ON dbo.Organisation.OrganisationID = dbo.Employee.OrganisationID
LEFT OUTER JOIN dbo.Contract 
	ON dbo.Employee.EmployeeID = dbo.Contract.EmployeeID
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
	--OR dbo.ContractSiteLocation.ContractID IS NULL
) 
-- Exclude test data:
AND dbo.Employee.EmployeeCode Not In (
'klu742',
'klu7421',
'klu7429',
'klu7428',
'500206',
'600002',
'600003',
'500097', --Explicit BOPS disconnector
'500099', --Explicit BOPS disconnector

-- Comments from Ruth Peppin:
-- I know the following records are either test data or were entered incorrectly and can be ignored
'500091', --ZZZ
'500110', --Ruth Test   
'500174', --Patricia Taaffe 
'500082' --Paul Neild   

-- The following records I think can be ignored as you will also find them in the Centacare organisation of BOPS2.

--'500150', --Claire Thwaites  
--'500151', --Scott  Handlin  

-- I am not sure about the following as I think they still should be in the Office of the Bishop organisation
--'500179', --Charmaine Clark 
--'500119', --Eileen Luthi 
--'500183' --Christine Reis   
) 

Union All

SELECT Distinct 
	'group' As ObjectType, 
	a.[ADSCode] As ID, 
	Null As EmployeeID, 
	Null As GivenName, 
	Null As Surname, 
	Null As Gender, 
	Null As Title, 
	Null As MobileNumber, 
	Null As ContactNumber, 
	Null As Email, 
	Null As EmailAccess, 
	Null As EmploymentTypeName,
	Null As DepartmentName,
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
	Null As CapsPin,
	Null As OrganisationID, 
	--Null As ContractSiteLocationID, 
	Null As EmployeeID, 
	a.[ADSCode]
	,(
		Select Top 1 A2.[ADSDescription]
		From [dbo].[ADSRole] A2
		Where A2.[ADSCode] = a.[ADSCode]
		Order By A2.[ADSDescription]
	) As [ADSDescription] 
FROM 
	[dbo].[ADSRole] a 
where IsNull(a.[ADSRoleStartDate], DateAdd(day, 1, GetDate())) <= GetDate()
and IsNull(a.[ADSRoleEndDate], GetDate()) >= GetDate()

GO

USE [BOPS2DB]
GO
/****** Object:  View [dbo].[vw_idmBOPSMultivalueObjects]    Script Date: 01/15/2009 00:31:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 20 Dev 2008
-- Description:	Provides ILM with an authoritative source for the employee/ADSCode relationship
-- Modification History:
-- =============================================

Create View [dbo].[vw_idmBOPSMultivalueObjects] As 
Select Distinct 
	'B' + Employee.EmployeeCode COLLATE SQL_Latin1_General_CP1_CI_AS As [ID], 
	'group' As [ObjectType], 
	a.[ADSCode] As [StringValue]
from [dbo].[ADSRole] a
inner join [dbo].[Contract] c on c.ContractID = a.ContractID
	inner join dbo.Employee on Employee.EmployeeID = c.EmployeeID
where IsNull(a.[ADSRoleStartDate], DateAdd(day, 1, GetDate())) <= GetDate()
and IsNull(a.[ADSRoleEndDate], GetDate()) >= GetDate()

UNION ALL

Select Distinct 
	a.ADSCode As ID, 
	'person' As [ObjectType], 
	c.ID COLLATE SQL_Latin1_General_CP1_CI_AS As [StringValue] 
from [dbo].[ADSRole] a
inner join dbo.[vw_idmBOPSObjects] c
	on c.ContractID = a.ContractID
where IsNull(a.[ADSRoleStartDate], DateAdd(day, 1, GetDate())) <= GetDate()
and IsNull(a.[ADSRoleEndDate], GetDate()) >= GetDate()

GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_ContractSiteLocationChanges]'))
DROP TRIGGER [dbo].[trg_ContractSiteLocationChanges]
GO

--IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_OrganisationChanges]'))
--DROP TRIGGER [dbo].[trg_OrganisationChanges]
--GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_ADSRoleChanges]'))
DROP TRIGGER [dbo].[trg_ADSRoleChanges]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_ContractChanges]'))
DROP TRIGGER [dbo].[trg_ContractChanges]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_EmployeeChanges]'))
DROP TRIGGER [dbo].[trg_EmployeeChanges]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the ContractSiteLocation table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table ADSRole there is a corresponding
--				changes table ADSRoleChanges, and that the ADSRoleChanges schema consists of all 
--				ADSRole columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string ADSRole with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from ADSRole
-- =============================================
CREATE TRIGGER [dbo].[trg_ContractSiteLocationChanges] 
   ON  [dbo].[ContractSiteLocation]
   AFTER  INSERT,DELETE,UPDATE
AS 
--IF ( 
--	UPDATE ([SiteLocation])
--) 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL, 
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2
		SELECT v.[ObjectType]
			,v.[ID]
			,v.[EmployeeNumber]
			,v.[GivenName]
			,v.[Surname]
			,v.[Gender] 
			,v.[Title] 
			,v.[MobileNumber] 
			,v.[ContactNumber] 
			,v.[Email] 
			,v.[EmailAccess] 
			,v.[EmploymentTypeName]
			,v.[DepartmentName]
			,v.[DOB]
			,v.[PreferredName]
			,v.[OrganisationName]
			,v.[ContractStartDate]
			,v.[ContractEndDate]
			,v.[PositionTitle]
			,inserted.SiteLocation As [PositionLocation]
			,v.[DaysToContractEnd]
			,v.[EmployeeStatus]
			,v.[ContractID]
			,v.[CapsPin]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[ContractID] = inserted.[ContractID]
		SELECT @event_type = 'U'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table2
			SELECT v.[ObjectType]
				,v.[ID]
				,v.[EmployeeNumber]
				,v.[GivenName]
				,v.[Surname]
				,v.[Gender] 
				,v.[Title] 
				,v.[MobileNumber] 
				,v.[ContactNumber] 
				,v.[Email] 
				,v.[EmailAccess] 
				,v.[EmploymentTypeName]
				,v.[DepartmentName]
				,v.[DOB]
				,v.[PreferredName]
				,v.[OrganisationName]
				,v.[ContractStartDate]
				,v.[ContractEndDate]
				,v.[PositionTitle]
				,deleted.SiteLocation As [PositionLocation]
				,v.[DaysToContractEnd]
				,v.[EmployeeStatus]
				,v.[ContractID]
				,v.[CapsPin]
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[ContractID] = deleted.[ContractID]
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
			,[Gender] 
			,[Title] 
			,[MobileNumber] 
			,[ContactNumber] 
			,[Email] 
			,[EmailAccess] 
			,[EmploymentTypeName]
			,[DepartmentName]
			,[DOB]
			,[PreferredName]
			,[OrganisationName]
			,[ContractStartDate]
			,[ContractEndDate]
			,[PositionTitle]
			,[PositionLocation]
			,[DaysToContractEnd]
			,[EmployeeStatus]
			,[ContractID]
			,[CapsPin]
			,[OrganisationID]
			--,[ContractSiteLocationID] 
			,[EmployeeID]
			,[ADSCode]
			,[ADSDescription]
			,[ChangeIndicator])
		select *, 'U' from @upd_table2
	END

END

GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the Organisation table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table ADSRole there is a corresponding
--				changes table ADSRoleChanges, and that the ADSRoleChanges schema consists of all 
--				ADSRole columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string ADSRole with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from ADSRole
-- =============================================
CREATE TRIGGER [dbo].[trg_OrganisationChanges] 
   ON  [dbo].[Organisation]
   AFTER  INSERT,DELETE,UPDATE
AS 
--IF ( 
--	UPDATE ([OrganisationName])
--) 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL,
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2
		SELECT v.[ObjectType]
			,v.[ID]
			,v.[EmployeeNumber]
			,v.[GivenName]
			,v.[Surname]
			,v.[Gender] 
			,v.[Title] 
			,v.[MobileNumber] 
			,v.[ContactNumber] 
			,v.[Email] 
			,v.[EmailAccess] 
			,v.[EmploymentTypeName]
			,v.[DepartmentName]
			,v.[DOB]
			,v.[PreferredName]
			,inserted.[OrganisationName]
			,v.[ContractStartDate]
			,v.[ContractEndDate]
			,v.[PositionTitle]
			,v.[PositionLocation]
			,v.[DaysToContractEnd]
			,v.[EmployeeStatus]
			,v.[ContractID]
			,v.[CapsPin]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[OrganisationID] = inserted.[OrganisationID]
		SELECT @event_type = 'U'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table2
			SELECT v.[ObjectType]
				,v.[ID]
				,v.[EmployeeNumber]
				,v.[GivenName]
				,v.[Surname]
				,v.[Gender] 
				,v.[Title] 
				,v.[MobileNumber] 
				,v.[ContactNumber] 
				,v.[Email] 
				,v.[EmailAccess] 
				,v.[EmploymentTypeName]
				,v.[DepartmentName]
				,v.[DOB]
				,v.[PreferredName]
				,v.[OrganisationName]
				,v.[ContractStartDate]
				,v.[ContractEndDate]
				,v.[PositionTitle]
				,v.[PositionLocation]
				,v.[DaysToContractEnd]
				,v.[EmployeeStatus]
				,v.[ContractID]
				,v.[CapsPin]
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[OrganisationID] = deleted.[OrganisationID]
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
			,[Gender] 
			,[Title] 
			,[MobileNumber] 
			,[ContactNumber] 
			,[Email] 
			,[EmailAccess] 
			,[EmploymentTypeName]
			,[DepartmentName]
			,[DOB]
			,[PreferredName]
			,[OrganisationName]
			,[ContractStartDate]
			,[ContractEndDate]
			,[PositionTitle]
			,[PositionLocation]
			,[DaysToContractEnd]
			,[EmployeeStatus]
			,[ContractID]
			,[CapsPin]
			,[OrganisationID]
			--,[ContractSiteLocationID] 
			,[EmployeeID]
			,[ADSCode]
			,[ADSDescription]
			,[ChangeIndicator])
		select *, 'U' from @upd_table2
	END

END

GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the ADSRole table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table ADSRole there is a corresponding
--				changes table ADSRoleChanges, and that the ADSRoleChanges schema consists of all 
--				ADSRole columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string ADSRole with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from ADSRole
-- =============================================
CREATE TRIGGER [dbo].[trg_ADSRoleChanges] 
   ON  [dbo].[ADSRole]
   AFTER  INSERT,DELETE,UPDATE
AS 
--IF ( 
--	UPDATE ([ADSDescription])
--) 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL,
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2
		SELECT v.[ObjectType]
			,v.[ID]
			,v.[EmployeeNumber]
			,v.[GivenName]
			,v.[Surname]
			,v.[Gender] 
			,v.[Title] 
			,v.[MobileNumber] 
			,v.[ContactNumber] 
			,v.[Email] 
			,v.[EmailAccess] 
			,v.[EmploymentTypeName]
			,v.[DepartmentName]
			,v.[DOB]
			,v.[PreferredName]
			,v.[OrganisationName]
			,v.[ContractStartDate]
			,v.[ContractEndDate]
			,v.[PositionTitle]
			,v.[PositionLocation]
			,v.[DaysToContractEnd]
			,v.[EmployeeStatus]
			,v.[ContractID]
			,v.[CapsPin]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,inserted.[ADSDescription]
		FROM [dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			--on v.[ADSCode] = inserted.[ADSCode]
			on v.[ContractID] = inserted.[ContractID]
			and v.[ObjectType] = 'person'

		insert into @upd_table2
		SELECT v.[ObjectType]
			,v.[ID]
			,v.[EmployeeNumber]
			,v.[GivenName]
			,v.[Surname]
			,v.[Gender] 
			,v.[Title] 
			,v.[MobileNumber] 
			,v.[ContactNumber] 
			,v.[Email] 
			,v.[EmailAccess] 
			,v.[EmploymentTypeName]
			,v.[DepartmentName]
			,v.[DOB]
			,v.[PreferredName]
			,v.[OrganisationName]
			,v.[ContractStartDate]
			,v.[ContractEndDate]
			,v.[PositionTitle]
			,v.[PositionLocation]
			,v.[DaysToContractEnd]
			,v.[EmployeeStatus]
			,v.[ContractID]
			,v.[CapsPin]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,inserted.[ADSDescription]
		FROM [dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[ID] = inserted.[ADSCode]
			and v.[ObjectType] = 'group'

		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
			SELECT @event_type = 'I'
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table2
			SELECT v.[ObjectType]
				,v.[ID]
				,v.[EmployeeNumber]
				,v.[GivenName]
				,v.[Surname]
				,v.[Gender] 
				,v.[Title] 
				,v.[MobileNumber] 
				,v.[ContactNumber] 
				,v.[Email] 
				,v.[EmailAccess] 
				,v.[EmploymentTypeName]
				,v.[DepartmentName]
				,v.[DOB]
				,v.[PreferredName]
				,v.[OrganisationName]
				,v.[ContractStartDate]
				,v.[ContractEndDate]
				,v.[PositionTitle]
				,v.[PositionLocation]
				,v.[DaysToContractEnd]
				,v.[EmployeeStatus]
				,v.[ContractID]
				,v.[CapsPin]
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				--on v.[ADSCode] = deleted.[ADSCode]
				on v.[ContractID] = deleted.[ContractID]
				and v.[ObjectType] = 'person'

			insert into @upd_table2
			SELECT 'group' As [ObjectType]
				,deleted.[ADSCode] As [ID]
				,Null As [EmployeeNumber]
				,Null As [GivenName]
				,Null As [Surname]
				,Null As Gender 
				,Null As Title 
				,Null As MobileNumber 
				,Null As ContactNumber 
				,Null As Email 
				,Null As EmailAccess 
				,Null As EmploymentTypeName
				,Null As DepartmentName
				,Null As [DOB]
				,Null As [PreferredName]
				,Null As [OrganisationName]
				,Null As [ContractStartDate]
				,Null As [ContractEndDate]
				,Null As [PositionTitle]
				,Null As [PositionLocation]
				,Null As [DaysToContractEnd]
				,Null As [EmployeeStatus]
				,Null As [ContractID]
				,Null As [CapsPin]
				,Null As [OrganisationID]
				--,v.[ContractSiteLocationID] 
				,Null As [EmployeeID]
				,deleted.[ADSCode]
				,deleted.[ADSDescription]
			FROM deleted

			SELECT @event_type = 'D'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
			,[Gender] 
			,[Title] 
			,[MobileNumber] 
			,[ContactNumber] 
			,[Email] 
			,[EmailAccess] 
			,[EmploymentTypeName]
			,[DepartmentName]
			,[DOB]
			,[PreferredName]
			,[OrganisationName]
			,[ContractStartDate]
			,[ContractEndDate]
			,[PositionTitle]
			,[PositionLocation]
			,[DaysToContractEnd]
			,[EmployeeStatus]
			,[ContractID]
			,[CapsPin]
			,[OrganisationID]
			--,[ContractSiteLocationID] 
			,[EmployeeID]
			,[ADSCode]
			,[ADSDescription]
			,[ChangeIndicator])
		select *, 'U' from @upd_table2
	END

END

GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the Contract table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table Contract there is a corresponding
--				changes table ContractChanges, and that the ContractChanges schema consists of all 
--				Contract columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string Contract with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from Contract
-- =============================================
CREATE TRIGGER [dbo].[trg_ContractChanges] 
   ON  [dbo].[Contract]
   AFTER  INSERT,DELETE,UPDATE
AS 
IF ( 
	UPDATE ([ContractStartDate]) OR 
	UPDATE ([ContractEndDate]) OR 
	UPDATE ([PositionTitle]) OR 
	UPDATE ([PositionLocation]) OR 
	UPDATE ([EmployeeStatus])  
) 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL,
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2
		SELECT v.[ObjectType]
			,v.[ID]
			,v.[EmployeeNumber]
			,v.[GivenName]
			,v.[Surname]
			,v.[Gender] 
			,v.[Title] 
			,v.[MobileNumber] 
			,v.[ContactNumber] 
			,v.[Email] 
			,v.[EmailAccess] 
			,v.[EmploymentTypeName]
			,v.[DepartmentName]
			,v.[DOB]
			,v.[PreferredName]
			,v.[OrganisationName]
			,inserted.[ContractStartDate]
			,inserted.[ContractEndDate]
			,inserted.[PositionTitle]
			,v.[PositionLocation]
			,v.[DaysToContractEnd]
			,inserted.[EmployeeStatus]
			,inserted.[ContractID]
			,'S' + inserted.[CapsPin] As [CapsPin]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[ContractID] = inserted.[ContractID]

		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
			SELECT @event_type = 'I'
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
		insert into @upd_table2
			SELECT v.[ObjectType]
				,v.[ID]
				,v.[EmployeeNumber]
				,v.[GivenName]
				,v.[Surname]
				,v.[Gender] 
				,v.[Title] 
				,v.[MobileNumber] 
				,v.[ContactNumber] 
				,v.[Email] 
				,v.[EmailAccess] 
				,v.[EmploymentTypeName]
				,v.[DepartmentName]
				,v.[DOB]
				,v.[PreferredName]
				,v.[OrganisationName]
				,deleted.[ContractStartDate]
				,deleted.[ContractEndDate]
				,deleted.[PositionTitle]
				,v.[PositionLocation]
				,v.[DaysToContractEnd]
				,deleted.[EmployeeStatus]
				,deleted.[ContractID]
				,deleted.[CapsPin]
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[ContractID] = deleted.[ContractID]

			SELECT @event_type = 'D'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
			,[Gender] 
			,[Title] 
			,[MobileNumber] 
			,[ContactNumber] 
			,[Email] 
			,[EmailAccess] 
			,[EmploymentTypeName]
			,[DepartmentName]
			,[DOB]
			,[PreferredName]
			,[OrganisationName]
			,[ContractStartDate]
			,[ContractEndDate]
			,[PositionTitle]
			,[PositionLocation]
			,[DaysToContractEnd]
			,[EmployeeStatus]
			,[ContractID]
			,[CapsPin]
			,[OrganisationID]
			--,[ContractSiteLocationID] 
			,[EmployeeID]
			,[ADSCode]
			,[ADSDescription]
			,[ChangeIndicator])
		select *, 'U' from @upd_table2
	END

END

GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the Employee table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table Employee there is a corresponding
--				changes table EmployeeChanges, and that the EmployeeChanges schema consists of all 
--				Employee columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string Employee with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from Employee
-- =============================================
CREATE TRIGGER [dbo].[trg_EmployeeChanges] 
   ON  [dbo].[Employee]
   AFTER  INSERT,DELETE,UPDATE
AS 
IF ( 
	UPDATE ([EmployeeCode]) OR 
	UPDATE ([GivenName]) OR 
	UPDATE ([Surname]) OR 
	UPDATE ([DOB]) OR 
	UPDATE ([PreferredName])  
) 
	BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[Gender] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[EmploymentTypeName] [nvarchar](100) NULL,
		[DepartmentName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[PreferredName] [nvarchar](100) NULL,
		[OrganisationName] [nvarchar](100) NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[DaysToContractEnd] [int] NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractID] [int] NULL,
		[CapsPin] [nvarchar](10) NULL,
		[OrganisationID] [int] NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2
		SELECT v.[ObjectType]
			,'B' + inserted.EmployeeCode COLLATE SQL_Latin1_General_CP1_CI_AS As [ID] 
			,inserted.[EmployeeCode] As [EmployeeNumber]
			,inserted.[GivenName]
			,inserted.[Surname]
			,v.[Gender] 
			,v.[Title] 
			,v.[MobileNumber] 
			,v.[ContactNumber] 
			,v.[Email] 
			,v.[EmailAccess] 
			,v.[EmploymentTypeName]
			,v.[DepartmentName]
			,inserted.[DOB]
			,inserted.[PreferredName]
			,v.[OrganisationName]
			,v.[ContractStartDate]
			,v.[ContractEndDate]
			,v.[PositionTitle]
			,v.[PositionLocation]
			,v.[DaysToContractEnd]
			,v.[EmployeeStatus]
			,v.[ContractID]
			,v.[CapsPin]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID]
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[EmployeeID] = inserted.[EmployeeID] 

		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
			SELECT @event_type = 'I'
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table2
			SELECT v.[ObjectType]
				,'B' + deleted.EmployeeCode COLLATE SQL_Latin1_General_CP1_CI_AS As [ID] 
				,deleted.[EmployeeCode] As [EmployeeNumber]
				,deleted.[GivenName]
				,deleted.[Surname]
				,v.[Gender] 
				,v.[Title] 
				,v.[MobileNumber] 
				,v.[ContactNumber] 
				,v.[Email] 
				,v.[EmailAccess] 
				,v.[EmploymentTypeName]
				,v.[DepartmentName]
				,deleted.[DOB]
				,deleted.[PreferredName]
				,v.[OrganisationName]
				,v.[ContractStartDate]
				,v.[ContractEndDate]
				,v.[PositionTitle]
				,v.[PositionLocation]
				,v.[DaysToContractEnd]
				,v.[EmployeeStatus]
				,v.[ContractID]
				,v.[CapsPin]
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID]
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[EmployeeID] = deleted.[EmployeeID] 

			SELECT @event_type = 'D'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
			,[Gender] 
			,[Title] 
			,[MobileNumber] 
			,[ContactNumber] 
			,[Email] 
			,[EmailAccess] 
			,[EmploymentTypeName]
			,[DepartmentName]
			,[DOB]
			,[PreferredName]
			,[OrganisationName]
			,[ContractStartDate]
			,[ContractEndDate]
			,[PositionTitle]
			,[PositionLocation]
			,[DaysToContractEnd]
			,[EmployeeStatus]
			,[ContractID]
			,[CapsPin]
			,[OrganisationID]
			--,[ContractSiteLocationID]
			,[EmployeeID]
			,[ADSCode]
			,[ADSDescription]
			,[ChangeIndicator])
		select *, @event_type from @upd_table2
	END

END

GO

-- Users

USE [BOPS2DB]
GO

-- Roles

CREATE ROLE [ILMChangeManager] AUTHORIZATION [dbo]
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DBB\svcma_sql')
CREATE USER [DBB\svcma_sql] FOR LOGIN [DBB\svcma_sql]
GO
EXEC sp_addrolemember N'db_datawriter', N'DBB\svcma_sql'
GO
EXEC sp_addrolemember N'ILMChangeManager', N'DBB\svcma_sql'
GO
EXEC sp_addrolemember N'db_datareader', N'DBB\svcma_sql'
GO

EXEC sp_addrolemember N'ILMChangeManager', N'dbb\svcilm'
GO

GRANT EXECUTE ON [dbo].[unifynow_idmBOPSObjects_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_idmBOPSObjects_clearChanges] TO [ILMChangeManager]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmBOPSObjectsChanges]'))
DROP VIEW [dbo].[vw_idmBOPSObjectsChanges]
Go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for BOPS source data CHANGES
-- Modification History:
-- =============================================

Create View dbo.vw_idmBOPSObjectsChanges As
SELECT [ObjectType]
      ,[ID]
      ,[EmployeeNumber]
      ,[GivenName]
      ,[Surname]
		,[Gender] 
		,[Title] 
		,[MobileNumber] 
		,[ContactNumber] 
		,[Email] 
		,[EmailAccess] 
		,[EmploymentTypeName]
		,[DepartmentName]
      ,[DOB]
      ,[PreferredName]
      ,[OrganisationName]
      ,[ContractStartDate]
      ,[ContractEndDate]
      ,[PositionTitle]
      ,[PositionLocation]
      ,[DaysToContractEnd]
      ,[EmployeeStatus]
      ,[ContractID]
	  ,[CapsPin]
      ,[OrganisationID]
      ,[EmployeeID]
      ,[ADSCode]
      ,[ADSDescription]
      ,[changeIndicator]
FROM [dbo].[idmBOPSObjectsChanges]
WHERE changeProcessingIndicator = 'Y'
AND changeGUID = (
	Select Top 1 changeGUID 
	From dbo.idmBOPSObjectsChanges c2
	Where c2.ID = [idmBOPSObjectsChanges].ID
	And c2.ObjectType = [idmBOPSObjectsChanges].ObjectType
	And c2.changeProcessingIndicator = [idmBOPSObjectsChanges].changeProcessingIndicator 
	Order By c2.changeTimestamp DESC
)

GO
