PARAM([string]$uri="http://localhost:5725", [boolean]$UpdateExisting=$true, [boolean]$Uninstall=$false)

### Written by Adrian Corston, UNIFY Solutions
### Template by Carol Wapshere, UNIFY Solutions
###
### CSODBB-541


$ErrorActionPreference = "Stop"

$scriptPath = "D:\scripts\CSODBB-541"
. D:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

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


## Objects to create are stored in hashtables.
## - The Object Type is the top level of the hashtable
## - The Display Name of the object is the next level
## - Under that we must have Add and Update - where "Add" includes attributes that may only be set at object creation
## - If an attribute is multivalued the values must be stored as an array, even if there is only one value to add.

$Objects = @{}



###
### Permission MPRs
###

$Objects.Add("MPRs", @{})

###
### Hide inactive Roles from non-admin users
### (MPR "cso-Administration: Entitlement administrators can manage roles": change resource current set from "cso-All Roles" to "cso-All active roles")
### (MPR "cso-Group management: All users can read all roles": change resource current set from "cso-All Roles" to "cso-All active roles")
###
$Objects.MPRs.Add("cso-Administration: Entitlement administrators can manage roles",
@{
    "Update" = @{"ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-All active roles")}
})
$Objects.MPRs.Add("cso-Group management: All users can read all roles",
@{
    "Update" = @{"ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-All active roles")}
})

### Process MPRs
ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.MPRs -UpdateExisting $true

