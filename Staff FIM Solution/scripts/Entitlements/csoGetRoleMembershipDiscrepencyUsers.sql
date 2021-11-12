USE [FIMService]
GO

/****** Object:  StoredProcedure [dbo].[csoGetRoleMembershipDiscrepencyUsers]    Script Date: 11/25/2016 15:06:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csoGetRoleMembershipDiscrepencyUsers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[csoGetRoleMembershipDiscrepencyUsers]
GO

USE [FIMService]
GO

/****** Object:  StoredProcedure [dbo].[csoGetRoleMembershipDiscrepencyUsers]    Script Date: 11/25/2016 15:06:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[csoGetRoleMembershipDiscrepencyUsers] as

-- to rebuild:
-- 1. save a backup of this script
-- 2. remove the 2 WITH sections (collapse and delete)
-- 3. run SQL profiler over the 2 xpaths you are comparing
-- 4. capture the SQL query and convert from "exec sql ..." style to raw TSQL, replacing '' with ' too
-- 5. replace user id with @userID param
-- 6. locate "main select" statement (x2) and replace with "select into ..." block from backup
-- 7. replace hard-coded references to today's date with @referenceDate, e.g. CONVERT(DATETIME,N'2014-02-18T22:11:32.304',126)

set nocount on;

Declare @userID bigint, @userGUID uniqueidentifier, @referenceDate datetime; --varchar(30);

--Select COUNT(*) from [FIMService].[fim].[Objects] with (nolock) with (nolock) WHERE [ObjectTypeKey] = 24
Set @referenceDate = GETDATE(); --N'2014-02-18T22:11:32.304';

Declare csr_Users CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
Select TOP 100 percent 
	[ObjectKey], [ObjectID]
  FROM [FIMService].[fim].[Objects] with (nolock)
  WHERE [ObjectTypeKey] = 24 /* user */
  AND [ObjectKey] IN (
	SELECT valueOfProposition0.ObjectKey
	FROM [fim].ObjectValueString AS valueOfProposition0 with (nolock)
	WHERE(valueOfProposition0.ObjectTypeKey = 24) /*Person*/
	AND (valueOfProposition0.AttributeKey = 32675) /*PersonType*/
	AND (valueOfProposition0.ValueString = N'Staff')
  )
  --and ObjectKey = 189525
  --and [ObjectKey] in (188211,190307,520380)
  --and [ObjectKey] in (185421,190441)
  
/*and [ObjectKey] in ( --3025181,3086470)
181355,
181411,
181437,
181723,
183655,
184445,
184609,
184895,
185137,
185297,
185473,
189281,
190463,
190551,
643436,
655505,
673708,
678686,
2027394,
2185970,

181437,
181723,
182005,
182157,
182303,
182547,
182605,
183173,
183655,
183863,
184379,
184381,
184445,
184895,
185103,
185297,
185473,
186125,
186819,
187227,
189103,
189281,
189485,
189605,
190141,
190603,
190871,
643436,
655505,
670900,
671069,
673708,
678686,
683650,
691887,
1471988,
2147875,
2611640,
2862572,
2922173,
2956004,
2977321,
2981106,
2981528,
3025181,
3086470,
3106013
)*/
  ;

OPEN csr_Users

DECLARE @userTable1 TABLE (
	UserKey bigint,
	UserIdentifier uniqueidentifier,
	ObjectKey bigint,
	ObjectIdentifier uniqueidentifier,
	AttributeKey bigint,
	ValueReferenceIdentifier uniqueidentifier,
	ValueString nvarchar(448)
)

DECLARE @userTable2 TABLE (
	UserKey bigint,
	UserIdentifier uniqueidentifier,
	ObjectKey bigint,
	ObjectIdentifier uniqueidentifier,
	AttributeKey bigint,
	ValueReferenceIdentifier uniqueidentifier,
	ValueString nvarchar(448)
)

FETCH NEXT FROM csr_Users
INTO @userID, @userGUID

