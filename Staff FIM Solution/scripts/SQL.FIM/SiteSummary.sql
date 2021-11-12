-- SITE Reporting

/*select uid, count(*)
from dbo.mms_metaverse mv
where mv.object_type = 'csoSite'
and csoSiteCode is not null
group by uid
having count(*) > 1
*/

select mv.DisplayName, mv.Description, mv.csoSiteCode, mv.uid, 
	IsNull(ILM.match,'') As [In ILM],
	IsNull(CSOADS.match,'') As [In Excel],
	IsNull(PHRIS.match,'') As [In PHRIS],
	IsNull(CAPS.match,'') As [In CAPS],
	IsNull(NASS.match,'') As [In NASS]
from dbo.mms_metaverse mv with (nolock)
left join (
	select mvl.mv_object_id, 'YES' as [match]
	from dbo.mms_connectorspace cs with (nolock)
	inner join dbo.mms_csmv_link mvl with (nolock)
		on cs.object_id = mvl.cs_object_id
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Site')
) ILM on ILM.mv_object_id = mv.object_id
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
	where cs.ma_id = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'CSO ADS')
) CSOADS on CSOADS.mv_object_id = mv.object_id
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
where mv.object_type = 'csoSite'
order by csoSiteCode, displayName