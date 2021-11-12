SELECT top 20 
   OBJECT_NAME (ips.[object_id]) AS [Object Name],
   si.name AS [Index Name],
   ROUND (ips.avg_fragmentation_in_percent, 2) AS [Fragmentation],
   ips.page_count AS [Pages],
   ROUND (ips.avg_page_space_used_in_percent, 2) AS [Page Density],
   case 
	when ips.avg_page_space_used_in_percent = 0
	then ips.page_count * ROUND (ips.avg_fragmentation_in_percent, 2)/100
	else ips.page_count * ROUND (ips.avg_fragmentation_in_percent, 2) / ROUND (ips.avg_page_space_used_in_percent, 2)
   end  as [Weighting]
FROM sys.dm_db_index_physical_stats (DB_ID ('FIMService'), NULL, NULL, NULL, 'DETAILED') ips
--FROM sys.dm_db_index_physical_stats (DB_ID ('FIMSynchronizationService'), NULL, NULL, NULL, 'DETAILED') ips
--FROM sys.dm_db_index_physical_stats (DB_ID ('Unify.IdentityBroker'), NULL, NULL, NULL, 'DETAILED') ips
CROSS APPLY sys.indexes si
WHERE
   si.object_id = ips.object_id
   AND si.index_id = ips.index_id
   AND ips.index_level = 0
   and si.name is not null
order by case 
	when ips.avg_page_space_used_in_percent = 0
	then ips.page_count * ROUND (ips.avg_fragmentation_in_percent, 2)/100
	else ips.page_count * ROUND (ips.avg_fragmentation_in_percent, 2) / ROUND (ips.avg_page_space_used_in_percent, 2)
   end desc
GO

/*
--IdB stats corrections:
update statistics dbo.Changes with fullscan
update statistics dbo.Entity with fullscan
update statistics dbo.EntityValue with fullscan
*/