USE TempDB
 GO
 EXEC sp_helpfile
 GO
/* 
Results will be something like:
 name fileid filename filegroup size
 ——- —— ————————————————————– ———- ——-
 tempdev 1 C:Program FilesMicrosoft SQL ServerMSSQLdatatempdb.mdf PRIMARY 16000 KB
 templog 2 C:Program FilesMicrosoft SQL ServerMSSQLdatatemplog.ldf NULL 1024 KB
 along with other information related to the database. The names of the files are usually tempdev and demplog by default. These names will be used in next statement. Run following code, to move mdf and ldf files.
 */
 USE master
 GO
 ALTER DATABASE TempDB MODIFY FILE
 (NAME = tempdev, FILENAME = 'E:\SQL.Data\tempdb.mdf')
 GO
 ALTER DATABASE TempDB MODIFY FILE
 (NAME = templog, FILENAME = 'F:\SQL.Logs\templog.ldf')
 GO
 