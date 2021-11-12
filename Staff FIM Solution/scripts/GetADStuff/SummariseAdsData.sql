/****** Object:  StoredProcedure [dbo].[ImportAdsXmlFile]    Script Date: 02/14/2008 10:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  DECLARE @AdsXmlFilePath varchar(200);
  DECLARE @SQL varchar(2000);

  SELECT @AdsXmlFilePath = N'C:\Users\bob.bradley.tst\Documents\Visual Studio 2008\Projects\GetADStuff\Groups.xml';  --Param.AdsXmlFilePath();

  IF OBJECT_ID('tempdb..#AdsXmlFile') IS NOT NULL
    DROP TABLE #AdsXmlFile;

  CREATE TABLE #AdsXmlFile
  ( 
    ix integer primary key,
    sAMAccountName varchar(25),
    info varchar(10),
    cn varchar(100),
    distinguishedName varchar(500),
    adsCode varchar(10),
    [description] varchar(500),
    objectClass varchar(25)
  );

  SET @SQL = 

  'DECLARE @AdsFile xml;

   SET @AdsFile = (SELECT * FROM OPENROWSET(BULK ''' 
           + @AdsXmlFilePath
           + ''', SINGLE_BLOB) AS s);
   INSERT #AdsXmlFile (ix, sAMAccountName, info, cn, distinguishedName, adsCode, description, objectClass)
   SELECT Ads.value(''@ix'',''integer''),
          Ads.value(''@sAMAccountName'',''varchar(25)''),
          Ads.value(''@info'',''varchar(10)''),
          Ads.value(''@cn'',''varchar(100)''),
          Ads.value(''@distinguishedName'',''varchar(500)''),
          Ads.value(''@adsCode'',''varchar(10)''),
          Ads.value(''@description'',''varchar(10)''),
          Ads.value(''@objectClass'',''varchar(25)'')
   FROM @AdsFile.nodes(''/adObjects/adObject'') AS AdsTable(Ads);
  ';
  EXEC (@SQL);

/*
select * 
from #AdsXmlFile a1
where a1.adsCode not like 'O4%'
and a1.cn like 'Centacare%'

select * 
from #AdsXmlFile a1
where a1.adsCode like 'O011230%'
or a1.cn in ('SSPGE Yr 2-D','SSPGE Year 2 Member-D')
*/


select * 
from #AdsXmlFile a1
where a1.objectClass+':'+a1.adsCode in (
	select objectClass+':'+adsCode
	from #AdsXmlFile a2
	where adsCode is not null
	group by objectClass+':'+adsCode
	having COUNT(*) > 1
)
order by objectClass,adsCode
;

DROP TABLE #AdsXmlFile;




-- Configured for delegated admin