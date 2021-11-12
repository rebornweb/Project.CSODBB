USE [BOPS2DB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

EXEC sp_droprolemember N'ILMChangeManager', N'dbb\svcilm'
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ILMChangeManager' AND type = 'R')
DROP ROLE [ILMChangeManager]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsChanges]') AND type in (N'U'))
DROP TABLE [dbo].[idmBOPSObjectsChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsHistory]') AND type in (N'U'))
DROP TABLE [dbo].[idmBOPSObjectsHistory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADSRoleHistory]') AND type in (N'U'))
DROP TABLE [dbo].[ADSRoleHistory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ContractHistory]') AND type in (N'U'))
DROP TABLE [dbo].[ContractHistory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeHistory]') AND type in (N'U'))
DROP TABLE [dbo].[EmployeeHistory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADSRoleChanges]') AND type in (N'U'))
DROP TABLE [dbo].[ADSRoleChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ContractChanges]') AND type in (N'U'))
DROP TABLE [dbo].[ContractChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeChanges]') AND type in (N'U'))
DROP TABLE [dbo].[EmployeeChanges]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[idmBOPSObjectsHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[idmBOPSObjectsHistory](
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
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


--* TODO: remove from here:

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADSRoleHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ADSRoleHistory](
		[ADSRoleID] [int] NOT NULL,
		[ContractID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL,
		[ADSRoleStartDate] [datetime] NULL,
		[ADSRoleEndDate] [datetime] NULL,
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_ADSRoleHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ADSRoleID] ASC, 
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ContractHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ContractHistory](
		[ContractID] [int] NOT NULL,
		[EmployeeID] [int] NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[Classification] [nvarchar](100) NULL,
		[EmploymentType] [nvarchar](100) NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractRenewed] [nvarchar](50) NULL,
		[ExitInterviewCompleted] [bit] NULL,
		[EmploymentTypeID] [int] NULL,
		[DepartmentID] [int] NULL,
		[AwardID] [int] NULL,
		[Salary] [decimal](15, 2) NOT NULL, 
		[SalaryType] [int] NOT NULL,
		[CalculatedSalary] [decimal](15, 2) NOT NULL,
		[ReportingManager] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[CapsPin] [nvarchar](10) NULL,
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_ContractHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ContractID] ASC, 
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[EmployeeHistory](
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[PreferredName] [nvarchar](100) NULL,
		[Initials] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[DOB] [datetime] NULL,
		[Gender] [nvarchar](50) NULL,
		[Address] [nvarchar](1024) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[EmergencyContactName] [nvarchar](100) NULL,
		[EmergencyContactNumber] [nvarchar](50) NULL,
		[OrganisationID] [int] NOT NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeCode] [nvarchar](7) NOT NULL,
		[EmployeeID] [int] NOT NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[HomeNumber] [nvarchar](50) NULL,
		[BankName] [nvarchar](50) NULL,
		[BankBranch] [nvarchar](50) NULL,
		[AccountNumber] [nvarchar](50) NULL,
		[AccountName] [nvarchar](50) NULL,
		[BSB] [nvarchar](50) NULL,
		[Notes] [nvarchar](max) NULL,
		[EmergencyContactName2] [nvarchar](100) NULL,
		[EmergencyContactNumber2] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmergencyContactRelationship] [nvarchar](40) NULL,
		[EmergencyContactRelationship2] [nvarchar](40) NULL,
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_EmployeeHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[EmployeeID] ASC, 
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END

