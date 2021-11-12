select mv.displayName, mv.firstName, mv.lastName
from dbo.mms_metaverse mv with (nolock)
where mv.object_type = 'person'
and ((mv.displayName not like '%' + mv.lastName + '%')
or (mv.displayName not like '%' + isnull(mv.PreferredName,mv.firstName)+ '%'))