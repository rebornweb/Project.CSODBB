--select *
delete
from dbo.ObjectsByType
where ID = --'B500093'
--'S070283'
'B500100'

and ObjectType = 'person'

delete
from dbo.ObjectsByType
where ID = 'O153101'
and ObjectType = 'group'

select *
from [dbo].[ObjectsByType]
where ObjectType = 'person'
and ID like 'S%'

where BaseID = 'S040326'
