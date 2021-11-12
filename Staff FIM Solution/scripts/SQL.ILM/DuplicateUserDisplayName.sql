select mv.DisplayName, mv.sAMAccountName, mv.EmployeeNumber, employeeID, mv.uid, mv.employeeType, mv.employeeStatus
from dbo.mms_metaverse mv with (nolock)
where mv.displayName in (
	select displayName
	from dbo.mms_metaverse mv with (nolock)
	where object_type = 'dbbStaff'
	and employeeStatus <> 'Terminated'
	group by displayName
	having count(*) > 1
)
order by mv.displayName

select mv.DisplayName, mv.sAMAccountName, mv.cn, mv.EmployeeNumber, employeeID, mv.uid, mv.employeeType, mv.employeeStatus
from dbo.mms_metaverse mv with (nolock)
where object_type = 'dbbStaff'
and mv.displayName <> mv.cn
order by mv.displayName
