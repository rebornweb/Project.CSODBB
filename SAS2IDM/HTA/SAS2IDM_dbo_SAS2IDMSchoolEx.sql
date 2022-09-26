USE [SAS2IDM_SAS2IDM_LIVE]
GO

USE [SAS2IDM_SAS2IDM_LIVE]
GO

/****** Object:  Table [dbo].[SAS2IDMSchoolEx]    Script Date: 23/09/2022 4:37:45 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAS2IDMSchoolEx]') AND type in (N'U'))
DROP TABLE [dbo].[SAS2IDMSchoolEx]
GO


/****** Object:  Table [dbo].[SAS2IDMSchoolEx]    Script Date: 23/09/2022 4:34:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAS2IDMSchoolEx]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAS2IDMSchoolEx](
	[SchoolID] [varchar](20) NOT NULL,
	[IsPromoted] [bit] NOT NULL,
 CONSTRAINT [PK_SAS2IDMSchoolEx] PRIMARY KEY CLUSTERED 
(
	[SchoolID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'SAS2IDMSchoolEx', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL SAS2IDM School Table Extensions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAS2IDMSchoolEx'
GO

-- Load with data from 

INSERT INTO dbo.SAS2IDMSchoolEx
SELECT [SchoolID],0
FROM dbo.SAS2IDMSchool
WHERE Archived = 'N'
GO
