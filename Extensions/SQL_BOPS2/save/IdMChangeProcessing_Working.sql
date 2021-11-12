

USE [BOPS2DB]
GO

/****** Object:  View [dbo].[AllStaff]    Script Date: 06/30/2008 13:42:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AllStaff]'))
DROP VIEW [dbo].[AllStaff]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 14 Aug 2008
-- Description:	Provides ILM with an authoritative source for admins (staff)
-- Modification History:
-- =============================================

Create View [dbo].[AllStaff] As 
SELECT [userID]
      ,[userName]
      ,[firstName]
      ,[lastName]
      ,[active]
--      ,[password]
--      ,[passwordExpiry]
      ,[orgCode]
      ,[userExpiry]
--      ,[lastLoginDate]
--      ,[lastLoginHost]
--      ,[loginAttempts]
--      ,[lockedUntil]
--      ,[when_Created]
--      ,[who_Created]
--      ,[when_Changed]
--      ,[who_Changed]
      ,[saceGUID]
      ,[mail]
      ,[dob]
      ,[gender]
      ,[employeeID]
  FROM [BOPS2DB].[dbo].[ADSRole]

Go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AllMultiValueObjects]'))
DROP VIEW [dbo].[AllMultiValueObjects]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 14 Aug 2008
-- Description:	Provides ILM with an authoritative source for the admin/school relationship
--				Note that unlike for teachers/students, there is only ever one relationship
-- Modification History:
-- =============================================

Create View [dbo].[AllMultiValueObjects] As 
Select Distinct 
	[userID] As [userID], 
	'Schools' As [ObjectType], 
	[orgCode] As [StringValue] 
from dbo.ADSRole

GO
USE [BOPS2DB]
GO
/****** Object:  Table [dbo].[OrganisationsHistory]    Script Date: 06/24/2008 16:19:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrganisationsHistory]') AND type in (N'U'))
DROP TABLE [dbo].[OrganisationsHistory]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrganisationsHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OrganisationsHistory](
	[Org_Code] [char](3) NOT NULL,
	[Org_Name] [varchar](50) NOT NULL,
	[Org_Type] [char](4) NOT NULL,
	[Location] [varchar](5) NULL,
	[LocOrder] [smallint] NULL,
	[Who_Changed] [varchar](25) NULL,
	[When_Changed] [datetime] NULL,
	[vendor_No] [char](10) NULL,
	[saceGUID] [uniqueidentifier] NOT NULL,
	[changeTimestamp] [datetime] NOT NULL, 
	[changeIndicator] [char](1) NOT NULL, 
	[changeProcessingIndicator] [char](1) NULL, 
	[changeGUID] [uniqueidentifier] NOT NULL , 
 CONSTRAINT [PK_OrganisationsHistory] PRIMARY KEY CLUSTERED 
(
	[changeTimestamp] DESC,
	[Org_Code] ASC, 
	[changeGUID] ASC 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] 
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
USE [BOPS2DB]
GO
/****** Object:  Table [dbo].[OrganisationsChanges]    Script Date: 06/24/2008 16:19:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrganisationsChanges]') AND type in (N'U'))
DROP TABLE [dbo].[OrganisationsChanges]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrganisationsChanges]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OrganisationsChanges](
	[Org_Code] [char](3) NOT NULL,
	[Org_Name] [varchar](50) NOT NULL,
	[Org_Type] [char](4) NOT NULL,
	[Location] [varchar](5) NULL,
	[LocOrder] [smallint] NULL,
	[Who_Changed] [varchar](25) NULL,
	[When_Changed] [datetime] NULL,
	[vendor_No] [char](10) NULL,
	[saceGUID] [uniqueidentifier] NOT NULL,
	[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_OrganisationsChanges_changeTimestamp]  DEFAULT (getDate()), 
	[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_OrganisationsChanges_changeIndicator]  DEFAULT ('M'), 
	[changeProcessingIndicator] [char](1) NULL, 
	[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_OrganisationsChanges_changeGuid]  DEFAULT (newID()), 
 CONSTRAINT [PK_OrganisationsChanges] PRIMARY KEY CLUSTERED 
(
	[changeGUID] ASC  
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF

--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Organisations_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Organisations_getChanges]
go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 14 Aug 2008
-- Description:	stored proc for UNIFYNow to get Organisations changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Organisations_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.OrganisationsChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.OrganisationsChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end
select top 1 1 
from dbo.OrganisationsChanges
where changeProcessingIndicator = 'Y' -- processing
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Organisations_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Organisations_clearChanges]
go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 14 Aug 2008
-- Description:	stored proc for UNIFYNow to clear Organisations changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Organisations_clearChanges] as

set nocount on
insert into dbo.OrganisationsHistory
select * from dbo.OrganisationsChanges
where changeProcessingIndicator = 'Y' -- processing

delete from dbo.OrganisationsChanges
where changeProcessingIndicator = 'Y' -- processing
go

USE [BOPS2DB]
GO
/****** Object:  Trigger [dbo].[trg_OrganisationsChanges]    Script Date: 08/19/2008 16:54:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_OrganisationsChanges]'))
DROP TRIGGER [dbo].[trg_OrganisationsChanges]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions; Gennadi Gretchkosiy, SQL Server DBA, SACE
-- Create date: 20 Aug 2008
-- Description:	Capture all changes to the Organisations table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table Organisations there is a corresponding
--				changes table OrganisationsChanges, and that the OrganisationsChanges schema consists of all 
--				Organisations columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string Organisations with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from Organisations
-- Modification History:
--				22/10/2008, BBradley, Changed filter to include Org_Type 'EXPS'
-- =============================================
CREATE TRIGGER [dbo].[trg_OrganisationsChanges] 
   ON  [dbo].[Organisations]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table table (
		[Org_Code] [char](3) NOT NULL,
		[Org_Name] [varchar](50) NOT NULL,
		[Org_Type] [char](4) NOT NULL,
		[Location] [varchar](5) NULL,
		[LocOrder] [smallint] NULL,
		[Who_Changed] [varchar](25) NULL,
		[When_Changed] [datetime] NULL,
		[vendor_No] [char](10) NULL,
		[saceGUID] [uniqueidentifier] NOT NULL 
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			select [Org_Code]
			  ,[Org_Name]
			  ,[Org_Type]
			  ,[Location]
			  ,[LocOrder]
			  ,[Who_Changed]
			  ,[When_Changed]
			  ,[vendor_No]
			  ,[saceGUID] 
			from inserted 
			--where [Org_Type] = 'SCHL' -- only interested in schools
			where [Org_Type] in ('SCHL','EXPS')
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
			insert into @upd_table 
			select [Org_Code]
			  ,[Org_Name]
			  ,[Org_Type]
			  ,[Location]
			  ,[LocOrder]
			  ,[Who_Changed]
			  ,[When_Changed]
			  ,[vendor_No]
			  ,[saceGUID] 
			from inserted 
			--where [Org_Type] = 'SCHL' -- only interested in schools
			where [Org_Type] in ('SCHL','EXPS')
			SELECT @event_type = 'I'
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			select [Org_Code]
			  ,[Org_Name]
			  ,[Org_Type]
			  ,[Location]
			  ,[LocOrder]
			  ,[Who_Changed]
			  ,[When_Changed]
			  ,[vendor_No]
			  ,[saceGUID] 
			from deleted 
			--where [Org_Type] = 'SCHL' -- only interested in schools
			where [Org_Type] in ('SCHL','EXPS')
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
		INSERT INTO [dbo].[OrganisationsChanges] 
			([Org_Code]
			,[Org_Name]
			,[Org_Type]
			,[Location]
			,[LocOrder]
			,[Who_Changed]
			,[When_Changed]
			,[vendor_No]
			,[saceGUID] 
			,[changeIndicator])
		select *, @event_type from @upd_table 
	END

END

GO


/* Testing: (clone data record)

Truncate table dbo.OrganisationsChanges
Go

insert into [dbo].[Organisations] 
Select dummy.*, main.* From ( 
	SELECT top 1 
      [Org_Name]
      ,[Org_Type]
      ,[Location]
      ,[LocOrder]
      ,[Who_Changed]
      ,[When_Changed]
      ,[vendor_No]
      ,[saceGUID] -- TODO: Remove key columns from select list!!!
  FROM [BOPS2DB].[dbo].[Organisations]
) main
Cross Join (Select 'XX1' As [PK1] UNION ALL Select 'XX2' As [PK1]) dummy

Update [dbo].[Organisations] 
Set [Org_Code] = Replace( [Org_Code], 'X','Y' )
Where [Org_Code] like 'XX_' 

Delete From [dbo].[Organisations] 
Where [Org_Code] like 'YY_'

*/USE [BOPS2DB]
GO

