USE [FIMDEEWRArchive]
GO

/****** Object:  Table [dbo].[ResourceManagementObject]    Script Date: 12/02/2011 12:22:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ResourceManagementObject]') AND type in (N'U'))
DROP TABLE [dbo].[ResourceManagementObject]
GO

USE [FIMDEEWRArchive]
GO

/****** Object:  Table [dbo].[ResourceManagementObject]    Script Date: 12/02/2011 12:22:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ResourceManagementObject](
	[ObjectIdentifier] [uniqueidentifier] NOT NULL,
	[CreatedTime] [datetime] NULL,
	[CommittedTime] [datetime] NULL,
	[ExpirationTime] [datetime] NULL,
	[Creator] [uniqueidentifier] NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[ObjectType] [varchar](50) NOT NULL,
	[Operation] [varchar](20) NULL,
	[IsPlaceholder] [varchar](10) NULL,
	[RequestStatus] [varchar](20) NULL,
	[Target] [uniqueidentifier] NULL,
	[TargetObjectType] [varchar](50) NULL,
	[ServicePartitionName] [varchar](50) NULL,
	[ResourceManagementAttributes] [xml] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ObjectIdentifier] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

