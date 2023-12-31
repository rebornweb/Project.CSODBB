USE [master]
GO
/****** Object:  Database [IdM]    Script Date: 01/14/2009 23:37:30 ******/
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'IdM')
BEGIN
CREATE DATABASE [IdM] ON  PRIMARY 
( NAME = N'IdM', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\IdM.mdf' , SIZE = 10240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'IdM_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\IdM_log.ldf' , SIZE = 5120KB , MAXSIZE = 2048GB , FILEGROWTH = 20%)
END
GO
EXEC dbo.sp_dbcmptlevel @dbname=N'IdM', @new_cmptlevel=90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [IdM].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [IdM] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [IdM] SET ANSI_NULLS OFF
GO
ALTER DATABASE [IdM] SET ANSI_PADDING OFF
GO
ALTER DATABASE [IdM] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [IdM] SET ARITHABORT OFF
GO
ALTER DATABASE [IdM] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [IdM] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [IdM] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [IdM] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [IdM] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [IdM] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [IdM] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [IdM] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [IdM] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [IdM] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [IdM] SET  ENABLE_BROKER
GO
ALTER DATABASE [IdM] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [IdM] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [IdM] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [IdM] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [IdM] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [IdM] SET  READ_WRITE
GO
ALTER DATABASE [IdM] SET RECOVERY FULL
GO
ALTER DATABASE [IdM] SET  MULTI_USER
GO
ALTER DATABASE [IdM] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [IdM] SET DB_CHAINING OFF
GO
USE [IdM]
GO
/****** Object:  Table [dbo].[Site]    Script Date: 01/14/2009 23:37:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Site]') AND type in (N'U'))
DROP TABLE [dbo].[Site]
GO
/****** Object:  View [dbo].[vw_idmObjectsByType]    Script Date: 01/14/2009 23:37:45 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByType]'))
DROP VIEW [dbo].[vw_idmObjectsByType]
GO
/****** Object:  StoredProcedure [dbo].[DeriveObjectsByType]    Script Date: 01/14/2009 23:37:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveObjectsByType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeriveObjectsByType]
GO
/****** Object:  View [dbo].[vw_idmMultivalueObjects]    Script Date: 01/14/2009 23:37:43 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmMultivalueObjects]'))
DROP VIEW [dbo].[vw_idmMultivalueObjects]
GO
/****** Object:  StoredProcedure [dbo].[DeriveMultivalueObjects]    Script Date: 01/14/2009 23:37:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveMultivalueObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DeriveMultivalueObjects]
GO
/****** Object:  StoredProcedure [dbo].[unifynow_ObjectsByType_getChanges]    Script Date: 01/14/2009 23:37:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ObjectsByType_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ObjectsByType_getChanges]
GO
/****** Object:  StoredProcedure [dbo].[unifynow_ObjectsByType_clearChanges]    Script Date: 01/14/2009 23:37:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ObjectsByType_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ObjectsByType_clearChanges]
GO
/****** Object:  StoredProcedure [dbo].[unifynow_Site_getChanges]    Script Date: 01/14/2009 23:37:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Site_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Site_getChanges]
GO
/****** Object:  StoredProcedure [dbo].[unifynow_Site_clearChanges]    Script Date: 01/14/2009 23:37:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Site_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Site_clearChanges]
GO
/****** Object:  View [dbo].[vw_idmObjectsByTypeChanges]    Script Date: 01/14/2009 23:37:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByTypeChanges]'))
DROP VIEW [dbo].[vw_idmObjectsByTypeChanges]
GO
/****** Object:  UserDefinedFunction [dbo].[DeriveADSCodes]    Script Date: 01/14/2009 23:37:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveADSCodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[DeriveADSCodes]
GO
/****** Object:  Table [dbo].[MultivalueObjects]    Script Date: 01/14/2009 23:37:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MultivalueObjects]') AND type in (N'U'))
DROP TABLE [dbo].[MultivalueObjects]
GO
/****** Object:  Table [dbo].[ObjectsByTypeChanges]    Script Date: 01/14/2009 23:37:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeChanges]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByTypeChanges]
GO
/****** Object:  Table [dbo].[ObjectsByTypeHistory]    Script Date: 01/14/2009 23:37:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeHistory]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByTypeHistory]
GO
/****** Object:  Table [dbo].[SiteChanges]    Script Date: 01/14/2009 23:37:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteChanges]') AND type in (N'U'))
DROP TABLE [dbo].[SiteChanges]
GO
/****** Object:  Table [dbo].[SiteHistory]    Script Date: 01/14/2009 23:37:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteHistory]') AND type in (N'U'))
DROP TABLE [dbo].[SiteHistory]
GO
/****** Object:  Table [dbo].[ObjectsByType]    Script Date: 01/14/2009 23:37:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByType]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByType]
GO
/****** Object:  Schema [dbb\svcilm]    Script Date: 01/14/2009 23:37:30 ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbb\svcilm')
DROP SCHEMA [dbb\svcilm]
GO
/****** Object:  User [dbb\svcma_sql]    Script Date: 01/14/2009 23:37:30 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dbb\svcma_sql')
DROP USER [dbb\svcma_sql]
GO
/****** Object:  User [dbb\svcilm]    Script Date: 01/14/2009 23:37:30 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dbb\svcilm')
DROP USER [dbb\svcilm]
GO
/****** Object:  Role [ILMChangeManager]    Script Date: 01/14/2009 23:37:30 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ILMChangeManager' AND type = 'R')
DROP ROLE [ILMChangeManager]
GO
/****** Object:  Role [ILMChangeManager]    Script Date: 01/14/2009 23:37:30 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ILMChangeManager' AND type = 'R')
CREATE ROLE [ILMChangeManager]
GO
/****** Object:  User [dbb\svcma_sql]    Script Date: 01/14/2009 23:37:30 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dbb\svcma_sql')
CREATE USER [dbb\svcma_sql] FOR LOGIN [DBB\svcma_sql] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [dbb\svcilm]    Script Date: 01/14/2009 23:37:30 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dbb\svcilm')
CREATE USER [dbb\svcilm] FOR LOGIN [dbb\svcilm] WITH DEFAULT_SCHEMA=[dbb\svcilm]
GO
/****** Object:  Schema [dbb\svcilm]    Script Date: 01/14/2009 23:37:30 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbb\svcilm')
EXEC sys.sp_executesql N'CREATE SCHEMA [dbb\svcilm] AUTHORIZATION [dbb\svcilm]'
GO
/****** Object:  Table [dbo].[Site]    Script Date: 01/14/2009 23:37:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Site]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Site](
	[SiteID] [char](5) NOT NULL,
	[physicalDeliveryOfficeName] [char](5) NOT NULL,
	[IsSchool] [bit] NOT NULL CONSTRAINT [DF__Site__IsSchool]  DEFAULT ((1)),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Site__IsActive]  DEFAULT ((1)),
	[IsMOE] [bit] NOT NULL CONSTRAINT [DF__Site__IsMOE]  DEFAULT ((1)),
 CONSTRAINT [PK_Site] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ObjectsByType]    Script Date: 01/14/2009 23:37:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ObjectsByType](
	[ObjectType] [varchar](20) NOT NULL,
	[ID] [nvarchar](50) NOT NULL,
	[BaseID] [nvarchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[physicalDeliveryOfficeName] [nvarchar](50) NULL,
 CONSTRAINT [PK_ObjectsByType] PRIMARY KEY CLUSTERED 
(
	[ObjectType] ASC,
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MultivalueObjects]    Script Date: 01/14/2009 23:37:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MultivalueObjects]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MultivalueObjects](
	[ID] [nvarchar](50) NOT NULL,
	[ObjectType] [varchar](6) NOT NULL,
	[StringValue] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_MultivalueObjects] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ObjectType] ASC,
	[StringValue] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ObjectsByTypeHistory]    Script Date: 01/14/2009 23:37:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ObjectsByTypeHistory](
	[ObjectType] [varchar](20) NOT NULL,
	[ID] [nvarchar](50) NOT NULL,
	[BaseID] [nvarchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[physicalDeliveryOfficeName] [nvarchar](50) NULL,
	[changeTimestamp] [datetime] NOT NULL,
	[changeIndicator] [char](1) NOT NULL,
	[changeProcessingIndicator] [char](1) NULL,
	[changeGUID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ObjectsByTypeHistory] PRIMARY KEY CLUSTERED 
(
	[changeTimestamp] DESC,
	[ObjectType] ASC,
	[ID] ASC,
	[changeGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ObjectsByTypeChanges]    Script Date: 01/14/2009 23:37:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeChanges]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ObjectsByTypeChanges](
	[ObjectType] [varchar](20) NOT NULL,
	[ID] [nvarchar](50) NOT NULL,
	[BaseID] [nvarchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[physicalDeliveryOfficeName] [nvarchar](50) NULL,
	[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_changeTimestamp]  DEFAULT (getdate()),
	[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_changeIndicator]  DEFAULT ('M'),
	[changeProcessingIndicator] [char](1) NULL,
	[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_changeGuid]  DEFAULT (newid()),
 CONSTRAINT [PK_ObjectsByTypeChanges] PRIMARY KEY CLUSTERED 
(
	[changeTimestamp] DESC,
	[ObjectType] ASC,
	[ID] ASC,
	[changeGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteHistory]    Script Date: 01/14/2009 23:37:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SiteHistory](
	[SiteID] [char](5) NOT NULL,
	[physicalDeliveryOfficeName] [char](5) NOT NULL,
	[IsSchool] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsMOE] [bit] NOT NULL,
	[changeTimestamp] [datetime] NOT NULL,
	[changeIndicator] [char](1) NOT NULL,
	[changeProcessingIndicator] [char](1) NULL,
	[changeGUID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_SiteHistory] PRIMARY KEY CLUSTERED 
(
	[changeTimestamp] DESC,
	[SiteID] ASC,
	[changeGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteChanges]    Script Date: 01/14/2009 23:37:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteChanges]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SiteChanges](
	[SiteID] [char](5) NOT NULL,
	[physicalDeliveryOfficeName] [char](5) NOT NULL,
	[IsSchool] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsMOE] [bit] NOT NULL,
	[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_SiteChanges_changeTimestamp]  DEFAULT (getdate()),
	[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_SiteChanges_changeIndicator]  DEFAULT ('M'),
	[changeProcessingIndicator] [char](1) NULL,
	[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SiteChanges_changeGuid]  DEFAULT (newid()),
 CONSTRAINT [PK_SiteChanges] PRIMARY KEY CLUSTERED 
(
	[changeTimestamp] DESC,
	[SiteID] ASC,
	[changeGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Trigger [trg_SiteChanges]    Script Date: 01/14/2009 23:37:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_SiteChanges]'))
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the Site table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table Site there is a corresponding
--				changes table SiteChanges, and that the SiteChanges schema consists of all 
--				Site columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT (''M'')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string Site with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from Site
-- =============================================
CREATE TRIGGER [dbo].[trg_SiteChanges] 
   ON  [dbo].[Site]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table table (
		[SiteID] [char](5) NOT NULL,
		[physicalDeliveryOfficeName] [char](5) NOT NULL,
		[IsSchool] [bit] NOT NULL,
		[IsActive] [bit] NOT NULL,
		[IsMOE] [bit] NOT NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			SELECT [SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
			from inserted
			SELECT @event_type = ''U''
		END
		ELSE
		BEGIN
			insert into @upd_table 
			SELECT [SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
			from inserted
			SELECT @event_type = ''I''
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			SELECT [SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
			from deleted
			SELECT @event_type = ''D''
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = ''N''
		END
	END
	
	IF NOT (@event_type = ''N'')
	BEGIN
		INSERT INTO [dbo].[SiteChanges] 
			([SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
				,[ChangeIndicator])
		select *, @event_type from @upd_table
	END

END

'
GO
/****** Object:  Trigger [trg_ObjectsByTypeChanges]    Script Date: 01/14/2009 23:37:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_ObjectsByTypeChanges]'))
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the ObjectsByType table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table ObjectsByType there is a corresponding
--				changes table ObjectsByTypeChanges, and that the ObjectsByTypeChanges schema consists of all 
--				ObjectsByType columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT (''M'')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string ObjectsByType with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from ObjectsByType
-- =============================================
CREATE TRIGGER [dbo].[trg_ObjectsByTypeChanges] 
   ON  [dbo].[ObjectsByType]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[BaseID] [nvarchar](50) NULL,
		[Name] [nvarchar](100) NULL,
		[physicalDeliveryOfficeName] [nvarchar](50) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table 
		SELECT [ObjectType]
			  ,[ID]
			  ,[BaseID]
			  ,[Name]
			  ,Case [ObjectType] 
				When ''group'' Then Null 
				Else [physicalDeliveryOfficeName] 
				End As [physicalDeliveryOfficeName]
		from inserted
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			SELECT @event_type = ''U''
		END
		ELSE
		BEGIN
			SELECT @event_type = ''I''
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			SELECT [ObjectType]
				  ,[ID]
				  ,[BaseID]
				  ,[Name]
				  ,Case [ObjectType] 
					When ''group'' Then Null 
					Else [physicalDeliveryOfficeName] 
					End As [physicalDeliveryOfficeName]
			from deleted
			SELECT @event_type = ''D''
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = ''N''
		END
	END
	
	IF NOT (@event_type = ''N'')
	BEGIN
		INSERT INTO [dbo].[ObjectsByTypeChanges] 
				([ObjectType]
				  ,[ID]
				  ,[BaseID]
				  ,[Name]
				  ,[physicalDeliveryOfficeName]
				,[ChangeIndicator])
		select *, @event_type from @upd_table
	END

END

'
GO
/****** Object:  Trigger [trg_MultivalueObjectsChanges]    Script Date: 01/14/2009 23:37:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_MultivalueObjectsChanges]'))
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the MultivalueObjects table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table MultivalueObjects there is a corresponding
--				changes table MultivalueObjectsChanges, and that the MultivalueObjectsChanges schema consists of all 
--				MultivalueObjects columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT (''M'')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string MultivalueObjects with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from MultivalueObjects
-- =============================================
CREATE TRIGGER [dbo].[trg_MultivalueObjectsChanges] 
   ON  [dbo].[MultivalueObjects]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
--	declare @upd_table table (
--		[ID] [nvarchar](50) NOT NULL,
--		[ObjectType] [varchar](6) NOT NULL,
--		[StringValue] [nvarchar](50) NOT NULL
--	)
	declare @upd_table2 table (
		[ObjectType] [varchar](6) NOT NULL,
		[ID] [nvarchar](50) NOT NULL,
		[BaseID] [nvarchar](50) NULL,
		[Name] [nvarchar](100) NULL,
		[physicalDeliveryOfficeName] [nvarchar](50) NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2 
		SELECT ''group'' As [ObjectType]
		  ,o.[ID]
		  ,o.[BaseID] 
		  ,o.Name
		  ,o.physicalDeliveryOfficeName
		from dbo.ObjectsByType o
		where o.ObjectType = ''group'' --122
		and ID in (select ID from inserted)
		SELECT @event_type = ''U''
--		IF EXISTS(SELECT Top 1 1 FROM deleted)
--		BEGIN
--			insert into @upd_table 
--			SELECT [ID]
--			  ,[ObjectType]
--			  ,[StringValue]
--			from inserted
--			SELECT @event_type = ''U''
--		END
--		ELSE
--		BEGIN
--			insert into @upd_table 
--			SELECT [ID]
--			  ,[ObjectType]
--			  ,[StringValue]
--			from inserted
--			SELECT @event_type = ''I''
--		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
		SELECT ''group'' As [ObjectType]
		  ,o.[ID]
		  ,o.[BaseID] 
		  ,o.Name
		  ,o.physicalDeliveryOfficeName
		from dbo.ObjectsByType o
		where o.ObjectType = ''group'' --122
		and ID in (select ID from deleted)
		SELECT @event_type = ''U''
--			insert into @upd_table 
--			SELECT [ID]
--			  ,[ObjectType]
--			  ,[StringValue]
--			from deleted
--			SELECT @event_type = ''D''
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = ''N''
		END
	END
	
	IF NOT (@event_type = ''N'')
	BEGIN
--		INSERT INTO [dbo].[MultivalueObjectsChanges] 
--			([ID]
--			  ,[ObjectType]
--			  ,[StringValue]
--				,[ChangeIndicator])
--		select *, @event_type from @upd_table
		INSERT INTO [dbo].[ObjectsByTypeChanges] 
		([ObjectType]
		,[ID]
		,[BaseID]
		,[Name]
		,[physicalDeliveryOfficeName]
		,[ChangeIndicator])
		select *, @event_type from @upd_table2
	END

END

'
GO
/****** Object:  UserDefinedFunction [dbo].[DeriveADSCodes]    Script Date: 01/14/2009 23:37:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveADSCodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
Create Function [dbo].[DeriveADSCodes]() 
Returns table --( ADSCode nvarchar(50), DerivedADSCode nvarchar(50))
As Return
(
--	-- add raw ADS code
--	Select Distinct [ID], [ID] As [DerivedADSCode]
--	From dbo.[ObjectsByType]
--	Where [ObjectType] = ''group''
--
--	Union All
	-- add Level 1
	Select Distinct 
		[ID], 
		Left([ID],6)+''Z'' As [DerivedADSCode], 
		[Name],
		[physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = ''group''
	And Right([ID],1) = ''1''

	Union All
	-- add Level 2
	Select Distinct [ID], 
		Case CharIndex(''0'', [ID])
			When 0 Then Left([ID],5)+''0Z''
			Else
			Left([ID],CharIndex(''0'', [ID])-2) + Right(''00000Z'',8-CharIndex(''0'', [ID])+1)
		End As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = ''group''
	And Right([ID],1) = ''1''

	Union All
	-- add ADS Group code
	Select Distinct 
		[ID], 
		Left([ID],6)+''0'' As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = ''group''
	--And Right([ID],1) = ''1''

	Union All
	-- add Internet Users
	Select 
		''Internet Users'', 
		[ID], 
		''Internet Users'' As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = ''group''

)
' 
END
GO
/****** Object:  StoredProcedure [dbo].[unifynow_ObjectsByType_clearChanges]    Script Date: 01/14/2009 23:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ObjectsByType_clearChanges]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear ObjectsByType changes
-- Modification History:
-- =============================================

create procedure [dbo].[unifynow_ObjectsByType_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = ''Y'' -- processing
) BEGIN
	insert into dbo.ObjectsByTypeHistory
	select * from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = ''Y'' -- processing

	delete from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = ''Y'' -- processing

	select 1
END
ELSE
	select 0

' 
END
GO
/****** Object:  StoredProcedure [dbo].[unifynow_ObjectsByType_getChanges]    Script Date: 01/14/2009 23:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ObjectsByType_getChanges]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect Site changes
-- Modification History:
-- =============================================

create procedure [dbo].[unifynow_ObjectsByType_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = ''Y'' -- processing
)
begin
	update dbo.ObjectsByTypeChanges
	set changeProcessingIndicator = ''Y''
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.ObjectsByTypeChanges
where changeProcessingIndicator = ''Y'' -- processing

' 
END
GO
/****** Object:  StoredProcedure [dbo].[unifynow_Site_clearChanges]    Script Date: 01/14/2009 23:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Site_clearChanges]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear Site changes
-- Modification History:
-- =============================================

create procedure [dbo].[unifynow_Site_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.SiteChanges
	where changeProcessingIndicator = ''Y'' -- processing
) BEGIN
	insert into dbo.SiteHistory
	select * from dbo.SiteChanges
	where changeProcessingIndicator = ''Y'' -- processing

	delete from dbo.SiteChanges
	where changeProcessingIndicator = ''Y'' -- processing

	--select 1
END
--ELSE
--	select 0

' 
END
GO
/****** Object:  StoredProcedure [dbo].[unifynow_Site_getChanges]    Script Date: 01/14/2009 23:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Site_getChanges]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--
---- =============================================
---- Author:		Bob Bradley, UNIFY Solutions
---- Create date: 22 Dec 2008
---- Description:	stored proc for UNIFYNow to detect MultivalueObjects changes
---- Modification History:
---- =============================================
--
--create procedure dbo.[unifynow_MultivalueObjects_getChanges] as
--
--set nocount on
--if not exists (
--	select 1 
--	from dbo.MultivalueObjectsChanges
--	where changeProcessingIndicator = ''Y'' -- processing
--)
--begin
--	update dbo.MultivalueObjectsChanges
--	set changeProcessingIndicator = ''Y''
--	where changeProcessingIndicator is null -- unprocessed
--end
--
----select top 1 1
----from dbo.MultivalueObjectsChanges
----where changeProcessingIndicator = ''Y'' -- processing
--
--go
--
---- =============================================
---- Author:		Bob Bradley, UNIFY Solutions
---- Create date: 22 Dec 2008
---- Description:	stored proc for UNIFYNow to clear MultivalueObjects changes
---- Modification History:
---- =============================================
--
--create procedure dbo.[unifynow_MultivalueObjects_clearChanges] as
--
--set nocount on
--
--IF EXISTS ( 
--	select top 1 1 from dbo.MultivalueObjectsChanges
--	where changeProcessingIndicator = ''Y'' -- processing
--) BEGIN
--	insert into dbo.MultivalueObjectsHistory
--	select * from dbo.MultivalueObjectsChanges
--	where changeProcessingIndicator = ''Y'' -- processing
--
--	delete from dbo.MultivalueObjectsChanges
--	where changeProcessingIndicator = ''Y'' -- processing
--
--	--select 1
--END
----ELSE
----	select 0
--
--go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect Site changes
-- Modification History:
-- =============================================

create procedure [dbo].[unifynow_Site_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.SiteChanges
	where changeProcessingIndicator = ''Y'' -- processing
)
begin
	update dbo.SiteChanges
	set changeProcessingIndicator = ''Y''
	where changeProcessingIndicator is null -- unprocessed
end

--select top 1 1
--from dbo.SiteChanges
--where changeProcessingIndicator = ''Y'' -- processing

' 
END
GO
/****** Object:  View [dbo].[vw_idmObjectsByType]    Script Date: 01/14/2009 23:37:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByType]'))
EXEC dbo.sp_executesql @statement = N'
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
		When ''person'' Then [physicalDeliveryOfficeName]
		Else Null
		End As [physicalDeliveryOfficeName]
	  ,Case 
		When [ObjectType] =''group'' Then ''base'' 
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
	''derived'' As [GroupType]
FROM [dbo].[ObjectsByType] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where o.ObjectType = ''group''
And a.DerivedADSCode Not In (
	Select [ID] From [dbo].[ObjectsByType]
)

UNION ALL 

SELECT Distinct 
	''group'' As [ObjectType], 
	[physicalDeliveryOfficeName] As [ID], 
	Null As [BaseID], 
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	''homeFolderGroup'' As [GroupType]
FROM [dbo].[ObjectsByType] 
Where ObjectType = ''person''
And [physicalDeliveryOfficeName] Is Not Null
And Not Exists (
	Select 1 From [dbo].[ObjectsByType] o2
	Where o2.[ID] = [dbo].[ObjectsByType].[physicalDeliveryOfficeName] 
	And o2.ObjectType = ''group''
)

'
GO
/****** Object:  StoredProcedure [dbo].[DeriveObjectsByType]    Script Date: 01/14/2009 23:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveObjectsByType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
Where ObjectType = ''group''
And Right([ID],1) = ''1''
And [ID] Not In (
	Select count(*)
	From [dbo].[DeriveADSCodes]() a
	Where a.[ID] = [dbo].[ObjectsByType].[ID]
)
*/

' 
END
GO
/****** Object:  View [dbo].[vw_idmMultivalueObjects]    Script Date: 01/14/2009 23:37:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmMultivalueObjects]'))
EXEC dbo.sp_executesql @statement = N'
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
Where ObjectType = ''person''
And [physicalDeliveryOfficeName] Is Not Null 

'
GO
/****** Object:  View [dbo].[vw_idmObjectsByTypeChanges]    Script Date: 01/14/2009 23:37:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByTypeChanges]'))
EXEC dbo.sp_executesql @statement = N'
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
	  ,Case [ObjectType]
		When ''person'' Then [physicalDeliveryOfficeName]
		Else Null
		End As [physicalDeliveryOfficeName]
	  ,Case 
		When [ObjectType] =''group'' Then ''base'' 
		Else Null 
		End As [GroupType]
      ,[changeIndicator]
  FROM [IdM].[dbo].[ObjectsByTypeChanges]
WHERE changeProcessingIndicator = ''Y''

UNION ALL

SELECT Distinct 
	o.ObjectType, 
	a.DerivedADSCode As [ID], 
	a.DerivedADSCode As [BaseID], 
	a.Name, 
	a.[physicalDeliveryOfficeName],
	''derived'' As [GroupType],
    o.[changeIndicator]
FROM [dbo].[ObjectsByTypeChanges] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where o.ObjectType = ''group''
And a.DerivedADSCode Not In (
	Select [ID] From [dbo].[ObjectsByTypeChanges]
)
And o.changeProcessingIndicator = ''Y''

UNION ALL

SELECT Distinct 
	''group'' As [ObjectType], 
	[physicalDeliveryOfficeName] As [ID], 
	Null As [BaseID], 
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	''homeFolderGroup'' As [GroupType]
	,''I'' As [changeIndicator]
FROM [dbo].[ObjectsByType] 
Where ObjectType = ''person''
And [physicalDeliveryOfficeName] Is Not Null
And Not Exists (
	Select 1 From [dbo].[ObjectsByType] o2
	Where o2.[ID] = [dbo].[ObjectsByType].[physicalDeliveryOfficeName] 
	And o2.ObjectType = ''group''
)
And [physicalDeliveryOfficeName] In ( 
	Select Distinct [physicalDeliveryOfficeName] 
	From [IdM].[dbo].[ObjectsByTypeChanges]
	Where ObjectType = ''person''
)

'
GO
/****** Object:  StoredProcedure [dbo].[DeriveMultivalueObjects]    Script Date: 01/14/2009 23:37:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveMultivalueObjects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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

' 
END
GO
USE [master]
GO
GRANT CONNECT TO [dbb\svcma_sql]
GO
USE [IdM]
GO
EXEC sys.sp_addrolemember @rolename=N'ILMChangeManager', @membername=N'dbb\svcilm'
GO
GRANT EXECUTE ON [dbo].[unifynow_ObjectsByType_clearChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_ObjectsByType_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Site_clearChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Site_getChanges] TO [ILMChangeManager]
GO

-- prime with dummy row
Insert Into dbo.ObjectsByType values ('group','zzzzzz','zzzzzz','zzzzzz','OCCCP')
