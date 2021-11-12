truncate table dbo.idmBOPSObjectsChanges
truncate table dbo.EmployeeChanges
truncate table dbo.ContractChanges
truncate table dbo.ADSRoleChanges

select * from dbo.vw_idmBOPSObjects
where ID = 'B500006'

select * from dbo.idmBOPSObjectsChanges
select * from dbo.EmployeeChanges
select * from dbo.ContractChanges
select * from dbo.ADSRoleChanges

select * from dbo.vw_idmBOPSObjects where EmployeeID = 1
select * from dbo.Contract where EmployeeID = 1


select * from [dbo].vw_idmBOPSObjectsChanges

exec dbo.unifynow_idmBOPSObjects_getChanges

select distinct PositionLocation 
from 


select distinct c.ReportingManager, e.EmployeeCode
from dbo.Contract c
	inner join dbo.Employee e on e.EmployeeID = c.EmployeeID
where c.ReportingManager is not null

