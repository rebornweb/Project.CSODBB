-- ADS Groups with NO nested group members AND NO staff members
select mv.info As [ADSCode], mv.displayName, mv.sAMAccountName
--, mv2.object_type, mv2.displayName, mv2.sAMAccountName, mv2.info
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	left join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	left join dbo.mms_mv_link mmv2 with (nolock)
		on mmv2.object_id = mv.object_id
		and mmv2.attribute_name = 'member'
where mv.object_type = 'dbbGroup' -- all of these groups have ADS codes
and mmv.object_id is null
and mmv2.object_id is null
--and mv.displayName = 'SOLWA Athena Users-D'
order by mv.info

-- ADS Groups with nested group members AND staff members
select mv.info As [ADSCode], mv.displayName, mv.sAMAccountName
, count(distinct mv3.object_id ) as [NumGroupMembers]
, count(distinct mv2.object_id ) as [NumStaffMembers]
--, mv2.object_type, mv2.displayName, mv2.sAMAccountName, mv2.info
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	inner join dbo.mms_metaverse mv3 with (nolock)
		on mv3.object_id = mmv.reference_id
	inner join dbo.mms_mv_link mmv2 with (nolock)
		on mmv2.object_id = mv.object_id
		and mmv2.attribute_name = 'member'
	left join dbo.mms_metaverse mv2 with (nolock)
		on mv2.object_id = mmv2.reference_id
		and mv2.object_type = 'dbbStaff'
where mv.object_type = 'dbbGroup' -- all of these groups have ADS codes
--and mv.displayName = 'SOLWA Athena Users-D'
group by mv.info, mv.displayName, mv.sAMAccountName
having count(distinct mv2.object_id ) > 0
order by mv.info

-- ADS Groups with nested group members AND NO staff members
select mv.info As [ADSCode], mv.displayName, mv.sAMAccountName 
,count(distinct mv3.object_id ) as [NumGroupMembers] 
--,count(distinct mv2.object_id ) as [NumStaffMembers]
--, mv2.object_type, mv2.displayName, mv2.sAMAccountName, mv2.info
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	inner join dbo.mms_metaverse mv3 with (nolock)
		on mv3.object_id = mmv.reference_id
	inner join dbo.mms_mv_link mmv2 with (nolock)
		on mmv2.object_id = mv.object_id
		and mmv2.attribute_name = 'member'
	left join dbo.mms_metaverse mv2 with (nolock)
		on mv2.object_id = mmv2.reference_id
		and mv2.object_type = 'dbbStaff'
where mv.object_type = 'dbbGroup' -- all of these groups have ADS codes
--and mv.displayName = 'SOLWA Athena Users-D'
group by mv.info, mv.displayName, mv.sAMAccountName
having count(distinct mv2.object_id ) = 0
order by mv.info

-- (Possible) ADS DOMAIN LOCAL Groups with nested group members
select mv.info As [ADSCode], mv.displayName, mv.sAMAccountName 
,count(distinct mv3.object_id ) as [NumGroupMembers] 
,count(distinct mv2.object_id ) as [NumStaffMembers]
--, mv2.object_type, mv2.displayName, mv2.sAMAccountName, mv2.info
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	left join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	left join dbo.mms_metaverse mv3 with (nolock)
		on mv3.object_id = mmv.reference_id
	left join dbo.mms_mv_link mmv2 with (nolock)
		on mmv2.object_id = mv.object_id
		and mmv2.attribute_name = 'member'
	left join dbo.mms_metaverse mv2 with (nolock)
		on mv2.object_id = mmv2.reference_id
		and mv2.object_type = 'dbbStaff'
where mv.object_type = 'dbbGroup' -- all of these groups have ADS codes
and mv.sAMAccountName like '%-D'
--and mv.displayName = 'SOLWA Athena Users-D'
group by mv.info, mv.displayName, mv.sAMAccountName
order by mv.info

-- ADS Groups with nested (possibly) DOMAIN LOCAL group members
select mv.info As [ADSCode], mv.displayName, mv.sAMAccountName 
,count(distinct mv3.object_id ) as [NumGroupMembers] 
,count(distinct mv2.object_id ) as [NumStaffMembers]
--, mv2.object_type, mv2.displayName, mv2.sAMAccountName, mv2.info
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	inner join dbo.mms_metaverse mv3 with (nolock)
		on mv3.object_id = mmv.reference_id
		and mv3.sAMAccountName like '%-D'
	left join dbo.mms_mv_link mmv2 with (nolock)
		on mmv2.object_id = mv.object_id
		and mmv2.attribute_name = 'member'
	left join dbo.mms_metaverse mv2 with (nolock)
		on mv2.object_id = mmv2.reference_id
		and mv2.object_type = 'dbbStaff'
