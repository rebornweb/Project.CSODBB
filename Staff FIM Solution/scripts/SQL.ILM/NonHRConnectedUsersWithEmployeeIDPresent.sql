select distinct mv.DisplayName, mv.sAMAccountName, employeeID, mv.employeeType, mv.employeeStatus, 
	IsNull(Staff.match,'') As [In DBB],
	IsNull(PHRIS.match,'') As [In MOSS],
	IsNull(CAPS.match,'') As [In CAPS],
	IsNull(NASS.match,'') As [In NASS]
from dbo.mms_metaverse mv with (nolock)
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'DBB')
) Staff on Staff.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'DBB.MOSS')
) PHRIS on PHRIS.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'CAPS Payroll')
) CAPS on CAPS.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'NASS')
) NASS on NASS.mv_object_id = mv.object_id
where mv.object_type = 'dbbStaff'
and mv.employeeID is not null
and Staff.match is not null
and (CAPS.match is null and NASS.match is null)
--and mv.employeeStatus = 'active'
order by employeeStatus,DisplayName