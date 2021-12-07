USE [FIMSynchronizationService]
GO

/****** Object:  View [dbo].[AllMIMStudents]    Script Date: 7/12/2021 4:48:36 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AllMIMStudents]'))
DROP VIEW [dbo].[AllMIMStudents]
GO

/****** Object:  View [dbo].[AllMIMStudents]    Script Date: 7/12/2021 3:57:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AllMIMStudents] AS 
SELECT [accountName]
      ,[class]
      ,[csoCeIder]
      ,[displayName]
      ,[DOB]
      ,[EmployeeNumber]
      ,[firstName]
      ,[lastName]
      ,[mailSuffix]
      ,[physicalDeliveryOfficeName]
      ,[SchoolCode]
      ,LEFT(LTRIM(RTRIM([SchoolID])),10) AS [SchoolID]
      ,[sex]
      ,[StudentID]
      ,[USIN]
      ,[Year]
  FROM [FIMSynchronizationService].[dbo].[mms_metaverse] with (nolock)
  WHERE object_type = 'person'
  AND SAS2IDMConnector = 1
  AND StudentID IS NOT NULL
  AND SchoolID IS NOT NULL
GO