WHILE @@FETCH_STATUS = 0
BEGIN

	--PRINT 'Processing User ' + CAST(@userGUID AS varchar(30)) + ' ... ';
	
	/* Query1: 
	/Person[ObjectID='C274A940-234C-435B-BCCD-83194A3A2494']/csoRoles 
	*/

	WITH CandidateList(ObjectKey, ObjectTypeKey)
	AS
	(
		SELECT
			valueOfFormula0.ValueReference,
			valueOfFormula0.ObjectTypeKey
		FROM [fim].ObjectValueReference AS valueOfFormula0
		WHERE
		(
			(valueOfFormula0.AttributeKey = 32636) /*csoRoles*/
			AND
			(
				valueOfFormula0.ObjectKey IN
				(
					SELECT
						valueOfProposition0.ObjectKey
					FROM [fim].ObjectValueDateTime AS valueOfProposition0
					WHERE
					(
						(
							(valueOfProposition0.ObjectKey = @userID)
						)
						AND
						(
							(valueOfProposition0.ObjectTypeKey = 24) /*Person*/
						)
					)
				)
			)
			AND
			(
				valueOfFormula0.ObjectKey IN
				(
					SELECT
						smr.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smr.ObjectTypeKey = 29)
						AND
						(smr.AttributeKey = 40)
						AND
						(
							smr.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalSet IN
									(
										SELECT
											smP.ObjectKey
										FROM [fim].ObjectValueReference AS smP
										WHERE
										(
											(smP.ObjectTypeKey = 29)
											AND
											(smP.AttributeKey = 40)
											AND
											(smP.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = 32636) /*csoRoles*/
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
				OR
				(
					valueOfFormula0.ObjectKey IN
					(
						SELECT
							smR.ValueReference
						FROM [fim].ObjectValueReference AS smr
						WHERE
						(
							(smR.ObjectTypeKey = 29)
							AND
							(smR.AttributeKey = 40)
							AND
							(
								smR.ObjectKey IN
								(
									SELECT
										mpr.ResourceCurrentSet
									FROM [fim].ManagementPolicyRuleReadInternal AS mpr
									WHERE
									(
										mpr.PrincipalRelativeToResource
										IN
										(
											SELECT
												ovrR.AttributeKey
											FROM [fim].ObjectValueReference AS ovrR
											WHERE
											(
												(ovrR.ObjectKey = valueOfFormula0.ObjectKey)
												AND
												(ovrR.ObjectTypeKey = valueOfFormula0.ObjectTypeKey)
												AND
												(ovrR.ValueReference = 184853)
											)
										)
										AND
										(
											(mpr.ActionParameterAll = 1)
											OR
											(
												mpr.ObjectKey IN
												(
													(
														SELECT
															mpra.ObjectKey
														FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
														WHERE
														(
															(mpra.ObjectKey = mpr.ObjectKey)
															AND
															(mpra.ActionParameterKey = 32636) /*csoRoles*/
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	),

	Objects (ObjectKey, ObjectTypeKey)
	AS
	(
		SELECT DISTINCT
			o.ObjectKey,
			o.ObjectTypeKey
		FROM [fim].Objects AS o
		INNER JOIN CandidateList AS c
		ON
		(
			(o.ObjectKey = c.ObjectKey)
		)
	),
	ObjectOrdering(ObjectKey, Ordering, ReverseOrdering)
	AS
	(	SELECT DISTINCT
			o.ObjectKey,
			ROW_NUMBER() OVER(ORDER BY sort1.ValueString ASC, o.ObjectKey ASC) AS [Index],
			ROW_NUMBER() OVER(ORDER BY sort1.ValueString DESC, o.ObjectKey DESC) AS [ReverseIndex]
		FROM Objects AS o
		LEFT OUTER JOIN [fim].ObjectValueString AS sort1
		ON
		(
			(o.ObjectKey = sort1.ObjectKey)
			AND
			(o.ObjectTypeKey = sort1.ObjectTypeKey)
			AND
			(sort1.AttributeKey = 66) /*DisplayName*/
			AND
			(sort1.LocaleKey = 127)
		)
		WHERE
		(
			o.ObjectKey IN
			(
				SELECT
					smr.ValueReference
				FROM [fim].ObjectValueReference AS smr
				WHERE
				(
					(smr.ObjectTypeKey = 29)
					AND
					(smr.AttributeKey = 40)
					AND
					(
						smr.ObjectKey IN
						(
							SELECT
								mpr.ResourceCurrentSet
							FROM [fim].ManagementPolicyRuleReadInternal AS mpr
							WHERE
							(
								mpr.PrincipalSet IN
								(
									SELECT
										smP.ObjectKey
									FROM [fim].ObjectValueReference AS smP
									WHERE
									(
										(smP.ObjectTypeKey = 29)
										AND
										(smP.AttributeKey = 40)
										AND
										(smP.ValueReference = 184853)
									)
								)
								AND
								(
									(mpr.ActionParameterAll = 1)
									OR
									(
										mpr.ObjectKey IN
										(
											(
												SELECT
													mpra.ObjectKey
												FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
												WHERE
												(
													(mpra.ObjectKey = mpr.ObjectKey)
													AND
													(mpra.ActionParameterKey = 66) /*DisplayName*/
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
			OR
			(
				o.ObjectKey IN
				(
					SELECT
						smR.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smR.ObjectTypeKey = 29)
						AND
						(smR.AttributeKey = 40)
						AND
						(
							smR.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalRelativeToResource
									IN
									(
										SELECT
											ovrR.AttributeKey
										FROM [fim].ObjectValueReference AS ovrR
										WHERE
										(
											(ovrR.ObjectKey = o.ObjectKey)
											AND
											(ovrR.ObjectTypeKey = o.ObjectTypeKey)
											AND
											(ovrR.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = 66) /*DisplayName*/
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	),
	Locale(LocaleKey)
	AS
	(
		SELECT
			li.[Key]
		FROM [fim].LocaleInternal AS li
		WHERE
		(
			(li.[Name] = 'en-US')
		)
	),
	ResultSet
	(
		ObjectKey,
		ObjectIdentifier,
		ObjectTypeKey,
		AttributeKey,
		ValueBinary,
		ValueBoolean,
		ValueDateTime,
		ValueInteger,
		ValueReference,
		ValueString,
		ValueText,
		Ordering,
		ReverseOrdering
	)
	AS
	(
		SELECT
			v.ObjectKey,
			v.ObjectID,
			v.ObjectTypeKey,
			ai.[Key],
			NULL /*Binary*/,
			NULL /*Boolean*/,
			NULL /*DateTime*/,
			NULL /*Integer*/,
			ovr.ValueReference,
			ovs.ValueString,
			NULL /*Text*/,
			o.Ordering,
			o.ReverseOrdering
		FROM [fim].Objects AS v
		INNER JOIN ObjectOrdering AS o
		ON
		(
			(v.ObjectKey = o.ObjectKey)
		)
		CROSS JOIN [fim].AttributeInternal AS ai
		LEFT OUTER JOIN [fim].ObjectValueReference AS ovr
		ON
		(
			(v.ObjectKey = ovr.ObjectKey)
			AND
			(v.ObjectTypeKey = ovr.ObjectTypeKey)
			AND
			(ai.[Key] = ovr.AttributeKey)
			AND
			(
				ovr.ObjectKey IN
				(
					SELECT
						smr.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smr.ObjectTypeKey = 29)
						AND
						(smr.AttributeKey = 40)
						AND
						(
							smr.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalSet IN
									(
										SELECT
											smP.ObjectKey
										FROM [fim].ObjectValueReference AS smP
										WHERE
										(
											(smP.ObjectTypeKey = 29)
											AND
											(smP.AttributeKey = 40)
											AND
											(smP.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = ovr.AttributeKey)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
				OR
				(
					ovr.ObjectKey IN
					(
						SELECT
							smR.ValueReference
						FROM [fim].ObjectValueReference AS smr
						WHERE
						(
							(smR.ObjectTypeKey = 29)
							AND
							(smR.AttributeKey = 40)
							AND
							(
								smR.ObjectKey IN
								(
									SELECT
										mpr.ResourceCurrentSet
									FROM [fim].ManagementPolicyRuleReadInternal AS mpr
									WHERE
									(
										mpr.PrincipalRelativeToResource
										IN
										(
											SELECT
												ovrR.AttributeKey
											FROM [fim].ObjectValueReference AS ovrR
											WHERE
											(
												(ovrR.ObjectKey = ovr.ObjectKey)
												AND
												(ovrR.ObjectTypeKey = ovr.ObjectTypeKey)
												AND
												(ovrR.ValueReference = 184853)
											)
										)
										AND
										(
											(mpr.ActionParameterAll = 1)
											OR
											(
												mpr.ObjectKey IN
												(
													(
														SELECT
															mpra.ObjectKey
														FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
														WHERE
														(
															(mpra.ObjectKey = mpr.ObjectKey)
															AND
															(mpra.ActionParameterKey = ovr.AttributeKey)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
		LEFT OUTER JOIN [fim].ObjectValueString AS ovs
		ON
		(
			(v.ObjectKey = ovs.ObjectKey)
			AND
			(v.ObjectTypeKey = ovs.ObjectTypeKey)
			AND
			(ai.[Key] = ovs.AttributeKey)
			AND
			(ovs.LocaleKey = 127)
			AND
			(
				ovs.ObjectKey IN
				(
					SELECT
						smr.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smr.ObjectTypeKey = 29)
						AND
						(smr.AttributeKey = 40)
						AND
						(
							smr.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalSet IN
									(
										SELECT
											smP.ObjectKey
										FROM [fim].ObjectValueReference AS smP
										WHERE
										(
											(smP.ObjectTypeKey = 29)
											AND
											(smP.AttributeKey = 40)
											AND
											(smP.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = ovs.AttributeKey)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
				OR
				(
					ovs.ObjectKey IN
					(
						SELECT
							smR.ValueReference
						FROM [fim].ObjectValueReference AS smr
						WHERE
						(
							(smR.ObjectTypeKey = 29)
							AND
							(smR.AttributeKey = 40)
							AND
							(
								smR.ObjectKey IN
								(
									SELECT
										mpr.ResourceCurrentSet
									FROM [fim].ManagementPolicyRuleReadInternal AS mpr
									WHERE
									(
										mpr.PrincipalRelativeToResource
										IN
										(
											SELECT
												ovrR.AttributeKey
											FROM [fim].ObjectValueReference AS ovrR
											WHERE
											(
												(ovrR.ObjectKey = ovs.ObjectKey)
												AND
												(ovrR.ObjectTypeKey = ovs.ObjectTypeKey)
												AND
												(ovrR.ValueReference = 184853)
											)
										)
										AND
										(
											(mpr.ActionParameterAll = 1)
											OR
											(
												mpr.ObjectKey IN
												(
													(
														SELECT
															mpra.ObjectKey
														FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
														WHERE
														(
															(mpra.ObjectKey = mpr.ObjectKey)
															AND
															(mpra.ActionParameterKey = ovs.AttributeKey)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
		WHERE
		(
			(
				ai.[Key] IN
				(132 /*ObjectType*/, 0 /*ObjectID*/, 66 /*DisplayName*/, 1 /*AccountName*/, 0 /*ObjectID*/)
			)
			AND
			(o.Ordering >= 1)
			AND 
			(o.Ordering <= 31)
		)
	)
	--- Main SELECT statement here:
	INSERT INTO @userTable1
	SELECT
		@userID AS UserKey, 
		@userGUID AS UserIdentifier,
		rs.ObjectKey AS ObjectKey,
		rs.ObjectIdentifier AS ObjectIdentifier,
		rs.AttributeKey AS AttributeKey,
		/*rs.ValueBinary AS ValueBinary,
		rs.ValueBoolean AS ValueBoolean,
		rs.ValueDateTime AS ValueDateTime,
		rs.ValueInteger AS ValueInteger,
		rs.ValueReference AS ValueReference,*/
		ovi.ValueIdentifier AS ValueReferenceIdentifier,
		COALESCE(ovs.ValueString, rs.ValueString) AS ValueString/*,
		NULL AS ValueText,
		CASE
			WHEN(ovs.ValueString IS NOT NULL)THEN ovs.LocaleKey
			ELSE 127
		END AS LocaleKey,
		rs.Ordering AS Ordering,
		rs.ReverseOrdering AS ReverseOrdering*/
	FROM ResultSet AS rs
	LEFT OUTER JOIN [fim].ObjectValueString AS ovs
	ON
	(
		(rs.ObjectKey = ovs.ObjectKey)
		AND
		(rs.ObjectTypeKey = ovs.ObjectTypeKey)
		AND
		(rs.AttributeKey = ovs.AttributeKey)
		AND
		(
			ovs.LocaleKey IN
			(
				SELECT
					l.LocaleKey
				FROM Locale AS l
			)
		)
		AND
		(
			ovs.AttributeKey IN
			(
				132 /*ObjectType*/, 66 /*DisplayName*/, 1 /*AccountName*/
			)
		)
	)
	LEFT OUTER JOIN [fim].ObjectValueIdentifier AS ovi
	ON
	(
		(rs.ValueReference = ovi.ObjectKey)
		AND
		(ovi.AttributeKey = 0)
	)
	WHERE
	(
		(rs.ValueBinary IS NOT NULL)
		OR
		(rs.ValueBoolean IS NOT NULL)
		OR
		(rs.ValueDateTime IS NOT NULL)
		OR
		(rs.ValueInteger IS NOT NULL)
		OR
		(rs.ValueReference IS NOT NULL)
		OR
		(rs.ValueString IS NOT NULL)
		OR
		(rs.ValueText IS NOT NULL)
	)
	ORDER BY rs.Ordering ASC;

	/* Query2: 
	/csoRole[
		ObjectID=/csoEntitlement[
			UserID='C274A940-234C-435B-BCCD-83194A3A2494' 
			and (idmStartDate < op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D'))) 
			and ((idmEndDate > op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D'))))
		]/csoRoles
		or
		ObjectID=/csoEntitlement[
			UserID='C274A940-234C-435B-BCCD-83194A3A2494' 
			and (idmStartDate < op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D'))) 
			and ((idmEndDate > op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D'))))
		]/csoRoles/csoRollUpRole
	]
	*/

	WITH CandidateList(ObjectKey, ObjectTypeKey)
	AS
	(
		(
			(
				SELECT
					valueOfFormula4.ObjectKey,
					valueOfFormula4.ObjectTypeKey
				FROM [fim].ObjectValueDateTime AS valueOfFormula4
				WHERE
				(
					(
						(valueOfFormula4.ObjectTypeKey = 32699) /*csoRole*/
					)
					AND
					(
						valueOfFormula4.ObjectKey IN
						(
							SELECT
								valueOfFormula3.ValueReference
							FROM [fim].ObjectValueReference AS valueOfFormula3
							WHERE
							(
								(valueOfFormula3.AttributeKey = 32636) /*csoRoles*/
								AND
								(
									valueOfFormula3.ObjectKey IN
									(
										SELECT
											valueOfProposition2.ObjectKey
										FROM [fim].ObjectValueDateTime AS valueOfProposition2
										WHERE
										(
											(
												(valueOfProposition2.ObjectTypeKey = 32695) /*csoEntitlement*/
											)
											AND
											(valueOfProposition2.AttributeKey = 32632) /*idmStartDate*/
											AND
											(valueOfProposition2.SequenceID = 0)
											AND
											(valueOfProposition2.ValueDateTime < @referenceDate)
											AND
											(
												valueOfProposition2.ObjectKey IN
												(
													SELECT
														valueOfProposition3.ObjectKey
													FROM [fim].ObjectValueDateTime AS valueOfProposition3
													WHERE
													(
														(
															(valueOfProposition3.ObjectTypeKey = 32695) /*csoEntitlement*/
														)
														AND
														(valueOfProposition3.AttributeKey = 32639) /*idmEndDate*/
														AND
														(valueOfProposition3.SequenceID = 0)
														AND
														(valueOfProposition3.ValueDateTime > @referenceDate)
														AND
														(
															valueOfProposition3.ObjectKey IN
															(
																SELECT
																	smr.ValueReference
																FROM [fim].ObjectValueReference AS smr
																WHERE
																(
																	(smr.ObjectTypeKey = 29)
																	AND
																	(smr.AttributeKey = 40)
																	AND
																	(
																		smr.ObjectKey IN
																		(
																			SELECT
																				mpr.ResourceCurrentSet
																			FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																			WHERE
																			(
																				mpr.PrincipalSet IN
																				(
																					SELECT
																						smP.ObjectKey
																					FROM [fim].ObjectValueReference AS smP
																					WHERE
																					(
																						(smP.ObjectTypeKey = 29)
																						AND
																						(smP.AttributeKey = 40)
																						AND
																						(smP.ValueReference = 184853)
																					)
																				)
																				AND
																				(
																					(mpr.ActionParameterAll = 1)
																					OR
																					(
																						mpr.ObjectKey IN
																						(
																							(
																								SELECT
																									mpra.ObjectKey
																								FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																								WHERE
																								(
																									(mpra.ObjectKey = mpr.ObjectKey)
																									AND
																									(mpra.ActionParameterKey = 32639) /*idmEndDate*/
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
															OR
															(
																valueOfProposition3.ObjectKey IN
																(
																	SELECT
																		smR.ValueReference
																	FROM [fim].ObjectValueReference AS smr
																	WHERE
																	(
																		(smR.ObjectTypeKey = 29)
																		AND
																		(smR.AttributeKey = 40)
																		AND
																		(
																			smR.ObjectKey IN
																			(
																				SELECT
																					mpr.ResourceCurrentSet
																				FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																				WHERE
																				(
																					mpr.PrincipalRelativeToResource
																					IN
																					(
																						SELECT
																							ovrR.AttributeKey
																						FROM [fim].ObjectValueReference AS ovrR
																						WHERE
																						(
																							(ovrR.ObjectKey = valueOfProposition3.ObjectKey)
																							AND
																							(ovrR.ObjectTypeKey = valueOfProposition3.ObjectTypeKey)
																							AND
																							(ovrR.ValueReference = 184853)
																						)
																					)
																					AND
																					(
																						(mpr.ActionParameterAll = 1)
																						OR
																						(
																							mpr.ObjectKey IN
																							(
																								(
																									SELECT
																										mpra.ObjectKey
																									FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																									WHERE
																									(
																										(mpra.ObjectKey = mpr.ObjectKey)
																										AND
																										(mpra.ActionParameterKey = 32639) /*idmEndDate*/
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
														AND
														(
															valueOfProposition3.ObjectKey IN
															(
																SELECT
																	valueOfProposition1.ObjectKey
																FROM [fim].ObjectValueReference AS valueOfProposition1
																WHERE
																(
																	(
																		(valueOfProposition1.ObjectTypeKey = 32695) /*csoEntitlement*/
																	)
																	AND
																	(valueOfProposition1.AttributeKey = 239) /*UserID*/
																	AND
																	(valueOfProposition1.ValueReference = @userID)
																	AND
																	(
																		valueOfProposition1.ObjectKey IN
																		(
																			SELECT
																				smr.ValueReference
																			FROM [fim].ObjectValueReference AS smr
																			WHERE
																			(
																				(smr.ObjectTypeKey = 29)
																				AND
																				(smr.AttributeKey = 40)
																				AND
																				(
																					smr.ObjectKey IN
																					(
																						SELECT
																							mpr.ResourceCurrentSet
																						FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																						WHERE
																						(
																							mpr.PrincipalSet IN
																							(
																								SELECT
																									smP.ObjectKey
																								FROM [fim].ObjectValueReference AS smP
																								WHERE
																								(
																									(smP.ObjectTypeKey = 29)
																									AND
																									(smP.AttributeKey = 40)
																									AND
																									(smP.ValueReference = 184853)
																								)
																							)
																							AND
																							(
																								(mpr.ActionParameterAll = 1)
																								OR
																								(
																									mpr.ObjectKey IN
																									(
																										(
																											SELECT
																												mpra.ObjectKey
																											FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																											WHERE
																											(
																												(mpra.ObjectKey = mpr.ObjectKey)
																												AND
																												(mpra.ActionParameterKey = 239) /*UserID*/
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																		OR
																		(
																			valueOfProposition1.ObjectKey IN
																			(
																				SELECT
																					smR.ValueReference
																				FROM [fim].ObjectValueReference AS smr
																				WHERE
																				(
																					(smR.ObjectTypeKey = 29)
																					AND
																					(smR.AttributeKey = 40)
																					AND
																					(
																						smR.ObjectKey IN
																						(
																							SELECT
																								mpr.ResourceCurrentSet
																							FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																							WHERE
																							(
																								mpr.PrincipalRelativeToResource
																								IN
																								(
																									SELECT
																										ovrR.AttributeKey
																									FROM [fim].ObjectValueReference AS ovrR
																									WHERE
																									(
																										(ovrR.ObjectKey = valueOfProposition1.ObjectKey)
																										AND
																										(ovrR.ObjectTypeKey = valueOfProposition1.ObjectTypeKey)
																										AND
																										(ovrR.ValueReference = 184853)
																									)
																								)
																								AND
																								(
																									(mpr.ActionParameterAll = 1)
																									OR
																									(
																										mpr.ObjectKey IN
																										(
																											(
																												SELECT
																													mpra.ObjectKey
																												FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																												WHERE
																												(
																													(mpra.ObjectKey = mpr.ObjectKey)
																													AND
																													(mpra.ActionParameterKey = 239) /*UserID*/
																												)
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
										)
											AND
											(
												valueOfProposition2.ObjectKey IN
												(
													SELECT
														smr.ValueReference
													FROM [fim].ObjectValueReference AS smr
													WHERE
													(
														(smr.ObjectTypeKey = 29)
														AND
														(smr.AttributeKey = 40)
														AND
														(
															smr.ObjectKey IN
															(
																SELECT
																	mpr.ResourceCurrentSet
																FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																WHERE
																(
																	mpr.PrincipalSet IN
																	(
																		SELECT
																			smP.ObjectKey
																		FROM [fim].ObjectValueReference AS smP
																		WHERE
																		(
																			(smP.ObjectTypeKey = 29)
																			AND
																			(smP.AttributeKey = 40)
																			AND
																			(smP.ValueReference = 184853)
																		)
																	)
																	AND
																	(
																		(mpr.ActionParameterAll = 1)
																		OR
																		(
																			mpr.ObjectKey IN
																			(
																				(
																					SELECT
																						mpra.ObjectKey
																					FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																					WHERE
																					(
																						(mpra.ObjectKey = mpr.ObjectKey)
																						AND
																						(mpra.ActionParameterKey = 132) /*ObjectType*/
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
													)
												)
												OR
												(
													valueOfProposition2.ObjectKey IN
													(
														SELECT
															smR.ValueReference
														FROM [fim].ObjectValueReference AS smr
														WHERE
														(
															(smR.ObjectTypeKey = 29)
															AND
															(smR.AttributeKey = 40)
															AND
															(
																smR.ObjectKey IN
																(
																	SELECT
																		mpr.ResourceCurrentSet
																	FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																	WHERE
																	(
																		mpr.PrincipalRelativeToResource
																		IN
																		(
																			SELECT
																				ovrR.AttributeKey
																			FROM [fim].ObjectValueReference AS ovrR
																			WHERE
																			(
																				(ovrR.ObjectKey = valueOfProposition2.ObjectKey)
																				AND
																				(ovrR.ObjectTypeKey = valueOfProposition2.ObjectTypeKey)
																				AND
																				(ovrR.ValueReference = 184853)
																			)
																		)
																		AND
																		(
																			(mpr.ActionParameterAll = 1)
																			OR
																			(
																				mpr.ObjectKey IN
																				(
																					(
																						SELECT
																							mpra.ObjectKey
																						FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																						WHERE
																						(
																							(mpra.ObjectKey = mpr.ObjectKey)
																							AND
																							(mpra.ActionParameterKey = 132) /*ObjectType*/
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
									)
								)
								AND
								(
									valueOfFormula3.ObjectKey IN
									(
										SELECT
											smr.ValueReference
										FROM [fim].ObjectValueReference AS smr
										WHERE
										(
											(smr.ObjectTypeKey = 29)
											AND
											(smr.AttributeKey = 40)
											AND
											(
												smr.ObjectKey IN
												(
													SELECT
														mpr.ResourceCurrentSet
													FROM [fim].ManagementPolicyRuleReadInternal AS mpr
													WHERE
													(
														mpr.PrincipalSet IN
														(
															SELECT
																smP.ObjectKey
															FROM [fim].ObjectValueReference AS smP
															WHERE
															(
																(smP.ObjectTypeKey = 29)
																AND
																(smP.AttributeKey = 40)
																AND
																(smP.ValueReference = 184853)
															)
														)
														AND
														(
															(mpr.ActionParameterAll = 1)
															OR
															(
																mpr.ObjectKey IN
																(
																	(
																		SELECT
																			mpra.ObjectKey
																		FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																		WHERE
																		(
																			(mpra.ObjectKey = mpr.ObjectKey)
																			AND
																			(mpra.ActionParameterKey = 32636) /*csoRoles*/
																		)
																	)
																)
															)
														)
													)
												)
											)
										)
									)
									OR
									(
										valueOfFormula3.ObjectKey IN
										(
											SELECT
												smR.ValueReference
											FROM [fim].ObjectValueReference AS smr
											WHERE
											(
												(smR.ObjectTypeKey = 29)
												AND
												(smR.AttributeKey = 40)
												AND
												(
													smR.ObjectKey IN
													(
														SELECT
															mpr.ResourceCurrentSet
														FROM [fim].ManagementPolicyRuleReadInternal AS mpr
														WHERE
														(
															mpr.PrincipalRelativeToResource
															IN
															(
																SELECT
																	ovrR.AttributeKey
																FROM [fim].ObjectValueReference AS ovrR
																WHERE
																(
																	(ovrR.ObjectKey = valueOfFormula3.ObjectKey)
																	AND
																	(ovrR.ObjectTypeKey = valueOfFormula3.ObjectTypeKey)
																	AND
																	(ovrR.ValueReference = 184853)
																)
															)
															AND
															(
																(mpr.ActionParameterAll = 1)
																OR
																(
																	mpr.ObjectKey IN
																	(
																		(
																			SELECT
																				mpra.ObjectKey
																			FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																			WHERE
																			(
																				(mpra.ObjectKey = mpr.ObjectKey)
																				AND
																				(mpra.ActionParameterKey = 32636) /*csoRoles*/
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
			UNION
			(
				SELECT
					valueOfFormula10.ObjectKey,
					valueOfFormula10.ObjectTypeKey
				FROM [fim].ObjectValueDateTime AS valueOfFormula10
				WHERE
				(
					(
						(valueOfFormula10.ObjectTypeKey = 32699) /*csoRole*/
					)
					AND
					(
						valueOfFormula10.ObjectKey IN
						(
							SELECT
								valueOfFormula9.ValueReference
							FROM [fim].ObjectValueReference AS valueOfFormula9
							WHERE
							(
								(valueOfFormula9.AttributeKey = 32637) /*csoRollUpRole*/
								AND
								(
									valueOfFormula9.ObjectKey IN
									(
										SELECT
											valueOfFormula8.ValueReference
										FROM [fim].ObjectValueReference AS valueOfFormula8
										WHERE
										(
											(valueOfFormula8.AttributeKey = 32636) /*csoRoles*/
											AND
											(
												valueOfFormula8.ObjectKey IN
												(
													SELECT
														valueOfProposition6.ObjectKey
													FROM [fim].ObjectValueDateTime AS valueOfProposition6
													WHERE
													(
														(
															(valueOfProposition6.ObjectTypeKey = 32695) /*csoEntitlement*/
														)
														AND
														(valueOfProposition6.AttributeKey = 32632) /*idmStartDate*/
														AND
														(valueOfProposition6.SequenceID = 0)
														AND
														(valueOfProposition6.ValueDateTime < @referenceDate)
														AND
														(
															valueOfProposition6.ObjectKey IN
															(
																SELECT
																	valueOfProposition7.ObjectKey
																FROM [fim].ObjectValueDateTime AS valueOfProposition7
																WHERE
																(
																	(
																		(valueOfProposition7.ObjectTypeKey = 32695) /*csoEntitlement*/
																	)
																	AND
																	(valueOfProposition7.AttributeKey = 32639) /*idmEndDate*/
																	AND
																	(valueOfProposition7.SequenceID = 0)
																	AND
																	(valueOfProposition7.ValueDateTime > @referenceDate)
																	AND
																	(
																		valueOfProposition7.ObjectKey IN
																		(
																			SELECT
																				smr.ValueReference
																			FROM [fim].ObjectValueReference AS smr
																			WHERE
																			(
																				(smr.ObjectTypeKey = 29)
																				AND
																				(smr.AttributeKey = 40)
																				AND
																				(
																					smr.ObjectKey IN
																					(
																						SELECT
																							mpr.ResourceCurrentSet
																						FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																						WHERE
																						(
																							mpr.PrincipalSet IN
																							(
																								SELECT
																									smP.ObjectKey
																								FROM [fim].ObjectValueReference AS smP
																								WHERE
																								(
																									(smP.ObjectTypeKey = 29)
																									AND
																									(smP.AttributeKey = 40)
																									AND
																									(smP.ValueReference = 184853)
																								)
																							)
																							AND
																							(
																								(mpr.ActionParameterAll = 1)
																								OR
																								(
																									mpr.ObjectKey IN
																									(
																										(
																											SELECT
																												mpra.ObjectKey
																											FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																											WHERE
																											(
																												(mpra.ObjectKey = mpr.ObjectKey)
																												AND
																												(mpra.ActionParameterKey = 32639) /*idmEndDate*/
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																		OR
																		(
																			valueOfProposition7.ObjectKey IN
																			(
																				SELECT
																					smR.ValueReference
																				FROM [fim].ObjectValueReference AS smr
																				WHERE
																				(
																					(smR.ObjectTypeKey = 29)
																					AND
																					(smR.AttributeKey = 40)
																					AND
																					(
																						smR.ObjectKey IN
																						(
																							SELECT
																								mpr.ResourceCurrentSet
																							FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																							WHERE
																							(
																								mpr.PrincipalRelativeToResource
																								IN
																								(
																									SELECT
																										ovrR.AttributeKey
																									FROM [fim].ObjectValueReference AS ovrR
																									WHERE
																									(
																										(ovrR.ObjectKey = valueOfProposition7.ObjectKey)
																										AND
																										(ovrR.ObjectTypeKey = valueOfProposition7.ObjectTypeKey)
																										AND
																										(ovrR.ValueReference = 184853)
																									)
																								)
																								AND
																								(
																									(mpr.ActionParameterAll = 1)
																									OR
																									(
																										mpr.ObjectKey IN
																										(
																											(
																												SELECT
																													mpra.ObjectKey
																												FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																												WHERE
																												(
																													(mpra.ObjectKey = mpr.ObjectKey)
																													AND
																													(mpra.ActionParameterKey = 32639) /*idmEndDate*/
																												)
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																	AND
																	(
																		valueOfProposition7.ObjectKey IN
																		(
																			SELECT
																				valueOfProposition5.ObjectKey
																			FROM [fim].ObjectValueReference AS valueOfProposition5
																			WHERE
																			(
																				(
																					(valueOfProposition5.ObjectTypeKey = 32695) /*csoEntitlement*/
																				)
																				AND
																				(valueOfProposition5.AttributeKey = 239) /*UserID*/
																				AND
																				(valueOfProposition5.ValueReference = @userID)
																				AND
																				(
																					valueOfProposition5.ObjectKey IN
																					(
																						SELECT
																							smr.ValueReference
																						FROM [fim].ObjectValueReference AS smr
																						WHERE
																						(
																							(smr.ObjectTypeKey = 29)
																							AND
																							(smr.AttributeKey = 40)
																							AND
																							(
																								smr.ObjectKey IN
																								(
																									SELECT
																										mpr.ResourceCurrentSet
																									FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																									WHERE
																									(
																										mpr.PrincipalSet IN
																										(
																											SELECT
																												smP.ObjectKey
																											FROM [fim].ObjectValueReference AS smP
																											WHERE
																											(
																												(smP.ObjectTypeKey = 29)
																												AND
																												(smP.AttributeKey = 40)
																												AND
																												(smP.ValueReference = 184853)
																											)
																										)
																										AND
																										(
																											(mpr.ActionParameterAll = 1)
																											OR
																											(
																												mpr.ObjectKey IN
																												(
																													(
																														SELECT
																															mpra.ObjectKey
																														FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																														WHERE
																														(
																															(mpra.ObjectKey = mpr.ObjectKey)
																															AND
																															(mpra.ActionParameterKey = 239) /*UserID*/
																														)
																													)
																												)
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																					OR
																					(
																						valueOfProposition5.ObjectKey IN
																						(
																							SELECT
																								smR.ValueReference
																							FROM [fim].ObjectValueReference AS smr
																							WHERE
																							(
																								(smR.ObjectTypeKey = 29)
																								AND
																								(smR.AttributeKey = 40)
																								AND
																								(
																									smR.ObjectKey IN
																									(
																										SELECT
																											mpr.ResourceCurrentSet
																										FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																										WHERE
																										(
																											mpr.PrincipalRelativeToResource
																											IN
																											(
																												SELECT
																													ovrR.AttributeKey
																												FROM [fim].ObjectValueReference AS ovrR
																												WHERE
																												(
																													(ovrR.ObjectKey = valueOfProposition5.ObjectKey)
																													AND
																													(ovrR.ObjectTypeKey = valueOfProposition5.ObjectTypeKey)
																													AND
																													(ovrR.ValueReference = 184853)
																												)
																											)
																											AND
																											(
																												(mpr.ActionParameterAll = 1)
																												OR
																												(
																													mpr.ObjectKey IN
																													(
																														(
																															SELECT
																																mpra.ObjectKey
																															FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																															WHERE
																															(
																																(mpra.ObjectKey = mpr.ObjectKey)
																																AND
																																(mpra.ActionParameterKey = 239) /*UserID*/
																															)
																														)
																													)
																												)
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
													)
														AND
														(
															valueOfProposition6.ObjectKey IN
															(
																SELECT
																	smr.ValueReference
																FROM [fim].ObjectValueReference AS smr
																WHERE
																(
																	(smr.ObjectTypeKey = 29)
																	AND
																	(smr.AttributeKey = 40)
																	AND
																	(
																		smr.ObjectKey IN
																		(
																			SELECT
																				mpr.ResourceCurrentSet
																			FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																			WHERE
																			(
																				mpr.PrincipalSet IN
																				(
																					SELECT
																						smP.ObjectKey
																					FROM [fim].ObjectValueReference AS smP
																					WHERE
																					(
																						(smP.ObjectTypeKey = 29)
																						AND
																						(smP.AttributeKey = 40)
																						AND
																						(smP.ValueReference = 184853)
																					)
																				)
																				AND
																				(
																					(mpr.ActionParameterAll = 1)
																					OR
																					(
																						mpr.ObjectKey IN
																						(
																							(
																								SELECT
																									mpra.ObjectKey
																								FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																								WHERE
																								(
																									(mpra.ObjectKey = mpr.ObjectKey)
																									AND
																									(mpra.ActionParameterKey = 132) /*ObjectType*/
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
															OR
															(
																valueOfProposition6.ObjectKey IN
																(
																	SELECT
																		smR.ValueReference
																	FROM [fim].ObjectValueReference AS smr
																	WHERE
																	(
																		(smR.ObjectTypeKey = 29)
																		AND
																		(smR.AttributeKey = 40)
																		AND
																		(
																			smR.ObjectKey IN
																			(
																				SELECT
																					mpr.ResourceCurrentSet
																				FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																				WHERE
																				(
																					mpr.PrincipalRelativeToResource
																					IN
																					(
																						SELECT
																							ovrR.AttributeKey
																						FROM [fim].ObjectValueReference AS ovrR
																						WHERE
																						(
																							(ovrR.ObjectKey = valueOfProposition6.ObjectKey)
																							AND
																							(ovrR.ObjectTypeKey = valueOfProposition6.ObjectTypeKey)
																							AND
																							(ovrR.ValueReference = 184853)
																						)
																					)
																					AND
																					(
																						(mpr.ActionParameterAll = 1)
																						OR
																						(
																							mpr.ObjectKey IN
																							(
																								(
																									SELECT
																										mpra.ObjectKey
																									FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																									WHERE
																									(
																										(mpra.ObjectKey = mpr.ObjectKey)
																										AND
																										(mpra.ActionParameterKey = 132) /*ObjectType*/
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
												)
											)
											AND
											(
												valueOfFormula8.ObjectKey IN
												(
													SELECT
														smr.ValueReference
													FROM [fim].ObjectValueReference AS smr
													WHERE
													(
														(smr.ObjectTypeKey = 29)
														AND
														(smr.AttributeKey = 40)
														AND
														(
															smr.ObjectKey IN
															(
																SELECT
																	mpr.ResourceCurrentSet
																FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																WHERE
																(
																	mpr.PrincipalSet IN
																	(
																		SELECT
																			smP.ObjectKey
																		FROM [fim].ObjectValueReference AS smP
																		WHERE
																		(
																			(smP.ObjectTypeKey = 29)
																			AND
																			(smP.AttributeKey = 40)
																			AND
																			(smP.ValueReference = 184853)
																		)
																	)
																	AND
																	(
																		(mpr.ActionParameterAll = 1)
																		OR
																		(
																			mpr.ObjectKey IN
																			(
																				(
																					SELECT
																						mpra.ObjectKey
																					FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																					WHERE
																					(
																						(mpra.ObjectKey = mpr.ObjectKey)
																						AND
																						(mpra.ActionParameterKey = 32636) /*csoRoles*/
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
													)
												)
												OR
												(
													valueOfFormula8.ObjectKey IN
													(
														SELECT
															smR.ValueReference
														FROM [fim].ObjectValueReference AS smr
														WHERE
														(
															(smR.ObjectTypeKey = 29)
															AND
															(smR.AttributeKey = 40)
															AND
															(
																smR.ObjectKey IN
																(
																	SELECT
																		mpr.ResourceCurrentSet
																	FROM [fim].ManagementPolicyRuleReadInternal AS mpr
																	WHERE
																	(
																		mpr.PrincipalRelativeToResource
																		IN
																		(
																			SELECT
																				ovrR.AttributeKey
																			FROM [fim].ObjectValueReference AS ovrR
																			WHERE
																			(
																				(ovrR.ObjectKey = valueOfFormula8.ObjectKey)
																				AND
																				(ovrR.ObjectTypeKey = valueOfFormula8.ObjectTypeKey)
																				AND
																				(ovrR.ValueReference = 184853)
																			)
																		)
																		AND
																		(
																			(mpr.ActionParameterAll = 1)
																			OR
																			(
																				mpr.ObjectKey IN
																				(
																					(
																						SELECT
																							mpra.ObjectKey
																						FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																						WHERE
																						(
																							(mpra.ObjectKey = mpr.ObjectKey)
																							AND
																							(mpra.ActionParameterKey = 32636) /*csoRoles*/
																						)
																					)
																				)
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
										)
									)
								)
								AND
								(
									valueOfFormula9.ObjectKey IN
									(
										SELECT
											smr.ValueReference
										FROM [fim].ObjectValueReference AS smr
										WHERE
										(
											(smr.ObjectTypeKey = 29)
											AND
											(smr.AttributeKey = 40)
											AND
											(
												smr.ObjectKey IN
												(
													SELECT
														mpr.ResourceCurrentSet
													FROM [fim].ManagementPolicyRuleReadInternal AS mpr
													WHERE
													(
														mpr.PrincipalSet IN
														(
															SELECT
																smP.ObjectKey
															FROM [fim].ObjectValueReference AS smP
															WHERE
															(
																(smP.ObjectTypeKey = 29)
																AND
																(smP.AttributeKey = 40)
																AND
																(smP.ValueReference = 184853)
															)
														)
														AND
														(
															(mpr.ActionParameterAll = 1)
															OR
															(
																mpr.ObjectKey IN
																(
																	(
																		SELECT
																			mpra.ObjectKey
																		FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																		WHERE
																		(
																			(mpra.ObjectKey = mpr.ObjectKey)
																			AND
																			(mpra.ActionParameterKey = 32637) /*csoRollUpRole*/
																		)
																	)
																)
															)
														)
													)
												)
											)
										)
									)
									OR
									(
										valueOfFormula9.ObjectKey IN
										(
											SELECT
												smR.ValueReference
											FROM [fim].ObjectValueReference AS smr
											WHERE
											(
												(smR.ObjectTypeKey = 29)
												AND
												(smR.AttributeKey = 40)
												AND
												(
													smR.ObjectKey IN
													(
														SELECT
															mpr.ResourceCurrentSet
														FROM [fim].ManagementPolicyRuleReadInternal AS mpr
														WHERE
														(
															mpr.PrincipalRelativeToResource
															IN
															(
																SELECT
																	ovrR.AttributeKey
																FROM [fim].ObjectValueReference AS ovrR
																WHERE
																(
																	(ovrR.ObjectKey = valueOfFormula9.ObjectKey)
																	AND
																	(ovrR.ObjectTypeKey = valueOfFormula9.ObjectTypeKey)
																	AND
																	(ovrR.ValueReference = 184853)
																)
															)
															AND
															(
																(mpr.ActionParameterAll = 1)
																OR
																(
																	mpr.ObjectKey IN
																	(
																		(
																			SELECT
																				mpra.ObjectKey
																			FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
																			WHERE
																			(
																				(mpra.ObjectKey = mpr.ObjectKey)
																				AND
																				(mpra.ActionParameterKey = 32637) /*csoRollUpRole*/
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	),

	Objects (ObjectKey, ObjectTypeKey)
	AS
	(
		SELECT DISTINCT
			o.ObjectKey,
			o.ObjectTypeKey
		FROM [fim].Objects AS o
		INNER JOIN CandidateList AS c
		ON
		(
			(o.ObjectKey = c.ObjectKey)
		)
	),
	ObjectOrdering(ObjectKey, Ordering, ReverseOrdering)
	AS
	(	SELECT DISTINCT
			o.ObjectKey,
			ROW_NUMBER() OVER(ORDER BY sort1.ValueString ASC, o.ObjectKey ASC) AS [Index],
			ROW_NUMBER() OVER(ORDER BY sort1.ValueString DESC, o.ObjectKey DESC) AS [ReverseIndex]
		FROM Objects AS o
		LEFT OUTER JOIN [fim].ObjectValueString AS sort1
		ON
		(
			(o.ObjectKey = sort1.ObjectKey)
			AND
			(o.ObjectTypeKey = sort1.ObjectTypeKey)
			AND
			(sort1.AttributeKey = 66) /*DisplayName*/
			AND
			(sort1.LocaleKey = 127)
		)
		WHERE
		(
			o.ObjectKey IN
			(
				SELECT
					smr.ValueReference
				FROM [fim].ObjectValueReference AS smr
				WHERE
				(
					(smr.ObjectTypeKey = 29)
					AND
					(smr.AttributeKey = 40)
					AND
					(
						smr.ObjectKey IN
						(
							SELECT
								mpr.ResourceCurrentSet
							FROM [fim].ManagementPolicyRuleReadInternal AS mpr
							WHERE
							(
								mpr.PrincipalSet IN
								(
									SELECT
										smP.ObjectKey
									FROM [fim].ObjectValueReference AS smP
									WHERE
									(
										(smP.ObjectTypeKey = 29)
										AND
										(smP.AttributeKey = 40)
										AND
										(smP.ValueReference = 184853)
									)
								)
								AND
								(
									(mpr.ActionParameterAll = 1)
									OR
									(
										mpr.ObjectKey IN
										(
											(
												SELECT
													mpra.ObjectKey
												FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
												WHERE
												(
													(mpra.ObjectKey = mpr.ObjectKey)
													AND
													(mpra.ActionParameterKey = 66) /*DisplayName*/
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
			OR
			(
				o.ObjectKey IN
				(
					SELECT
						smR.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smR.ObjectTypeKey = 29)
						AND
						(smR.AttributeKey = 40)
						AND
						(
							smR.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalRelativeToResource
									IN
									(
										SELECT
											ovrR.AttributeKey
										FROM [fim].ObjectValueReference AS ovrR
										WHERE
										(
											(ovrR.ObjectKey = o.ObjectKey)
											AND
											(ovrR.ObjectTypeKey = o.ObjectTypeKey)
											AND
											(ovrR.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = 66) /*DisplayName*/
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	),
	Locale(LocaleKey)
	AS
	(
		SELECT
			li.[Key]
		FROM [fim].LocaleInternal AS li
		WHERE
		(
			(li.[Name] = 'en-US')
		)
	),
	ResultSet
	(
		ObjectKey,
		ObjectIdentifier,
		ObjectTypeKey,
		AttributeKey,
		ValueBinary,
		ValueBoolean,
		ValueDateTime,
		ValueInteger,
		ValueReference,
		ValueString,
		ValueText,
		Ordering,
		ReverseOrdering
	)
	AS
	(
		SELECT
			v.ObjectKey,
			v.ObjectID,
			v.ObjectTypeKey,
			ai.[Key],
			NULL /*Binary*/,
			NULL /*Boolean*/,
			NULL /*DateTime*/,
			NULL /*Integer*/,
			ovr.ValueReference,
			ovs.ValueString,
			NULL /*Text*/,
			o.Ordering,
			o.ReverseOrdering
		FROM [fim].Objects AS v
		INNER JOIN ObjectOrdering AS o
		ON
		(
			(v.ObjectKey = o.ObjectKey)
		)
		CROSS JOIN [fim].AttributeInternal AS ai
		LEFT OUTER JOIN [fim].ObjectValueReference AS ovr
		ON
		(
			(v.ObjectKey = ovr.ObjectKey)
			AND
			(v.ObjectTypeKey = ovr.ObjectTypeKey)
			AND
			(ai.[Key] = ovr.AttributeKey)
			AND
			(
				ovr.ObjectKey IN
				(
					SELECT
						smr.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smr.ObjectTypeKey = 29)
						AND
						(smr.AttributeKey = 40)
						AND
						(
							smr.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalSet IN
									(
										SELECT
											smP.ObjectKey
										FROM [fim].ObjectValueReference AS smP
										WHERE
										(
											(smP.ObjectTypeKey = 29)
											AND
											(smP.AttributeKey = 40)
											AND
											(smP.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = ovr.AttributeKey)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
				OR
				(
					ovr.ObjectKey IN
					(
						SELECT
							smR.ValueReference
						FROM [fim].ObjectValueReference AS smr
						WHERE
						(
							(smR.ObjectTypeKey = 29)
							AND
							(smR.AttributeKey = 40)
							AND
							(
								smR.ObjectKey IN
								(
									SELECT
										mpr.ResourceCurrentSet
									FROM [fim].ManagementPolicyRuleReadInternal AS mpr
									WHERE
									(
										mpr.PrincipalRelativeToResource
										IN
										(
											SELECT
												ovrR.AttributeKey
											FROM [fim].ObjectValueReference AS ovrR
											WHERE
											(
												(ovrR.ObjectKey = ovr.ObjectKey)
												AND
												(ovrR.ObjectTypeKey = ovr.ObjectTypeKey)
												AND
												(ovrR.ValueReference = 184853)
											)
										)
										AND
										(
											(mpr.ActionParameterAll = 1)
											OR
											(
												mpr.ObjectKey IN
												(
													(
														SELECT
															mpra.ObjectKey
														FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
														WHERE
														(
															(mpra.ObjectKey = mpr.ObjectKey)
															AND
															(mpra.ActionParameterKey = ovr.AttributeKey)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
		LEFT OUTER JOIN [fim].ObjectValueString AS ovs
		ON
		(
			(v.ObjectKey = ovs.ObjectKey)
			AND
			(v.ObjectTypeKey = ovs.ObjectTypeKey)
			AND
			(ai.[Key] = ovs.AttributeKey)
			AND
			(ovs.LocaleKey = 127)
			AND
			(
				ovs.ObjectKey IN
				(
					SELECT
						smr.ValueReference
					FROM [fim].ObjectValueReference AS smr
					WHERE
					(
						(smr.ObjectTypeKey = 29)
						AND
						(smr.AttributeKey = 40)
						AND
						(
							smr.ObjectKey IN
							(
								SELECT
									mpr.ResourceCurrentSet
								FROM [fim].ManagementPolicyRuleReadInternal AS mpr
								WHERE
								(
									mpr.PrincipalSet IN
									(
										SELECT
											smP.ObjectKey
										FROM [fim].ObjectValueReference AS smP
										WHERE
										(
											(smP.ObjectTypeKey = 29)
											AND
											(smP.AttributeKey = 40)
											AND
											(smP.ValueReference = 184853)
										)
									)
									AND
									(
										(mpr.ActionParameterAll = 1)
										OR
										(
											mpr.ObjectKey IN
											(
												(
													SELECT
														mpra.ObjectKey
													FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
													WHERE
													(
														(mpra.ObjectKey = mpr.ObjectKey)
														AND
														(mpra.ActionParameterKey = ovs.AttributeKey)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
				OR
				(
					ovs.ObjectKey IN
					(
						SELECT
							smR.ValueReference
						FROM [fim].ObjectValueReference AS smr
						WHERE
						(
							(smR.ObjectTypeKey = 29)
							AND
							(smR.AttributeKey = 40)
							AND
							(
								smR.ObjectKey IN
								(
									SELECT
										mpr.ResourceCurrentSet
									FROM [fim].ManagementPolicyRuleReadInternal AS mpr
									WHERE
									(
										mpr.PrincipalRelativeToResource
										IN
										(
											SELECT
												ovrR.AttributeKey
											FROM [fim].ObjectValueReference AS ovrR
											WHERE
											(
												(ovrR.ObjectKey = ovs.ObjectKey)
												AND
												(ovrR.ObjectTypeKey = ovs.ObjectTypeKey)
												AND
												(ovrR.ValueReference = 184853)
											)
										)
										AND
										(
											(mpr.ActionParameterAll = 1)
											OR
											(
												mpr.ObjectKey IN
												(
													(
														SELECT
															mpra.ObjectKey
														FROM [fim].ManagementPolicyRuleReadInternalAttribute AS mpra
														WHERE
														(
															(mpra.ObjectKey = mpr.ObjectKey)
															AND
															(mpra.ActionParameterKey = ovs.AttributeKey)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
		WHERE
		(
			(
				ai.[Key] IN
				(132 /*ObjectType*/, 0 /*ObjectID*/, 66 /*DisplayName*/, 1 /*AccountName*/, 0 /*ObjectID*/)
			)
			AND
			(o.Ordering >= 1)
			AND 
			(o.Ordering <= 31)
		)
	)
	--- Main SELECT statement here:
	INSERT INTO @userTable2
	SELECT
		@userID AS UserKey, 
		@userGUID AS UserIdentifier,
		rs.ObjectKey AS ObjectKey,
		rs.ObjectIdentifier AS ObjectIdentifier,
		rs.AttributeKey AS AttributeKey,
		/*rs.ValueBinary AS ValueBinary,
		rs.ValueBoolean AS ValueBoolean,
		rs.ValueDateTime AS ValueDateTime,
		rs.ValueInteger AS ValueInteger,
		rs.ValueReference AS ValueReference,*/
		ovi.ValueIdentifier AS ValueReferenceIdentifier,
		COALESCE(ovs.ValueString, rs.ValueString) AS ValueString/*,
		NULL AS ValueText,
		CASE
			WHEN(ovs.ValueString IS NOT NULL)THEN ovs.LocaleKey
			ELSE 127
		END AS LocaleKey,
		rs.Ordering AS Ordering,
		rs.ReverseOrdering AS ReverseOrdering*/
	FROM ResultSet AS rs
	LEFT OUTER JOIN [fim].ObjectValueString AS ovs
	ON
	(
		(rs.ObjectKey = ovs.ObjectKey)
		AND
		(rs.ObjectTypeKey = ovs.ObjectTypeKey)
		AND
		(rs.AttributeKey = ovs.AttributeKey)
		AND
		(
			ovs.LocaleKey IN
			(
				SELECT
					l.LocaleKey
				FROM Locale AS l
			)
		)
		AND
		(
			ovs.AttributeKey IN
			(
				132 /*ObjectType*/, 66 /*DisplayName*/, 1 /*AccountName*/
			)
		)
	)
	LEFT OUTER JOIN [fim].ObjectValueIdentifier AS ovi
	ON
	(
		(rs.ValueReference = ovi.ObjectKey)
		AND
		(ovi.AttributeKey = 0)
	)
	WHERE
	(
		(rs.ValueBinary IS NOT NULL)
		OR
		(rs.ValueBoolean IS NOT NULL)
		OR
		(rs.ValueDateTime IS NOT NULL)
		OR
		(rs.ValueInteger IS NOT NULL)
		OR
		(rs.ValueReference IS NOT NULL)
		OR
		(rs.ValueString IS NOT NULL)
		OR
		(rs.ValueText IS NOT NULL)
	)
	ORDER BY rs.Ordering ASC;

	FETCH NEXT FROM csr_Users
	INTO @userID, @userGUID

END

CLOSE csr_Users;
DEALLOCATE csr_Users;

/*

Select * from @userTable1 U1

Select * from @userTable2 U1

Select * from @userTable1 U1
WHERE not exists (
	Select * from @userTable2 U2
	WHERE U1.ObjectKey = U2.ObjectKey
	And U1.UserKey = U2.UserKey
	And U1.AttributeKey = U2.AttributeKey
)

Select * from @userTable2 U2
WHERE not exists (
	Select * from @userTable1 U1
	WHERE U1.ObjectKey = U2.ObjectKey
	And U1.UserKey = U2.UserKey
	And U1.AttributeKey = U2.AttributeKey
)
*/

/*
http://richarddingwall.name/2008/08/26/nested-xml-results-from-sql-server-with-for-xml-path/
*/

SELECT
(
	Select * From (
		Select DISTINCT UserKey, UserIdentifier from @userTable1 U1
		WHERE not exists (
			Select * from @userTable2 U2
			WHERE U1.ObjectKey = U2.ObjectKey
			And U1.UserKey = U2.UserKey
			And U1.AttributeKey = U2.AttributeKey
		)
		union all

		Select DISTINCT UserKey, UserIdentifier from @userTable2 U2
		WHERE not exists (
			Select * from @userTable1 U1
			WHERE U1.ObjectKey = U2.ObjectKey
			And U1.UserKey = U2.UserKey
			And U1.AttributeKey = U2.AttributeKey
		)
	) X
	FOR XML PATH('user'), TYPE
)
for xml path (''), ROOT ('roleUsers')


GO


