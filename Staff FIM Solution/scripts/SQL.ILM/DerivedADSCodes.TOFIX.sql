	-- add Level 2
	Select Distinct [ID], [BaseID], CharIndex('0', [BaseID]),
		Case CharIndex('0', [BaseID])
			When 0 Then Left([BaseID],5)+'0Z'
			When 2 Then 'O00000Z' -- THIS IS THE LINE THAT IS MISSING!!!
			Else
			Left([BaseID],CharIndex('0', [BaseID])-2) + Right('00000Z',8-CharIndex('0', [BaseID])+1)
		End As [DerivedADSCode], 
		Null As [Name],
		Null As [physicalDeliveryOfficeName]
	From dbo.[ObjectsByType]
	Where [ObjectType] = 'group'
	And BaseID Is Not Null
	And Right([BaseID],1) = '1'
and Case CharIndex('0', [BaseID])
			When 0 Then Left([BaseID],5)+'0Z'
			Else
			Left([BaseID],CharIndex('0', [BaseID])-2) + Right('00000Z',8-CharIndex('0', [BaseID])+1)
		End like '0%'

