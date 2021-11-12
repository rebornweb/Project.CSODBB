SELECT top 500 
	mv1.displayName, 
	mv1.employeeID,	
	mv2.DisplayName, 
	mv2.employeeID,	
	soundex(mv1.sn) as sx1, 
	soundex(mv2.sn) as sx2, 
	DIFFERENCE(mv1.sn, mv2.sn) as diffSn,
	DIFFERENCE(mv1.givenName, mv2.givenName) as diffGivenName
From dbo.mms_metaverse mv1 with (nolock)
Cross Join dbo.mms_metaverse mv2 with (nolock)
Where mv1.object_type = 'dbbStaff'
And mv2.object_type = 'dbbStaff'
And DIFFERENCE(mv1.sn, mv2.sn) = 4
And DIFFERENCE(mv1.givenName, mv2.givenName) = 4
And mv1.object_id > mv2.object_id

/*
select count(*)
from dbo.mms_metaverse with (nolock)
Where object_type = 'dbbPerson'
*/

drop View dbo.vw_PossibleDuplicates
go

Create View dbo.vw_PossibleDuplicates As
SELECT 
	mv1.displayName as displayName1, 
	mv1.employeeID as employeeID1,	
	mv1.employeeStatus as employeeStatus1,
	mv1.sAMAccountName as sAMAccountName1,
	mv2.DisplayName as displayName2, 
	mv2.employeeID as employeeID2, 
	mv2.employeeStatus as employeeStatus2,
	mv2.sAMAccountName as sAMAccountName2
From dbo.mms_metaverse mv1 with (nolock)
Inner Join dbo.mms_metaverse mv2 with (nolock)
	On mv2.object_type = 'dbbStaff'
	And mv2.employeeStatus = 'active'
	And (
		(mv1.sn = mv2.sn And DIFFERENCE(mv1.givenName, mv2.givenName) = 4)
	Or (mv1.givenName = mv2.givenName And mv1.sn <> mv2.sn And DIFFERENCE(mv1.sn, mv2.sn) = 4))
Where mv1.object_type = 'dbbStaff'
And mv1.object_id > mv2.object_id
And mv1.employeeStatus = 'active'

/*
Cross Join dbo.mms_metaverse mv2 with (nolock)
Where mv1.object_type = 'dbbStaff'
And mv2.object_type = 'dbbStaff'
And (
	(mv1.sn = mv2.sn And DIFFERENCE(mv1.givenName, mv2.givenName) = 4)
Or (mv1.givenName = mv2.givenName And mv1.sn <> mv2.sn And DIFFERENCE(mv1.sn, mv2.sn) = 4))
And mv1.object_id > mv2.object_id
And mv1.employeeStatus = 'active'
And mv2.employeeStatus = 'active'
*/
