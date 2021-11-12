use [MicrosoftIdentityIntegrationServer]
go

/****** Object:  StoredProcedure [dbo].[unify_ExtractDataFromDropFile]    Script Date: 09/09/2009 15:24:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unify_ExtractDataFromDropFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unify_ExtractDataFromDropFile]
GO

Create Procedure dbo.unify_ExtractDataFromDropFile( @inputDSMLFilePath varchar(1000), @toW7 bit) AS

-- The following script is designed to convert DSML audit files dropped from ILM run profiles into 
-- W7 XML format for consumption as a TCIM event source (@toW7 = 1), or as a raw SQL result set (@toW7 = 0).
-- XML files are saved to the default TEMP folder for the SQL session (e.g. C:\Documents and Settings\Administrator.GBN\Local Settings\Temp\1)
-- SQL Books Online URLs of interest are:
--		FOR XML PATH syntax: ms-help://MS.SQLCC.v9/MS.SQLSVR.v9.en/udb9/html/a685a9ad-3d28-4596-aa72-119202df3976.htm
--		FOR XML syntax: ms-help://MS.SQLCC.v9/MS.SQLSVR.v9.en/udb9/html/52acb3a8-d464-4cdf-8bd0-aae504586513.htm
--
-- Bob Bradley, UNIFY Solutions, 2 Sep 2009

SET NOCOUNT ON 

--Declare @inputDSMLFilePath nvarchar(100), @toW7 bit
--Select @toW7 = 0, @inputDSMLFilePath = N'E:\temp\MISTextExport.xml' -- THIS CAN BE PASSED IN AS A SP VARIABLE

Declare @sql nvarchar(1000)
DECLARE @ParmDefinition nvarchar(500)

Select @sql = N'
SELECT @xmlString = BulkColumn  
FROM OPENROWSET(BULK ''' + @inputDSMLFilePath + ''', SINGLE_NCLOB) AS AD 
'
SET @ParmDefinition = N'@xmlString XML output';

Declare @tblDSML table (
	ChangeID int identity(1,1) NOT NULL, 
	DeltaOp varchar(20) NOT NULL,
	DNAOp varchar(20) NULL,
	DNVOp varchar(20) NULL,
	ObjectDN varchar(1000) NOT NULL, 
	AttrName varchar(100) NOT NULL,
	dn varchar(1000) NULL,
	AttrType varchar(20) NULL, 
	AttrMV varchar(5) NULL,
	AttrValDel varchar(100) NULL,
	AttrValAdd varchar(100) NULL,
	AttrValNew varchar(100) NULL
)

DECLARE @ADXMLData XML

exec sp_executesql @sql, @ParmDefinition, @xmlString=@ADXMLData OUTPUT

--SELECT @ADXMLData = BulkColumn  
--FROM OPENROWSET(BULK @inputDSMLFilePath, SINGLE_NCLOB) AS AD 

DECLARE @docHandle int 
EXEC sp_xml_preparedocument @docHandle OUTPUT, @ADXMLData, '<mmsml xmlns:a="http://www.microsoft.com/mms/mmsml/v2"/>' 

-- reference attribute changes
insert into @tblDSML (
	DeltaOp, DNAOp, DNVOp, ObjectDN, AttrName, dn
)
SELECT *  
FROM OPENXML(@docHandle, N'//a:mmsml/a:directory-entries/a:delta/a:dn-attr/a:dn-value/a:dn',2)  
 With ( 
        DeltaOp varchar(100) '../../../@operation' 
        ,DNAOp varchar(100) '../../@operation' 
        ,DNVOp varchar(100) '../@operation' 
        ,ObjectDN varchar(1000) '../../../@dn' 
        ,AttrName varchar(100) '../../@name' 
        ,dn        varchar(1000) '.' 
) Export 
ORDER BY ObjectDN 

-- non-reference attribute changes - deletes
insert into @tblDSML (
	DeltaOp, DNAOp, ObjectDN, AttrName, AttrType, AttrMV
)
SELECT *  
FROM OPENXML(@docHandle, N'//a:mmsml/a:directory-entries/a:delta/a:attr',2)  
 With ( 
        DeltaOp varchar(100) '../@operation' 
        ,DNAOp varchar(100) '@operation' 
        ,ObjectDN varchar(1000) '../@dn' 
        ,AttrName varchar(100) '@name' 
        ,AttrType varchar(100) '@type' 
        ,AttrMV varchar(100) '@multivalued' 
) Export 
Where DNAOp = 'delete'
ORDER BY ObjectDN 

-- non-reference attribute changes - inserts/updates
insert into @tblDSML (
	DeltaOp, DNAOp, ObjectDN, AttrName, AttrType, AttrMV, AttrValDel, AttrValAdd, AttrValNew
)
SELECT *  
FROM OPENXML(@docHandle, N'//a:mmsml/a:directory-entries/a:delta/a:attr/a:value',2)  
 With ( 
        DeltaOp varchar(100) '../../@operation' 
        ,DNAOp varchar(100) '../@operation' 
        ,ObjectDN varchar(1000) '../../@dn' 
        ,AttrName varchar(100) '../@name' 
        ,AttrType varchar(100) '../@type' 
        ,AttrMV varchar(100) '../@multivalued' 
        ,AttrValDel varchar(1000) '.[@operation=''delete'']' 
        ,AttrValAdd varchar(1000) '.[@operation=''add'']' 
        ,AttrValNew varchar(1000) '.[not(@operation)]' 
) Export 
ORDER BY ObjectDN 

EXEC sp_xml_removedocument @docHandle

IF @toW7 = 1
BEGIN
	select 
		GetDate() As [when], 
		DeltaOp As [what/@verb],
		'row' As [what/@noun], 
		'success' As [what/@success],
		'FILE' As [onwhat/@type], 
		'C:\Program Files\Microsoft Identity Integration Server\MaData\MIS TEXT EXPORT MA\' As [onwhat/@path], 
		'MISExport.csv' As [onwhat/@name], 
		'MIIS-SVC' as [who/@logonname],
		'MIIS Service Account' as [who/@realname],
		'Microsoft Windows' as [where/@type],
		host_name() as [where/@name],
		'FILE' as [whereto/@type],
		'MISExport.csv' as [whereto/@name],
		'SQL DB' as [wherefrom/@type],
		db_name() as [wherefrom/@name],
		ChangeID as [info/ChangeID],
		DeltaOp as [info/DeltaOp],
		DNAOp as [info/DNAOp],
		DNVOp as [info/DNVOp],
		ObjectDN as [info/ObjectDN],
		AttrName as [info/AttrName],
		dn as [info/dn],
		AttrType as [info/AttrType],
		AttrMV as [info/AttrMV],
		AttrValDel as [info/AttrValDel],
		IsNull(AttrValNew,AttrValAdd) as [info/AttrValAdd]

	--	ChangeID int identity(1,1) NOT NULL, 
	--	DeltaOp varchar(20) NOT NULL,
	--	DNAOp varchar(20) NULL,
	--	DNVOp varchar(20) NULL,
	--	ObjectDN varchar(100) NOT NULL, 
	--	AttrName varchar(100) NOT NULL,
	--	dn varchar(100) NULL,
	--	AttrType varchar(20) NOT NULL, 
	--	AttrMV varchar(5) NOT NULL,
	--	AttrValDel varchar(100) NULL,
	--	AttrValAdd varchar(100) NULL,
	--	AttrValNew varchar(100) NULL

	from @tblDSML
	for xml path ('event'), root ('sample')
END
ELSE
BEGIN
	Select * from @tblDSML
END
GO

exec dbo.unify_ExtractDataFromDropFile 'C:\Program Files\Microsoft Identity Integration Server\MaData\DBB\ExportChanges.xml', 0
GO
