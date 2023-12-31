PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false,[string]$fimSyncServer="occcp-as034")

### Written by Bob Bradley, UNIFY Solutions
###
### Installs the Schema and Policy objects for specified Sync Rules.
###

$ErrorActionPreference = "Stop"

. E:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

#$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = "E:\Scripts\Installation\SyncRules"

###
### Check dependencies
###
if (-not (Test-Path ($WFScriptFolder + "\WFFunctions.ps1"))) {Throw ("Expected to find " + $WFScriptFolder + "\WFFunctions.ps1. If it is in a different location then change or set the $WFScriptFolder variable in the Set-LocalVariables.ps1 script.")}
if (-not (Test-Path $WFLogFolder)) {Throw ("Expected to find " + $WFLogFolder + ". If you want to use a different location for Workflow logging then change or set the $WFLogFolder variable in the Set-LocalVariables.ps1 script. Otherwise, create the folder in the specified location.")}

#$filter = "/ActivityInformationConfiguration[ActivityName='FimExtensions.FimActivityLibrary.PowerShellActivity']"
#$AICObj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
#if (-not $AICObj) {Throw "The PowerShell activity must be installed."}

$filter = "/ActivityInformationConfiguration[ActivityName='UFIM.CustomActivities.UpdateResourceFromWorkflowData']"
$AICObj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $AICObj) {Throw "The 'UNIFY-Create update and delete FIM resource activity' must be installed."}

#$filter = "/AttributeTypeDescription[Name='PolicyGroup']"
#$obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
#if (-not $obj) {Throw "The PolicyGroup attribut must exist, must be bound to all Policy and UI object types, and the current account must have permission to update it. The script Setup-MPRs.ps1 may be used to create these prerequisites."}

#$filter = "/ma-data[DisplayName='Downstream AD']"
#$MAobj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter

## XML and WMI functions
function getMAGuid (
    [string]$maName="Upstream AD"
) {
    $thisMA = get-wmiobject -class "MIIS_ManagementAgent where Name = '$maName'" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $fimSyncServer
    $thisMA.Guid
}

function getMAName (
    [string]$maGuid="{405DD2A1-8B12-478C-A78B-7D398BE6DC7A}"
) {
    $thisMA = get-wmiobject -class "MIIS_ManagementAgent where Guid = '$maGuid'" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $fimSyncServer
    $thisMA.Name
}

function Add-XmlFragment {
    Param(        
        [Parameter(Mandatory=$true)][System.Xml.XmlNode] $xmlElement,
        [Parameter(Mandatory=$true)][string] $text)        
    $xml = $xmlElement.OwnerDocument.ImportNode(([xml]$text).DocumentElement, $true)
    [void]$xmlElement.AppendChild($xml)
}

function ReadSRXml
{
    PARAM([string]$srName)
    END
    {
        $HashReturn = @{}

        $XmlFile = "$scriptPath\$srName.xml"
        if (Test-Path $XmlFile)
        {
            [xml]$sr = Get-Content $XmlFile
 
            $HashReturn.Add("ConnectedSystemScope",$sr.SynchronizationRule.ConnectedSystemScope.InnerXml)
            $HashReturn.Add("OutboundScope",$sr.SynchronizationRule.OutboundScope.InnerXml)
            $HashReturn.Add("RelationshipCriteria",$sr.SynchronizationRule.RelationshipCriteria.InnerXml)

            $PersistentFlow = @()
            foreach ($rule in $sr.SynchronizationRule.PersistentFlow."import-flow")
            {
                $PersistentFlow += $rule.OuterXml
            }
            foreach ($rule in $sr.SynchronizationRule.PersistentFlow."export-flow")
            {
                $PersistentFlow += $rule.OuterXml
            }
            $HashReturn.Add("PersistentFlow",$PersistentFlow)

            $InitialFlow = @()
            foreach ($rule in $sr.SynchronizationRule.InitialFlow."import-flow")
            {
                $InitialFlow += $rule.OuterXml
            }
            foreach ($rule in $sr.SynchronizationRule.InitialFlow."export-flow")
            {
                $InitialFlow += $rule.OuterXml
            }
            $HashReturn.Add("InitialFlow",$InitialFlow)

            return $HashReturn
        }
    }
}

#cls
$Objects = @{}

###
### Sync Rules
###

$Objects.Add("SynchronizationRules", @{})

$SRName = "cso Staff: Set extra AD Attributes for NASS Users"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        "ConnectedObjectType"="user"
        "ConnectedSystem"=(getMAGuid -maName "Staff")
        "ILMObjectType"="person"
        "FlowType"="1"
        "DisconnectConnectedSystemObject"="False"
        "CreateILMObject"="False"
        "CreateConnectedSystemObject"="False"
        "Precedence"="8"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="Set extra AD Attributes for NASS Users"
    }
    "Uninstall" = "DeleteObject"
})


