-->> BEGIN SITE CONFIG

USE [master]
GO
/****** Object:  Database [IdM]    Script Date: 03/02/2009 23:12:19 ******/
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'IdM')
DROP DATABASE [IdM]
GO

/****** Object:  Database [IdM]    Script Date: 03/02/2009 23:12:30 ******/
CREATE DATABASE [IdM] ON  PRIMARY 
( NAME = N'IdM', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\IdM.mdf' , SIZE = 10240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'IdM_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\IdM_log.ldf' , SIZE = 7424KB , MAXSIZE = 2048GB , FILEGROWTH = 20%)
GO
EXEC dbo.sp_dbcmptlevel @dbname=N'IdM', @new_cmptlevel=90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [IdM].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [IdM] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [IdM] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [IdM] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [IdM] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [IdM] SET ARITHABORT OFF 
GO
ALTER DATABASE [IdM] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [IdM] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [IdM] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [IdM] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [IdM] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [IdM] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [IdM] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [IdM] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [IdM] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [IdM] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [IdM] SET  ENABLE_BROKER 
GO
ALTER DATABASE [IdM] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [IdM] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [IdM] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [IdM] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [IdM] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [IdM] SET  READ_WRITE 
GO
ALTER DATABASE [IdM] SET RECOVERY FULL 
GO
ALTER DATABASE [IdM] SET  MULTI_USER 
GO
ALTER DATABASE [IdM] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [IdM] SET DB_CHAINING OFF 
GO

USE [IdM]
GO
/****** Object:  Table [dbo].[Site]    Script Date: 12/24/2008 14:57:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Site]') AND type in (N'U'))
DROP TABLE [dbo].[Site]
GO

/****** Object:  Table [dbo].[Site]    Script Date: 12/24/2008 14:56:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Site](
	[SiteID] [char](5) NOT NULL,
	[SiteName] [varchar](100) NULL,
	[physicalDeliveryOfficeName] [char](5) NOT NULL,
	[forwarderContainer] [varchar](200) NULL, 
	[IsSchool] [bit] NOT NULL CONSTRAINT [DF__Site__IsSchool]  DEFAULT ((1)),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Site__IsActive]  DEFAULT ((1)),
	[IsMOE] [bit] NOT NULL CONSTRAINT [DF__Site__IsMOE]  DEFAULT ((0)),
	[ProfilePathLoc] [char](5) NULL,
 CONSTRAINT [PK_Site] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

Insert Into Site ( SiteID, physicalDeliveryOfficeName )
	Select '00001' As [SiteID], 'OCCCP' As [physicalDeliveryOfficeName] Union All
	Select '01359', 'SCCSI' Union All
	Select '05002', 'SHCPK' Union All
	Select '01396', 'SHFPL' Union All
	Select '01332', 'SMCCC' Union All
	Select '05006', 'SMCCW' Union All
	Select '01450', 'SMMCW' Union All
	Select '01424', 'SMRPA' Union All
	Select '01480', 'SOLDC' Union All
	Select '01484', 'SOLGF' Union All
	Select '01476', 'SOLHE' Union All
	Select '01501', 'SOLPW' Union All
	Select '01509', 'SOLRE' Union All
	Select '02346', 'SOLST' Union All
	Select '01510', 'SOLWA' Union All
	Select '02348', 'SOLWY' Union All
	Select '01529', 'SPCSW' Union All
	Select '01556', 'SSAPH' Union All
	Select '01593', 'SSBBH' Union All
	Select '05001', 'SSBLM' Union All
	Select '01616', 'SSCPB' Union All
	Select '01617', 'SSCPW' Union All
	Select '01658', 'SSGPC' Union All
	Select '01548', 'SSHMV' Union All
	Select '01460', 'SSHPP' Union All
	Select '01688', 'SSJAN' Union All
	Select '01691', 'SSJBH' Union All
	Select '01714', 'SSJGE' Union All
	Select '01727', 'SSJPN' Union All
	Select '05978', 'SSJTU' Union All
	Select '01692', 'SSJWW' Union All
	Select '01805', 'SSKDW' Union All
	Select '01807', 'SSKMV' Union All
	Select '01813', 'SSLCW' Union All
	Select '02347', 'SSMPD' Union All
	Select '01858', 'SSMPM' Union All
	Select '02220', 'SSMPT' Union All
	Select '01351', 'SSPCM' Union All
	Select '05005', 'SSPCT' Union All
	Select '01905', 'SSPGE' Union All
	Select '01621', 'SSPNN' Union All
	Select '01903', 'SSPPA' Union All
	Select '02117', 'SSRCP' Union All
	Select '01983', 'SSTPW'

GO

Update [dbo].[Site] Set SiteName='Corpus Christi Catholic School (St Ives)'					   where physicalDeliveryOfficeName='SCCSI'; 
Update [dbo].[Site] Set SiteName='Holy Cross Catholic School (Kincumber)'                      where physicalDeliveryOfficeName='SHCPK' ;
Update [dbo].[Site] Set SiteName='Holy Family Catholic School (Lindfield)'                     where physicalDeliveryOfficeName='SHFPL' ;
Update [dbo].[Site] Set SiteName='Mercy Catholic College (Chatswood)'                          where physicalDeliveryOfficeName='SMCCC' ;
Update [dbo].[Site] Set SiteName='MacKillop Catholic College (Warnervale)'                     where physicalDeliveryOfficeName='SMCCW' ;
Update [dbo].[Site] Set SiteName='Mater Maria Catholic College (Warriewood)'                   where physicalDeliveryOfficeName='SMMCW' ;
Update [dbo].[Site] Set SiteName='Maria Regina Catholic School (Avalon)'                       where physicalDeliveryOfficeName='SMRPA' ;
Update [dbo].[Site] Set SiteName='Our Lady of Dolours Catholic School (Chatswood)'             where physicalDeliveryOfficeName='SOLDC' ;
Update [dbo].[Site] Set SiteName='Our Lady of Good Counsel Catholic School (Forestville)'      where physicalDeliveryOfficeName='SOLGF' ;
Update [dbo].[Site] Set SiteName='Our Lady Help of Christians Catholic School (Epping)'        where physicalDeliveryOfficeName='SOLHE' ;
Update [dbo].[Site] Set SiteName='Our Lady of Perpetual Succour Catholic School (West Pymble)' where physicalDeliveryOfficeName='SOLPW' ;
Update [dbo].[Site] Set SiteName='Our Lady of the Rosary Catholic School (Shelly Beach)'       where physicalDeliveryOfficeName='SOLRE' ;
Update [dbo].[Site] Set SiteName='Our Lady Star of the Sea Catholic School (Terrigal)'         where physicalDeliveryOfficeName='SOLST' ;
Update [dbo].[Site] Set SiteName='Our Lady of the Rosary Catholic School (Waitara)'            where physicalDeliveryOfficeName='SOLWA' ;
Update [dbo].[Site] Set SiteName='Our Lady of the Rosary Catholic School (Wyoming)'            where physicalDeliveryOfficeName='SOLWY' ;
Update [dbo].[Site] Set SiteName='Prouille Catholic School (Wahroonga)'                        where physicalDeliveryOfficeName='SPCSW' ;
Update [dbo].[Site] Set SiteName='St Agatha''s Catholic School (Pennant Hills)'                 where physicalDeliveryOfficeName='SSAPH' ;
Update [dbo].[Site] Set SiteName='St Bernard''s Catholic School (Berowra Heights)'              where physicalDeliveryOfficeName='SSBBH' ;
Update [dbo].[Site] Set SiteName='St Brendan''s Catholic School (Lake Munmorah)'                where physicalDeliveryOfficeName='SSBLM' ;
Update [dbo].[Site] Set SiteName='St Cecilia''s Catholic School (Balgowlah)'                    where physicalDeliveryOfficeName='SSCPB' ;
Update [dbo].[Site] Set SiteName='St Cecilia''s Catholic School (Wyong)'                        where physicalDeliveryOfficeName='SSCPW' ;
Update [dbo].[Site] Set SiteName='St Gerard''s Catholic School (Carlingford)'                   where physicalDeliveryOfficeName='SSGPC' ;
Update [dbo].[Site] Set SiteName='Sacred Heart Catholic School (Mona Vale)'                    where physicalDeliveryOfficeName='SSHMV' ;
Update [dbo].[Site] Set SiteName='Sacred Heart Catholic School (Pymble)'                       where physicalDeliveryOfficeName='SSHPP' ;
Update [dbo].[Site] Set SiteName='St John''s Catholic School (Narraweena)'                      where physicalDeliveryOfficeName='SSJAN' ;
Update [dbo].[Site] Set SiteName='St John the Baptist Catholic School (Harbord)'               where physicalDeliveryOfficeName='SSJBH' ;
Update [dbo].[Site] Set SiteName='St Joseph''s Catholic College (East Gosford)'                 where physicalDeliveryOfficeName='SSJGE' ;
Update [dbo].[Site] Set SiteName='St Joseph''s Catholic School (Narrabeen)'                     where physicalDeliveryOfficeName='SSJPN' ;
Update [dbo].[Site] Set SiteName='St John Fisher Catholic School (Tumbi Umbi)'                 where physicalDeliveryOfficeName='SSJTU' ;
Update [dbo].[Site] Set SiteName='St John the Baptist Catholic School (Woy Woy South)'         where physicalDeliveryOfficeName='SSJWW' ;
Update [dbo].[Site] Set SiteName='St Kevin''s Catholic School (Dee Why)'                        where physicalDeliveryOfficeName='SSKDW' ;
Update [dbo].[Site] Set SiteName='St Kieran''s Catholic School (Manly Vale)'                    where physicalDeliveryOfficeName='SSKMV' ;
Update [dbo].[Site] Set SiteName='St Leo''s Catholic College (Wahroonga)'                       where physicalDeliveryOfficeName='SSLCW' ;
Update [dbo].[Site] Set SiteName='St Martin''s Catholic School Davidson (Davidson)'             where physicalDeliveryOfficeName='SSMPD' ;
Update [dbo].[Site] Set SiteName='St Mary''s Catholic School (Manly)'                           where physicalDeliveryOfficeName='SSMPM' ;
Update [dbo].[Site] Set SiteName='St Mary''s Catholic School (Toukley)'                         where physicalDeliveryOfficeName='SSMPT' ;
Update [dbo].[Site] Set SiteName='St Paul''s Catholic College (Manly)'                          where physicalDeliveryOfficeName='SSPCM' ;
Update [dbo].[Site] Set SiteName='St Peter''s Catholic College (Tuggerah)'                      where physicalDeliveryOfficeName='SSPCT' ;
Update [dbo].[Site] Set SiteName='St Patrick''s Catholic School (East Gosford)'                 where physicalDeliveryOfficeName='SSPGE' ;
Update [dbo].[Site] Set SiteName='St Philip Neri Catholic School (Northbridge)'                where physicalDeliveryOfficeName='SSPNN' ;
Update [dbo].[Site] Set SiteName='St Patrick''s Catholic School (Asquith)'                      where physicalDeliveryOfficeName='SSPPA' ;
Update [dbo].[Site] Set SiteName='St Rose Catholic School (Collaroy Plateau)'                  where physicalDeliveryOfficeName='SSRCP' ;
Update [dbo].[Site] Set SiteName='St Thomas'' Catholic School (Willoughby)'                     where physicalDeliveryOfficeName='SSTPW' ;
Update [dbo].[Site] Set SiteName='ARCADIA Parish'                                              where physicalDeliveryOfficeName='PARCA' ;
Update [dbo].[Site] Set SiteName='CHATSWOOD Parish'                                            where physicalDeliveryOfficeName='PODCH' ;
Update [dbo].[Site] Set SiteName='DEE WHY Parish'                                              where physicalDeliveryOfficeName='PSKDW' ;
Update [dbo].[Site] Set SiteName='EPPING and CARLINGFORD Parish'                               where physicalDeliveryOfficeName='PEPPI' ;
Update [dbo].[Site] Set SiteName='FRENCHS FOREST Parish'                                       where physicalDeliveryOfficeName='PFREN' ;
Update [dbo].[Site] Set SiteName='GOSFORD Parish'                                              where physicalDeliveryOfficeName='PGOSF' ;
Update [dbo].[Site] Set SiteName='HARBORD Parish'                                              where physicalDeliveryOfficeName='PHARB' ;
Update [dbo].[Site] Set SiteName='KILLARA Parish'                                              where physicalDeliveryOfficeName='PKILL' ;
Update [dbo].[Site] Set SiteName='KINCUMBER Parish'                                            where physicalDeliveryOfficeName='PKINC' ;
Update [dbo].[Site] Set SiteName='KU-RING-GAI CHASE Parish'                                    where physicalDeliveryOfficeName='PKURI' ;
Update [dbo].[Site] Set SiteName='THE LAKES Parish'                                            where physicalDeliveryOfficeName='PLAKE' ;
Update [dbo].[Site] Set SiteName='LINDFIELD Parish'                                            where physicalDeliveryOfficeName='PLIND' ;
Update [dbo].[Site] Set SiteName='MANLY Parish'                                                where physicalDeliveryOfficeName='PMANL' ;
Update [dbo].[Site] Set SiteName='NAREMBURN Parish'                                            where physicalDeliveryOfficeName='PNARE' ;
Update [dbo].[Site] Set SiteName='NARRAWEENA Parish'                                           where physicalDeliveryOfficeName='PNARR' ;
Update [dbo].[Site] Set SiteName='NORMANHURST Parish'                                          where physicalDeliveryOfficeName='PNORM' ;
Update [dbo].[Site] Set SiteName='NORTHBRIDGE Parish'                                          where physicalDeliveryOfficeName='PNORT' ;
Update [dbo].[Site] Set SiteName='NORTH HARBOUR Parish'                                        where physicalDeliveryOfficeName='PNHAR' ;
Update [dbo].[Site] Set SiteName='PENNANT HILLS Parish'                                        where physicalDeliveryOfficeName='PPENN' ;
Update [dbo].[Site] Set SiteName='PITTWATER Parish'                                            where physicalDeliveryOfficeName='PPITT' ;
Update [dbo].[Site] Set SiteName='PYMBLE Parish'                                               where physicalDeliveryOfficeName='PPYMB' ;
Update [dbo].[Site] Set SiteName='ST IVES Parish'                                              where physicalDeliveryOfficeName='PSTIV' ;
Update [dbo].[Site] Set SiteName='TERRY HILLS Parish'                                          where physicalDeliveryOfficeName='PTHIL' ;
Update [dbo].[Site] Set SiteName='TERRIGAL Parish'                                             where physicalDeliveryOfficeName='PTERR' ;
Update [dbo].[Site] Set SiteName='THE ENTRANCE Parish'                                         where physicalDeliveryOfficeName='PENTR' ;
Update [dbo].[Site] Set SiteName='TOUKLEY Parish'                                              where physicalDeliveryOfficeName='PTOUK' ;
Update [dbo].[Site] Set SiteName='WAHROONGA Parish'                                            where physicalDeliveryOfficeName='PWAHR' ;
Update [dbo].[Site] Set SiteName='WAITARA Parish'                                              where physicalDeliveryOfficeName='PWAIT' ;
Update [dbo].[Site] Set SiteName='WARNERVALE Parish'                                           where physicalDeliveryOfficeName='PWARN' ;
Update [dbo].[Site] Set SiteName='WILLOUGHBY Parish'                                           where physicalDeliveryOfficeName='PWILL' ;
Update [dbo].[Site] Set SiteName='WOY WOY Parish'                                              where physicalDeliveryOfficeName='PWWOY' ;
Update [dbo].[Site] Set SiteName='WYOMING Parish'                                              where physicalDeliveryOfficeName='PWYOM' ;
Update [dbo].[Site] Set SiteName='WYONG and TUMBI UMBI Parish'                                 where physicalDeliveryOfficeName='PWYON' ;
Update [dbo].[Site] Set SiteName='Caroline Chisholm Centre'                                    where physicalDeliveryOfficeName='OCCCP' ;
Update [dbo].[Site] Set SiteName='Challenge Ranch'                                             where physicalDeliveryOfficeName='OCHRS' ;
Update [dbo].[Site] Set SiteName='St Francis of Assisi Centre'                                 where physicalDeliveryOfficeName='OSFAS' ;
Update [dbo].[Site] Set SiteName='Confraternity of Christian Doctrine Central Coast (Gosford)' where physicalDeliveryOfficeName='OCCDE' ;
Update [dbo].[Site] Set SiteName='Confraternity of Christian Doctrine Central Coast (Wyong)'   where physicalDeliveryOfficeName='OCCDT' ;
Update [dbo].[Site] Set SiteName='Confraternity of Christian Doctrine Manly Warringah Region'  where physicalDeliveryOfficeName='OCCDN' ;
Update [dbo].[Site] Set SiteName='Centacare Brookvale'                                         where physicalDeliveryOfficeName='OCBRK' ;
Update [dbo].[Site] Set SiteName='Centacare The Entrance'                                      where physicalDeliveryOfficeName='OCENT' ;
Update [dbo].[Site] Set SiteName='Centacare Gosford'                                           where physicalDeliveryOfficeName='OCGOS' ;
Update [dbo].[Site] Set SiteName='Centacare OOHC Kangy Angy'                                   where physicalDeliveryOfficeName='OCKAN' ;
Update [dbo].[Site] Set SiteName='Centacare Naremburn'                                         where physicalDeliveryOfficeName='OCNAR' ;
Update [dbo].[Site] Set SiteName='Centacare OOHC Thanbarra'                                    where physicalDeliveryOfficeName='OCNMH' ;
Update [dbo].[Site] Set SiteName='Centacare OOHC Sherbrook'                                    where physicalDeliveryOfficeName='OCPHB' ;
Update [dbo].[Site] Set SiteName='Centacare OOHC Grainger'                                     where physicalDeliveryOfficeName='OCPHO' ;
Update [dbo].[Site] Set SiteName='Centacare Boohna'                                            where physicalDeliveryOfficeName='OCPYM' ;
Update [dbo].[Site] Set SiteName='Centacare Waitara Northern Sydney Day Service'               where physicalDeliveryOfficeName='OCW08' ;
Update [dbo].[Site] Set SiteName='Centacare Waitara Community Access Service'                  where physicalDeliveryOfficeName='OCW17' ;
Update [dbo].[Site] Set SiteName='Centacare Waitara OOHC Office'                               where physicalDeliveryOfficeName='OCW24' ;
Update [dbo].[Site] Set SiteName='Centacare Waitara Illoura'                                   where physicalDeliveryOfficeName='OCW26' ;
Update [dbo].[Site] Set SiteName='Centacare Waitara HO'                                        where physicalDeliveryOfficeName='OCWAI' ;
Update [dbo].[Site] Set SiteName='Centacare Waitara Children''s Centre'                         where physicalDeliveryOfficeName='OCWMC' ;
Update [dbo].[Site] Set SiteName='Centacare Wyong'                                             where physicalDeliveryOfficeName='OCCCW' ;
GO


-- CentaCare sites:
Insert Into Site ( SiteID, SiteName, physicalDeliveryOfficeName )
----Select 'OCCDE', 'Confraternity of Christian Doctrine Central Coast (Gosford)', 'OCCDE' Union All 
----Select 'OCCDT', 'Confraternity of Christian Doctrine Central Coast (Wyong)', 'OCCDT' Union All 
----Select 'OCCDN', 'Confraternity of Christian Doctrine Manly Warringah Region', 'OCCDN' Union All 
--Select 'OCBRK', 'Centacare Brookvale', 'OCBRK' Union All 
Select 'OCENT' As [SiteID], 'Centacare The Entrance' As [SiteName], 'OCENT' As [physicalDeliveryOfficeName] Union All 
Select 'OCGOS', 'Centacare Gosford', 'OCGOS' Union All 
Select 'OCKAN', 'Centacare OOHC Kangy Angy', 'OCKAN' Union All 
Select 'OCNAR', 'Centacare Naremburn', 'OCNAR' Union All 
Select 'OCNMH', 'Centacare OOHC Thanbarra', 'OCNMH' Union All 
Select 'OCPHB', 'Centacare OOHC Sherbrook', 'OCPHB' Union All 
Select 'OCPHO', 'Centacare OOHC Grainger', 'OCPHO' Union All 
Select 'OCPYM', 'Centacare Boohna', 'OCPYM' Union All 
Select 'OCW08', 'Centacare Waitara Northern Sydney Day Service', 'OCW08' Union All 
Select 'OCW17', 'Centacare Waitara Community Access Service', 'OCW17' Union All 
Select 'OCW24', 'Centacare Waitara OOHC Office', 'OCW24' Union All 
Select 'OCW26', 'Centacare Waitara Illoura', 'OCW26' Union All 
Select 'OCWAI', 'Centacare Waitara HO', 'OCWAI' Union All 
Select 'OCWMC', 'Centacare Waitara Children''s Centre', 'OCWMC'
Go

-- Extra site
Insert Into Site ( SiteID, SiteName, physicalDeliveryOfficeName )
Select 'PGOSF' As [SiteID], 'GOSFORD Parish' As [SiteName], 'PGOSF' As [physicalDeliveryOfficeName] 
GO

Update [dbo].[Site] 
Set [forwarderContainer] = 'cn=Exchange 2003 Forwarders,ou=Waitara,o=Catholic Schools Office',
isMOE = 1
Where [physicalDeliveryOfficeName] in ( 'OCCCP', 'SOLWA', 'SMCCW' )
GO

Select * from [dbo].[Site]
GO


--<< END SITE CONFIG
-->> BEGIN GROUP CONFIG


USE [IdM]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MultivalueObjects]') AND type in (N'U'))
DROP TABLE [dbo].[MultivalueObjects]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByType]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByType]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[ObjectsByType](
	[ObjectType] [varchar](20) NOT NULL,
	[ID] [nvarchar](100) NOT NULL,
	[BaseID] [nvarchar](100) NULL,
	[sAMAccountName] [nvarchar](100) NULL,
	[Name] [nvarchar](100) NULL,
	[physicalDeliveryOfficeName] [nvarchar](50) NULL,
	[GroupType] [nvarchar](15) NULL,
	[isCommon] [bit] NOT NULL CONSTRAINT [DF_ObjectsByType_isCommon]  DEFAULT ((0)),
 CONSTRAINT [PK_ObjectsByType] PRIMARY KEY CLUSTERED 
(
	[ObjectType] ASC,
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_ObjectsByType_ID] ON [dbo].[ObjectsByType] 
(
	[ID] ASC,
	[ObjectType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_ObjectsByType_BaseID] ON [dbo].[ObjectsByType] 
(
	[BaseID] ASC,
	[ObjectType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_ObjectsByType_sAMAccountName] ON [dbo].[ObjectsByType] 
(
	[sAMAccountName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MultivalueObjects](
	[ID] [nvarchar](100) NOT NULL,
	[ObjectType] [varchar](20) NOT NULL,
	[StringValue] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_MultivalueObjects] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ObjectType] ASC,
	[StringValue] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_MultivalueObjects_StringValue] ON [dbo].[MultivalueObjects] 
(
	[StringValue] ASC,
	[ObjectType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_ObjectsByType]    Script Date: 08/04/2009 23:20:31 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ObjectsByType] ON [dbo].[ObjectsByType] 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MultivalueObjects]  WITH CHECK ADD  CONSTRAINT [FK_MultivalueObjects_ObjectsByType1] FOREIGN KEY([ID])
REFERENCES [dbo].[ObjectsByType] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MultivalueObjects] CHECK CONSTRAINT [FK_MultivalueObjects_ObjectsByType1]
GO
SET ANSI_PADDING OFF
GO

--Start Here:

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeriveADSCodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[DeriveADSCodes]
GO


-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 25 Feb 2009
-- Description: Calculates Derived ADS Codes based on Raw set
-- Modification History:
--				10 Aug 2009, BB, Exclude where BaseID is null (i.e. non ADS groups)
--							+ base calc on [BaseID] and not [ID]
-- =============================================
Create Function DeriveADSCodes() 
Returns table --( ADSCode nvarchar(50), DerivedADSCode nvarchar(50))
As Return
(
	-- add Level 1
	Select Distinct 
		[ID], 
		Left([BaseID],6)+'Z' As [DerivedADSCode], 
		[Name],
		[physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And BaseID Is Not Null
	And Right([BaseID],1) = '1'

	Union All
	-- add Level 2
	Select Distinct [ID], 
		Case CharIndex('0', [BaseID])
			When 0 Then Left([BaseID],5)+'0Z'
			Else
			Left([BaseID],CharIndex('0', [BaseID])-2) + Right('00000Z',8-CharIndex('0', [BaseID])+1)
		End As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And BaseID Is Not Null
	And Right([BaseID],1) = '1'

	Union All
	-- add ADS Group code
	Select Distinct 
		[ID], 
		Left([BaseID],6)+'0' As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And BaseID Is Not Null
	And [isCommon] = 0
)
go

/****** Object:  UserDefinedFunction [dbo].[GetParentADSCode]    Script Date: 02/25/2009 16:37:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetParentADSCode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GetParentADSCode]
go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 25 Feb 2009
-- Description: Experimental - calculates parent ADS Code in hierarchy
-- Modification History:
-- =============================================
Create Function dbo.GetParentADSCode (@ADSCode varchar(20))
Returns varchar(20) As
Begin
	return Case
		When @ADSCode Is Null 
			Then Null 
		When Right(@ADSCode,1) = '0' 
			Then Left(@ADSCode,6)+'1'
		When CharIndex('0', @ADSCode) <= 2 
			Then Left(@ADSCode,6)+'1'
		When Right(@ADSCode,1) = '1' 
			Then Left(@ADSCode,CharIndex('0', @ADSCode)-2) + Right('O000001',8-CharIndex('0', @ADSCode)+1)
			Else Left(@ADSCode,6)+'1'
	End
End
GO

/****** Object:  View [dbo].[vw_idmObjectsByType]    Script Date: 12/24/2008 02:02:34 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByType]'))
DROP VIEW [dbo].[vw_idmObjectsByType]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode collection
-- Modification History:
--				11 Aug 2009, BB, added '-G' for sAMAccountName matching
-- =============================================

Create View [dbo].[vw_idmObjectsByType] As 

SELECT 
	[ObjectType]
	,Case 
		When [ObjectType] like 'group%' Then
			Case
				When [sAMAccountName] Is Not Null Then [sAMAccountName]
				When [sAMAccountName] Is Null And [BaseID] Is Not Null Then [BaseID] + '-G'
				Else [ID]
			End
		Else [ID]
	End As [ID]
	,[BaseID]
	,[sAMAccountName]
	,[Name]
	,Case [ObjectType]
		When 'person' Then [physicalDeliveryOfficeName]
		Else Null
	End As [physicalDeliveryOfficeName]
	,Case 
		--When [GroupType] Is Null And [ObjectType] like 'group%' And [isCommon] = 1 Then 'common' 
		When [GroupType] Is Null And [ObjectType] like 'group%' And [isCommon] = 0 Then 'base' 
		Else [GroupType] 
	End As [GroupType]
	,1 As [groupCount]
	,(
			Select Top 1 
				mv2.StringValue
			From dbo.MultivalueObjects mv1
			Inner Join dbo.MultivalueObjects mv2
				On mv2.ID = dbo.GetParentADSCode(mv1.ID)
				And mv2.ObjectType = 'person'
			Where mv1.ObjectType = 'person'
			And mv1.StringValue = [dbo].[ObjectsByType].[ID]
			And mv2.StringValue is not null
		) As [managerID]
  FROM [dbo].[ObjectsByType]
Where IsNull(GroupType, 'x') Not In ('derived', 'homeFolderGroup')

UNION ALL

SELECT Distinct 
	o.ObjectType, 
	a.DerivedADSCode + '-G' As [ID], 
	a.DerivedADSCode As [BaseID], 
	Null As [sAMAccountName],
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	'derived' As [GroupType],
	Null As [groupCount],
	Null As [managerID]
FROM [dbo].[ObjectsByType] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
	Left Join [dbo].[ObjectsByType] o2
		On o2.[ID] = a.DerivedADSCode + '-G'
		And o2.ObjectType = 'group'
	Left Join [dbo].[ObjectsByType] o3
		On o3.[BaseID] Is Not Null
		And o3.[BaseID] = a.DerivedADSCode
		And o3.ObjectType = 'group'
Where o.ObjectType = 'group'
And IsNull(o.GroupType, 'x') Not In ('derived', 'common', 'homeFolderGroup')
And o2.ID Is Null
And o3.ID Is Null

UNION ALL 

SELECT Distinct 
	'group' As [ObjectType], 
	[physicalDeliveryOfficeName] + '-G' As [ID], 
	[physicalDeliveryOfficeName] As [BaseID], 
	Null As [sAMAccountName],
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	'homeFolderGroup' As [GroupType],
	Null As [groupCount],
	Null As [managerID]
FROM [dbo].[ObjectsByType] 
Where ObjectType = 'person'
And [physicalDeliveryOfficeName] Is Not Null
And Not Exists (
	Select 1 From [dbo].[ObjectsByType] o2
	Where o2.[ID] = [dbo].[ObjectsByType].[physicalDeliveryOfficeName] + '-G' 
	And o2.ObjectType = 'group'
	And o2.GroupType <> 'homeFolderGroup'
)

Go

/****** Object:  View [dbo].[vw_idmMultivalueObjects]    Script Date: 12/24/2008 02:05:05 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmMultivalueObjects]'))
DROP VIEW [dbo].[vw_idmMultivalueObjects]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode/employee relationship
-- Modification History:
--				30/7/09, BB, fixed ObjectType to 'member'
-- =============================================

Create View [dbo].[vw_idmMultivalueObjects] As 

SELECT IsNull(o.[sAMAccountName],mv.[ID]) As [ID]
      ,'member' As [ObjectType]
      ,mv.[StringValue]
  FROM [dbo].[MultivalueObjects] mv
LEFT JOIN [dbo].[ObjectsByType] o 
	ON o.[sAMAccountName] Is Not Null
	AND o.[BaseID] Is Not Null
	AND mv.[ObjectType] = 'person'
	AND o.[BaseID] = mv.[ID]

UNION ALL

SELECT IsNull(o3.ID,a.DerivedADSCode + '-G') As [ID] --Distinct
      ,'member' As [ObjectType]
      ,[StringValue]
  FROM [dbo].[MultivalueObjects] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
	Left Join [dbo].[ObjectsByType] o2
		On o2.[ID] = a.DerivedADSCode + '-G'
		And o2.ObjectType = 'group'
	Left Join [dbo].[ObjectsByType] o3
		On o3.[BaseID] Is Not Null
		And o3.[BaseID] = a.DerivedADSCode
		And o3.ObjectType = 'group'

UNION ALL 

-- homeFolderGroup set:
SELECT [physicalDeliveryOfficeName] + '-G' As [ID]
      ,'member' As [ObjectType]
      ,[ID] As [StringValue]
  FROM [dbo].[ObjectsByType]
Where ObjectType = 'person'
And [physicalDeliveryOfficeName] Is Not Null 

UNION ALL 
-- add groups 'Common' to all users (e.g. InternetUsers)
Select c.[ID]
      ,'member' As [ObjectType] 
      ,p.[ID] As [StringValue]
From dbo.[ObjectsByType] p
Cross Join dbo.[ObjectsByType] c 
Where c.[isCommon] = 1 
And c.[ObjectType] = 'group'
And p.[ObjectType] = 'person'

/*
UNION ALL
-- add 'other' groups
SELECT IsNull(o.[sAMAccountName],mv.[ID]) As [ID]
      ,'member' As [ObjectType]
      ,mv.[StringValue]
  FROM [dbo].[MultivalueObjects] mv
LEFT JOIN [dbo].[ObjectsByType] o 
	ON o.[sAMAccountName] Is Not Null
	AND o.[BaseID] Is Not Null
	AND o.[GroupType] In ('unknown', 'derived', 'common', 'homeFolderGroup')
	AND o.[BaseID] = mv.[ID]
Where mv.[ObjectType] in ('group','groupNested')
*/

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ILMChangeManager' AND type = 'R')
EXEC sp_droprolemember N'ILMChangeManager', N'dbb\svcilm'
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ILMChangeManager' AND type = 'R')
DROP ROLE [ILMChangeManager]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeHistory]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByTypeHistory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeChanges]') AND type in (N'U'))
DROP TABLE [dbo].[ObjectsByTypeChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MultivalueObjectsChanges]') AND type in (N'U'))
DROP TABLE [dbo].[MultivalueObjectsChanges]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteHistory]') AND type in (N'U'))
DROP TABLE [dbo].[SiteHistory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteChanges]') AND type in (N'U'))
DROP TABLE [dbo].[SiteChanges]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ObjectsByTypeHistory](
		[ObjectType] [varchar](20) NOT NULL,
		[ID] [nvarchar](100) NOT NULL,
		[BaseID] [nvarchar](100) NULL,
		[sAMAccountName] [nvarchar](100) NULL,
		[Name] [nvarchar](100) NULL,
		[physicalDeliveryOfficeName] [nvarchar](50) NULL,
		[GroupType] [nvarchar](15) NULL,
		[isCommon] [bit] NOT NULL CONSTRAINT [DF_ObjectsByTypeHistory_isCommon]  DEFAULT (0),
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_ObjectsByTypeHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ObjectType] ASC, 
		[ID] ASC, 
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectsByTypeChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[ObjectsByTypeChanges](
		[ObjectType] [varchar](20) NOT NULL,
		[ID] [nvarchar](100) NOT NULL,
		[BaseID] [nvarchar](100) NULL,
		[sAMAccountName] [nvarchar](100) NULL,
		[Name] [nvarchar](100) NULL,
		[physicalDeliveryOfficeName] [nvarchar](50) NULL,
		[GroupType] [nvarchar](15) NULL,
		[isCommon] [bit] NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_isCommon]  DEFAULT (0),
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_changeIndicator]  DEFAULT ('U'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectsByTypeChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_ObjectsByTypeChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ObjectType] ASC, 
		[ID] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MultivalueObjectsChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[MultivalueObjectsChanges](
		[ID] [nvarchar](100) NOT NULL,
		[ObjectType] [varchar](20) NOT NULL,
		[StringValue] [nvarchar](100) NOT NULL,
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_MultivalueObjectsChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_MultivalueObjectsChanges_changeIndicator]  DEFAULT ('M'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MultivalueObjectsChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_MultivalueObjectsChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[ObjectType] ASC, 
		[ID] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[SiteHistory](
		[SiteID] [char](5) NOT NULL,
		[physicalDeliveryOfficeName] [char](5) NOT NULL,
		[IsSchool] [bit] NOT NULL,
		[IsActive] [bit] NOT NULL,
		[IsMOE] [bit] NOT NULL,
 		[changeTimestamp] [datetime] NOT NULL, 
		[changeIndicator] [char](1) NOT NULL, 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL , 
	CONSTRAINT [PK_SiteHistory] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[SiteID] ASC, 
		[changeGUID] ASC 
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SiteChanges]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[SiteChanges](
		[SiteID] [char](5) NOT NULL,
		[physicalDeliveryOfficeName] [char](5) NOT NULL,
		[IsSchool] [bit] NOT NULL,
		[IsActive] [bit] NOT NULL,
		[IsMOE] [bit] NOT NULL,
		[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_SiteChanges_changeTimestamp]  DEFAULT (getDate()), 
		[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_SiteChanges_changeIndicator]  DEFAULT ('U'), 
		[changeProcessingIndicator] [char](1) NULL, 
		[changeGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SiteChanges_changeGuid]  DEFAULT (newID()), 
	 CONSTRAINT [PK_SiteChanges] PRIMARY KEY CLUSTERED 
	(
		[changeTimestamp] DESC, 
		[SiteID] ASC, 
		[changeGUID] ASC  
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ObjectsByType_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ObjectsByType_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_ObjectsByType_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_ObjectsByType_clearChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Site_getChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Site_getChanges]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unifynow_Site_clearChanges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[unifynow_Site_clearChanges]
go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect Site changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_ObjectsByType_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.ObjectsByTypeChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.ObjectsByTypeChanges
where changeProcessingIndicator = 'Y' -- processing

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear ObjectsByType changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_ObjectsByType_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = 'Y' -- processing
) BEGIN
	insert into dbo.ObjectsByTypeHistory
	select * from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = 'Y' -- processing

	delete from dbo.ObjectsByTypeChanges
	where changeProcessingIndicator = 'Y' -- processing

	select 1
END
ELSE
	select 0

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to detect Site changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Site_getChanges] as

