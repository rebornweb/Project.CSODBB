/****** Object:  StoredProcedure [dbo].[ImportAdsXmlFile]    Script Date: 02/14/2008 10:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  DECLARE @AdsXmlFilePath varchar(200);
  DECLARE @SQL varchar(2000);

  SELECT @AdsXmlFilePath = N'F:\Development\CSODBB\AD\Groups.xml';  --Param.AdsXmlFilePath();

  IF OBJECT_ID('tempdb..#AdsXmlFile') IS NOT NULL
    DROP TABLE #AdsXmlFile;

  CREATE TABLE #AdsXmlFile
  ( 
    ix integer,
    sAMAccountName varchar(25),
    info varchar(10),
    cn varchar(100),
    adsCode varchar(10),
    objectClass varchar(25)
  );

  SET @SQL = 

  'DECLARE @AdsFile xml;

   SET @AdsFile = (SELECT * FROM OPENROWSET(BULK ''' 
           + @AdsXmlFilePath
           + ''', SINGLE_BLOB) AS s);
   INSERT #AdsXmlFile (ix, sAMAccountName, info, cn, adsCode, objectClass)
   SELECT Ads.value(''@ix'',''integer''),
          Ads.value(''@sAMAccountName'',''varchar(25)''),
          Ads.value(''@info'',''varchar(10)''),
          Ads.value(''@cn'',''varchar(100)''),
          Ads.value(''@adsCode'',''varchar(10)''),
          Ads.value(''@objectClass'',''varchar(25)'')
   FROM @AdsFile.nodes(''/adObject'') AS AdsTable(Ads);
  ';
  EXEC (@SQL);

select * from #AdsXmlFile;

DROP TABLE #AdsXmlFile;