$SRName = "cso Staff: Set extra AD Attributes for PHRIS Users"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        "ConnectedObjectType"="user"
        "ConnectedSystem"=(getMAGuid -maName "Staff")
        "ILMObjectType"="person"
        "FlowType"="1"
        "DisconnectConnectedSystemObject"="False"
        "CreateILMObject"="False"
        "CreateConnectedSystemObject"="False"
        "Precedence"="7"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="Set extra AD Attributes for PHRIS Users"
    }
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "SynchronizationRule" -HashObjects $Objects.SynchronizationRules

###
### Workflows
###

$Objects.Add("Workflows", @{})
$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity1" SynchronizationRuleId="SRGUID" Action="Remove">
		<ns0:SynchronizationRuleActivity.Parameters>
			<x:Array Type="{x:Type ns0:SynchronizationRuleParameter}" />
		</ns0:SynchronizationRuleActivity.Parameters>
	</ns0:SynchronizationRuleActivity>
</ns0:SequentialWorkflow>
"@
$XOML = $XOML.Replace("SRGUID",(LookupObject -ObjectType "SynchronizationRule" -Name "cso Staff: Set extra AD Attributes for NASS Users" -NoPrefix $true))
$Objects.Workflows.Add("cso-Additional NASS User attributes are NOT synchronised to AD",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Additional NASS User attributes are NOT synchronised to AD";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity1" SynchronizationRuleId="SRGUID" Action="Remove">
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
$XOML = $XOML.Replace("SRGUID",(LookupObject -ObjectType "SynchronizationRule" -Name "cso Staff: Set extra AD Attributes for NASS Users" -NoPrefix $true))
$Objects.Workflows.Add("cso-Additional NASS User attributes are synchronised to AD",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Additional NASS User attributes are synchronised to AD";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity1" SynchronizationRuleId="SRGUID" Action="Remove">
		<ns0:SynchronizationRuleActivity.Parameters>
			<x:Array Type="{x:Type ns0:SynchronizationRuleParameter}" />
		</ns0:SynchronizationRuleActivity.Parameters>
	</ns0:SynchronizationRuleActivity>
</ns0:SequentialWorkflow>
"@
$XOML = $XOML.Replace("SRGUID",(LookupObject -ObjectType "SynchronizationRule" -Name "cso Staff: Set extra AD Attributes for PHRIS Users" -NoPrefix $true))
$Objects.Workflows.Add("cso-Additional PHRIS User attributes are NOT synchronised to AD",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Additional PHRIS User attributes are NOT synchronised to AD";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:SynchronizationRuleActivity RemoveValue="{x:Null}" AttributeId="00000000-0000-0000-0000-000000000000" AddValue="{x:Null}" x:Name="authenticationGateActivity1" SynchronizationRuleId="SRGUID" Action="Remove">
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
$XOML = $XOML.Replace("SRGUID",(LookupObject -ObjectType "SynchronizationRule" -Name "cso Staff: Set extra AD Attributes for PHRIS Users" -NoPrefix $true))
$Objects.Workflows.Add("cso-Additional PHRIS User attributes are synchronised to AD",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Additional PHRIS User attributes are synchronised to AD";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "WorkflowDefinition" -HashObjects $Objects.Workflows

###
### Transition MPRs
###

$Objects.Add("TransMPRs", @{})
$Objects.TransMPRs.Add("cso-Synchronization: Additional attributes are NOT synchronized to AD for NASS users",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionOut");"ActionParameter"=@("*")}
    "Update" = @{"ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-All migrated people from NASS");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Additional NASS User attributes are NOT synchronised to AD"))}
    "Uninstall" = "DeleteObject"
})

$Objects.TransMPRs.Add("cso-Synchronization: Additional attributes are synchronized to AD for NASS users",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionIn");"ActionParameter"=@("*")}
    "Update" = @{"ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-All migrated people from NASS");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Additional NASS User attributes are synchronised to AD"))}
    "Uninstall" = "DeleteObject"
})

$Objects.TransMPRs.Add("cso-Synchronization: Additional attributes are NOT synchronized to AD for PHRIS users",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionOut");"ActionParameter"=@("*")}
    "Update" = @{"ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "All Casual Staff");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Additional PHRIS User attributes are NOT synchronised to AD"))}
    "Uninstall" = "DeleteObject"
})

$Objects.TransMPRs.Add("cso-Synchronization: Additional attributes are synchronized to AD for PHRIS users",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionIn");"ActionParameter"=@("*")}
    "Update" = @{"ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "All Casual Staff");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Additional PHRIS User attributes are synchronised to AD"))}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.TransMPRs