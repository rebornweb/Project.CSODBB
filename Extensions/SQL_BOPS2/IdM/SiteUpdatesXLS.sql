USE [master]
GO
/****** Object:  LinkedServer [.]    Script Date: 04/17/2009 14:19:06 ******/
EXEC master.dbo.sp_dropserver @server=N'ExcelSource', @droplogins='droplogins'
GO
--sp_addlinkedserver @server='occcp-as021', 
--	@srvproduct='Jet 4.0', 
--	@provider='Microsoft.Jet.OLEDB.4.0', 
--	@datasrc='D:\ILM\DEPLOY_UAT2\015_SQL\IDM\ILMSites4Prod.xls', 
--	@provstr='Excel 5.0'
--GO

EXEC sp_addlinkedserver 'ExcelSource',
   'Jet 4.0',
   'Microsoft.Jet.OLEDB.4.0',
   'C:\ILM2007\Extensions\SQL_BOPS2\IdM\ILMSites4Prod_with_profilePathloc.xls', -- ILMSites4Prod.xls
   NULL,
   'Excel 5.0'
GO

--Select * Into [IdM].dbo.SiteBackup From [IdM].dbo.Site
go

Truncate Table [IdM].dbo.Site
GO

Insert Into [IdM].dbo.Site (
	[SiteID]
	,[SiteName]
	,[physicalDeliveryOfficeName]
	,[forwarderContainer]
	,[IsSchool]
	,[IsActive]
	,[IsMOE]
	,[ProfilePathLoc]
)
Select IsNull(Cast([SiteID] As varchar),[physicalDeliveryOfficeName]) As [SiteID]
      ,[SiteName]
      ,[physicalDeliveryOfficeName]
      ,case When [forwarderContainer] = 'NULL' Then Null Else [forwarderContainer] End As [forwarderContainer] 
      ,[IsSchool]
      ,[IsActive]
      ,[IsMOE]
	  ,[ProfilePathLoc]
  FROM [ExcelSource]...['Modified Site Locations Table F$']

GO
--EXEC master.dbo.sp_dropserver @server=N'ExcelSource', @droplogins='droplogins'
GO