set nocount on
if not exists (
	select 1 
	from dbo.SiteChanges
	where changeProcessingIndicator = 'Y' -- processing
)
begin
	update dbo.SiteChanges
	set changeProcessingIndicator = 'Y'
	where changeProcessingIndicator is null -- unprocessed
end

select top 1 1
from dbo.SiteChanges
where changeProcessingIndicator = 'Y' -- processing

go

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	stored proc for UNIFYNow to clear Site changes
-- Modification History:
-- =============================================

create procedure dbo.[unifynow_Site_clearChanges] as

set nocount on

IF EXISTS ( 
	select top 1 1 from dbo.SiteChanges
	where changeProcessingIndicator = 'Y' -- processing
) BEGIN
	insert into dbo.SiteHistory
	select * from dbo.SiteChanges
	where changeProcessingIndicator = 'Y' -- processing

	delete from dbo.SiteChanges
	where changeProcessingIndicator = 'Y' -- processing

	select 1
END
ELSE
	select 0

go


IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_ObjectsByTypeChanges]'))
DROP TRIGGER [dbo].[trg_ObjectsByTypeChanges]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_MultivalueObjectsChanges]'))
DROP TRIGGER [dbo].[trg_MultivalueObjectsChanges]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the ObjectsByType table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table ObjectsByType there is a corresponding
--				changes table ObjectsByTypeChanges, and that the ObjectsByTypeChanges schema consists of all 
--				ObjectsByType columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string ObjectsByType with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from ObjectsByType
-- =============================================
CREATE TRIGGER [dbo].[trg_ObjectsByTypeChanges] 
   ON  [dbo].[ObjectsByType]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--	declare @event_type char(1)
	declare @upd_table table (
		[ObjectType] [varchar](20) NOT NULL,
		[ID] [nvarchar](100) NOT NULL,
		[BaseID] [nvarchar](100) NULL,
		[sAMAccountName] [nvarchar](100) NULL,
		[Name] [nvarchar](100) NULL,
		[physicalDeliveryOfficeName] [nvarchar](50) NULL, 
		[GroupType] [nvarchar](15) NULL, 
		[isCommon] [bit] NULL, 
		[changeIndicator] [char](1) NOT NULL
	)

	insert into @upd_table 
	SELECT inserted.[ObjectType]
		  ,inserted.[ID]
		  ,inserted.[BaseID]
		  ,inserted.[sAMAccountName]
		  ,inserted.[Name]
		  ,Case inserted.[ObjectType] 
			When 'group' Then Null 
			When 'groupNested' Then Null 
			Else inserted.[physicalDeliveryOfficeName] 
			End As [physicalDeliveryOfficeName]
		  ,inserted.[GroupType]
		  ,inserted.[isCommon]
		  ,Case 
			When deleted.ID Is Null Then 'I' 
			Else 'U'
			End As [changeIndicator]
	From inserted
	Left Outer Join deleted 
		On deleted.[ObjectType] = inserted.[ObjectType]
		And deleted.[ID] = inserted.[ID]

	insert into @upd_table 
	SELECT deleted.[ObjectType]
		  ,deleted.[ID]
		  ,deleted.[BaseID]
		  ,deleted.[sAMAccountName]
		  ,deleted.[Name]
		  ,Case deleted.[ObjectType] 
			When 'group' Then Null 
			When 'groupNested' Then Null 
			Else deleted.[physicalDeliveryOfficeName] 
			End As [physicalDeliveryOfficeName]
		  ,deleted.[GroupType]
		  ,deleted.[isCommon]
		  ,'D' As [changeIndicator]
	From deleted
	Where Not Exists (
		Select 1 From inserted
		Where deleted.[ObjectType] = inserted.[ObjectType]
		And deleted.[ID] = inserted.[ID]
	)

	INSERT INTO [dbo].[ObjectsByTypeChanges] 
			([ObjectType]
			  ,[ID]
			  ,[BaseID]
			  ,[sAMAccountName]
			  ,[Name]
			  ,[physicalDeliveryOfficeName]
		    ,[GroupType]
			,[isCommon]
			,[ChangeIndicator])
	select * from @upd_table

