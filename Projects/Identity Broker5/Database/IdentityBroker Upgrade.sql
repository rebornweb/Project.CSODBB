SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Check Version--
DECLARE @v303 BIT
DECLARE @v50 BIT
DECLARE @v51 BIT

SET @v303 = 0
SET @v50 = 0
SET @v51 = 0

--NOTE: All versions that require upgrade must be set.
IF (SELECT COUNT(*) FROM sys.columns WHERE name = 'StoredValueCollectionKey') = 0
BEGIN
    SET @v303 = 1
    SET @v50 = 1
    SET @v51 = 1
END
IF (SELECT COUNT(*) FROM sys.objects WHERE name = 'SetRequired') = 0
BEGIN
    SET @v50 = 1
    SET @v51 = 1
END
IF (SELECT COUNT(*) FROM sys.objects WHERE name = 'EntityValueOrigin') = 0
BEGIN
    SET @v51 = 1
END

--Clean up--
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'ChangesSelect')
BEGIN
    EXEC('DROP TABLE ChangesSelect')
END
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'EntityValueSelect')
BEGIN
    EXEC('DROP TABLE EntityValueSelect')
END
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'EntitySelect')
BEGIN
    EXEC('DROP TABLE EntitySelect')
END

--Upgrades--
IF @v303 = 1
BEGIN
    IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_StoredValueCollection')
    BEGIN
        EXEC('ALTER TABLE [StoredValueCollection] DROP CONSTRAINT [PK_StoredValueCollection]')
    END

    IF EXISTS (SELECT * FROM sys.indexes WHERE name = '_dta_index_Entity_c_7_149575571__K1')
    BEGIN
        EXEC('DROP INDEX Entity._dta_index_Entity_c_7_149575571__K1')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Entity_ObjectClass_PartitionId')
    BEGIN
        EXEC('DROP INDEX Entity.IX_Entity_ObjectClass_PartitionId')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = '_dta_index_EntityValue_7_181575685__K13_K12_K2_1_3_4_5_6_8_9_11')
    BEGIN
        EXEC('DROP INDEX EntityValue._dta_index_EntityValue_7_181575685__K13_K12_K2_1_3_4_5_6_8_9_11')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = '_dta_index_EntityValue_c_7_181575685__K2')
    BEGIN
        EXEC('DROP INDEX EntityValue._dta_index_EntityValue_c_7_181575685__K2')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityValue_IntValue')
    BEGIN
        EXEC('DROP INDEX EntityValue.IX_EntityValue_IntValue')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityValue_PartitionId')
    BEGIN
        EXEC('DROP INDEX EntityValue.IX_EntityValue_PartitionId')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityValue_StringValue')
    BEGIN
        EXEC('DROP INDEX EntityValue.IX_EntityValue_StringValue')
    END

    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_EntityValue_CollectionKey')
    BEGIN
        EXEC('ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_CollectionKey]')
    END
    IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_CollectionKey')
    BEGIN
        EXEC('ALTER TABLE [CollectionKey] DROP CONSTRAINT [PK_CollectionKey]')
    END
    EXEC('ALTER TABLE [dbo].[CollectionKey]  ADD  CONSTRAINT [PK_CollectionKey] PRIMARY KEY CLUSTERED ([CollectionKeyId] ASC)')

    EXEC('sp_rename ''StoredValueCollection'', ''StoredValueCollection_bak''')

    CREATE TABLE [dbo].[StoredValueCollection](
        [StoredValueCollectionKey] [bigint] IDENTITY(1,1) NOT NULL,
        [StoredValueCollectionId] [uniqueidentifier] NOT NULL,
        [Values] [nvarchar](max) NOT NULL,
     CONSTRAINT [PK_StoredValueCollection] PRIMARY KEY NONCLUSTERED
        (
            [StoredValueCollectionId] ASC
        )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
    )

    EXEC('INSERT INTO StoredValueCollection (
        [StoredValueCollectionId],
        [Values]
    )
    SELECT
        [StoredValueCollectionId],
        [Values]
    FROM StoredValueCollection_bak

    UPDATE StoredValueCollection SET [Values] = REPLACE([Values], ''/Unify.Framework"'', ''/Unify.Framework.StoredValues"'')')

    --Update IdentityBroker ValueTypes
    UPDATE EntityValue
    SET ValueType = 0
    WHERE ValueType = 128

    UPDATE EntityValue
    SET ValueType = POWER(2, (ValueType))
    WHERE ValueType < 128

    UPDATE EntityValue
    SET ValueType = POWER(2, (ValueType - 128)) + 1
    WHERE ValueType > 128 AND ValueType < 256

    EXEC('CREATE CLUSTERED INDEX [IX_StoredValueCollectionKey] ON [dbo].[StoredValueCollection]
    (
        [StoredValueCollectionKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
END

IF @v50 = 1
BEGIN
    IF (SELECT COUNT(*) FROM sys.views WHERE name = 'AdapterEntityChanges') > 0
    BEGIN
        EXEC('DROP VIEW AdapterEntityChanges')
    END

    IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Changes_Identity')
    BEGIN
        EXEC('ALTER TABLE [Changes] DROP CONSTRAINT [PK_Changes_Identity]')
    END
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_EntityValue_Entity')
    BEGIN
        EXEC('ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_Entity]')
    END
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_EntityValue_CollectionKey')
    BEGIN
        EXEC('ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_CollectionKey]')
    END
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Entity_ObjectClass')
    BEGIN
        EXEC('ALTER TABLE [Entity] DROP CONSTRAINT [FK_Entity_ObjectClass]')
    END
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Entity_Partition')
    BEGIN
        EXEC('ALTER TABLE [Entity] DROP CONSTRAINT [FK_Entity_Partition]')
    END
    IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Entity')
    BEGIN
        EXEC('ALTER TABLE [Entity] DROP CONSTRAINT [PK_Entity]')
    END
    IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_EntityValue')
    BEGIN
        EXEC('ALTER TABLE [EntityValue] DROP CONSTRAINT [PK_EntityValue]')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityValueKey')
    BEGIN
        EXEC('DROP INDEX EntityValue.IX_EntityValueKey')
    END
    IF EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'DF_EntityValue_ValueOrder')
    BEGIN
        EXEC('ALTER TABLE [EntityValue] DROP CONSTRAINT [DF_EntityValue_ValueOrder]')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Entity_PartitionId')
    BEGIN
        EXEC('DROP INDEX Entity.IX_Entity_PartitionId')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityValue_EntityId_PartitionId')
    BEGIN
        EXEC('DROP INDEX EntityValue.IX_EntityValue_EntityId_PartitionId')
    END
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityValue_ValueTypes')
    BEGIN
        EXEC('DROP INDEX EntityValue.IX_EntityValue_ValueTypes')
    END

    EXEC('sp_rename ''Entity'', ''Entity_bak''')

    EXEC('CREATE TABLE [dbo].[Entity](
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
    )')

    EXEC('INSERT INTO Entity (
        [EntityId],
        [PartitionId],
        [CreatedTime],
        [ModifiedTime],
        [ObjectClassId],
        [DN]
    )
    SELECT
        [EntityId],
        [PartitionId],
        GETDATE(),
        GETDATE(),
        [ObjectClassId],
        [DN] [nvarchar]
    FROM Entity_bak')

    EXEC('sp_rename ''EntityValue'', ''EntityValue_bak''')

    EXEC('CREATE TABLE [dbo].[EntityValue](
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
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON))')

    EXEC('INSERT INTO EntityValue (
        [EntityValueId],
        [EntityId],
        [ValueType],
        [BigIntValue],
        [BitValue],
        [FloatValue],
        [ImageValue],
        [IntValue],
        [StringValue],
        [StringHash],
        [UniqueIdentifierValue],
        [PartitionId],
        [CollectionKeyId],
        [ValueOrder],
        [DecimalValue]
    )
    SELECT
        [EntityValueId],
        [EntityId],
        [ValueType],
        [BigIntValue],
        [BitValue],
        [FloatValue],
        [ImageValue],
        [IntValue],
        [StringValue],
        CAST(HASHBYTES(''MD5'', [StringValue]) AS INT),
        [UniqueIdentifierValue],
        [PartitionId],
        [CollectionKeyId],
        [ValueOrder],
        [DecimalValue]
    FROM EntityValue_bak')

    EXEC('DROP TABLE Entity_bak')
    EXEC('DROP TABLE EntityValue_bak')

    EXEC('sp_rename ''Changes'', ''Changes_bak''')

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

    EXEC('INSERT INTO [Changes] (
        [EntityId],
        [AdapterId],
        [ChangeTimestamp])
     SELECT
        [EntityId],
        [AdapterId],
        [ChangeTimestamp]
     FROM Changes_bak')

    EXEC('DROP TABLE Changes_bak')

    EXEC('CREATE UNIQUE CLUSTERED INDEX [IX_EntityKey] ON [dbo].[Entity]
    (
        [EntityKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_ContainerId] ON [dbo].[Entity]
    (
        [ContainerId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_CreatedTime] ON [dbo].[Entity]
    (
        [CreatedTime] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_ModifiedTime] ON [dbo].[Entity]
    (
        [ModifiedTime] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)')

    EXEC('ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Partition] FOREIGN KEY([PartitionId])
    REFERENCES [dbo].[Partition] ([PartitionId])
    ON UPDATE CASCADE
    ON DELETE CASCADE')
    EXEC('ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Partition]')

    EXEC('ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_ObjectClass] FOREIGN KEY([ObjectClassId])
    REFERENCES [dbo].[ObjectClass] ([ObjectClassId])')
    EXEC('ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_ObjectClass]')

    EXEC('CREATE UNIQUE CLUSTERED INDEX [IX_EntityValueKey] ON [dbo].[EntityValue]
    (
        [EntityValueKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('ALTER TABLE [dbo].[EntityValue] ADD  CONSTRAINT [DF_EntityValue_ValueOrder]  DEFAULT ((0)) FOR [ValueOrder]')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_PartitionId] ON [dbo].[Entity]
    (
        [PartitionId] ASC,
        [EntityId] ASC
    )
    INCLUDE ( [ObjectClassId],
    [DN]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_EntityId_PartitionId] ON [dbo].[EntityValue]
    (
        [PartitionId] ASC,
        [EntityId] ASC
    )
    INCLUDE ( [CollectionKeyId]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_ValueTypes] ON [dbo].[EntityValue]
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
    [DecimalValue]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_StringHash] ON [dbo].[EntityValue]
    (
        [StringHash] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_CollectionKey] FOREIGN KEY([CollectionKeyId])
    REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])')
    EXEC('ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_CollectionKey]')
    EXEC('ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_Entity] FOREIGN KEY([EntityId], [PartitionId])
    REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
    ON UPDATE CASCADE
    ON DELETE CASCADE')
    EXEC('ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_Entity]')

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

    CREATE NONCLUSTERED INDEX [IX_ChangeLog_AdapterId] ON [dbo].[ChangeLog]
    (
        [AdapterId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

    ALTER TABLE [dbo].[ChangeLog]  WITH CHECK ADD  CONSTRAINT [FK_ChangeLog_Partition] FOREIGN KEY([AdapterId])
    REFERENCES [dbo].[Partition] ([PartitionId])
    ON UPDATE CASCADE
    ON DELETE CASCADE
    ALTER TABLE [dbo].[ChangeLog] CHECK CONSTRAINT [FK_ChangeLog_Partition]

    IF (SELECT COUNT(*) FROM sys.objects WHERE name = 'Container') > 0
    BEGIN
        EXEC('DROP TABLE Container')
    END

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
    CREATE UNIQUE NONCLUSTERED INDEX [IX_Container_ContainerId] ON [dbo].[Container]
    (
        [ContainerId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    CREATE UNIQUE NONCLUSTERED INDEX [IX_Container_DistinguishedName] ON [dbo].[Container]
    (
        [DistinguishedName] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    CREATE NONCLUSTERED INDEX [IX_Container_CreatedTime] ON [dbo].[Container]
    (
        [CreatedTime] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    CREATE NONCLUSTERED INDEX [IX_Container_ModifiedTime] ON [dbo].[Container]
    (
        [ModifiedTime] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

    ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Container] FOREIGN KEY([ContainerId])
    REFERENCES [dbo].[Container] ([ContainerId])
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Container]

    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('InsertEntityValueSelectType'))
    BEGIN
        EXEC('DROP PROCEDURE InsertEntityValueSelectType')
    END
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('InsertChangesSelectType'))
    BEGIN
        EXEC('DROP PROCEDURE InsertChangesSelectType')
    END
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('InsertEntitySelectType'))
    BEGIN
        EXEC('DROP PROCEDURE InsertEntitySelectType')
    END
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('InsertContainerSelectType'))
    BEGIN
        EXEC('DROP PROCEDURE InsertContainerSelectType')
    END
    IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'EntityValueSelectType')
    BEGIN
        EXEC('DROP TYPE EntityValueSelectType')
    END
    IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'EntitySelectType')
    BEGIN
        EXEC('DROP TYPE EntitySelectType')
    END
    IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'ContainerSelectType')
    BEGIN
        EXEC('DROP TYPE ContainerSelectType')
    END

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
    IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'ChangesSelectType')
    BEGIN
        EXEC('DROP TYPE ChangesSelectType')
    END
    CREATE TYPE [dbo].[ChangesSelectType] AS TABLE
    (
        [ChangesSelectId] [uniqueidentifier] NOT NULL,
        [EntityId] [uniqueidentifier] NOT NULL,
        [AdapterId] [uniqueidentifier] NOT NULL,
        [ChangeTimestamp] [bigint] NOT NULL
    )
    EXEC('CREATE PROCEDURE [dbo].[InsertEntityValueSelectType]
    (@EntityValueSelect as EntityValueSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #EntityValueSelect (ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue) SELECT ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue FROM @thisEntityValueSelect'', N''@thisEntityValueSelect EntityValueSelectType READONLY'', @EntityValueSelect')
    EXEC('CREATE PROCEDURE [dbo].[InsertChangesSelectType]
    (@ChangesSelect as ChangesSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #ChangesSelect (ChangesSelectId, EntityId, AdapterId, ChangeTimestamp) SELECT ChangesSelectId, EntityId, AdapterId, ChangeTimestamp FROM @thisChangesSelect'', N''@thisChangesSelect ChangesSelectType READONLY'', @ChangesSelect')
    CREATE TYPE [dbo].[EntitySelectType] AS TABLE
    (
        [EntitySelectGroupId] uniqueidentifier NOT NULL,
        [EntityId] uniqueidentifier NULL,
        [PartitionId] uniqueidentifier NULL,
        [ContainerId] uniqueidentifier NULL,
        [DN] nvarchar(400) NULL,
        [ObjectClassId] int NULL
    )
    EXEC('CREATE PROCEDURE [dbo].[InsertEntitySelectType]
    (@EntitySelect as EntitySelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #EntitySelect (EntitySelectGroupId, EntityId, PartitionId, ContainerId, DN, ObjectClassId) SELECT EntitySelectGroupId, EntityId, PartitionId, ContainerId, DN, ObjectClassId FROM @thisEntitySelect'', N''@thisEntitySelect EntitySelectType READONLY'', @EntitySelect')
    CREATE TYPE [dbo].[ContainerSelectType] AS TABLE
    (
        [ContainerSelectId] bigint NOT NULL,
        [ContainerSelectGroupId] uniqueidentifier NOT NULL,
        [ContainerId] uniqueidentifier NULL,
        [DistinguishedName] nvarchar(400) NULL,
        [PartitionId] uniqueidentifier NULL,
        [Required] bit NULL
    )
    EXEC('CREATE PROCEDURE [dbo].[InsertContainerSelectType]
    (@ContainerSelect as ContainerSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #ContainerSelect (ContainerSelectGroupId, ContainerId, DistinguishedName, PartitionId, Required) SELECT ContainerSelectGroupId, ContainerId, DistinguishedName, PartitionId, Required FROM @thisContainerSelect'', N''@thisContainerSelect ContainerSelectType READONLY'', @ContainerSelect')

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
    EXEC('CREATE PROCEDURE [dbo].[InsertContainerInsertType]
    (@ContainerInsert as ContainerInsertType READONLY)
    AS
       EXECUTE sp_executesql N''INSERT INTO #ContainerInsert (ContainerId, DistinguishedName, Level, ParentDistinguishedName, CreatedTime, ModifiedTime, PartitionId, Required) SELECT ContainerId, DistinguishedName, Level, ParentDistinguishedName, CreatedTime, ModifiedTime, PartitionId, Required FROM @thisContainerInsert'', N''@thisContainerInsert ContainerInsertType READONLY'', @ContainerInsert')

    EXEC('CREATE PROCEDURE [dbo].[AddChildContainer]
    (@ParentDistinguishedName nvarchar(400), @ContainerId uniqueidentifier, @DistinguishedName nvarchar(400), @CreatedTime datetime2, @ModifiedTime datetime2, @PartitionId uniqueidentifier, @Required bit)
    AS
        BEGIN
            SET NOCOUNT ON;

            DECLARE @Parent hierarchyid;
            DECLARE @LastChild hierarchyid;
            SELECT @Parent = [Id] FROM [Container] WHERE [DistinguishedName] = @ParentDistinguishedName
            SELECT @LastChild = MAX([Id]) FROM [Container] WHERE [Id].GetAncestor(1) = @Parent

            INSERT INTO [dbo].[Container] ([Id], [ContainerId], [DistinguishedName], [CreatedTime], [ModifiedTime], [PartitionId], [Required])
            VALUES (@Parent.GetDescendant(@LastChild, NULL), @ContainerId, @DistinguishedName, @CreatedTime, @ModifiedTime, @PartitionId, @Required)
        END')

    EXEC('CREATE PROCEDURE [dbo].[GetContainersBaseLevel] (@DistinguishedName nvarchar(400)) AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [Id].ToString() AS [Path], [Id].GetLevel() AS [Level], [ContainerId], [DistinguishedName] FROM [Container] WHERE [DistinguishedName] = @DistinguishedName
    END')

    EXEC('CREATE PROCEDURE [dbo].[GetContainersSubTree] (@ParentDistinguishedName nvarchar(400)) AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ParentId hierarchyid;
        SELECT @ParentId = [Id] FROM [Container] WHERE [DistinguishedName] = @ParentDistinguishedName
        SELECT [Id].ToString() AS [Path], [Id].GetLevel() AS [Level], [ContainerId], [DistinguishedName] FROM [Container] WHERE [Id].IsDescendantOf(@ParentId) = 1
    END')

    EXEC('CREATE PROCEDURE [dbo].[GetContainersOneLevel] (@ParentDistinguishedName nvarchar(400)) AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ParentId hierarchyid;
        SELECT @ParentId = [Id] FROM [Container] WHERE [DistinguishedName] = @ParentDistinguishedName
        SELECT [Id].ToString() AS [Path], [Id].GetLevel() AS [Level], [ContainerId], [DistinguishedName] FROM [Container] WHERE [Id].IsDescendantOf(@ParentId) = 1 AND [Id].GetLevel() <= @ParentId.GetLevel() + 1
    END')

    EXEC('CREATE PROCEDURE [dbo].[SetRequired] (@DistinguishedName nvarchar(400), @Required bit) AS
    BEGIN
        UPDATE [dbo].[Container] SET [Required] = @Required WHERE [DistinguishedName] = @DistinguishedName
    END')

END


IF @v51 = 1
BEGIN
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
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    )
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

    ALTER TABLE [dbo].[EntityValueOrigin] WITH CHECK ADD CONSTRAINT [FK_EntityValueOrigin_Entity] FOREIGN KEY([EntityId], [PartitionId])
    REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
    ON DELETE CASCADE
    ON UPDATE CASCADE
    ALTER TABLE [dbo].[EntityValueOrigin] CHECK CONSTRAINT [FK_EntityValueOrigin_Entity]

    ALTER TABLE [dbo].[EntityValueOrigin] WITH CHECK ADD CONSTRAINT [FK_EntityValueOrigin_CollectionKeyId] FOREIGN KEY([CollectionKeyId])
    REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
    ON DELETE CASCADE
    ON UPDATE CASCADE
    ALTER TABLE [dbo].[EntityValueOrigin] CHECK CONSTRAINT [FK_EntityValueOrigin_CollectionKeyId]

    ALTER TABLE [dbo].[EntityValueOrigin] WITH CHECK ADD CONSTRAINT [FK_EntityValueOrigin_SourceCollectionKeyId] FOREIGN KEY([SourceCollectionKeyId])
    REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    ALTER TABLE [dbo].[EntityValueOrigin] CHECK CONSTRAINT [FK_EntityValueOrigin_SourceCollectionKeyId]

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

    EXEC('CREATE PROCEDURE [dbo].[InsertEntityValueOriginSelectType]
    (@OriginSelect as EntityValueOriginSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #EntityValueOriginSelect (EntityValueOriginSelectId, EntityId, PartitionId, CollectionKeyId, SourceEntityId, SourcePartitionId, SourceCollectionKeyId) SELECT EntityValueOriginSelectId, EntityId, PartitionId, CollectionKeyId, SourceEntityId, SourcePartitionId, SourceCollectionKeyId FROM @thisOriginSelect'', N''@thisOriginSelect EntityValueOriginSelectType READONLY'', @OriginSelect')
END

IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'DF_CollectionKey_Caption')
BEGIN
    EXEC('ALTER TABLE [CollectionKey] DROP CONSTRAINT [DF_CollectionKey_Caption]')
END