where mv.object_type = 'dbbGroup' -- all of these groups have ADS codes
--and mv.displayName = 'SOLWA Athena Users-D'
group by mv.info, mv.displayName, mv.sAMAccountName
order by mv.info


-- Non-ADS Groups with nested ADS group members
select case 
	when mv.description is null then 'Missing' 
	when rtrim(mv.description) like 'O______' and mv3.info = rtrim(mv.description) then 'ADS - matched'
	when rtrim(mv.description) like 'O______' and mv3.info <> rtrim(mv.description) then 'ADS - unmatched'
	else 'Unmatched Other' end as [Grouping]
,IsNull(mv.description,'O______') As [ADSCode?], mv.displayName, mv.sAMAccountName, 
mv3.info As [ADSCode], mv3.displayName, mv3.sAMAccountName 
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	inner join dbo.mms_metaverse mv3 with (nolock)
		on mv3.object_id = mmv.reference_id
		and mv3.object_type = 'dbbGroup'
where mv.object_type = 'dbbGroupNested' -- all of these groups do NOT have ADS codes
order by case 
	when mv.description is null then 'Missing' 
	when rtrim(mv.description) like 'O______' and mv3.info = rtrim(mv.description) then 'ADS - matched'
	when rtrim(mv.description) like 'O______' and mv3.info <> rtrim(mv.description) then 'ADS - unmatched'
	else 'Unmatched Other' end, mv.description, mv3.info

-- Non-ADS Groups with nested ADS group members (summary)
select case 
	when mv.description is null then 'Missing' 
	when rtrim(mv.description) like 'O______' and mv3.info = rtrim(mv.description) then 'ADS - matched'
	when rtrim(mv.description) like 'O______' and mv3.info <> rtrim(mv.description) then 'ADS - unmatched'
	else 'Unmatched Other' end as [Grouping] 
	,count(*) as [Count]
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	inner join dbo.mms_metaverse mv3 with (nolock)
		on mv3.object_id = mmv.reference_id
		and mv3.object_type = 'dbbGroup'
where mv.object_type = 'dbbGroupNested'
group by case 
	when mv.description is null then 'Missing' 
	when rtrim(mv.description) like 'O______' and mv3.info = rtrim(mv.description) then 'ADS - matched'
	when rtrim(mv.description) like 'O______' and mv3.info <> rtrim(mv.description) then 'ADS - unmatched'
	else 'Unmatched Other' end



-- Duplicate ADS Groups
select rtrim(ltrim(info)) as [ADSCode], count(*) as [Count]
from dbo.mms_metaverse with (nolock)
where object_type in ('dbbGroup','dbbGroupNested')
and info is not null
group by rtrim(ltrim(info))
having count(*) > 1





--- redundant:


/*

-- ADS Groups with nested group members
select mv.displayName, mv.sAMAccountName, mv.info, mv2.object_type, mv2.displayName, mv2.sAMAccountName, mv2.info
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'member'
	inner join dbo.mms_metaverse mv2 with (nolock)
		on mv2.object_id = mmv.reference_id
		and mv2.object_type = 'dbbStaff'
where mv.object_type = 'dbbGroupNested' -- all of these groups do NOT have ADS codes
--and mv.displayName = 'SOLWA Athena Users-D'
order by mv2.displayName

select mv.displayName, mv.sAMAccountName, mv2.object_type, mv2.displayName, mv2.sAMAccountName
--, mv.cn, mv.description, mv.info, mv.infoNested
from dbo.mms_metaverse mv with (nolock)
	inner join dbo.mms_mv_link mmv with (nolock)
		on mmv.object_id = mv.object_id
		and mmv.attribute_name = 'memberNested'
	inner join dbo.mms_metaverse mv2 with (nolock)
		on mv2.object_id = mmv.reference_id
	and mv2.object_type = 'dbbStaff'
where mv.object_type = 'dbbGroupNested'
--and mv.displayName = 'SOLWA Athena Users-D'
order by mv2.displayName

*/