/****** Object:  UserDefinedFunction [dbo].[IsTrainedInPLP]    Script Date: 08/28/2008 14:22:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IsTrainedInPLP]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[IsTrainedInPLP]
GO

/****** Object:  UserDefinedFunction [dbo].[SchoolFilter]    Script Date: 08/28/2008 14:21:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 26 Aug 2008
-- Description:	Provides ILM with a means to provision only data for trained schools to Studywiz
-- Modification History:
-- =============================================
Create Function [dbo].[IsTrainedInPLP](
	@Org_Code char(3) 
) 
Returns bit As 
Begin
	declare @result bit 
	Select @result = Case When (@Org_Code In (
		'001', 
		'005',
		'010',
		'020',
		'810' -- Testing by Bob
	)) Then 1 Else 0 End
	return @result
End
go

/****** Object:  View [dbo].[AllSchools]    Script Date: 08/26/2008 15:58:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AllSchools]'))
DROP VIEW [dbo].[AllSchools]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 26 Aug 2008
-- Description:	Provides ILM with a master set of School IDs and names
-- Modification History:
--				22/10/2008, BBradley, Changed filter to include Org_Type 'EXPS'
-- =============================================
Create View [dbo].[AllSchools] As
SELECT [Org_Code]
      ,[Org_Name]
      ,[Org_Type]
      ,[Location]
      ,[LocOrder]
      ,[Who_Changed]
      ,[When_Changed]
      ,[vendor_No]
      ,[saceGUID]
      ,[dbo].[IsTrainedInPLP] ([Org_Code]) As [IsTrainedInPLP]
  FROM [BOPS2DB].[dbo].[Organisations]
--WHERE [Org_Type] = 'SCHL'
WHERE [Org_Type] in ('SCHL','EXPS')

GO

/****** Object:  View [dbo].[AllSchools]    Script Date: 08/26/2008 15:58:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AllSchoolsChanges]'))
DROP VIEW [dbo].[AllSchoolsChanges]
GO

/****** Object:  View [dbo].[AllSchoolsChanges]    Script Date: 09/03/2008 14:55:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create View [dbo].[AllSchoolsChanges] As 

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 3 Sep 2008
-- Description:	Provides ILM with an authoritative source for school identity changes
-- Modification History:
--				22/10/2008, BBradley, Changed filter to include Org_Type 'EXPS'
-- =============================================

SELECT [Org_Code]
      ,[Org_Name]
      ,[Org_Type]
      ,[Location]
      ,[LocOrder]
      ,[Who_Changed]
      ,[When_Changed]
      ,[vendor_No]
      ,[saceGUID]
      ,[changeTimestamp]
      ,[changeIndicator]
      ,[changeProcessingIndicator]
      ,[changeGUID]
      ,[dbo].[IsTrainedInPLP] ([Org_Code]) As [IsTrainedInPLP]
  FROM [BOPS2DB].[dbo].[OrganisationsChanges]
--WHERE [Org_Type] = 'SCHL'
WHERE [Org_Type] in ('SCHL','EXPS')
Go
