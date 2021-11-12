select t.*, mv.count
from [dbo].[vw_idmObjectsByType] t
--where [GroupType] <> 'base'
left join (
	Select mv.StringValue, count(*) As [count]
	From dbo.vw_idmMultivalueObjects mv
	where mv.ObjectType = 'person'
	group by mv.StringValue
) mv On mv.StringValue = t.ID
where t.ObjectType = 'person'
And mv.count is null

select * from dbo.vw_idmMultivalueObjects
where StringValue = 'XB500179'


select * from dbo.vw_idmMultivalueObjects
where StringValue = 'S040120'

select * from dbo.vw_idmObjectsByType
where ID = 'OCCCP'


select db_id()

select [ID], [ObjectType], [StringValue] from [dbo].[vw_idmMultivalueObjects]  WHERE [ID] = 'S000007%'

select [ID], [ObjectType], [StringValue] from [dbo].[vw_idmMultivalueObjects]  WHERE [ID] like 'S%'


SELECT DISTINCT a.DerivedADSCode As [ID]
      ,[ObjectType]
      ,[StringValue]
  FROM [dbo].[MultivalueObjects] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[MultivalueObjects]
)

select Distinct DerivedADSCode As [ID]
from [dbo].[DeriveADSCodes]()

--

SELECT [ID]
      ,[ObjectType]
      ,[StringValue]
  FROM [dbo].[MultivalueObjects]

UNION ALL

SELECT Distinct a.DerivedADSCode As [ID]
      ,[ObjectType]
      ,[StringValue]
  FROM [dbo].[MultivalueObjects] o
Inner Join [dbo].[DeriveADSCodes]() a 
	On a.ID = o.ID
Where a.DerivedADSCode Not In (
	Select [ID] From [dbo].[MultivalueObjects]
)

UNION ALL 

SELECT [physicalDeliveryOfficeName] As [ID]
      ,[ObjectType]
      ,[ID] As [StringValue]
  FROM [dbo].[ObjectsByType]
Where ObjectType = 'person'
And [physicalDeliveryOfficeName] Is Not Null 

