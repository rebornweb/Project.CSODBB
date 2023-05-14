SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Check Version--
DECLARE @v300 BIT
DECLARE @v303 BIT
DECLARE @v40 BIT
DECLARE @v41 BIT

SET @v300 = 0
SET @v303 = 0
SET @v40 = 0
SET @v41 = 0

--NOTE: All versions that require upgrade must be set.
IF (SELECT COUNT(*) FROM sys.objects WHERE name = 'ChangesSelect') > 0
BEGIN
    SET @v300 = 1
    SET @v303 = 1
    SET @v40 = 1
    SET @v41 = 1
END
IF (SELECT COUNT(*) FROM sys.columns WHERE name = 'StoredValueCollectionKey') = 0
BEGIN
    SET @v303 = 1
    SET @v40 = 1
    SET @v41 = 1
END
IF (SELECT COUNT(*) FROM sys.columns WHERE name = 'StringHash') = 0
BEGIN
    SET @v40 = 1
    SET @v41 = 1
END
IF (SELECT COUNT(*) FROM sys.objects WHERE name = 'InsertChangesSelectType') = 0
BEGIN
    SET @v41 = 1
END

IF @v300 = 1
BEGIN
    DROP TABLE ChangesSelect
    DROP TABLE EntityValueSelect
    DROP TABLE EntitySelect
    
    ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_Entity]
    ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_CollectionKey]
    ALTER TABLE [EntityValue] DROP CONSTRAINT [PK_EntityValue]
    
    ALTER TABLE [Entity] DROP CONSTRAINT [PK_Entity]
    DROP INDEX Entity._dta_index_Entity_c_7_149575571__K1
    DROP INDEX Entity.IX_Entity_ObjectClass_PartitionId
    DROP INDEX Entity.IX_Entity_PartitionId

    DROP INDEX EntityValue._dta_index_EntityValue_7_181575685__K13_K12_K2_1_3_4_5_6_8_9_11
    DROP INDEX EntityValue._dta_index_EntityValue_c_7_181575685__K2
    DROP INDEX EntityValue.IX_EntityValue_IntValue
    DROP INDEX EntityValue.IX_EntityValue_PartitionId
    DROP INDEX EntityValue.IX_EntityValue_StringValue

    EXEC('sp_rename ''Entity'', ''Entity_bak''')

    EXEC('CREATE TABLE [dbo].[Entity](
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
    )')
    EXEC('CREATE CLUSTERED INDEX [IX_EntityKey] ON [dbo].[Entity] 
    (
        [EntityKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [_dta_index_Entity_c_7_149575571__K1] ON [dbo].[Entity] 
    (
        [EntityId] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_ObjectClass_PartitionId] ON [dbo].[Entity] 
    (
        [PartitionId] ASC,
        [ObjectClassId] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_PartitionId] ON [dbo].[Entity] 
    (
        [PartitionId] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    
    EXEC('INSERT INTO Entity (
        [EntityId],
        [PartitionId],
        [ObjectClassId],
        [DN]
    )
    SELECT
        [EntityId],
        [PartitionId],
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
        [ImageValue] [image] NULL,
        [IntValue] [int] NULL,
        [StringValue] [nvarchar](450) NULL,
        [TextValue] [text] NULL,
        [UniqueIdentifierValue] [uniqueidentifier] NULL,
        [PartitionId] [uniqueidentifier] NOT NULL,
        [CollectionKeyId] [int] NOT NULL,
        [ValueOrder] [int] NOT NULL,
        [DecimalValue] [decimal](38, 12) NULL,
     CONSTRAINT [PK_EntityValue] PRIMARY KEY NONCLUSTERED 
    (
        [EntityValueId] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON))')
    EXEC('CREATE CLUSTERED INDEX [IX_EntityValueKey] ON [dbo].[EntityValue] 
    (
        [EntityValueKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [_dta_index_EntityValue_7_181575685__K13_K12_K2_1_3_4_5_6_8_9_11] ON [dbo].[EntityValue] 
    (
        [CollectionKeyId] ASC,
        [PartitionId] ASC,
        [EntityId] ASC
    )
    INCLUDE ( [EntityValueId],
    [ValueType],
    [BigIntValue],
    [BitValue],
    [FloatValue],
    [IntValue],
    [StringValue],
    [UniqueIdentifierValue]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [_dta_index_EntityValue_c_7_181575685__K2] ON [dbo].[EntityValue] 
    (
        [EntityId] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_IntValue] ON [dbo].[EntityValue] 
    (
        [IntValue] ASC,
        [ValueType] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_PartitionId] ON [dbo].[EntityValue] 
    (
        [PartitionId] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_StringValue] ON [dbo].[EntityValue] 
    (
        [StringValue] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')

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
        [TextValue],
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
        [TextValue],
        [UniqueIdentifierValue],
        [PartitionId],
        [CollectionKeyId],
        [ValueOrder],
        [DecimalValue]
    FROM EntityValue_bak')

    EXEC('DROP TABLE Entity_bak')
    EXEC('DROP TABLE EntityValue_bak')
    
    ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_CollectionKey] FOREIGN KEY([CollectionKeyId])
    REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])
    ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_CollectionKey]
    
    ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_Entity] FOREIGN KEY([EntityId], [PartitionId])
    REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
    ON UPDATE CASCADE
    ON DELETE CASCADE
    ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_Entity]
END

IF @v303 = 1
BEGIN
    ALTER TABLE [dbo].[StoredValueCollection] DROP CONSTRAINT [PK_StoredValueCollection]
    
    ALTER TABLE [EntityValue] DROP CONSTRAINT [PK_EntityValue]
    ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_CollectionKey]
    ALTER TABLE [EntityValue] DROP CONSTRAINT [FK_EntityValue_Entity]

	IF EXISTS (SELECT * FROM sys.default_constraints WHERE name='DF_EntityValue_ValueOrder')
	BEGIN 
		EXEC('ALTER TABLE [EntityValue] DROP CONSTRAINT [DF_EntityValue_ValueOrder]')
	END
    
    DROP INDEX Entity._dta_index_Entity_c_7_149575571__K1
    DROP INDEX Entity.IX_Entity_ObjectClass_PartitionId
    DROP INDEX Entity.IX_Entity_PartitionId
    DROP INDEX EntityValue._dta_index_EntityValue_7_181575685__K13_K12_K2_1_3_4_5_6_8_9_11
    DROP INDEX EntityValue._dta_index_EntityValue_c_7_181575685__K2
    DROP INDEX EntityValue.IX_EntityValue_IntValue
    DROP INDEX EntityValue.IX_EntityValue_PartitionId
    DROP INDEX EntityValue.IX_EntityValue_StringValue
    DROP INDEX EntityValue.IX_EntityValueKey

    EXEC('sp_rename ''EntityValue'', ''EntityValue_bak''')

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
        
    EXEC('ALTER TABLE [dbo].[EntityValue] ADD  CONSTRAINT [DF_EntityValue_ValueOrder]  DEFAULT ((0)) FOR [ValueOrder]')
        
    EXEC('ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_CollectionKey] FOREIGN KEY([CollectionKeyId])
        REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])')
    
    EXEC('ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_CollectionKey]')
    
    EXEC('ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_Entity] FOREIGN KEY([EntityId], [PartitionId])
            REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
            ON UPDATE CASCADE
            ON DELETE CASCADE')
    
    EXEC('ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_Entity]')

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

    -------------------------------------
    --Update IdentityBroker ValueTypes
    -------------------------------------
    /* Prepare MultiValue value-types to be correctly updated */
    UPDATE EntityValue
    SET ValueType = 0
    WHERE ValueType = 128

    
     /* Old Value  | New Value
     ----------------------
     0          | 2^0 (Updated MultiValues)
     1            | 2^1
     2            | 2^2
     3            | 2^3 and so on...*/
    UPDATE EntityValue
    SET ValueType = POWER(2, (ValueType))
    WHERE ValueType < 128

    /* Update multivalues */
    UPDATE EntityValue
    SET ValueType = POWER(2, (ValueType - 128)) + 1
    WHERE ValueType > 128 AND ValueType < 256

    -------------------------------------
    --Update IdentityBroker Indexes
    -------------------------------------
    EXEC('CREATE CLUSTERED INDEX [IX_StoredValueCollectionKey] ON [dbo].[StoredValueCollection] 
    (
        [StoredValueCollectionKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE CLUSTERED INDEX [IX_EntityValueKey] ON [dbo].[EntityValue] 
    (
        [EntityValueKey] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_EntityValue_StringHash] ON [dbo].[EntityValue] 
    (
        [StringHash] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)')
    EXEC('CREATE NONCLUSTERED INDEX [IX_Entity_PartitionId] ON [dbo].[Entity] 
    (
        [PartitionId] ASC,
        [EntityId] ASC
    )
    INCLUDE ( [ObjectClassId],
    [DN]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)')
    CREATE NONCLUSTERED INDEX [IX_EntityValue_EntityId_PartitionId] ON [dbo].[EntityValue] 
    (
        [PartitionId] ASC,
        [EntityId] ASC
    )
    INCLUDE ( [CollectionKeyId]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
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
        
    EXEC('sp_rename ''Changes'', ''Changes_bak''')
        
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
    
    EXEC('INSERT INTO [Changes] (
        [EntityId],
        [AdapterId],
        [ChangeTimestamp])
     SELECT 
        [EntityId],
        [AdapterId],
        [ChangeTimestamp]
     FROM Changes_bak')

    EXEC('DROP TABLE StoredValueCollection_bak')
    EXEC('DROP TABLE Changes_bak')
    EXEC('DROP TABLE EntityValue_bak')
    
    EXEC('CREATE VIEW [dbo].[AdapterEntityChanges] AS
    (SELECT     dbo.Entity.EntityKey, dbo.Entity.EntityId, C.AdapterId AS PartitionId, dbo.Entity.ObjectClassId, dbo.Entity.DN, C.ChangeTimestamp, 
                      dbo.Entity.PartitionId AS BaseReferenceId
FROM         dbo.Entity INNER JOIN
                      dbo.Changes AS C ON dbo.Entity.EntityId = C.EntityId
WHERE     (C.ChangesKey =
                          (SELECT     TOP (1) ChangesKey
                            FROM          dbo.Changes AS D
                            WHERE      (dbo.Entity.EntityId = EntityId)
                            ORDER BY ChangeTimestamp)) AND (dbo.Entity.ObjectClassId IS NULL) AND (dbo.Entity.DN IS NULL))')
END

IF @v41 = 1
BEGIN
    CREATE TYPE [dbo].[EntitySelectType] AS TABLE
    (
        EntitySelectGroupId uniqueidentifier NOT NULL,
        EntityId uniqueidentifier NULL,
        PartitionId uniqueidentifier NULL,
        DN nvarchar(400) NULL,
        ObjectClassId int NULL
    )
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
    CREATE TYPE [dbo].[ContainerSelectType] AS TABLE
    (
        ContainerSelectGroupId uniqueidentifier NOT NULL,
        PartitionId uniqueidentifier NOT NULL,
        ContainerId uniqueidentifier NOT NULL,
        DistinguishedName nvarchar(400) NOT NULL
    )
    CREATE TYPE [dbo].[ChangesSelectType] AS TABLE
    (
        [ChangesSelectId] [uniqueidentifier] NOT NULL,
        [EntityId] [uniqueidentifier] NOT NULL,
        [AdapterId] [uniqueidentifier] NOT NULL,
        [ChangeTimestamp] [bigint] NOT NULL
    )
    EXEC('CREATE PROCEDURE [dbo].[InsertEntitySelectType]
    (@EntitySelect as EntitySelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #EntitySelect (EntitySelectGroupId, EntityId, PartitionId, DN, ObjectClassId) SELECT EntitySelectGroupId, EntityId, PartitionId, DN, ObjectClassId FROM @thisEntitySelect'', N''@thisEntitySelect EntitySelectType READONLY'', @EntitySelect')
    EXEC('CREATE PROCEDURE [dbo].[InsertEntityValueSelectType]
    (@EntityValueSelect as EntityValueSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #EntityValueSelect (ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue) SELECT ValueType, BigIntValue, BitValue, FloatValue, ImageValue, IntValue, StringValue, StringHash, UniqueIdentifierValue, EntityValueSelectId, ValueSequence, ColumnSequence, DecimalValue FROM @thisEntityValueSelect'', N''@thisEntityValueSelect EntityValueSelectType READONLY'', @EntityValueSelect')
    EXEC('CREATE PROCEDURE [dbo].[InsertContainerSelectType]
    (@ContainerSelect as ContainerSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #ContainerSelect (ContainerSelectGroupId, PartitionId, ContainerId, DistinguishedName) SELECT ContainerSelectGroupId, PartitionId, ContainerId, DistinguishedName FROM @thisContainerSelect'', N''@thisContainerSelect ContainerSelectType READONLY'', @ContainerSelect')
    EXEC('CREATE PROCEDURE [dbo].[InsertChangesSelectType]
    (@ChangesSelect as ChangesSelectType READONLY)
    AS
        EXECUTE sp_executesql N''INSERT INTO #ChangesSelect (ChangesSelectId, EntityId, AdapterId, ChangeTimestamp) SELECT ChangesSelectId, EntityId, AdapterId, ChangeTimestamp FROM @thisChangesSelect'', N''@thisChangesSelect ChangesSelectType READONLY'', @ChangesSelect')
END
