declare @tblSiteUpdates Table ( physicalDeliveryOfficeName char(5) NOT NULL, SiteName varchar(100) NOT NULL )
Insert Into @tblSiteUpdates
Select * from (
	Select 'SCCSI' As [physicalDeliveryOfficeName], 'Corpus Christi Catholic School (St Ives)' As [SiteName] Union All 
	Select 'SHCPK' As [physicalDeliveryOfficeName], 'Holy Cross Catholic School (Kincumber)' As [SiteName] Union All 
	Select 'SHFPL' As [physicalDeliveryOfficeName], 'Holy Family Catholic School (Lindfield)' As [SiteName] Union All 
	Select 'SMCCC' As [physicalDeliveryOfficeName], 'Mercy Catholic College (Chatswood)' As [SiteName] Union All 
	Select 'SMCCW' As [physicalDeliveryOfficeName], 'MacKillop Catholic College (Warnervale)' As [SiteName] Union All 
	Select 'SMMCW' As [physicalDeliveryOfficeName], 'Mater Maria Catholic College (Warriewood)' As [SiteName] Union All 
	Select 'SMRPA' As [physicalDeliveryOfficeName], 'Maria Regina Catholic School (Avalon)' As [SiteName] Union All 
	Select 'SOLDC' As [physicalDeliveryOfficeName], 'Our Lady of Dolours Catholic School (Chatswood)' As [SiteName] Union All 
	Select 'SOLGF' As [physicalDeliveryOfficeName], 'Our Lady of Good Counsel Catholic School (Forestville)' As [SiteName] Union All 
	Select 'SOLHE' As [physicalDeliveryOfficeName], 'Our Lady Help of Christians Catholic School (Epping)' As [SiteName] Union All 
	Select 'SOLPW' As [physicalDeliveryOfficeName], 'Our Lady of Perpetual Succour Catholic School (West Pymble)' As [SiteName] Union All 
	Select 'SOLRE' As [physicalDeliveryOfficeName], 'Our Lady of the Rosary Catholic School (Shelly Beach)' As [SiteName] Union All 
	Select 'SOLST' As [physicalDeliveryOfficeName], 'Our Lady Star of the Sea Catholic School (Terrigal)' As [SiteName] Union All 
	Select 'SOLWA' As [physicalDeliveryOfficeName], 'Our Lady of the Rosary Catholic School (Waitara)' As [SiteName] Union All 
	Select 'SOLWY' As [physicalDeliveryOfficeName], 'Our Lady of the Rosary Catholic School (Wyoming)' As [SiteName] Union All 
	Select 'SPCSW' As [physicalDeliveryOfficeName], 'Prouille Catholic School (Wahroonga)' As [SiteName] Union All 
	Select 'SSAPH' As [physicalDeliveryOfficeName], 'St Agatha''s Catholic School (Pennant Hills)' As [SiteName] Union All 
	Select 'SSBBH' As [physicalDeliveryOfficeName], 'St Bernard''s Catholic School (Berowra Heights)' As [SiteName] Union All 
	Select 'SSBLM' As [physicalDeliveryOfficeName], 'St Brendan''s Catholic School (Lake Munmorah)' As [SiteName] Union All 
	Select 'SSCPB' As [physicalDeliveryOfficeName], 'St Cecilia''s Catholic School (Balgowlah)' As [SiteName] Union All 
	Select 'SSCPW' As [physicalDeliveryOfficeName], 'St Cecilia''s Catholic School (Wyong)' As [SiteName] Union All 
	Select 'SSGPC' As [physicalDeliveryOfficeName], 'St Gerard''s Catholic School (Carlingford)' As [SiteName] Union All 
	Select 'SSHMV' As [physicalDeliveryOfficeName], 'Sacred Heart Catholic School (Mona Vale)' As [SiteName] Union All 
	Select 'SSHPP' As [physicalDeliveryOfficeName], 'Sacred Heart Catholic School (Pymble)' As [SiteName] Union All 
	Select 'SSJAN' As [physicalDeliveryOfficeName], 'St John''s Catholic School (Narraweena)' As [SiteName] Union All 
	Select 'SSJBH' As [physicalDeliveryOfficeName], 'St John the Baptist Catholic School (Harbord)' As [SiteName] Union All 
	Select 'SSJGE' As [physicalDeliveryOfficeName], 'St Joseph''s Catholic College (East Gosford)' As [SiteName] Union All 
	Select 'SSJPN' As [physicalDeliveryOfficeName], 'St Joseph''s Catholic School (Narrabeen)' As [SiteName] Union All 
	Select 'SSJTU' As [physicalDeliveryOfficeName], 'St John Fisher Catholic School (Tumbi Umbi)' As [SiteName] Union All 
	Select 'SSJWW' As [physicalDeliveryOfficeName], 'St John the Baptist Catholic School (Woy Woy South)' As [SiteName] Union All 
	Select 'SSKDW' As [physicalDeliveryOfficeName], 'St Kevin''s Catholic School (Dee Why)' As [SiteName] Union All 
	Select 'SSKMV' As [physicalDeliveryOfficeName], 'St Kieran''s Catholic School (Manly Vale)' As [SiteName] Union All 
	Select 'SSLCW' As [physicalDeliveryOfficeName], 'St Leo''s Catholic College (Wahroonga)' As [SiteName] Union All 
	Select 'SSMPD' As [physicalDeliveryOfficeName], 'St Martin''s Catholic School Davidson (Davidson)' As [SiteName] Union All 
	Select 'SSMPM' As [physicalDeliveryOfficeName], 'St Mary''s Catholic School (Manly)' As [SiteName] Union All 
	Select 'SSMPT' As [physicalDeliveryOfficeName], 'St Mary''s Catholic School (Toukley)' As [SiteName] Union All 
	Select 'SSPCM' As [physicalDeliveryOfficeName], 'St Paul''s Catholic College (Manly)' As [SiteName] Union All 
	Select 'SSPCT' As [physicalDeliveryOfficeName], 'St Peter''s Catholic College (Tuggerah)' As [SiteName] Union All 
	Select 'SSPGE' As [physicalDeliveryOfficeName], 'St Patrick''s Catholic School (East Gosford)' As [SiteName] Union All 
	Select 'SSPNN' As [physicalDeliveryOfficeName], 'St Philip Neri Catholic School (Northbridge)' As [SiteName] Union All 
	Select 'SSPPA' As [physicalDeliveryOfficeName], 'St Patrick''s Catholic School (Asquith)' As [SiteName] Union All 
	Select 'SSRCP' As [physicalDeliveryOfficeName], 'St Rose Catholic School (Collaroy Plateau)' As [SiteName] Union All 
	Select 'SSTPW' As [physicalDeliveryOfficeName], 'St Thomas'' Catholic School (Willoughby)' As [SiteName] Union All 
	Select 'PARCA' As [physicalDeliveryOfficeName], 'ARCADIA Parish' As [SiteName] Union All 
	Select 'PODCH' As [physicalDeliveryOfficeName], 'CHATSWOOD Parish' As [SiteName] Union All 
	Select 'PSKDW' As [physicalDeliveryOfficeName], 'DEE WHY Parish' As [SiteName] Union All 
	Select 'PEPPI' As [physicalDeliveryOfficeName], 'EPPING and CARLINGFORD Parish' As [SiteName] Union All 
	Select 'PFREN' As [physicalDeliveryOfficeName], 'FRENCHS FOREST Parish' As [SiteName] Union All 
	Select 'PSJBH' As [physicalDeliveryOfficeName], 'Freshwater Parish (Harbord)' As [SiteName] Union All 
	Select 'PSMPM' As [physicalDeliveryOfficeName], 'Freshwater Parish (Manly)' As [SiteName] Union All 
	Select 'PGOSF' As [physicalDeliveryOfficeName], 'GOSFORD Parish' As [SiteName] Union All 
	Select 'PKILL' As [physicalDeliveryOfficeName], 'KILLARA Parish' As [SiteName] Union All 
	Select 'PKINC' As [physicalDeliveryOfficeName], 'KINCUMBER Parish' As [SiteName] Union All 
	Select 'PKURI' As [physicalDeliveryOfficeName], 'KU-RING-GAI CHASE Parish' As [SiteName] Union All 
	Select 'PLAKE' As [physicalDeliveryOfficeName], 'THE LAKES Parish' As [SiteName] Union All 
	Select 'PLIND' As [physicalDeliveryOfficeName], 'LINDFIELD Parish' As [SiteName] Union All 
	Select 'PNARE' As [physicalDeliveryOfficeName], 'NAREMBURN Parish' As [SiteName] Union All 
	Select 'PNARR' As [physicalDeliveryOfficeName], 'NARRAWEENA Parish' As [SiteName] Union All 
	Select 'PNORM' As [physicalDeliveryOfficeName], 'NORMANHURST Parish' As [SiteName] Union All 
	Select 'PNORT' As [physicalDeliveryOfficeName], 'NORTHBRIDGE Parish' As [SiteName] Union All 
	Select 'PNHAR' As [physicalDeliveryOfficeName], 'NORTH HARBOUR Parish' As [SiteName] Union All 
	Select 'PPENN' As [physicalDeliveryOfficeName], 'PENNANT HILLS Parish' As [SiteName] Union All 
	Select 'PPITT' As [physicalDeliveryOfficeName], 'PITTWATER Parish' As [SiteName] Union All 
	Select 'PPYMB' As [physicalDeliveryOfficeName], 'PYMBLE Parish' As [SiteName] Union All 
	Select 'PSTIV' As [physicalDeliveryOfficeName], 'ST IVES Parish' As [SiteName] Union All 
	Select 'PTHIL' As [physicalDeliveryOfficeName], 'TERRY HILLS Parish' As [SiteName] Union All 
	Select 'PTERR' As [physicalDeliveryOfficeName], 'TERRIGAL Parish' As [SiteName] Union All 
	Select 'PENTR' As [physicalDeliveryOfficeName], 'THE ENTRANCE Parish' As [SiteName] Union All 
	Select 'PTOUK' As [physicalDeliveryOfficeName], 'TOUKLEY Parish' As [SiteName] Union All 
	Select 'PWAHR' As [physicalDeliveryOfficeName], 'WAHROONGA Parish' As [SiteName] Union All 
	Select 'PWAIT' As [physicalDeliveryOfficeName], 'WAITARA Parish' As [SiteName] Union All 
	Select 'PWARN' As [physicalDeliveryOfficeName], 'WARNERVALE Parish' As [SiteName] Union All 
	Select 'PWILL' As [physicalDeliveryOfficeName], 'WILLOUGHBY Parish' As [SiteName] Union All 
	Select 'PWWOY' As [physicalDeliveryOfficeName], 'WOY WOY Parish' As [SiteName] Union All 
	Select 'PWYOM' As [physicalDeliveryOfficeName], 'WYOMING Parish' As [SiteName] Union All 
	Select 'PWYON' As [physicalDeliveryOfficeName], 'WYONG and TUMBI UMBI Parish' As [SiteName] Union All 
	Select 'OCCCP' As [physicalDeliveryOfficeName], 'Caroline Chisholm Centre' As [SiteName] Union All 
	Select 'OCHRS' As [physicalDeliveryOfficeName], 'Challenge Ranch' As [SiteName] Union All 
	Select 'OSFAS' As [physicalDeliveryOfficeName], 'St Francis of Assisi Centre' As [SiteName] Union All 
	Select 'OCBRK' As [physicalDeliveryOfficeName], 'Centacare Brookvale' As [SiteName] Union All 
	Select 'OCENT' As [physicalDeliveryOfficeName], 'Centacare The Entrance' As [SiteName] Union All 
	Select 'OCGOS' As [physicalDeliveryOfficeName], 'Centacare Gosford' As [SiteName] Union All 
	Select 'OCKAN' As [physicalDeliveryOfficeName], 'Centacare OOHC Kangy Angy' As [SiteName] Union All 
	Select 'OCNAR' As [physicalDeliveryOfficeName], 'Centacare Naremburn' As [SiteName] Union All 
	Select 'OCNMH' As [physicalDeliveryOfficeName], 'Centacare OOHC Thanbarra' As [SiteName] Union All 
	Select 'OCPHB' As [physicalDeliveryOfficeName], 'Centacare OOHC Sherbrook' As [SiteName] Union All 
	Select 'OCPHO' As [physicalDeliveryOfficeName], 'Centacare OOHC Grainger' As [SiteName] Union All 
	Select 'OCPYM' As [physicalDeliveryOfficeName], 'Centacare Boohna' As [SiteName] Union All 
	Select 'OCW08' As [physicalDeliveryOfficeName], 'Centacare Waitara Northern Sydney Day Service' As [SiteName] Union All 
	Select 'OCW17' As [physicalDeliveryOfficeName], 'Centacare Waitara Community Access Service' As [SiteName] Union All 
	Select 'OCW24' As [physicalDeliveryOfficeName], 'Centacare Waitara OOHC Office' As [SiteName] Union All 
	Select 'OCW26' As [physicalDeliveryOfficeName], 'Centacare Waitara Illoura' As [SiteName] Union All 
	Select 'OCWAI' As [physicalDeliveryOfficeName], 'Centacare Waitara HO' As [SiteName] Union All 
	Select 'OCWMC' As [physicalDeliveryOfficeName], 'Centacare Waitara Children''s Centre' As [SiteName] Union All 
	Select 'OCCCW' As [physicalDeliveryOfficeName], 'Centacare Wyong' As [SiteName] Union All 
	Select 'OCPEG' As [physicalDeliveryOfficeName], 'PSU East Gosford' As [SiteName] Union All 
	Select 'OCPEN' As [physicalDeliveryOfficeName], 'PSU Entrance' As [SiteName] Union All 
	Select 'OCPMV' As [physicalDeliveryOfficeName], 'PSU Manly Vale' As [SiteName] Union All 
	Select 'OWRRA' As [physicalDeliveryOfficeName], 'Bethany Centre (Warrawee)' As [SiteName] 
) X

insert into dbo.Site ([SiteID], [SiteName], [physicalDeliveryOfficeName])
Select [physicalDeliveryOfficeName], [SiteName], [physicalDeliveryOfficeName] 
From @tblSiteUpdates
Where [physicalDeliveryOfficeName] Not in (
	Select [physicalDeliveryOfficeName] From dbo.Site
)

update dbo.Site
Set [SiteName] = updates.[SiteName]
From @tblSiteUpdates [updates]
Where Site.[physicalDeliveryOfficeName] = updates.[physicalDeliveryOfficeName] 
And [updates].[SiteName] <> Site.[SiteName]

/*
select * from dbo.Site
order by [SiteName], [physicalDeliveryOfficeName]

select [SiteName]
from dbo.Site
group by [SiteName]
having count(*) > 1
*/