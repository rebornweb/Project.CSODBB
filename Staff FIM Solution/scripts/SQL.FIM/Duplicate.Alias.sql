select accountName, mailNickname, email, displayName, employeeID, csoLegacyEmployeeID
from dbo.mms_metaverse with (nolock)
where mailNickname in (
select mailNickname
from dbo.mms_metaverse with (nolock)
where PersonType = 'Staff'
and mailNickname is not null
group by mailNickname
having count(*) > 1
)
order by mailNickname