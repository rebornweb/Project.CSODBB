/*
	This script is designed to be executed by the script InstallAllScript.sql run in SQLCMD mode so as to deploy to all 44 school SAS databases.
	This script will
	1. delete any existing role / member user for the target database matching db_SAS2IDM_SSIS / DBB\svcSSIS
	2. drop any existing user DBB\svcSSIS
	3. create the role db_SAS2IDM_SSIS (and targeted 3 securables)
	4. create the user DBB\svcSSIS
	5. add the user to the [db_datareader] and [db_SAS2IDM_SSIS] roles

	UNIFYSOLUTIONS\Bob Bradley
	22/10/2021
*/
ALTER ROLE [db_datareader] DROP MEMBER [DBB\svcSSIS];
ALTER ROLE [db_datareader] DROP MEMBER [DBB\svcFIM_EBroker];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'db_SAS2IDM_SSIS' AND type = 'R')
BEGIN
	IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DBB\svcSSIS')
	BEGIN
		ALTER ROLE [db_SAS2IDM_SSIS] DROP MEMBER [DBB\svcSSIS]
		ALTER ROLE [db_SAS2IDM_SSIS] DROP MEMBER [DBB\svcFIM_EBroker]
	END
	REVOKE EXECUTE ON [dbo].[procSAS2IDM_StudentDioces_TOTUpdate] TO [db_SAS2IDM_SSIS] AS [dbo];
	REVOKE UPDATE ON [dbo].[SAS2IDMStudentDioces] TO [db_SAS2IDM_SSIS] AS [dbo];
	REVOKE EXECUTE ON [dbo].[procSAS2IDM_StudentDioces_Update] TO [db_SAS2IDM_SSIS] AS [dbo];
	REVOKE EXECUTE ON [dbo].[BitToYN] TO [db_SAS2IDM_SSIS]
	DROP ROLE [db_SAS2IDM_SSIS];
END
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DBB\svcSSIS')
BEGIN
	DROP USER [DBB\svcSSIS];
END
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DBB\svcFIM_EBroker')
BEGIN
	DROP USER [DBB\svcFIM_EBroker];
END
CREATE ROLE [db_SAS2IDM_SSIS];
GRANT EXECUTE ON [dbo].[procSAS2IDM_StudentDioces_TOTUpdate] TO [db_SAS2IDM_SSIS] AS [dbo];
GRANT UPDATE ON [dbo].[SAS2IDMStudentDioces] TO [db_SAS2IDM_SSIS] AS [dbo];
GRANT EXECUTE ON [dbo].[procSAS2IDM_StudentDioces_Update] TO [db_SAS2IDM_SSIS] AS [dbo];
GRANT EXECUTE ON [dbo].[BitToYN] TO [db_SAS2IDM_SSIS]
CREATE USER [DBB\svcSSIS] FOR LOGIN [DBB\svcSSIS];
CREATE USER [DBB\svcFIM_EBroker] FOR LOGIN [DBB\svcFIM_EBroker];
ALTER ROLE [db_datareader] ADD MEMBER [DBB\svcSSIS];
ALTER ROLE [db_datareader] ADD MEMBER [DBB\svcFIM_EBroker];
ALTER ROLE [db_SAS2IDM_SSIS] ADD MEMBER [DBB\svcSSIS];
ALTER ROLE [db_SAS2IDM_SSIS] ADD MEMBER [DBB\svcFIM_EBroker];

