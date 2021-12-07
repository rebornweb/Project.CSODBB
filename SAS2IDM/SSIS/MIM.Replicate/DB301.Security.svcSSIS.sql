USE [master]
GO

/****** Object:  Login [DBB\svcSSIS]    Script Date: 7/12/2021 4:28:39 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'DBB\svcSSIS')
CREATE LOGIN [DBB\svcSSIS] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO


USE [FIMSynchronizationService]
GO

/****** Object:  User [DBB\svcSSIS]    Script Date: 7/12/2021 4:36:42 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DBB\svcSSIS')
CREATE USER [DBB\svcSSIS] FOR LOGIN [DBB\svcSSIS] WITH DEFAULT_SCHEMA=[dbo]
GO


