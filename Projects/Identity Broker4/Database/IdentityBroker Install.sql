/****** Object:  Table [dbo].[CollectionKey]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CollectionKey](
	[CollectionKeyId] [int] IDENTITY(1,1) NOT NULL,
	[Caption] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_CollectionKey] PRIMARY KEY CLUSTERED 
(
	[CollectionKeyId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
/****** Object:  Table [dbo].[Changes]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Changes](
	[ChangesKey] int IDENTITY(1, 1), 
	[EntityId] [uniqueidentifier] NOT NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[ChangeTimestamp] [bigint] NOT NULL,
 CONSTRAINT [PK_Changes_Identity] PRIMARY KEY CLUSTERED 
	(
		[ChangesKey] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
 )
GO
/****** Object:  Table [dbo].[StoredValueCollection]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StoredValueCollection](
	[StoredValueCollectionKey] [bigint] IDENTITY(1,1) NOT NULL,
	[StoredValueCollectionId] [uniqueidentifier] NOT NULL,
	[Values] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_StoredValueCollection] PRIMARY KEY NONCLUSTERED
	(
		[StoredValueCollectionId] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
 )
GO
CREATE CLUSTERED INDEX [IX_StoredValueCollectionKey] ON [dbo].[StoredValueCollection] 
(
	[StoredValueCollectionKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
/****** Object:  Table [dbo].[Partition]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Partition](
	[PartitionId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Connector] PRIMARY KEY CLUSTERED 
(
	[PartitionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
/****** Object:  Table [dbo].[Container]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Container](
	[PartitionId] [uniqueidentifier] NOT NULL,
	[ContainerId] [uniqueidentifier] NOT NULL,
	[DistinguishedName] [nvarchar](400) NOT NULL,
 CONSTRAINT [PK_Container] PRIMARY KEY CLUSTERED 
(
	[ContainerId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
/****** Object:  Table [dbo].[ObjectClass]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ObjectClass](
	[ObjectClassId] [int] IDENTITY(1,1) NOT NULL,
	[ClassName] [nvarchar](50) NOT NULL,
	[PartitionId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ObjectClass_1] PRIMARY KEY CLUSTERED 
(
	[ObjectClassId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
/****** Object:  Table [dbo].[Entity]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Entity](
	[EntityKey] [bigint] IDENTITY(1,1) NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[PartitionId] [uniqueidentifier] NOT NULL,
	[ObjectClassId] [int] NULL,
	[DN] [nvarchar](400) NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY NONCLUSTERED 
(
	[EntityId] ASC,
	[PartitionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
CREATE CLUSTERED INDEX [IX_EntityKey] ON [dbo].[Entity] 
(
	[EntityKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
/****** Object:  Table [dbo].[EntityValue]    Script Date: 03/22/2010 13:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityValue](
	[EntityValueKey] [bigint] IDENTITY(1,1) NOT NULL,
	[EntityValueId] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[ValueType] [int] NOT NULL,
	[BigIntValue] [bigint] NULL,
	[BitValue] [bit] NULL,
	[FloatValue] [float] NULL,
	[ImageValue] [varbinary](max) NULL,
	[IntValue] [int] NULL,
	[StringValue] [nvarchar](max) NULL,
	[StringHash] [int] NULL,
	[UniqueIdentifierValue] [uniqueidentifier] NULL,
	[PartitionId] [uniqueidentifier] NOT NULL,
	[CollectionKeyId] [int] NOT NULL,
	[ValueOrder] [int] NOT NULL,
	[DecimalValue] [decimal](38, 12) NULL,
 CONSTRAINT [PK_EntityValue] PRIMARY KEY NONCLUSTERED 
(
	[EntityValueId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
CREATE CLUSTERED INDEX [IX_EntityValueKey] ON [dbo].[EntityValue] 
(
	[EntityValueKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
CREATE NONCLUSTERED INDEX [IX_EntityValue_StringHash] ON [dbo].[EntityValue] 
(
	[StringHash] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
/****** Object:  Default [DF_EntityValue_ValueOrder]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[EntityValue] ADD  CONSTRAINT [DF_EntityValue_ValueOrder]  DEFAULT ((0)) FOR [ValueOrder]
GO
CREATE NONCLUSTERED INDEX [IX_Entity_PartitionId] ON [dbo].[Entity] 
(
	[PartitionId] ASC,
	[EntityId] ASC
)
INCLUDE ( [ObjectClassId],
[DN]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
CREATE NONCLUSTERED INDEX [IX_EntityValue_EntityId_PartitionId] ON [dbo].[EntityValue] 
(
	[PartitionId] ASC,
	[EntityId] ASC
)
INCLUDE ( [CollectionKeyId]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
CREATE NONCLUSTERED INDEX [IX_EntityValue_ValueTypes] ON [dbo].[EntityValue] 
(
	[CollectionKeyId] ASC,
	[PartitionId] ASC,
	[EntityId] ASC,
	[EntityValueId] ASC
)
INCLUDE ( [ValueType],
[BigIntValue],
[BitValue],
[FloatValue],
[IntValue],
[StringValue],
[UniqueIdentifierValue],
[ValueOrder],
[DecimalValue]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  ForeignKey [FK_Container_Container]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[Container]  WITH CHECK ADD  CONSTRAINT [FK_Container_Container] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON DELETE CASCADE
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Container] CHECK CONSTRAINT [FK_Container_Container]
GO
/****** Object:  ForeignKey [FK_Entity_ObjectClass]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_ObjectClass] FOREIGN KEY([ObjectClassId])
REFERENCES [dbo].[ObjectClass] ([ObjectClassId])
GO
ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_ObjectClass]
GO
/****** Object:  ForeignKey [FK_Entity_Partition]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Partition]
GO
/****** Object:  ForeignKey [FK_EntityValue_CollectionKey]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_CollectionKey] FOREIGN KEY([CollectionKeyId])
REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
GO
ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_CollectionKey]
GO
/****** Object:  ForeignKey [FK_EntityValue_Entity]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_Entity] FOREIGN KEY([EntityId], [PartitionId])
REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_Entity]
GO
/****** Object:  ForeignKey [FK_ObjectClass_Partition]    Script Date: 03/22/2010 13:34:56 ******/
ALTER TABLE [dbo].[ObjectClass]  WITH CHECK ADD  CONSTRAINT [FK_ObjectClass_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ObjectClass] CHECK CONSTRAINT [FK_ObjectClass_Partition]
GO
CREATE VIEW [dbo].[AdapterEntityChanges] AS
(SELECT     dbo.Entity.EntityKey, dbo.Entity.EntityId, C.AdapterId AS PartitionId, dbo.Entity.ObjectClassId, dbo.Entity.DN, C.ChangeTimestamp, 
                      dbo.Entity.PartitionId AS BaseReferenceId
FROM         dbo.Entity INNER JOIN
                      dbo.Changes AS C ON dbo.Entity.EntityId = C.EntityId
WHERE     (C.ChangesKey =
                          (SELECT     TOP (1) ChangesKey
                            FROM          dbo.Changes AS D
                            WHERE      (dbo.Entity.EntityId = EntityId)
                            ORDER BY ChangeTimestamp)) AND (dbo.Entity.ObjectClassId IS NULL) AND (dbo.Entity.DN IS NULL))
