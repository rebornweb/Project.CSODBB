PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false)

### Includes Workflows for processing policy upgrades at the time of the FIM=>MIM upgrade
###
### Parameters:
###   -UpdateExisting  Checks if Existing objects should be updated 
###   -Uninstall       Reverse changes made by this script


$ErrorActionPreference = "Stop"

###
### Include Scripts
###
. D:\Scripts\shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

$Objects = @{}

###
### Workflows
###

$Objects.Add("Workflows", @{})
$XOML =  @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/ObjectID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity5" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/Person[ObjectID='[//Target/ObjectID]' and starts-with(csoLegacyEmployeeID,'%')]" x:Name="authenticationGateActivity7" ResolvedXpathFilter="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="E:\LOGS\FIM\CSO.SetEntitlementDisplayNames.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/Person[ObjectID='[//Target/ObjectID]' and starts-with(EmployeeID,'%')]" x:Name="authenticationGateActivity6" ResolvedXpathFilter="{x:Null}" AttributeNames="EmployeeID" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="E:\LOGS\FIM\CSO.SetEntitlementDisplayNames.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/csoEntitlement[UserID='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="Entitlement for EmployeeID [//WorkflowData/EmployeeID] ... recalculating decription" TargetResource="{x:Null}" ObjectType="csoEntitlement" SaveWorkflowDataStorageMode="Object" DeleteIfFound="False" ExtraAttributes="Description=string:[//Target/DisplayName] entitlements (renamed user, EmployeeID [//WorkflowData/EmployeeID])" InsertIfNotFound="False" LogFile="E:\LOGS\FIM\CSO.SetEntitlementDisplayNames.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set entitlement display name on linked user change",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Update each entitlement description whenever the corresponding user's display name changes";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "WorkflowDefinition" -HashObjects $Objects.Workflows -UpdateExisting $UpdateExisting


###
### Sets 
###
### Create new set (with filter rule) for CeIder
###

$Objects.Add("Set",@{})
$Objects.Set.Add("cso-All users with entitlements",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath "/Person[ObjectID=/Set[ObjectID='$(LookupObject -ObjectType "Set" -Name "All People" -NoPrefix $true)']/ComputedMember `
and csoRoles = /Set[ObjectID='$(LookupObject -ObjectType "Set" -Name "cso-All Roles" -NoPrefix $true)']/ComputedMember]"
                "Description" ="All users with entitlements"}
    "Uninstall" = "DeleteObject" 
})

ProcessObjects -ObjectType "Set" -HashObjects $Objects.Set -UpdateExisting $UpdateExisting

###
###
### MPRs
###

$Objects.Add("MPRs", @{})
$MPRName = "cso-Synchronisation: Entitlement description is recalculated when user DisplayName changes"
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=@("DisplayName")
                "ActionType"=@("Modify")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "All People")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-All users with entitlements")
                "Description"="Entitlement description is recalculated when user DisplayName changes"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Set entitlement display name on linked user change"))
                "Disabled"="$false"}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.MPRs -UpdateExisting $UpdateExisting

