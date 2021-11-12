
USE [Unify.IdentityBroker];
EXEC sp_MSforeachtable @command1="print '?'", @command2="UPDATE STATISTICS ? WITH FULLSCAN";
EXEC sp_MSforeachtable @command1="print '?'", @command2="ALTER INDEX ALL ON ? REBUILD WITH (ONLINE=OFF)";
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

USE [FIMSynchronizationService];
EXEC sp_MSforeachtable @command1="print '?'", @command2="UPDATE STATISTICS ? WITH FULLSCAN";
EXEC sp_MSforeachtable @command1="print '?'", @command2="ALTER INDEX ALL ON ? REBUILD WITH (ONLINE=OFF)";
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

USE [FIMService];
EXEC sp_MSforeachtable @command1="print '?'", @command2="UPDATE STATISTICS ? WITH FULLSCAN";
--EXEC sp_MSforeachtable @command1="print '?'", @command2="ALTER INDEX ALL ON ? REBUILD WITH (ONLINE=OFF)", @whereand=' and o.name like ''%RequestOutputString%''  ';
EXEC sp_MSforeachtable @command1="print '?'", @command2="ALTER INDEX ALL ON ? REBUILD WITH (ONLINE=OFF)";
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

