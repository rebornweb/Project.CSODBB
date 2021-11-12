PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false)

### Includes MPR, Sets, Workflow for processing CeIder for Students within FIM Portal
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
### New attribute in FIM Portal Schema
###

$Objects.Add("AttributeTypeDescription", @{})
$Objects.AttributeTypeDescription.Add("csoCeIder",
@{
    "Add" = @{"Name"="csoCeIder";"DisplayName"="CeIder";"DataType"="String";"Multivalued"="False"};
    "Update" = @{"Description"="Catholic education Identifier"}
});

ProcessObjects -objectType "AttributeTypeDescription" -HashObjects $Objects.AttributeTypeDescription

###
### Bindings for new attribute
###

$Objects.Add("BindingDescription",@{})
$Objects.BindingDescription.Add("Person",@{})
$Objects.BindingDescription.Person.Add("CeIder",
@{
    "Add" = @{"BoundAttributeType"=(LookupObject -ObjectType "AttributeTypeDescription" -Name "csoCeIder");
                "BoundObjectType"=(LookupObject -ObjectType "ObjectTypeDescription" -Name "Person");
                "DisplayName"="CeIder"};
    "Update" = @{"Required"="false";"Description"="Catholic education Identifier"}
})

ProcessObjects -ObjectType "BindingDescription" -HashObjects $Objects.BindingDescription.Person

###
### Filter Permissions
###

$Objects.Add("FilterScopes", @{})

$filter = "/FilterScope[DisplayName='Administrator Filter Permission']"
$obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $obj) {Throw "The OOTB 'Administrator Filter Permission' Filter Scope must exist."}
# Append to existing set of filters
$AllowedAttributes = ($obj.ResourceManagementObject.ResourceManagementAttributes | where { $_.AttributeName -eq "AllowedAttributes"}).Values
$AllowedAttributes += $(LookupObject -ObjectType "AttributeTypeDescription" -Name "csoCeIder")


$Objects.FilterScopes.Add("Administrator Filter Permission",
@{
    "Add" = @{"DisplayName"="Administrator Filter Permission"};
    "Update" = @{"AllowedAttributes"=$AllowedAttributes
                "AllowedMembershipReferences"=@($(LookupObject -ObjectType "Set" -Name "All Groups and Sets"))}
})

ProcessObjects -ObjectType "FilterScope" -HashObjects $Objects.FilterScopes

###
### Sync Filter
###

$Objects.Add("SynchronizationFilter",@{})

$filter = "/SynchronizationFilter[DisplayName='Synchronization Filter']"
$obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $obj) {Throw "The OOTB 'Administrator Filter Permission' Filter Scope must exist."}
# Append to existing set of filters
$SynchronizationFilter = ($obj.ResourceManagementObject.ResourceManagementAttributes | where { $_.AttributeName -eq "SynchronizeObjectType"}).Values
$NewAllowedAttribute = (LookupObject -ObjectType "AttributeTypeDescription" -Name "csoCeIder")
if ($SynchronizationFilter -notcontains $NewAllowedAttribute) {
    $SynchronizationFilter += @($NewAllowedAttribute)
}

$Objects.SynchronizationFilter.Add("Synchronization Filter",
@{
    "Add" = @{"DisplayName"="Synchronization Filter"};
    "Update" = @{"SynchronizeObjectType"=$SynchronizationFilter}   

})

ProcessObjects -ObjectType "SynchronizationFilter" -HashObjects $Objects.SynchronizationFilter

###
### Sets 
###
### Create new set (with filter rule) for CeIder
###

$Objects.Add("Set",@{})
$Objects.Set.Add("DBBCSO - All Students with a CeIder",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath "/Person[(SAS2IDMConnector = True) and (PersonType = 'Student') and starts-with(csoCeIder,'%')]"
                "Description" ="DBBCSO - All Current Students with a CeIder"}
    "Uninstall" = "DeleteObject" 
})

ProcessObjects -ObjectType "Set" -HashObjects $Objects.Set


###
### Workflows
###

$Objects.Add("Workflows", @{})
$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity4" SynchronizationRuleId="SRGUID" Action="Remove">
		<ns0:SynchronizationRuleActivity.Parameters>
			<x:Array Type="{x:Type ns0:SynchronizationRuleParameter}" />
		</ns0:SynchronizationRuleActivity.Parameters>
	</ns0:SynchronizationRuleActivity>
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity2" SynchronizationRuleId="SRGUID" Action="Add">
		<ns0:SynchronizationRuleActivity.Parameters>
			<x:Array Type="{x:Type ns0:SynchronizationRuleParameter}" />
		</ns0:SynchronizationRuleActivity.Parameters>
	</ns0:SynchronizationRuleActivity>
</ns0:SequentialWorkflow>
"@
$XOML = $XOML.Replace("SRGUID",(LookupObject -ObjectType "SynchronizationRule" -Name "DBBCSO - Manage students as SAS records" -NoPrefix $true))
$Objects.Workflows.Add("DBBCSO - Manage Active Students as SAS Records",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Manage Active Students as SAS Records";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity4" SynchronizationRuleId="SRGUID" Action="Remove">
		<ns0:SynchronizationRuleActivity.Parameters>
			<x:Array Type="{x:Type ns0:SynchronizationRuleParameter}" />
		</ns0:SynchronizationRuleActivity.Parameters>
	</ns0:SynchronizationRuleActivity>
</ns0:SequentialWorkflow>
"@
$XOML = $XOML.Replace("SRGUID",(LookupObject -ObjectType "SynchronizationRule" -Name "DBBCSO - Manage students as SAS records" -NoPrefix $true))
$Objects.Workflows.Add("DBBCSO - Manage Inactive Students as SAS Records",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Manage Inactive Students as SAS Records";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})
ProcessObjects -ObjectType "WorkflowDefinition" -HashObjects $Objects.Workflows


###
###
### MPRs
###

$Objects.Add("MPRs", @{})
$MPRName = "cso-Synchronization: Synchronization account controls users it synchronizes"
$obj = Export-FIMConfig -OnlyBaseResources -URI $URI -CustomConfig "/ManagementPolicyRule[DisplayName='$MPRName']"
if ($obj) {
    $ActionParams = ($obj.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq "ActionParameter"}).Values
} else {
    $ActionParams = @()
}
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="true"}
    "Update" = @{"ActionParameter"=$($ActionParams+"csoCeIder")
                "ActionType"=@("Create","Delete","Modify","Add","Remove")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "Synchronization Engine")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "All People")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "All People")
                "Description"="Synchronization account controls users it synchronizes"}
    "Uninstall" = "DeleteObject"
})

# Transition MPRs
$Objects.MPRs.Add("DBBCSO - Manage Active Students in SAS",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionIn");"ActionParameter"=@("*")}
    "Update" = @{"ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "DBBCSO - All Students with a CeIder");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "DBBCSO - Manage Active Students as SAS Records"))
                "Description"="Manage Active Students in SAS"}
    "Uninstall" = "DeleteObject"
})
$Objects.MPRs.Add("DBBCSO - Manage Inactive Students in SAS",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionOut");"ActionParameter"=@("*")}
    "Update" = @{"ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "DBBCSO - All Students with a CeIder");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "DBBCSO - Manage Inactive Students as SAS Records"))
                "Description"="Manage Inactive Students in SAS"}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.MPRs

