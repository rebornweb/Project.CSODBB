USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  Table [dbo].[SAS2IDMStudent]    Script Date: 04/10/2017 14:51:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAS2IDMStudentEx]') AND type in (N'U'))
DROP TABLE [dbo].[SAS2IDMStudentEx]
GO

USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  Table [dbo].[SAS2IDMStudent]    Script Date: 04/10/2017 14:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SAS2IDMStudentEx](
	[SchoolID] [varchar](50) NOT NULL,
	[StudentID] [int] NOT NULL,
	[CeIder] [bigint] NOT NULL,
	[UniversalIdentificationNumber] [varchar](20) NOT NULL,
 CONSTRAINT [PK_SAS2IDMStudentEx] PRIMARY KEY CLUSTERED 
(
	[SchoolID] ASC,
	[StudentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

USE [SAS2IDM_SAS2IDM_LIVE]
/****** Object:  Index [UX_CeIder]    Script Date: 04/10/2017 15:38:19 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_CeIder] ON [dbo].[SAS2IDMStudentEx] 
(
	[CeIder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [UX_CeIder]    Script Date: 04/10/2017 15:38:19 ******/
CREATE NONCLUSTERED INDEX [UX_UniversalIdentificationNumber] ON [dbo].[SAS2IDMStudentEx] 
(
	[UniversalIdentificationNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL SAS2IDM Student Table Extensions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAS2IDMStudentEx'
GO


