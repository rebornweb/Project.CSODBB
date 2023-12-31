PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false,[string]$fimSyncServer="occcp-as033")

### Written by Bob Bradley, UNIFY Solutions
###
### Installs the Schema and Policy objects for specified Sync Rules.
###

$ErrorActionPreference = "Stop"

. D:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

#$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = "D:\Scripts\Installation\SyncRules"

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

<#<scoping><scope><csAttribute>csodbbPersonType</csAttribute><csOperator>EQUAL</csOperator><csValue>Student</csValue></scope></scoping>#>

$SRName = "cso-People: Student attributes are imported from ADLDS"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        "ConnectedObjectType"="user"
        "ConnectedSystem"=(getMAGuid -maName "CSODBB LDS")
        "ILMObjectType"="person"
        "FlowType"="0"
        "DisconnectConnectedSystemObject"="False"
        "CreateILMObject"="False"
        "CreateConnectedSystemObject"="False"
        "Precedence"="2"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="Student attributes are imported from ADLDS"
    }
    "Uninstall" = "DeleteObject"
})


$SRName = "DBBCSO - Manage students as SAS records"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        "ConnectedObjectType"="personEx"
        "ConnectedSystem"=(getMAGuid -maName "SAS2IDM")
        "ILMObjectType"="person"
        "FlowType"="1"
        "DisconnectConnectedSystemObject"="True"
        "CreateILMObject"="False"
        "CreateConnectedSystemObject"="True"
        "Precedence"="1"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="Manage students as SAS records"
    }
    "Uninstall" = "DeleteObject"
})

# Revert changes for a previous JIRA which were corrupting the sync server deployment process
$SRName = "DBBCSO - Manage Current Students as AD Contacts"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        "ConnectedObjectType"="contact"
        "ConnectedSystem"=(getMAGuid -maName "Contacts")
        "ILMObjectType"="person"
        "FlowType"="1"
        "DisconnectConnectedSystemObject"="True"
        "CreateILMObject"="False"
        "CreateConnectedSystemObject"="True"
        "Precedence"="1"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="Manage Current Students as Contacts Using Contacts AD MA"
    }
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "SynchronizationRule" -HashObjects $Objects.SynchronizationRules
