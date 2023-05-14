ALTER TABLE [dbo].[Entity]  
DROP CONSTRAINT [FK_Entity_Partition]

ALTER TABLE [dbo].[Entity]
DROP CONSTRAINT [FK_Entity_ObjectClass]

ALTER TABLE [dbo].[EntityValue]  
DROP CONSTRAINT [FK_EntityValue_CollectionKey]

ALTER TABLE [dbo].[EntityValue]  
DROP CONSTRAINT [FK_EntityValue_Entity]

ALTER TABLE [dbo].[ObjectClass]  
DROP CONSTRAINT [FK_ObjectClass_Partition]

ALTER TABLE [dbo].[Container]  
DROP CONSTRAINT [FK_Container_Container]

TRUNCATE TABLE [Container]
TRUNCATE TABLE [Partition]
TRUNCATE TABLE [Entity]
TRUNCATE TABLE [EntityValue]
TRUNCATE TABLE [ObjectClass]

ALTER TABLE [dbo].[Container]  WITH CHECK ADD  CONSTRAINT [FK_Container_Container] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON DELETE CASCADE
ON UPDATE CASCADE

ALTER TABLE [dbo].[Container] CHECK CONSTRAINT [FK_Container_Container]

ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_ObjectClass] FOREIGN KEY([ObjectClassId])
REFERENCES [dbo].[ObjectClass] ([ObjectClassId])

ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_ObjectClass]

ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Partition] FOREIGN KEY([PartitionId])
REFERENCES [dbo].[Partition] ([PartitionId])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_Partition]

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