END

GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the MultivalueObjects table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table MultivalueObjects there is a corresponding
--				changes table MultivalueObjectsChanges, and that the MultivalueObjectsChanges schema consists of all 
--				MultivalueObjects columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string MultivalueObjects with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from MultivalueObjects
-- =============================================
CREATE TRIGGER [dbo].[trg_MultivalueObjectsChanges] 
   ON  [dbo].[MultivalueObjects]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table table (
		[ID] [nvarchar](100) NOT NULL,
		[ObjectType] [varchar](20) NOT NULL,
		[StringValue] [nvarchar](100) NOT NULL
	)
	declare @upd_table2 table (
		[ObjectType] [varchar](20) NOT NULL,
		[ID] [nvarchar](100) NOT NULL,
		[BaseID] [nvarchar](100) NULL,
		[sAMAccountName] [nvarchar](100) NULL,
		[Name] [nvarchar](100) NULL,
		[physicalDeliveryOfficeName] [nvarchar](50) NULL,
		[GroupType] [nvarchar](15) NULL, 
		[isCommon] [bit] NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		insert into @upd_table2 
		SELECT 'group' As [ObjectType]
		  ,o.[ID]
		  ,o.[BaseID] 
		  ,o.[sAMAccountName]
		  ,o.Name
		  ,o.physicalDeliveryOfficeName
		  ,o.[GroupType]
		  ,o.[isCommon]
		from dbo.ObjectsByType o
		where o.ObjectType like 'group%' --122
		and ID in (select ID from inserted)
		--SELECT @event_type = 'U'

		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			SELECT [ID]
			  ,[ObjectType]
			  ,[StringValue]
			from inserted
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
			insert into @upd_table 
			SELECT [ID]
			  ,[ObjectType]
			  ,[StringValue]
			from inserted
			SELECT @event_type = 'I'
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table2 
			SELECT 'group' As [ObjectType]
			  ,o.[ID]
			  ,o.[BaseID] 
			  ,o.[sAMAccountName]
			  ,o.Name
			  ,o.physicalDeliveryOfficeName
			  ,o.[GroupType]
			  ,o.[isCommon]
			from dbo.ObjectsByType o
			where o.ObjectType like 'group%' --122
			and ID in (select ID from deleted)
			--SELECT @event_type = 'U'

			insert into @upd_table 
			SELECT [ID]
			  ,[ObjectType]
			  ,[StringValue]
			from deleted
			SELECT @event_type = 'D'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[MultivalueObjectsChanges] 
			([ID]
			  ,[ObjectType]
			  ,[StringValue]
				,[ChangeIndicator])
		select *, @event_type from @upd_table
		INSERT INTO [dbo].[ObjectsByTypeChanges] 
		([ObjectType]
		,[ID]
		,[BaseID]
		,[sAMAccountName]
		,[Name]
		,[physicalDeliveryOfficeName]
		,[GroupType]
		,[isCommon]
		,[ChangeIndicator])
		select *, 'U' from @upd_table2
	END

END

GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_SiteChanges]'))
DROP TRIGGER [dbo].[trg_SiteChanges]
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 22 Dec 2008
-- Description:	Capture all changes to the Site table and record in a changes table for delta 
--				imports to ILM.  Script assumes that for table Site there is a corresponding
--				changes table SiteChanges, and that the SiteChanges schema consists of all 
--				Site columns in addition to the following standard columns:
--					[changeTimestamp] [datetime] NOT NULL CONSTRAINT [DF_CandidateChanges_changeTimestamp]  DEFAULT (getdate())
--					[changeIndicator] [char](1) NOT NULL CONSTRAINT [DF_CandidateChanges_changeIndicator]  DEFAULT ('M')
--					[changeProcessingIndicator] [char](1) NULL
--	Template Usage:	
--				This trigger has been constructed using a standard template as follows:
--				(1) Replace all instances of string Site with the name of the table for which
--					changes are being audited; and
--				(2)	Replace all instances of <SELECT_LIST> with the FULL select list from Site
-- =============================================
CREATE TRIGGER [dbo].[trg_SiteChanges] 
   ON  [dbo].[Site]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @event_type char(1)
	declare @upd_table table (
		[SiteID] [char](5) NOT NULL,
		[physicalDeliveryOfficeName] [char](5) NOT NULL,
		[IsSchool] [bit] NOT NULL,
		[IsActive] [bit] NOT NULL,
		[IsMOE] [bit] NOT NULL
	)

	IF EXISTS(SELECT Top 1 1 FROM inserted)
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			SELECT [SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
			from inserted
			SELECT @event_type = 'U'
		END
		ELSE
		BEGIN
			insert into @upd_table 
			SELECT [SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
			from inserted
			SELECT @event_type = 'I'
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Top 1 1 FROM deleted)
		BEGIN
			insert into @upd_table 
			SELECT [SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
			from deleted
			SELECT @event_type = 'D'
		END
		ELSE
		BEGIN
		--no rows affected - cannot determine event
			SELECT @event_type = 'N'
		END
	END
	
	IF NOT (@event_type = 'N')
	BEGIN
		INSERT INTO [dbo].[SiteChanges] 
			([SiteID]
			  ,[physicalDeliveryOfficeName]
			  ,[IsSchool]
			  ,[IsActive]
			  ,[IsMOE]
				,[ChangeIndicator])
		select *, @event_type from @upd_table
	END

END

GO

USE [IdM]
GO
/****** Object:  View [dbo].[vw_idmObjectsByTypeChanges]    Script Date: 01/09/2009 11:50:16 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmObjectsByTypeChanges]'))
DROP VIEW [dbo].[vw_idmObjectsByTypeChanges]
GO
/****** Object:  View [dbo].[vw_idmObjectsByTypeChanges]    Script Date: 01/09/2009 11:46:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the DERIVED ADSCode collection CHANGES
-- Modification History:
--				11 Aug 2009, BB, added '-G' for sAMAccountName matching
-- =============================================

Create View [dbo].[vw_idmObjectsByTypeChanges] As 

SELECT 
		[ObjectType]
	,Case 
		When [ObjectType] like 'group%' Then
			Case
				When [sAMAccountName] Is Not Null Then [sAMAccountName]
				When [sAMAccountName] Is Null And [BaseID] Is Not Null Then [BaseID] + '-G'
				Else [ID]
			End
		Else [ID]
	End As [ID]
      ,[BaseID]
      ,[sAMAccountName]
      ,[Name]
	  ,Case [ObjectType]
		When 'person' Then [physicalDeliveryOfficeName]
		Else Null
		End As [physicalDeliveryOfficeName]
	  ,Case 
			--When [GroupType] Is Null And [ObjectType] like 'group%' And [isCommon] = 1 Then 'common' 
			When [GroupType] Is Null And [ObjectType] like 'group%' And [isCommon] = 0 Then 'base' 
			Else [GroupType] 
		End As [GroupType]
	  ,	1 As [groupCount]
	  ,(
			Select Top 1 
				mv2.StringValue
			From dbo.MultivalueObjects mv1
			Inner Join dbo.MultivalueObjects mv2
				On mv2.ID = dbo.GetParentADSCode(mv1.ID)
				And mv2.ObjectType = 'person'
			Where mv1.ObjectType = 'person'
			And mv1.StringValue = [dbo].[ObjectsByTypeChanges].[ID]
			And mv2.StringValue is not null
		) As [managerID]
      ,[changeIndicator]
  FROM [dbo].[ObjectsByTypeChanges]
WHERE changeProcessingIndicator = 'Y'
And IsNull(GroupType, 'x') Not In ('derived', 'homeFolderGroup')

UNION ALL

SELECT Distinct 
	o.ObjectType, 
	a.DerivedADSCode + '-G' As [ID], 
	a.DerivedADSCode As [BaseID], 
	Null As [sAMAccountName], 
	a.Name, 
	a.[physicalDeliveryOfficeName],
	'derived' As [GroupType],
	Null As [groupCount],
	Null As [managerID],
    o.[changeIndicator]
FROM [dbo].[ObjectsByTypeChanges] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
	Left Join [dbo].[ObjectsByType] o2
		On o2.[ID] = a.DerivedADSCode + '-G'
		And o2.ObjectType = 'group'
	Left Join [dbo].[ObjectsByType] o3
		On o3.[BaseID] Is Not Null
		And o3.[BaseID] = a.DerivedADSCode
		And o3.ObjectType = 'group'
Where o.ObjectType = 'group'
And o.changeProcessingIndicator = 'Y'
And IsNull(o.GroupType, 'x') Not In ('derived', 'common', 'homeFolderGroup')
And o2.ID Is Null
And o3.ID Is Null

UNION ALL

SELECT Distinct 
	'group' As [ObjectType], 
	[physicalDeliveryOfficeName] + '-G' As [ID], 
	[physicalDeliveryOfficeName] As [BaseID], 
    Null As [sAMAccountName],
    Null As [Name],
	Null As [physicalDeliveryOfficeName], 
	'homeFolderGroup' As [GroupType],
	Null As [groupCount],
	Null As [managerID],
	'I' As [changeIndicator]
FROM [dbo].[ObjectsByType] 
Where ObjectType = 'person'
And [physicalDeliveryOfficeName] Is Not Null
And Not Exists (
	Select 1 From [dbo].[ObjectsByType] o2
	Where o2.[ID] = [dbo].[ObjectsByType].[physicalDeliveryOfficeName] 
	And o2.ObjectType = 'group'
	And o2.GroupType <> 'homeFolderGroup'
)
And [physicalDeliveryOfficeName] In ( 
	Select Distinct [physicalDeliveryOfficeName] 
	From [dbo].[ObjectsByTypeChanges]
	Where ObjectType = 'person'
)

/*
UNION ALL

SELECT Distinct 
	g.[ObjectType], 
	g.[ID], 
	g.[BaseID], 
    g.[sAMAccountName],
    g.[Name],
	g.[physicalDeliveryOfficeName], 
	'common'As [GroupType],
	1 As [groupCount],
	Null As [managerID],
	'U' As [changeIndicator]
FROM [dbo].[ObjectsByType] g 
Where g.[ObjectType] = 'group'
and g.[isCommon] = 1
And IsNull(g.GroupType, 'x') Not In ('derived', 'common', 'homeFolderGroup')
*/

GO


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmNestedObjectsByType]'))
DROP VIEW [dbo].[vw_idmNestedObjectsByType]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the NESTED GROUPS
-- Modification History:
-- =============================================

Create view dbo.vw_idmNestedObjectsByType As
Select [ObjectType]
      ,[ID]
      ,[BaseID]
      ,[sAMAccountName]
      ,[Name]
      ,[physicalDeliveryOfficeName]
	  ,[GroupType]
      ,[isCommon] 
from [dbo].[ObjectsByType] --[vw_idmObjectsByType]
Where ObjectType <> 'person'

-->>
/*
union all

SELECT [ObjectType]
      ,[ID]
      ,[BaseID]
      ,[sAMAccountName]
      ,[Name]
      ,[physicalDeliveryOfficeName]
      ,Cast(0 As bit) As [isCommon]
  FROM [dbo].[vw_idmObjectsByType]
Where GroupType In ('derived','homeFolderGroup','common')
*/
--<<

go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmNestedObjectsByTypeChanges]'))
DROP VIEW [dbo].[vw_idmNestedObjectsByTypeChanges]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the NESTED GROUP CHANGES
-- Modification History:
-- =============================================

