select * from dbo.ObjectsByType
where ID in (
'0-G',
'O821900-G',
'Hy-tek Team Manager Lite Swim 6.0',
'O821903',
'SSJGE R House System Coordinator-D',
'SSJGE R Religious Education Coordinator-D',
'SMCCW R Parish Secretary NASS-D',
'Adobe Flash Player Plugin 11.2.202 64bit',
'Adobe Flash Player Plugin 11.2.202 32bit',
'SMCCW R Parish Secretary NASS Member-D',
'2_Free_Time Format_Factory 2.70_1.0',
'SPCSW Teaching Email-D',
'Google Chrome Frame'
)
or sAMAccountName in (
'0-G',
'O821900-G',
'Hy-tek Team Manager Lite Swim 6.0',
'O821903',
'SSJGE R House System Coordinator-D',
'SSJGE R Religious Education Coordinator-D',
'SMCCW R Parish Secretary NASS-D',
'Adobe Flash Player Plugin 11.2.202 64bit',
'Adobe Flash Player Plugin 11.2.202 32bit',
'SMCCW R Parish Secretary NASS Member-D',
'2_Free_Time Format_Factory 2.70_1.0',
'SPCSW Teaching Email-D',
'Google Chrome Frame'
)


/*
select * from dbo.vw_idmObjectsByType
where ID in (
select ID from dbo.vw_idmObjectsByType
group by ID
having count(*) > 1
)


select * 
--delete 
from dbo.ObjectsByType
where ID in (
select ID from dbo.vw_idmObjectsByType
group by ID
having count(*) > 1
)
*/

select * from dbo.vw_idmObjectsByType
where ID in ( '0-G', 'o821903')
or BaseID in ( '0-G', 'o821903')
or sAMAccountName in ( '0-G', 'o821903')

select *
--delete
from dbo.vw_idmObjectsByType
--where BaseID like '0%'
where BaseID like ' %'

select *
--delete
from dbo.ObjectsByType
where ID = 'SSMPT Labora Users-G'

update dbo.ObjectsByType
set ObjectType = 'groupNested'
where ID = 'SSMPT Labora Users-G'

select *
--delete
from dbo.ObjectsByType
where BaseID like ' %'

Update dbo.ObjectsByType
Set BaseID = LTRIM(BaseID)
where BaseID like ' %'

select *
--delete
from dbo.ObjectsByType
where BaseID = '0'-- like '0%'


--CN=SSMPT Labora Users-G,OU=Managed,OU=St Mary's Toukley,OU=Security,OU=Groups,DC=dbb,DC=local


-- The following identifies some 34 groups with leading spaces in the INFO property:

select *
--delete
from dbo.ObjectsByType
--where BaseID like '0%'
where BaseID like ' 0%'


select *
--delete
from dbo.ObjectsByType
where ID in (
'2_Free_Time Format_Factory 2.60_1.0',
'2_PaperCut Client_Inst_From_Server 1.0_SSPCT',
'Adobe Flash Player ActiveX Plugin 11.2.202 32bit',
'Adobe Flash Player ActiveX Plugin 11.2.202 64bit',
'Bear_Solutions_PCOUNTER_2.4',
'Centacare Family Services Coordinator-D',
'Centacare FORESTVILLE ELC Member-D',
'Centacare TERRIGAL ELC Member-D',
'Citrix CCD LabOra-G',
'Citrix SOLGF Starcare Member-D',
'Citrix SOLST Starcare Member-D',
'ClayAnimator StopMotionAnimator 1.1 1.0',
'CSO – Literacy Teacher Leaders',
'CSO – Numeracy Teacher Leaders',
'CSO Director’s Group',
'Google Chrome Framework IE',
'Hy-tek Team Manager Lite 6.0',
'License required 2_Sonar Home_Studio 7.0xl_2.0',
'PFW Distribution List',
'PSU Senior Admin-D',
'SMCCW PACS-D',
'SMCCW R Parish Sectretary NASS Member-D',
'SMCCW R Parish Sectretary NASS-D',
'SMCCW R Parish Staff NASS Emailr-D',
'SMRPA Learning Support Staff Member-D',
'SMRPA Learning Support Staff-D',
'SPCSW Teaching Email -D',
'SSJGE R House System Coordintaor-D',
'SSJGE R Religious Eductaion Coordinator-D',
'SSRCP Citrix Athena Admins-D',
'SSRCP R St Rose Collaroy-D',
'zzz_2_Litcom LaboraWorship 2010_5.6'
)

/*
select *
--delete
from dbo.ObjectsByType
where ID like 'CSO _ Literacy Teacher Leaders'
or ID like 'CSO _ Numeracy Teacher Leaders'
or ID like 'CSO Director_s Group'
*/

select *
--delete
from dbo.vw_idmObjectsByType --ObjectsByType
where ID like '0%'

select *
--delete
from dbo.ObjectsByType --ObjectsByType
where BaseID like '0%'
or ID like '0%'

select * from dbo.MultivalueObjects
where ID like '0%'