/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[EmployeeHistory](
		--Insert Cols
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_EmployeeHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		--Insert Key Col ASC
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
*/
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADSRoleChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ADSRoleChanges](
		[ADSRoleID] [int] NOT NULL,
		[ContractID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL,
		[ADSRoleStartDate] [datetime] NULL,
		[ADSRoleEndDate] [datetime] NULL,
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_ADSRoleChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_ADSRoleChanges_changeIndicator]  DEFAULT ('M'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ADSRoleChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_ADSRoleChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ADSRoleID] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ContractChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ContractChanges](
		[ContractID] [int] NOT NULL,
		[EmployeeID] [int] NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[Classification] [nvarchar](100) NULL,
		[EmploymentType] [nvarchar](100) NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractRenewed] [nvarchar](50) NULL,
		[ExitInterviewCompleted] [bit] NULL,
		[EmploymentTypeID] [int] NULL,
		[DepartmentID] [int] NULL,
		[AwardID] [int] NULL,
		[Salary] [decimal](15, 2) NOT NULL, 
		[SalaryType] [int] NOT NULL,
		[CalculatedSalary] [decimal](15, 2) NOT NULL,
		[ReportingManager] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[CapsPin] [nvarchar](10) NULL,
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_ContractChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_ContractChanges_changeIndicator]  DEFAULT ('M'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ContractChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_ContractChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ContractID] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[EmployeeChanges](
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[PreferredName] [nvarchar](100) NULL,
		[Initials] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[DOB] [datetime] NULL,
		[Gender] [nvarchar](50) NULL,
		[Address] [nvarchar](1024) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[EmergencyContactName] [nvarchar](100) NULL,
		[EmergencyContactNumber] [nvarchar](50) NULL,
		[OrganisationID] [int] NOT NULL,
		--[ContractSiteLocationID] [int] NULL,
		[EmployeeCode] [nvarchar](7) NOT NULL,
		[EmployeeID] [int] NOT NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[HomeNumber] [nvarchar](50) NULL,
		[BankName] [nvarchar](50) NULL,
		[BankBranch] [nvarchar](50) NULL,
		[AccountNumber] [nvarchar](50) NULL,
		[AccountName] [nvarchar](50) NULL,
		[BSB] [nvarchar](50) NULL,
		[Notes] [nvarchar](max) NULL,
		[EmergencyContactName2] [nvarchar](100) NULL,
		[EmergencyContactNumber2] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmergencyContactRelationship] [nvarchar](40) NULL,
		[EmergencyContactRelationship2] [nvarchar](40) NULL,
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_EmployeeChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_EmployeeChanges_changeIndicator]  DEFAULT ('M'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EmployeeChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_EmployeeChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[EmployeeID] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADSRoleChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ADSRoleChanges](
		-- insert cols here
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_ADSRoleChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_ADSRoleChanges_changeIndicator]  DEFAULT ('M'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ADSRoleChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_ADSRoleChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		-- insert keys here ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
*/


SET ANSI_PADDING OFF

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ADSRole_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ADSRole_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Contract_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Contract_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Employee_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Employee_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_BOPS2_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_BOPS2_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ADSRole_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ADSRole_clearChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Contract_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Contract_clearChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Employee_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Employee_clearChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_BOPS2_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_BOPS2_clearChanges]
go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect ADSRole changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_ADSRole_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.ADSRoleChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.ADSRoleChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.ADSRoleChanges
where changeProcessingIndicator = 'Y' -- processing

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear ADSRole changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_ADSRole_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.ADSRoleChanges
	where changeProcessingIndicator = 'Y' -- processing
) BEGIN
	insert into dbo.ADSRoleHistory
	select * from dbo.ADSRoleChanges
	where changeProcessingIndicator = 'Y' -- processing

	delete from dbo.ADSRoleChanges
	where changeProcessingIndicator = 'Y' -- processing

	select 1
END
ELSE
	select 0

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect Contract changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Contract_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.ContractChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.ContractChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.ContractChanges
where changeProcessingIndicator = 'Y' -- processing

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear Contract changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Contract_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.EmployeeChanges
	where changeProcessingIndicator = 'Y' -- processing
) BEGIN
	insert into dbo.ContractHistory
	select * from dbo.ContractChanges
	where changeProcessingIndicator = 'Y' -- processing

	delete from dbo.ContractChanges
	where changeProcessingIndicator = 'Y' -- processing

	select 1
