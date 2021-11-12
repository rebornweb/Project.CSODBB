-- Unmatched FIM ADS Groups

select mv.DisplayName, mv.accountName, mv.csoADSCode, mv.info, mv.description, mv.uid, 
	IsNull(Staff.match,'') As [In Staff],
	IsNull(FIM.match,'') As [In FIM]
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
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'FIM Portal')
) FIM on FIM.mv_object_id = mv.object_id
where mv.object_type = 'group'
and mv.scope = 'Global'
and FIM.match is not null and Staff.match is null -- 1 (joshua.mcdonald)
order by accountName, displayName


select 
	case when right(rdn,2) = '-G' then 'Global' else 'Local' end as [scope],
	count(*)
from dbo.mms_connectorspace cs with (nolock)
where ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Staff')
and object_type = 'group'
and is_connector = 0
group by case when right(rdn,2) = '-G' then 'Global' else 'Local' end
order by case when right(rdn,2) = '-G' then 'Global' else 'Local' end

select 
	case when right(rdn,2) = '-G' then 'Global' else 'Local' end as [scope],
	rdn
from dbo.mms_connectorspace cs with (nolock)
where ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Staff')
and object_type = 'group'
and is_connector = 0
order by case when right(rdn,2) = '-G' then 'Global' else 'Local' end, rdn