Create view dbo.[vw_idmNestedObjectsByTypeChanges] As
Select [ObjectType]
      ,[ID]
      ,[BaseID]
      ,[sAMAccountName]
      ,[Name]
      ,[physicalDeliveryOfficeName]
      ,[GroupType]
      ,[isCommon]
      ,changeIndicator
From [dbo].[ObjectsByTypeChanges] --[vw_idmObjectsByTypeChanges]
Where ObjectType <> 'person'

-->>
/*
union all

SELECT [ObjectType]
      ,[ID]
      ,[BaseID]
      ,[sAMAccountName]
      ,[Name]
      ,[physicalDeliveryOfficeName]
      ,Cast(0 As bit) As [isCommon]
      ,changeIndicator
  FROM [dbo].[vw_idmObjectsByTypeChanges]
Where GroupType In ('derived','homeFolderGroup','common')
*/
--<<
go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmNestedMultivalueObjects]'))
DROP VIEW [dbo].[vw_idmNestedMultivalueObjects]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the NESTED GROUP MV OBJECTS
-- Modification History:
-- =============================================

Create view dbo.vw_idmNestedMultivalueObjects As
Select * from [dbo].[MultivalueObjects]
Where ObjectType <> 'person'
go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmNonNestedObjectsByType]'))
DROP VIEW [dbo].[vw_idmNonNestedObjectsByType]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the Non-NESTED GROUPS
-- Modification History:
-- =============================================

