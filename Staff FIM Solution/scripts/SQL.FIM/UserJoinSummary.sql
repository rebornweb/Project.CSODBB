select distinct mv.DisplayName, mv.accountName, mv.EmployeeNumber, mv.csoLegacyEmployeeID, employeeID, mv.physicalDeliveryOfficeName, mv.jobTitle, mv.csoBirthDate, mv.employeeType, mv.employeeStatus, mv.PersonType,
	IsNull(Staff.match,'') As [In Staff],
	IsNull(UsersAndGroups.match,'') As [In Users and Groups],
	IsNull(PHRIS.match,'') As [In PHRIS],
	IsNull(CAPS.match,'') As [In CAPS],
	IsNull(NASS.match,'') As [In NASS],
	IsNull(SAS2IDM.match,'') As [In SAS2IDM]
from dbo.mms_metaverse mv with (nolock)
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Staff')
) Staff on Staff.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'PHRIS')
) PHRIS on PHRIS.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Users and Groups')
) UsersAndGroups on UsersAndGroups.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'CAPS')
) CAPS on CAPS.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'NASS')
) NASS on NASS.mv_object_id = mv.object_id
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'SAS2IDM')
) SAS2IDM on SAS2IDM.mv_object_id = mv.object_id
--where mv.object_type = 'person'
--and Staff.match is not null and UsersAndGroups.match is not null -- 1 (joshua.mcdonald)
--and NASS.match is not null and CAPS.match is not null -- 0 !!! need to manually join because of missing alt NASS join key (CAPS precedent)
-- and SAS2IDM.match is not null and 
-- 	(CAPS.match is not null or NASS.match is not null or PHRIS.match is not null) -- 1 (joshua.mcdonald)

where mv.displayName in (
	select displayName
	from dbo.mms_metaverse mv with (nolock)
	where object_type = 'person'
	and PersonType = 'Staff'
	and employeeStatus <> 'Terminated'
	group by displayName
	having count(*) > 1
)

/*
where object_type = 'person'
and mv.csoLegacyEmployeeID is not null
and PHRIS.match is not null
and NASS.match is null
and CAPS.match is null
*/

order by displayName, accountName, csoLegacyEmployeeID

-- duplicate people
/*
select mv.DisplayName, mv.accountName, mv.EmployeeNumber, mv.csoLegacyEmployeeID, employeeID, mv.uid, mv.employeeType, mv.employeeStatus
from dbo.mms_metaverse mv with (nolock)
where mv.displayName in (
	select displayName
	from dbo.mms_metaverse mv with (nolock)
	where object_type = 'person'
	and PersonType = 'Staff'
	and employeeStatus <> 'Terminated'
	group by displayName
	having count(*) > 1
)
order by mv.displayName

*/

