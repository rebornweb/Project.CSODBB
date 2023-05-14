/****** Object:  Table [dbo].[CollectionKey] ******/
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
/****** Object:  Table [dbo].[Changes] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Changes](
    [ChangesKey] [bigint] IDENTITY(1, 1),
    [EntityId] [uniqueidentifier] NOT NULL,
    [AdapterId] [uniqueidentifier] NOT NULL,
    [ChangeTimestamp] [bigint] NOT NULL,
 CONSTRAINT [PK_Changes_Identity] PRIMARY KEY CLUSTERED
    (
        [ChangesKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
 )
GO
/****** Object:  Table [dbo].[ChangeLog] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ChangeLog](
    [ChangeLogKey] [bigint] IDENTITY(1, 1),
    [AdapterId] [uniqueidentifier] NOT NULL,
    [ChangeType] [tinyint] NOT NULL,
    [ChangeTimestamp] [datetime2] NOT NULL,
    [TargetDistinguishedName] [nvarchar](400) NOT NULL,
    [NewDistinguishedName] [nvarchar](400) NULL,
    [Changes] [nvarchar](MAX) NULL,
 CONSTRAINT [PK_ChangeLog_Identity] PRIMARY KEY CLUSTERED
    (
        [ChangeLogKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
 )
GO
CREATE NONCLUSTERED INDEX [IX_ChangeLog_AdapterId] ON [dbo].[ChangeLog]
(
    [AdapterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Table [dbo].[StoredValueCollection] ******/
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
/****** Object:  Table [dbo].[Partition] ******/
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
/****** Object:  Table [dbo].[Container] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Container](
    [Id] [hierarchyid] NOT NULL,
    [ContainerId] [uniqueidentifier] NOT NULL,
    [DistinguishedName] [nvarchar](400) NOT NULL,
    [CreatedTime] [datetime2] NOT NULL,
    [ModifiedTime] [datetime2] NOT NULL,
    [PartitionId] [uniqueidentifier] NOT NULL,
    [Required] [bit] NOT NULL,
 CONSTRAINT [PK_Container] PRIMARY KEY CLUSTERED
(
    [Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Container_ContainerId] ON [dbo].[Container]
(
    [ContainerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Container_DistinguishedName] ON [dbo].[Container]
(
    [DistinguishedName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
CREATE NONCLUSTERED INDEX [IX_Container_CreatedTime] ON [dbo].[Container]
(
    [CreatedTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
CREATE NONCLUSTERED INDEX [IX_Container_ModifiedTime] ON [dbo].[Container]
(
    [ModifiedTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Table [dbo].[ObjectClass] ******/
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
/****** Object:  Table [dbo].[Entity] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Entity](
    [EntityKey] [bigint] IDENTITY(1,1) NOT NULL,
    [EntityId] [uniqueidentifier] NOT NULL,
    [PartitionId] [uniqueidentifier] NOT NULL,
    [CreatedTime] [datetime2] NULL,
    [ModifiedTime] [datetime2] NULL,
    [ContainerId] [uniqueidentifier] NULL,
    [ObjectClassId] [int] NULL,
    [DN] [nvarchar](400) NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY NONCLUSTERED
(
    [EntityId] ASC,
    [PartitionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
GO
CREATE UNIQUE CLUSTERED INDEX [IX_EntityKey] ON [dbo].[Entity]
(
    [EntityKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
CREATE NONCLUSTERED INDEX [IX_Entity_ContainerId] ON [dbo].[Entity]
(
    [ContainerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
CREATE NONCLUSTERED INDEX [IX_Entity_CreatedTime] ON [dbo].[Entity]
(
    [CreatedTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
CREATE NONCLUSTERED INDEX [IX_Entity_ModifiedTime] ON [dbo].[Entity]
(
    [ModifiedTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Table [dbo].[EntityValue] ******/
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
CREATE UNIQUE CLUSTERED INDEX [IX_EntityValueKey] ON [dbo].[EntityValue]
(
    [EntityValueKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
CREATE NONCLUSTERED INDEX [IX_EntityValue_StringHash] ON [dbo].[EntityValue]
(
    [StringHash] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
/****** Object:  Default [DF_EntityValue_ValueOrder] ******/
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

/****** Object:  Table [dbo].[EntityValueOrigin] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EntityValueOrigin](
    [EntityValueOriginKey] [bigint] IDENTITY(1,1) NOT NULL,
    [EntityId] [uniqueidentifier] NOT NULL,
    [PartitionId] [uniqueidentifier] NOT NULL,
    [CollectionKeyId] [int] NOT NULL,
    [SourceEntityId] [uniqueidentifier],
    [SourcePartitionId] [uniqueidentifier],
    [SourceCollectionKeyId] [int],
    CONSTRAINT [PK_EntityValueOrigin_Identity] PRIMARY KEY CLUSTERED
    (
        [EntityValueOriginKey] ASC
    )
    WITH
    (
        PAD_INDEX = OFF,
        STATISTICS_NORECOMPUTE = OFF,
        IGNORE_DUP_KEY = OFF,
        ALLOW_ROW_LOCKS = ON,
        ALLOW_PAGE_LOCKS = ON
    )
)
GO

CREATE NONCLUSTERED INDEX [IX_EntityValueOrigin_EntityId] ON [dbo].[EntityValueOrigin]
(
    [EntityId] ASC,
    [PartitionId] ASC,
    [CollectionKeyId] ASC
)
WITH
(
    PAD_INDEX = OFF,
    STATISTICS_NORECOMPUTE = OFF,
    SORT_IN_TEMPDB = OFF,
    IGNORE_DUP_KEY = OFF,
    DROP_EXISTING = OFF,
    ONLINE = OFF,
    ALLOW_ROW_LOCKS = ON,
    ALLOW_PAGE_LOCKS = ON
)
GO

/****** Object:  ForeignKey [FK_Entity_Partition] ******/
ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Partition]
GO
/****** Object:  ForeignKey [FK_Entity_Container] ******/
ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Container] FOREIGN KEY([ContainerId])
REFERENCES [dbo].[Container] ([ContainerId])
ON DELETE NO ACTION
ON UPDATE NO ACTION
GO
ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Container]
GO
/****** Object:  ForeignKey [FK_Entity_ObjectClass] ******/
ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_ObjectClass] FOREIGN KEY([ObjectClassId])
REFERENCES [dbo].[ObjectClass] ([ObjectClassId])
GO
ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_ObjectClass]
GO
/****** Object:  ForeignKey [FK_Container_Partition] ******/
ALTER TABLE [dbo].[Container]  WITH CHECK ADD  CONSTRAINT [FK_Container_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Container] CHECK CONSTRAINT [FK_Container_Partition]
GO
/****** Object:  ForeignKey [FK_EntityValue_CollectionKey] ******/
ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_CollectionKey] FOREIGN KEY([CollectionKeyId])
REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
GO
ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_CollectionKey]
GO
/****** Object:  ForeignKey [FK_EntityValue_Entity] ******/
ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_Entity] FOREIGN KEY([EntityId], [PartitionId])
REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_Entity]
GO
/****** Object:  ForeignKey [FK_ObjectClass_Partition] ******/
ALTER TABLE [dbo].[ObjectClass]  WITH CHECK ADD  CONSTRAINT [FK_ObjectClass_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ObjectClass] CHECK CONSTRAINT [FK_ObjectClass_Partition]
GO
/****** Object:  ForeignKey [FK_ChangeLog_Partition] ******/
ALTER TABLE [dbo].[ChangeLog]  WITH CHECK ADD  CONSTRAINT [FK_ChangeLog_Partition] FOREIGN KEY([AdapterId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ChangeLog] CHECK CONSTRAINT [FK_ChangeLog_Partition]
GO
/****** Object:  ForeignKey [FK_EntityValueOrigin_Entity] ******/
ALTER TABLE [dbo].[EntityValueOrigin] WITH CHECK ADD CONSTRAINT [FK_EntityValueOrigin_Entity] FOREIGN KEY([EntityId], [PartitionId])
REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
ON DELETE CASCADE
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[EntityValueOrigin] CHECK CONSTRAINT [FK_EntityValueOrigin_Entity]
GO
/****** Object:  ForeignKey [FK_EntityValueOrigin_CollectionKeyId] ******/
ALTER TABLE [dbo].[EntityValueOrigin] WITH CHECK ADD CONSTRAINT [FK_EntityValueOrigin_CollectionKeyId] FOREIGN KEY([CollectionKeyId])
REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
ON DELETE CASCADE
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[EntityValueOrigin] CHECK CONSTRAINT [FK_EntityValueOrigin_CollectionKeyId]
GO
/****** Object:  ForeignKey [FK_EntityValueOrigin_SourceCollectionKeyId] ******/
ALTER TABLE [dbo].[EntityValueOrigin] WITH CHECK ADD CONSTRAINT [FK_EntityValueOrigin_SourceCollectionKeyId] FOREIGN KEY([SourceCollectionKeyId])
REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
ON DELETE NO ACTION
ON UPDATE NO ACTION
GO
ALTER TABLE [dbo].[EntityValueOrigin] CHECK CONSTRAINT [FK_EntityValueOrigin_SourceCollectionKeyId]
GO

/****** Stored procedures ******/
CREATE PROCEDURE AddChildContainer
    @ParentDistinguishedName nvarchar(400),
    @ContainerId uniqueidentifier,
    @DistinguishedName nvarchar(400),
    @CreatedTime datetime2,
    @ModifiedTime datetime2,
    @PartitionId uniqueidentifier,
    @Required bit
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Parent hierarchyid;
    DECLARE @LastChild hierarchyid;
    SELECT @Parent = [Id] FROM [Container] WHERE [DistinguishedName] = @ParentDistinguishedName
    SELECT @LastChild = MAX([Id]) FROM [Container] WHERE [Id].GetAncestor(1) = @Parent

    INSERT INTO [dbo].[Container]
               ([Id], [ContainerId], [DistinguishedName], [CreatedTime], [ModifiedTime], [PartitionId], [Required])
         VALUES
               (@Parent.GetDescendant(@LastChild, NULL), @ContainerId, @DistinguishedName, @CreatedTime, @ModifiedTime, @PartitionId, @Required)
END
GO

CREATE PROCEDURE GetContainersBaseLevel
    @DistinguishedName nvarchar(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [Id].ToString() AS [Path], [Id].GetLevel() AS [Level], [ContainerId], [DistinguishedName] FROM [Container] WHERE [DistinguishedName] = @DistinguishedName
END
GO

CREATE PROCEDURE GetContainersSubTree
    @ParentDistinguishedName nvarchar(400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ParentId hierarchyid;
    SELECT @ParentId = [Id] FROM [Container] WHERE [DistinguishedName] = @ParentDistinguishedName

    SELECT [Id].ToString() AS [Path], [Id].GetLevel() AS [Level], [ContainerId], [DistinguishedName] FROM [Container] WHERE [Id].IsDescendantOf(@ParentId) = 1
END
GO

CREATE PROCEDURE GetContainersOneLevel
    @ParentDistinguishedName nvarchar(400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ParentId hierarchyid;
    SELECT @ParentId = [Id] FROM [Container] WHERE [DistinguishedName] = @ParentDistinguishedName

    SELECT [Id].ToString() AS [Path], [Id].GetLevel() AS [Level], [ContainerId], [DistinguishedName] FROM [Container] WHERE [Id].IsDescendantOf(@ParentId) = 1 AND [Id].GetLevel() <= @ParentId.GetLevel() + 1
END
GO

CREATE PROCEDURE SetRequired
    @DistinguishedName nvarchar(400),
    @Required bit
AS
BEGIN
    UPDATE [dbo].[Container] SET [Required] = @Required WHERE [DistinguishedName] = @DistinguishedName
END
GO
/****** Table variables ******/
CREATE TYPE [dbo].[EntitySelectType] AS TABLE
(
    [EntitySelectGroupId] uniqueidentifier NOT NULL,
    [EntityId] uniqueidentifier NULL,
    [PartitionId] uniqueidentifier NULL,
    [ContainerId] uniqueidentifier NULL,
    [DN] nvarchar(400) NULL,
    [ObjectClassId] int NULL
)
GO
CREATE TYPE [dbo].[EntityValueSelectType] AS TABLE
(
    [ValueType] int NOT NULL,
    [BigIntValue] bigint NULL,
    [BitValue] bit NULL,
    [FloatValue] float NULL,
    [ImageValue] varbinary(MAX) NULL,
    [IntValue] int NULL,
    [StringValue] nvarchar(MAX) NULL,
    [StringHash] int NULL,
    [UniqueIdentifierValue] uniqueidentifier NULL,
    [EntityValueSelectId] uniqueidentifier NOT NULL,
    [ValueSequence] int NOT NULL,
    [ColumnSequence] int NOT NULL,
    [DecimalValue] decimal(38,12) NULL
)
GO
CREATE TYPE [dbo].[ContainerSelectType] AS TABLE
(
    [ContainerSelectId] bigint NOT NULL,
    [ContainerSelectGroupId] uniqueidentifier NOT NULL,
    [ContainerId] uniqueidentifier NULL,
    [DistinguishedName] nvarchar(400) NULL,
    [PartitionId] uniqueidentifier NULL,
    [Required] bit NULL
)
GO
CREATE TYPE [dbo].[ContainerInsertType] AS TABLE
(
    [ContainerId] [uniqueidentifier] NOT NULL,
    [DistinguishedName] [nvarchar](400) NOT NULL,
    [Level] [int] NOT NULL,
    [ParentDistinguishedName] [nvarchar](400) NOT NULL,
    [CreatedTime] [datetime2] NOT NULL,
    [ModifiedTime] [datetime2] NOT NULL,
    [PartitionId] [uniqueidentifier] NOT NULL,
    [Required] [bit] NOT NULL
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

CREATE TYPE [dbo].[EntityValueOriginSelectType] AS TABLE
(
    [EntityValueOriginSelectId] [uniqueidentifier] NOT NULL,
    [EntityId] [uniqueidentifier],
    [PartitionId] [uniqueidentifier],
    [CollectionKeyId] [int],
    [SourceEntityId] [uniqueidentifier],
    [SourcePartitionId] [uniqueidentifier],
    [SourceCollectionKeyId] [int]
)
GO

/****** Stored procedures ******/
CREATE PROCEDURE [dbo].[InsertEntitySelectType]
(@EntitySelect as EntitySelectType READONLY)
AS
    EXECUTE sp_executesql N'INSERT INTO #EntitySelect (EntitySelectGroupId, EntityId, PartitionId, ContainerId, DN, ObjectClassId) SELECT EntitySelectGroupId, EntityId, PartitionId, ContainerId, DN, ObjectClassId FROM @thisEntitySelect', N'@thisEntitySelect EntitySelectType READONLY', @EntitySelect
GO
CREATE PROCEDURE [dbo].[InsertEntityValueSelectType]
(@EntityValueSelect as EntityValueSelectType READONLY)
AS
    EXECUTE sp_executesql N'INSERT INTO #EntityValueSelect (ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue) SELECT ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue FROM @thisEntityValueSelect', N'@thisEntityValueSelect EntityValueSelectType READONLY', @EntityValueSelect
GO
CREATE PROCEDURE [dbo].[InsertContainerSelectType]
(@ContainerSelect as ContainerSelectType READONLY)
AS
    EXECUTE sp_executesql N'INSERT INTO #ContainerSelect (ContainerSelectGroupId, ContainerId, DistinguishedName, PartitionId, Required) SELECT ContainerSelectGroupId, ContainerId, DistinguishedName, PartitionId, Required FROM @thisContainerSelect', N'@thisContainerSelect ContainerSelectType READONLY', @ContainerSelect
GO
CREATE PROCEDURE [dbo].[InsertContainerInsertType]
(@ContainerInsert as ContainerInsertType READONLY)
AS
    EXECUTE sp_executesql N'INSERT INTO #ContainerInsert (ContainerId, DistinguishedName, Level, ParentDistinguishedName, CreatedTime, ModifiedTime, PartitionId, Required) SELECT ContainerId, DistinguishedName, Level, ParentDistinguishedName, CreatedTime, ModifiedTime, PartitionId, Required FROM @thisContainerInsert', N'@thisContainerInsert ContainerInsertType READONLY', @ContainerInsert
GO
CREATE PROCEDURE [dbo].[InsertChangesSelectType]
(@ChangesSelect as ChangesSelectType READONLY)
AS
    EXECUTE sp_executesql N'INSERT INTO #ChangesSelect (ChangesSelectId, EntityId, AdapterId, ChangeTimestamp) SELECT ChangesSelectId, EntityId, AdapterId, ChangeTimestamp FROM @thisChangesSelect', N'@thisChangesSelect ChangesSelectType READONLY', @ChangesSelect
GO
CREATE PROCEDURE [dbo].[InsertEntityValueOriginSelectType]
(@OriginSelect as EntityValueOriginSelectType READONLY)
AS
    EXECUTE sp_executesql N'INSERT INTO #EntityValueOriginSelect (EntityValueOriginSelectId, EntityId, PartitionId, CollectionKeyId, SourceEntityId, SourcePartitionId, SourceCollectionKeyId) SELECT EntityValueOriginSelectId, EntityId, PartitionId, CollectionKeyId, SourceEntityId, SourcePartitionId, SourceCollectionKeyId FROM @thisOriginSelect', N'@thisOriginSelect EntityValueOriginSelectType READONLY', @OriginSelect
GO