Create view dbo.vw_idmNonNestedObjectsByType As
Select * from [dbo].[ObjectsByType] --[vw_idmObjectsByType]
Where ObjectType <> 'groupNested'
go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmNonNestedObjectsByTypeChanges]'))
DROP VIEW [dbo].[vw_idmNonNestedObjectsByTypeChanges]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the Non-NESTED GROUP CHANGES
-- Modification History:
-- =============================================

Create view dbo.[vw_idmNonNestedObjectsByTypeChanges] As
Select * from [dbo].[ObjectsByTypeChanges] --[vw_idmObjectsByTypeChanges]
Where ObjectType <> 'groupNested'
go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_idmNonNestedMultivalueObjects]'))
DROP VIEW [dbo].[vw_idmNonNestedMultivalueObjects]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 21 Dev 2008
-- Description:	Provides ILM with an authoritative source for the Non-NESTED GROUP MV OBJECTS
-- Modification History:
-- =============================================

Create view dbo.vw_idmNonNestedMultivalueObjects As
Select * from [dbo].[MultivalueObjects]
Where ObjectType <> 'groupNested'
go

-- Roles

CREATE ROLE [ILMChangeManager] AUTHORIZATION [dbo]
GO

EXEC sp_addrolemember N'ILMChangeManager', N'dbb\svcilm'
GO
EXEC sp_addrolemember N'db_owner', N'DBB\svcma_sql'
GO

