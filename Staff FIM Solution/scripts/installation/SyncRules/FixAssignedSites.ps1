PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false,[string]$fimSyncServer="occcp-as033")

### Written by Bob Bradley, UNIFY Solutions
###
### Remove redundantly assigned sites.
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

$filter = "/ActivityInformationConfiguration[ActivityName='UFIM.CustomActivities.UpdateResourceFromWorkflowData']"
$AICObj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $AICObj) {Throw "The 'UNIFY-Create update and delete FIM resource activity' must be installed."}

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
$Objects.Add("Sets", @{})
$filter = "/Person[
(PersonType = 'Staff') 
and (csoEmployeeStatus = 'Active') 
and (csoAssignedSite = /csoSite[not(DisplayName='OCCCP')])
and (csoSites = /csoSite[DisplayName='Casual Pool']) 
and (csoSites = /csoSite[not(DisplayName='Casual Pool')]) 
]"
$allUsersToReview = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter

# Can't process users individually so I need a set to process
$setNameToProcess = "AAA-Explicit People Set"
$setToProcess = Export-FIMConfig -OnlyBaseResources -CustomConfig "/Set[DisplayName='$setNameToProcess']"
$members=@()
#$allUsersToReview[0].ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "csoAssignedSite"}
foreach ($user in $allUsersToReview) {
    #$user = $allUsersToReview[0]
    $valueToNull = ($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "csoAssignedSite"}).Value
    if (($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "csoSites"}).Values -contains $valueToNull) {
        "$(($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "AccountName"}).Value) csoSites CONTAINS $valueToNull ... clearing value!"
        ###
        ### User with csoAssignedSite to clear
        ###
        <#$DisplayName = ($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "DisplayName"}).Value
        $Objects.People.Add($DisplayName,
        @{
            "Update" = @{
                "AccountName"=($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "AccountName"}).Value
                "csoAssignedSite"=" "
            }
        })#>
        $members += ($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "ObjectID"}).Value
    } else {
        "$(($user.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "AccountName"}).Value) csoSites NOT CONTAINS $valueToNull - nothing to do."
    }
}

$Objects.Sets.Add($setNameToProcess,
    @{
        "Update" = @{
            "ExplicitMember"=$members
        }
    })
        
ProcessObjects -ObjectType "Set" -HashObjects $Objects.Sets



