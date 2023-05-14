ALTER TABLE [dbo].[Entity]
DROP CONSTRAINT [FK_Entity_Partition]

ALTER TABLE [dbo].[Entity]
DROP CONSTRAINT [FK_Entity_Container]

ALTER TABLE [dbo].[Entity]
DROP CONSTRAINT [FK_Entity_ObjectClass]

ALTER TABLE [dbo].[Container]
DROP CONSTRAINT [FK_Container_Partition]

ALTER TABLE [dbo].[EntityValue]
DROP CONSTRAINT [FK_EntityValue_CollectionKey]

ALTER TABLE [dbo].[EntityValue]
DROP CONSTRAINT [FK_EntityValue_Entity]

ALTER TABLE [dbo].[ChangeLog]
DROP CONSTRAINT [FK_ChangeLog_Partition]

ALTER TABLE [dbo].[ObjectClass]
DROP CONSTRAINT [FK_ObjectClass_Partition]

ALTER TABLE [dbo].[EntityValueOrigin]
DROP CONSTRAINT [FK_EntityValueOrigin_Entity]

ALTER TABLE [dbo].[EntityValueOrigin]
DROP CONSTRAINT [FK_EntityValueOrigin_CollectionKeyId]

ALTER TABLE [dbo].[EntityValueOrigin]
DROP CONSTRAINT [FK_EntityValueOrigin_SourceCollectionKeyId]



TRUNCATE TABLE [dbo].[Container]
TRUNCATE TABLE [dbo].[Partition]
TRUNCATE TABLE [dbo].[Entity]
TRUNCATE TABLE [dbo].[EntityValue]
TRUNCATE TABLE [dbo].[ObjectClass]
TRUNCATE TABLE [dbo].[Changes]
TRUNCATE TABLE [dbo].[ChangeLog]
TRUNCATE TABLE [dbo].[StoredValueCollection]
TRUNCATE TABLE [dbo].[EntityValueOrigin]
TRUNCATE TABLE [dbo].[CollectionKey]


ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Partition]


ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Container] FOREIGN KEY([ContainerId])
REFERENCES [dbo].[Container] ([ContainerId])
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Container]


ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_ObjectClass] FOREIGN KEY([ObjectClassId])
REFERENCES [dbo].[ObjectClass] ([ObjectClassId])

ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_ObjectClass]


ALTER TABLE [dbo].[Container]  WITH CHECK ADD  CONSTRAINT [FK_Container_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE [dbo].[Container] CHECK CONSTRAINT [FK_Container_Partition]


ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_CollectionKey] FOREIGN KEY([CollectionKeyId])
REFERENCES [dbo].[CollectionKey] ([CollectionKeyId])

ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_CollectionKey]


ALTER TABLE [dbo].[EntityValue]  WITH CHECK ADD  CONSTRAINT [FK_EntityValue_Entity] FOREIGN KEY([EntityId], [PartitionId])
REFERENCES [dbo].[Entity] ([EntityId], [PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE [dbo].[EntityValue] CHECK CONSTRAINT [FK_EntityValue_Entity]


ALTER TABLE [dbo].[ObjectClass]  WITH CHECK ADD  CONSTRAINT [FK_ObjectClass_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE [dbo].[ObjectClass] CHECK CONSTRAINT [FK_ObjectClass_Partition]


ALTER TABLE [dbo].[ChangeLog]  WITH CHECK ADD  CONSTRAINT [FK_ChangeLog_Partition] FOREIGN KEY([AdapterId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE [dbo].[ChangeLog] CHECK CONSTRAINT [FK_ChangeLog_Partition]


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