GRANT EXECUTE ON [dbo].[unifynow_ObjectsByType_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_ObjectsByType_clearChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Site_getChanges] TO [ILMChangeManager]
GO
GRANT EXECUTE ON [dbo].[unifynow_Site_clearChanges] TO [ILMChangeManager]
GO


-- Prime
begin transaction
delete from dbo.ObjectsByType where ID like 'InternetUsers%'
Insert Into dbo.ObjectsByType (
	[ObjectType]
      ,[ID]
	  ,[sAMAccountName]
      ,[BaseID]
      ,[Name]
      ,[physicalDeliveryOfficeName]
	  ,[GroupType]
      ,[isCommon] )
Select 
	'group' As [ObjectType], 
	'InternetUsers-G' As [ID],
	'InternetUsers-G' As [sAMAccountName],
	'InternetUsers-G' As [BaseID], 
    'InternetUsers-G' As [Name],
	Null As [physicalDeliveryOfficeName],
	'common' As [GroupType],
	1 As [isCommon]
commit transaction

truncate table dbo.MultivalueObjectsChanges


/*
Insert Into dbo.ObjectsByType
Select 
	'group' As [ObjectType], 
	'TestForBob2' As [ID],
	'TestForBob2' As [sAMAccountName],
	'TestForBob2' As [BaseID], 
    'TestForBob2' As [Name],
	Null As [physicalDeliveryOfficeName],
	Null As [GroupType],
	1 As [isCommon]
*/