END
ELSE
	select 0

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect Employee changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Employee_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.EmployeeChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.EmployeeChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.EmployeeChanges
where changeProcessingIndicator = 'Y' -- processing

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear Employee changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Employee_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.EmployeeChanges
	where changeProcessingIndicator = 'Y' -- processing
) BEGIN
	insert into dbo.EmployeeHistory
	select * from dbo.EmployeeChanges
	where changeProcessingIndicator = 'Y' -- processing

	delete from dbo.EmployeeChanges
	where changeProcessingIndicator = 'Y' -- processing

	select 1
END
ELSE
	select 0

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Consolidated stored proc for UNIFYNow to detect ALL BOPS changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_BOPS2_getChanges] as

set nocount on

DECLARE @RC bit
EXECUTE @RC = [dbo].[unifynow_ADSRole_getChanges]
IF @RC Is Null OR @RC = 0
BEGIN
	EXECUTE @RC = [dbo].[unifynow_Contract_getChanges] 
END
IF @RC Is Null OR @RC = 0
BEGIN
	EXECUTE @RC = [dbo].[unifynow_Employee_getChanges] 
END
SELECT @RC

GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Consolidated stored proc for UNIFYNow to clear ALL BOPS changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_BOPS2_clearChanges] as

set nocount on

DECLARE @RC bit
EXECUTE @RC = [dbo].[unifynow_ADSRole_clearChanges] 
IF @RC = 0
BEGIN
	EXECUTE @RC = [dbo].[unifynow_Contract_clearChanges] 
END
IF @RC = 0
BEGIN
	EXECUTE @RC = [dbo].[unifynow_Employee_clearChanges] 
END
SELECT @RC

GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_ContractSiteLocationChanges]'))
DROP TRIGGER [dbo].[trg_ContractSiteLocationChanges]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_OrganisationChanges]'))
DROP TRIGGER [dbo].[trg_OrganisationChanges]
GO

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
IF ( 
	UPDATE ([SiteLocation])
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
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
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
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
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
IF ( 
	UPDATE ([OrganisationName])
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
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
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
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
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
IF ( 
	UPDATE ([ADSDescription])
) 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table table (
		[ADSRoleID] [int] NOT NULL,
		[ContractID] [int] NULL,
		[ADSCode] [nvarchar](50) NULL,
		[ADSDescription] [nvarchar](256) NULL,
		[ADSRoleStartDate] [datetime] NULL,
		[ADSRoleEndDate] [datetime] NULL
	)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
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
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,inserted.[ADSDescription]
		FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[ADSCode] = inserted.[ADSCode]

		insert into @upd_table
		SELECT [ADSRoleID]
			  ,[ContractID]
			  ,[ADSCode]
			  ,[ADSDescription]
			  ,[ADSRoleStartDate]
			  ,[ADSRoleEndDate]
		from inserted
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
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[ADSCode] = deleted.[ADSCode]

			insert into @upd_table 
			SELECT [ADSRoleID]
				  ,[ContractID]
				  ,[ADSCode]
				  ,[ADSDescription]
				  ,[ADSRoleStartDate]
				  ,[ADSRoleEndDate]
			from deleted
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
		INSERT INTO [dbo].[ADSRoleChanges] 
			([ADSRoleID]
			  ,[ContractID]
			  ,[ADSCode]
			  ,[ADSDescription]
			  ,[ADSRoleStartDate]
			  ,[ADSRoleEndDate]
				,[ChangeIndicator])
		select *, @event_type from @upd_table

		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
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



/* Testing: (clone data record)

Truncate table dbo.ADSRoleChanges
Go

insert into [dbo].[ADSRole] 
Select dummy.*, main.* From ( 
	SELECT top 1 
      [firstName]
      ,[lastName]
      ,[active]
      ,[password]
      ,[passwordExpiry]
      ,[orgCode]
      ,[userExpiry]
      ,[lastLoginDate]
      ,[lastLoginHost]
      ,[loginAttempts]
      ,[lockedUntil]
      ,[when_Created]
      ,[who_Created]
      ,[when_Changed]
      ,[who_Changed]
      ,[saceGUID]
      ,[mail]
      ,[dob]
      ,[gender]
      ,[employeeID] -- TODO: Remove key columns from select list!!!
  FROM [dbo].[ADSRole]
) main
Cross Join (Select 999991 As [PK1], '999991' As [userName] UNION ALL Select 999992 As [PK1], '999992' As [userName]) dummy

Update [dbo].[ADSRole] 
Set [userID] = [userID] + 3 
Where [userID] between  999991 and 999992

Delete From [dbo].[ADSRole] 
Where [userID] between  999994 and 999995

*/




--select max(len(EmployeeID)) from dbo.Employee
--
--declare @intEmployeeID int
--set @intEmployeeID = 900000000

/*
select * from [dbo].[vw_idmADSCodeEmployees]
where [IntegerValue] = 71

select * from dbo.vw_idmPerson
where employeeID = 71
*/

-- Discrepencies:
/*
Select Distinct ADSCode, ADSDescription --(130-154)
From dbo.ADSRole
Order by ADSCode, ADSDescription

Select distinct ADSCode, ADSDescription 
From dbo.ADSRole
Where ADSCode in (
	Select ADSCode
	From dbo.ADSRole
	Group by ADSCode
	Having Count(distinct ADSDescription) > 1
)
Order by ADSCode, ADSDescription
*/

go

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
	declare @upd_table table (
		[ContractID] [int] NOT NULL,
		[EmployeeID] [int] NULL,
		[ContractStartDate] [datetime] NULL,
		[ContractEndDate] [datetime] NULL,
		[PositionTitle] [nvarchar](100) NULL,
		[PositionLocation] [nvarchar](100) NULL,
		[Classification] [nvarchar](100) NULL,
		[EmploymentType] [nvarchar](100) NULL,
		[EmployeeStatus] [nvarchar](50) NULL,
		[ContractRenewed] [nvarchar](50) NULL,
		[ExitInterviewCompleted] [bit] NULL,
		[EmploymentTypeID] [int] NULL,
		[DepartmentID] [int] NULL,
		[AwardID] [int] NULL,
		[Salary] [decimal](15, 2) NOT NULL, 
		[SalaryType] [int] NOT NULL,
		[CalculatedSalary] [decimal](15, 2) NOT NULL,
		[ReportingManager] [nvarchar](50) NULL,
		[EmailAccess] [bit] NOT NULL,
		[CapsPin] [nvarchar](10) NULL
	)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
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
			,v.[DOB]
			,v.[PreferredName]
			,v.[OrganisationName]
			,inserted.[ContractStartDate]
			,inserted.[ContractEndDate]
			,inserted.[PositionTitle]
			,v.[PositionLocation]
			,v.[DaysToContractEnd]
			,inserted.[EmployeeStatus]
			,v.[ContractID]
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID] 
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[ContractID] = inserted.[ContractID]

		insert into @upd_table 
		SELECT [ContractID]
		  ,[EmployeeID]
		  ,[ContractStartDate]
		  ,[ContractEndDate]
		  ,[PositionTitle]
		  ,[PositionLocation]
		  ,[Classification]
		  ,[EmploymentType]
		  ,[EmployeeStatus]
		  ,[ContractRenewed]
		  ,[ExitInterviewCompleted]
		  ,[EmploymentTypeID]
		  ,[DepartmentID]
		  ,[AwardID]
		  ,[Salary]
		  ,[SalaryType]
		  ,[CalculatedSalary]
		  ,[ReportingManager]
		  ,[EmailAccess]
		  ,[CapsPin]
		from inserted

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
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID] 
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[ContractID] = deleted.[ContractID]

			insert into @upd_table 
			SELECT [ContractID]
			  ,[EmployeeID]
			  ,[ContractStartDate]
			  ,[ContractEndDate]
			  ,[PositionTitle]
			  ,[PositionLocation]
			  ,[Classification]
			  ,[EmploymentType]
			  ,[EmployeeStatus]
			  ,[ContractRenewed]
			  ,[ExitInterviewCompleted]
			  ,[EmploymentTypeID]
			  ,[DepartmentID]
			  ,[AwardID]
			  ,[Salary]
			  ,[SalaryType]
			  ,[CalculatedSalary]
			  ,[ReportingManager]
			  ,[EmailAccess]
			  ,[CapsPin]
			from deleted
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
		INSERT INTO [dbo].[ContractChanges] 
			([ContractID]
			  ,[EmployeeID]
			  ,[ContractStartDate]
			  ,[ContractEndDate]
			  ,[PositionTitle]
			  ,[PositionLocation]
			  ,[Classification]
			  ,[EmploymentType]
			  ,[EmployeeStatus]
			  ,[ContractRenewed]
			  ,[ExitInterviewCompleted]
			  ,[EmploymentTypeID]
			  ,[DepartmentID]
			  ,[AwardID]
			  ,[Salary]
			  ,[SalaryType]
			  ,[CalculatedSalary]
			  ,[ReportingManager]
			  ,[EmailAccess]
			  ,[CapsPin]
				,[ChangeIndicator])
		select *, @event_type from @upd_table

		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
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
	declare @upd_table table (
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
		[PreferredName] [nvarchar](100) NULL,
		[Initials] [nvarchar](50) NULL,
		[Title] [nvarchar](50) NULL,
		[DOB] [datetime] NULL,
		[Gender] [nvarchar](50) NULL,
		[Address] [nvarchar](1024) NULL,
		[ContactNumber] [nvarchar](50) NULL,
		[EmergencyContactName] [nvarchar](100) NULL,
		[EmergencyContactNumber] [nvarchar](50) NULL,
		[OrganisationID] [int] NOT NULL,
		[EmployeeCode] [nvarchar](7) NOT NULL,
		[EmployeeID] [int] NOT NULL,
		[MobileNumber] [nvarchar](50) NULL,
		[HomeNumber] [nvarchar](50) NULL,
		[BankName] [nvarchar](50) NULL,
		[BankBranch] [nvarchar](50) NULL,
		[AccountNumber] [nvarchar](50) NULL,
		[AccountName] [nvarchar](50) NULL,
		[BSB] [nvarchar](50) NULL,
		[Notes] [nvarchar](max) NULL,
		[EmergencyContactName2] [nvarchar](100) NULL,
		[EmergencyContactNumber2] [nvarchar](50) NULL,
		[Email] [nvarchar](50) NULL,
		[EmergencyContactRelationship] [nvarchar](40) NULL,
		[EmergencyContactRelationship2] [nvarchar](40) NULL
	)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[EmployeeNumber] [nvarchar](7) NULL,
		[GivenName] [nvarchar](100) NULL,
		[Surname] [nvarchar](100) NULL,
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
			,v.[OrganisationID]
			--,v.[ContractSiteLocationID]
			,v.[EmployeeID]
			,v.[ADSCode]
			,v.[ADSDescription]
		FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
		inner join inserted 
			on v.[EmployeeID] = inserted.[EmployeeID] 

		insert into @upd_table 
		SELECT [GivenName]
		  ,[Surname]
		  ,[PreferredName]
		  ,[Initials]
		  ,[Title]
		  ,[DOB]
		  ,[Gender]
		  ,[Address]
		  ,[ContactNumber]
		  ,[EmergencyContactName]
		  ,[EmergencyContactNumber]
		  ,[OrganisationID]
		  ,[EmployeeCode]
		  ,[EmployeeID]
		  ,[MobileNumber]
		  ,[HomeNumber]
		  ,[BankName]
		  ,[BankBranch]
		  ,[AccountNumber]
		  ,[AccountName]
		  ,[BSB]
		  ,[Notes]
		  ,[EmergencyContactName2]
		  ,[EmergencyContactNumber2]
		  ,[Email]
		  ,[EmergencyContactRelationship]
		  ,[EmergencyContactRelationship2]
		from inserted
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
				,v.[OrganisationID]
				--,v.[ContractSiteLocationID]
				,v.[EmployeeID]
				,v.[ADSCode]
				,v.[ADSDescription]
			FROM [BOPS2DB].[dbo].[vw_idmBOPSObjects] v 
			inner join deleted 
				on v.[EmployeeID] = deleted.[EmployeeID] 

			insert into @upd_table 
			SELECT [GivenName]
			  ,[Surname]
			  ,[PreferredName]
			  ,[Initials]
			  ,[Title]
			  ,[DOB]
			  ,[Gender]
			  ,[Address]
			  ,[ContactNumber]
			  ,[EmergencyContactName]
			  ,[EmergencyContactNumber]
			  ,[OrganisationID]
			  ,[EmployeeCode]
			  ,[EmployeeID]
			  ,[MobileNumber]
			  ,[HomeNumber]
			  ,[BankName]
			  ,[BankBranch]
			  ,[AccountNumber]
			  ,[AccountName]
			  ,[BSB]
			  ,[Notes]
			  ,[EmergencyContactName2]
			  ,[EmergencyContactNumber2]
			  ,[Email]
			  ,[EmergencyContactRelationship]
			  ,[EmergencyContactRelationship2]
			from deleted
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
		INSERT INTO [dbo].[EmployeeChanges] 
			([GivenName]
			  ,[Surname]
			  ,[PreferredName]
			  ,[Initials]
			  ,[Title]
			  ,[DOB]
			  ,[Gender]
			  ,[Address]
			  ,[ContactNumber]
			  ,[EmergencyContactName]
			  ,[EmergencyContactNumber]
			  ,[OrganisationID]
			  ,[EmployeeCode]
			  ,[EmployeeID]
			  ,[MobileNumber]
			  ,[HomeNumber]
			  ,[BankName]
			  ,[BankBranch]
			  ,[AccountNumber]
			  ,[AccountName]
			  ,[BSB]
			  ,[Notes]
			  ,[EmergencyContactName2]
			  ,[EmergencyContactNumber2]
			  ,[Email]
			  ,[EmergencyContactRelationship]
			  ,[EmergencyContactRelationship2]
				,[ChangeIndicator])
		select *, @event_type from @upd_table

		INSERT INTO [dbo].[idmBOPSObjectsChanges] ( 
			[ObjectType]
			,[ID]
			,[EmployeeNumber]
			,[GivenName]
			,[Surname]
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

-- Roles

CREATE ROLE [ILMChangeManager] AUTHORIZATION [dbo]
GO

EXEC sp_addrolemember N'ILMChangeManager', N'dbb\svcilm'
GO

GRANT EXECUTE ON [dbo].[unifynow_ADSRole_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_ADSRole_clearChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Contract_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Contract_clearChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Employee_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Employee_clearChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_BOPS2_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_BOPS2_clearChanges] TO [ILMChangeManager]
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
SELECT Distinct [ObjectType]
      ,[ID]
      ,[EmployeeNumber]
      ,[GivenName]
      ,[Surname]
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
      ,[OrganisationID]
      ,[EmployeeID]
      ,[ADSCode]
      ,[ADSDescription]
      ,[changeIndicator]
FROM [BOPS2DB].[dbo].[idmBOPSObjectsChanges]
WHERE changeProcessingIndicator = 'Y'

GO
