SELECT [ADSCode]
      ,[ObjectType]
      ,[IntegerValue]
  FROM [BOPS2DB].[dbo].[vw_idmADSCodeEmployees]
where ADSCode like '%O10000Z%'


select * from dbo.vw_idmADSCode
where ADSCode like '%O10000Z%'

SELECT Distinct a.DerivedADSCode As [ADSCode]
      ,(
			Select Top 1 A2.[ADSDescription]
			From [dbo].[ADSRole] A2
			Where A2.[ADSCode] = a.[ADSCode]
			Order By A2.[ADSDescription]
		) As [ADSDescription]
FROM [dbo].[DeriveADSCodes]() a --[dbo].[ADSRole]
where a.DerivedADSCode like '%O10000Z%'

SELECT Distinct a.[ADSCode]
      ,(
			Select Top 1 A2.[ADSDescription]
			From [dbo].[ADSRole] A2
			Where A2.[ADSCode] = a.[ADSCode]
			Order By A2.[ADSDescription]
		) As [ADSDescription]
FROM [dbo].[ADSRole] a
where a.ADSCode like '%O10000%'

select * from [dbo].[ADSRole]
where [ADSCode] like '%O10000Z%'
 
select * from [dbo].[DeriveADSCodes]()
where 