GO
/****** Table variables ******/
CREATE TYPE [dbo].[EntitySelectType] AS TABLE
(
	EntitySelectGroupId uniqueidentifier NOT NULL,
	EntityId uniqueidentifier NULL,
	PartitionId uniqueidentifier NULL,
	DN nvarchar(400) NULL,
	ObjectClassId int NULL
)
GO
CREATE TYPE [dbo].[EntityValueSelectType] AS TABLE
(
	ValueType int NOT NULL,
	BigIntValue bigint NULL,
	BitValue bit NULL,
	FloatValue float NULL,
	ImageValue varbinary(MAX) NULL,
	IntValue int NULL,
	StringValue nvarchar(MAX) NULL,
	StringHash int NULL,
	UniqueIdentifierValue uniqueidentifier NULL,
	EntityValueSelectId uniqueidentifier NOT NULL,
	ValueSequence int NOT NULL,
	ColumnSequence int NOT NULL,
	DecimalValue decimal(38,12) NULL
)
GO
CREATE TYPE [dbo].[ContainerSelectType] AS TABLE
(
	ContainerSelectGroupId uniqueidentifier NOT NULL,
	PartitionId uniqueidentifier NOT NULL,
	ContainerId uniqueidentifier NOT NULL,
	DistinguishedName nvarchar(400) NOT NULL
)
GO
CREATE TYPE [dbo].[ChangesSelectType] AS TABLE
(
	[ChangesSelectId] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[AdapterId] [uniqueidentifier] NOT NULL,
	[ChangeTimestamp] [bigint] NOT NULL
)
GO

/****** Stored procedures ******/
CREATE PROCEDURE [dbo].[InsertEntitySelectType]
(@EntitySelect as EntitySelectType READONLY)
AS
	EXECUTE sp_executesql N'INSERT INTO #EntitySelect (EntitySelectGroupId, EntityId, PartitionId, DN, ObjectClassId) SELECT EntitySelectGroupId, EntityId, PartitionId, DN, ObjectClassId FROM @thisEntitySelect', N'@thisEntitySelect EntitySelectType READONLY', @EntitySelect
GO
CREATE PROCEDURE [dbo].[InsertEntityValueSelectType]
(@EntityValueSelect as EntityValueSelectType READONLY)
AS
	EXECUTE sp_executesql N'INSERT INTO #EntityValueSelect (ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue) SELECT ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue FROM @thisEntityValueSelect', N'@thisEntityValueSelect EntityValueSelectType READONLY', @EntityValueSelect
GO
CREATE PROCEDURE [dbo].[InsertContainerSelectType]
(@ContainerSelect as ContainerSelectType READONLY)
AS
	EXECUTE sp_executesql N'INSERT INTO #ContainerSelect (ContainerSelectGroupId, PartitionId, ContainerId, DistinguishedName) SELECT ContainerSelectGroupId, PartitionId, ContainerId, DistinguishedName FROM @thisContainerSelect', N'@thisContainerSelect ContainerSelectType READONLY', @ContainerSelect
GO
CREATE PROCEDURE [dbo].[InsertChangesSelectType]
(@ChangesSelect as ChangesSelectType READONLY)
AS
	EXECUTE sp_executesql N'INSERT INTO #ChangesSelect (ChangesSelectId, EntityId, AdapterId, ChangeTimestamp) SELECT ChangesSelectId, EntityId, AdapterId, ChangeTimestamp FROM @thisChangesSelect', N'@thisChangesSelect ChangesSelectType READONLY', @ChangesSelect
GO
