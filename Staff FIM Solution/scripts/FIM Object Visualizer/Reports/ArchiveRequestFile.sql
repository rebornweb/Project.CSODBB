USE [FIMDEEWRArchive]
GO

/****** Object:  StoredProcedure [dbo].[ArchiveRequestFile]    Script Date: 12/02/2011 12:21:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ArchiveRequestFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ArchiveRequestFile]
GO

USE [FIMDEEWRArchive]
GO

/****** Object:  StoredProcedure [dbo].[ArchiveRequestFile]    Script Date: 12/02/2011 12:21:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[ArchiveRequestFile](@filePath varchar(200)) As

-- =============================================
-- Author:		Bob Bradley, UNIFY Solutions
-- Create date: 27/10/2011
-- Description:	Import XML exported from the FIM Request history into a SQL table
-- =============================================

SET NOCOUNT ON 

Declare @sql nvarchar(1000)
DECLARE @ParmDefinition nvarchar(500)

Select @sql = N'
SELECT @xmlString = BulkColumn  
FROM OPENROWSET(BULK ''' + @filePath + ''', SINGLE_CLOB) AS AD 
'
SET @ParmDefinition = N'@xmlString XML output';

DECLARE @ADXMLData XML

exec sys.sp_executesql @sql, @ParmDefinition, @xmlString=@ADXMLData OUTPUT

DECLARE @docHandle int 
EXEC sys.sp_xml_preparedocument @docHandle OUTPUT, @ADXMLData, '<Results xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>' 

Declare @tblForArchive Table (
	[ObjectIdentifier] uniqueidentifier PRIMARY KEY NOT NULL,
	[CreatedTime] [datetime] NULL,
	[CommittedTime] [datetime] NULL,
	[ExpirationTime] [datetime] NULL,
	[Creator] [uniqueidentifier] NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[ObjectType] [varchar](50) NOT NULL,
	[Operation] [varchar](20) NULL,
	[IsPlaceholder] [varchar](10) NULL,
	[RequestStatus] [varchar](20) NULL,
	[Target] [uniqueidentifier] NULL,
	[TargetObjectType] [varchar](50) NULL,
	[ServicePartitionName] [varchar](50) NULL,
	[ResourceManagementAttributes] [xml] NOT NULL
)

INSERT INTO @tblForArchive
	SELECT 
		CAST(REPLACE([ObjectIdentifier],'urn:uuid:','') as uniqueidentifier) As [ObjectIdentifier],
		dbo.ConvertFIMDate([CreatedTime]) As [CreatedTime],
		dbo.ConvertFIMDate([CommittedTime]) As [CommittedTime],
		CASE WHEN RTRIM([ExpirationTime]) = '' THEN NULL ELSE dbo.ConvertFIMDate([ExpirationTime]) END As [ExpirationTime],
		CAST(REPLACE([Creator],'urn:uuid:','') as uniqueidentifier) As [Creator],
		[DisplayName],
		[ObjectType],
		[Operation],
		[IsPlaceholder],
		[RequestStatus],
		CAST(REPLACE([Target],'urn:uuid:','') as uniqueidentifier) As [Target],
		[TargetObjectType],
		[ServicePartitionName],
		[ResourceManagementAttributes]
	FROM OPENXML(@docHandle, N'//ExportObject/ResourceManagementObject',2)  
	 With ( 
			[ObjectIdentifier] char(45), 
			[CreatedTime] varchar(30) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''CreatedTime'']/Value',
			[CommittedTime] varchar(30) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''CommittedTime'']/Value',
			[ExpirationTime] varchar(30) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''ExpirationTime'']/Value',
			[Creator] char(45) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''Creator'']/Value',
			[DisplayName] varchar(100) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''DisplayName'']/Value',
			[ObjectType] varchar(50),
			[Operation] varchar(20) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''Operation'']/Value',
			[IsPlaceHolder] char(5),
			[RequestStatus] varchar(20) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''RequestStatus'']/Value',
			[Target] char(45) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''Target'']/Value',
			[TargetObjectType] varchar(50) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''TargetObjectType'']/Value',
			[ServicePartitionName] varchar(50) N'ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=''ServicePartitionName'']/Value',
			[ResourceManagementAttributes] xml
	) Export 

Insert into dbo.ResourceManagementObject (
	[ObjectIdentifier]
	,[CreatedTime]
	,[CommittedTime]
	,[ExpirationTime]
	,[Creator]
	,[DisplayName]
	,[ObjectType]
	,[Operation]
	,[IsPlaceholder]
	,[RequestStatus]
	,[Target]
	,[TargetObjectType]
	,[ServicePartitionName]
	,[ResourceManagementAttributes])
Select fa.[ObjectIdentifier]
	,fa.[CreatedTime]
	,fa.[CommittedTime]
	,fa.[ExpirationTime]
	,fa.[Creator]
	,fa.[DisplayName]
	,fa.[ObjectType]
	,fa.[Operation]
	,fa.[IsPlaceholder]
	,fa.[RequestStatus]
	,fa.[Target]
	,fa.[TargetObjectType]
	,fa.[ServicePartitionName]
	,fa.[ResourceManagementAttributes]
From @tblForArchive fa
Left Join dbo.ResourceManagementObject ro2 
	On ro2.ObjectIdentifier = fa.ObjectIdentifier
Where ro2.ObjectIdentifier is null

Update dbo.ResourceManagementObject
Set [CreatedTime] = fa.[CreatedTime],
	[CommittedTime] = fa.[CommittedTime],
	[ExpirationTime] = fa.[ExpirationTime],
	[Creator] = fa.[Creator],
	[DisplayName] = fa.[DisplayName],
	[ObjectType] = fa.[ObjectType],
	[Operation] = fa.[Operation],
	[IsPlaceholder] = fa.[IsPlaceholder],
	[RequestStatus] = fa.[RequestStatus],
	[Target] = fa.[Target],
	[TargetObjectType] = fa.[TargetObjectType],
	[ServicePartitionName] = fa.[ServicePartitionName],
	[ResourceManagementAttributes] = fa.[ResourceManagementAttributes]
From @tblForArchive fa
Where fa.ObjectIdentifier = ResourceManagementObject.ObjectIdentifier

EXEC sys.sp_xml_removedocument @docHandle 




GO

