if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}

$userFilter = "/Person[ObjectID=/Set[ObjectID='159bc3f2-c2af-4a66-90d0-3234390337a2']/ComputedMember]"
$EREFilter = "/ExpectedRuleEntry[SynchronizationRuleID='2be38e3e-c9f4-43aa-ac33-5fc28648eed6']"
$comboFilter = "/Person[PersonType='Student' and not(ObjectID=/ExpectedRuleEntry[SynchronizationRuleID='2be38e3e-c9f4-43aa-ac33-5fc28648eed6']/ResourceParent) and ObjectID=/Set[ObjectID='159bc3f2-c2af-4a66-90d0-3234390337a2']/ComputedMember]"

$users = Export-FIMConfig -OnlyBaseResources -CustomConfig $comboFilter
#$eres = Export-FIMConfig -OnlyBaseResources -CustomConfig $EREFilter
$users | % {($_.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq 'DisplayName'}) | Select Value}