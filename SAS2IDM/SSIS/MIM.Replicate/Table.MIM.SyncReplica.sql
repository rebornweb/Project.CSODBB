USE [MIM_SyncReplica]
GO

/*
see https://www.sqlservercentral.com/forums/topic/alternatives-to-linked-servers 
... after eliminating both linked server and OPENROWSET options, we were left with only SSIS to achieve the required outcome

create new db MIM_SyncReplica (on OCCCP-DB222)
CREATE TABLE [SAS2IDM_SAS2IDM_LIVE].[dbo].[AllMIMStudents] on OCCCP-DB222
Create new view [FIMSynchronizationService].dbo.AllMIMStudents on D-OCCCP-IM301
Create and deploy SSIS package to replicate source MIM to replica data table
Create SQL agent job to run on a schedule
Grant svcSSIS rights to the source and replica dbs
*/

/****** Object:  Table [dbo].[AllMIMStudents]    Script Date: 7/12/2021 2:06:29 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllMIMStudents]') AND type in (N'U'))
DROP TABLE [dbo].[AllMIMStudents]
GO

/****** Object:  Table [dbo].[AllMIMStudents]    Script Date: 7/12/2021 2:06:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllMIMStudents]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AllMIMStudents](
	[accountName] [nvarchar](448) NULL,
	[class] [nvarchar](448) NULL,
	[csoCeIder] [nvarchar](448) NULL,
	[displayName] [nvarchar](448) NULL,
	[DOB] [nvarchar](448) NULL,
	[EmployeeNumber] [nvarchar](448) NULL,
	[firstName] [nvarchar](448) NULL,
	[lastName] [nvarchar](448) NULL,
	[mailSuffix] [nvarchar](448) NULL,
	[physicalDeliveryOfficeName] [nvarchar](448) NULL,
	[SchoolCode] [nvarchar](448) NULL,
	[SchoolID] [nvarchar](10) NOT NULL,
	[sex] [nvarchar](448) NULL,
	[StudentID] [bigint] NOT NULL,
	[USIN] [nvarchar](448) NULL,
	[Year] [nvarchar](448) NULL
) ON [PRIMARY]
END
GO

/****** Object:  Index [ixCeIder]    Script Date: 7/12/2021 4:09:50 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AllMIMStudents]') AND name = N'ixCeIder')
CREATE NONCLUSTERED INDEX [ixCeIder] ON [dbo].[AllMIMStudents]
(
	[csoCeIder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ixUSIN]    Script Date: 7/12/2021 4:10:12 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AllMIMStudents]') AND name = N'ixUSIN')
CREATE NONCLUSTERED INDEX [ixUSIN] ON [dbo].[AllMIMStudents]
(
	[USIN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ixSchoolStudent]    Script Date: 7/12/2021 4:10:27 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AllMIMStudents]') AND name = N'ixSchoolStudent')
CREATE UNIQUE CLUSTERED INDEX [ixSchoolStudent] ON [dbo].[AllMIMStudents]
(
	[SchoolID] ASC,
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

