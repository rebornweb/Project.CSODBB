Select 
	mv.accountName, 
	mv.email, 
	mv.mailNickname, 
	mv.userAccountControl,
	LEFT(mv.email,CHARINDEX('@',mv.email,0)-1) As [EffectiveAlias],
	Case
		When mv.accountName <> mv.mailNickname Then '2. account <> alias'
		When mv.accountName <> LEFT(mv.email,CHARINDEX('@',mv.email,0)-1) Then '1. account <> mail prefix'
		When mv.mailNickname <> LEFT(mv.email,CHARINDEX('@',mv.email,0)-1) Then '3. alias <> mail prefix'
	End As [Reason]
From dbo.mms_metaverse mv with (nolock)
where mv.objectSid is not null
and mv.PersonType = 'Staff'
and mv.mailNickname is not null
and mv.userAccountControl <> 514
and (
	mv.accountName <> LEFT(mv.email,CHARINDEX('@',mv.email,0)-1) or
	mv.accountName <> mv.mailNickname or
	mv.mailNickname <> LEFT(mv.email,CHARINDEX('@',mv.email,0)-1)
)
order by Case
		When mv.accountName <> mv.mailNickname Then '2. account <> alias'
		When mv.accountName <> LEFT(mv.email,CHARINDEX('@',mv.email,0)-1) Then '1. account <> mail prefix'
		When mv.mailNickname <> LEFT(mv.email,CHARINDEX('@',mv.email,0)-1) Then '3. alias <> mail prefix'
	End,
	accountName