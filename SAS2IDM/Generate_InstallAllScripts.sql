-- see https://stackoverflow.com/questions/39336171/executing-sql-query-on-multiple-databases
-- see https://stackoverflow.com/questions/482885/how-do-i-drop-a-foreign-key-constraint-only-if-it-exists-in-sql-server
DECLARE @rn INT = 1, @dbname varchar(MAX) = '';
DECLARE @sql nvarchar(MAX) = '';

WHILE @dbname IS NOT NULL 
BEGIN
    SET @dbname = (SELECT name FROM (SELECT name, ROW_NUMBER() OVER (ORDER BY name) rn 
        FROM sys.databases WHERE name NOT IN('master','tempdb')) t WHERE rn = @rn);

    IF (@dbname <> '') AND (@dbname IS NOT NULL) AND (@dbname LIKE '%SAS2000_LIVE_%') 
	BEGIN
		SET @sql = @sql + 'USE ['+@dbname+'];
GO
:r C:\scripts\SAS2IDM.Fix\Uninstall.sql
GO
'
        --PRINT (@sql);
        --EXECUTE (@sql);
	END
	SET @rn = @rn + 1;
END;

PRINT (@sql);
