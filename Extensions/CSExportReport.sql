SET NOCOUNT ON

DECLARE @ADXML TABLE (ADID int identity (1,1), XMLFROMCS XML)

INSERT @ADXML (XMLFROMCS)
SELECT * 
FROM OPENROWSET(BULK 
--'C:\FuzzyLogic\ADExport\ADExport.xml'
'C:\Program Files\Microsoft Identity Integration Server\MaData\DBB Group\manualExportWithPendingImports.xml'
,SINGLE_BLOB) AS AD


 


DECLARE @ADXMLData XML


 


SELECT @ADXMLData = XMLFROMCS


FROM @ADXML


 


DECLARE @docHandle int


EXEC sp_xml_preparedocument @docHandle OUTPUT, @ADXMLData


 


TRUNCATE TABLE dbo.adUsers 


 


INSERT dbo.adUsers (dn, [cn],[department],[displayname],[employeeid],[givenname],[mail],[sn],[title])


 
/*
cn
displayName
groupType
info
mail
mailNickname
name
objectGUID
objectSid
sAMAccountName
member
*/

SELECT dn, [cn],[department],[displayname],[employeeid],[givenname],[mail],[sn],[title]


FROM


    (


            SELECT dn, attrname, attrvalue  


            FROM OPENXML(@docHandle, N'/cs-objects/cs-object/pending-import-hologram/entry/attr/value',2)  


             WITH 


                (dn nvarchar(450) '../../@dn'


                ,primaryobjectclass nvarchar(450) '../../primary-objectclass'


                ,attrname nvarchar(450) '../@name'


                ,attrvalue nvarchar(450) '.'


                ,multivalued nvarchar(450) '../@multivalued'


                ) adusers


            WHERE adusers.primaryobjectclass = 'user' AND adusers.multivalued = 'false'


                AND attrname in ('cn','department','displayname', 'employeeid', 'givenName', 'mail', 'sn','title') 


        ) AS ADList1


        


    PIVOT (MIN(attrvalue) FOR attrname in ([cn],[department],[displayname],[employeeid],[givenname],[mail],[sn],[title])


 )AS ADUserPivot


 


EXEC sp_xml_removedocument @docHandle 
