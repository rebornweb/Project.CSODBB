PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false)

### Includes Workflows for processing policy upgrades at the time of the FIM=>MIM upgrade
###
### Parameters:
###   -UpdateExisting  Checks if Existing objects should be updated 
###   -Uninstall       Reverse changes made by this script

cls
$ErrorActionPreference = "Stop"

###
### Include Scripts
###
. D:\Scripts\shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

# In many production environments, some Set resources are larger than the default message size of 10 MB.
<#$policy = Export-FIMConfig -Uri "http://occcp-as034:5725/ResourceManagementService" -customConfig `
    "/csoEntitlement[ObjectID=/Request[CreatedTime > '$from_date' and Operation = 'Create']/Target[ObjectType='csoEntitlement']]",`
    "/csoSite[ObjectID=/Request[CreatedTime > '$from_date' and Operation = 'Create']/Target[ObjectType='csoSite']]",`
    "/csoRole[ObjectID=/Request[CreatedTime > '$from_date' and Operation = 'Create']/Target[ObjectType='csoRole']]",`
    "/Group[not(csoRoleID = /csoRole) and ObjectID=/Request[CreatedTime > '$from_date' and Operation = 'Create']/Target[ObjectType='Group']]",`
    "/Person[not(PersonType='Staff') and not(PersonType='Student') and ObjectID=/Request[CreatedTime > '$from_date' and Operation = 'Create']/Target[ObjectType='Person']]" -MessageSize 9999999 -AllLocales#>

$LookupObjects = @{}
$uriFIM = "http://occcp-as034:5725/ResourceManagementService"
$uriMIM = "http://localhost:5725/ResourceManagementService"
$Objects = @{}
### Date of MIM installation from restored FIM Db
$from_date = "2017-07-17T00:00:00.000"
$to_date = "2017-07-19T00:00:00.000"
[System.TimeSpan]$Duration = [System.TimeSpan]::MinValue
[datetime]$StartTime = Get-Date

Function LookupFIMObject
{
    PARAM([string]$Filter,[string]$Key,$NoPrefix=$false)
    END
    {
        if ($LookupObjects.ContainsKey($Key)) {[string]$ObjectID = $LookupObjects.($Key)}
        else 
        {
            [string]$keyGuid = $Key
            $keyGuid = $keyGuid.Replace("urn:uuid:","")
            [string]$guidFilter = $Filter
            $guidFilter = $guidFilter -f $keyGuid
            $mimobj = $null
            $fimobj = Export-FIMConfig -OnlyBaseResources -CustomConfig $guidFilter -Uri $uriFIM
            if ($fimobj)
            {
                if ($fimobj.Count -gt 1) {Throw "More than one FIM object found matching $keyGuid"}
                [string]$displayName = ""
                [string]$accountName = ""
                $resourceType = $Filter.Split('[')[0]
                $guidFilter = $Filter
                if ($resourceType -eq "/Person") {
                    if ($fimobj.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq "AccountName"}) {
                        [string]$accountName = ($fimobj.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq "AccountName"}).Value
                        $guidFilter = $guidFilter.Replace("ObjectID=","AccountName=")
                        $guidFilter = $guidFilter -f $accountName
                    }
                } else {
                    if ($fimobj.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq "DisplayName"}) {
                        [string]$displayName = ($fimobj.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq "DisplayName"}).Value
                        $guidFilter = $guidFilter.Replace("ObjectID=","DisplayName=")
                        $guidFilter = $guidFilter -f $displayName
                    }
                }
                if ($guidFilter -ne $Filter) {
                    $mimobj = Export-FIMConfig -OnlyBaseResources -CustomConfig $guidFilter -Uri $uriMIM
                }
                if ($mimobj)
                {
                    if ($mimobj.Count -gt 1) {Throw "More than one MIM object found matching $keyGuid"}
                    [string]$ObjectID = $mimobj.ResourceManagementObject.ObjectIdentifier
                    #try {
	                    $LookupObjects.Add($Key,$ObjectID)
                        write-host "$Key [$($LookupObjects.Count)]"
                    #} catch {
                    #    Write-Host $Error.ToString()
                    #    $Error.Clear()
                    #}
                }
                else
                {
                    if (-not $Uninstall) {Throw "Failed to find an MIM object matching $keyGuid"}
                        $ObjectID = "none"
                }
            }
            else
            {
                if (-not $Uninstall) {Throw "Failed to find a FIM object matching [$guidFilter]"}
                    $ObjectID = "none"
            }
        }
        if ($NoPrefix) {Return $ObjectID.Replace("urn:uuid:","")}
        else {Return $ObjectID}
    }
}

Function LookupFIMObjects
{
    PARAM([string]$Filter,[string[]]$Keys,$NoPrefix=$false)
    END
    {
        [string[]]$ObjectIDs = @()
        foreach($key in $Keys) {
            [string]$ObjectID = LookupFIMObject -Filter $Filter -Key $key -NoPrefix $NoPrefix
            $ObjectIDs += $ObjectID
        }
        Return $ObjectIDs
    }
}

if ($false) {

###
### Roles
###
$objectTypeName = "csoRole"
Write-Host "[$(Get-Date)]: Exporting $objectTypeName data changes from FIM platform ..."
$policy = Export-FIMConfig -Uri $uriFIM -customConfig `
    "/$objectTypeName[starts-with(csoADSCode,'O714J')]" -MessageSize 9999999 -AllLocales -OnlyBaseResources
#    "/$objectTypeName[ObjectID=/Request[(CreatedTime > '$from_date') and (CreatedTime <= '$to_date')]/Target[ObjectType='$objectTypeName']]" -MessageSize 9999999 -AllLocales -OnlyBaseResources

if ($policy.Count -gt 0) {
    Write-Host "[$(Get-Date)]: Found [$($policy.Count)] $objectTypeName objects to process between [$from_date] and [$to_date] ..."
    $Objects.Add($objectTypeName, @{})
    foreach($policyItem in $policy) {
    #$policyItem = $policy[0]
        $resourceAttributes = $policyItem.ResourceManagementObject.ResourceManagementAttributes
        $idDisplayedOwner = "$(($resourceAttributes | where {$_.AttributeName -eq "DisplayedOwner"}).Value)"
        [string[]]$idOwner = @($resourceAttributes | where {$_.AttributeName -eq "Owner"}).Values
        $idcsoSite = "$(($resourceAttributes | where {$_.AttributeName -eq "csoSite"}).Value)"

        [string]$DisplayedOwner = LookupFIMObject -Filter "/Person[ObjectID=""{0}""]" -Key $idDisplayedOwner
        [string]$csoSite = LookupFIMObject -Filter "/csoSite[ObjectID=""{0}""]" -Key $idcsoSite
        [string[]]$Owner = LookupFIMObjects -Filter "/Person[ObjectID=""{0}""]" -Keys $idOwner
        if (!$Owner) {
            $Owner = @()
        }

        $Objects.csoRole.Add("$(($resourceAttributes | where {$_.AttributeName -eq "DisplayName"}).Value)",
        @{
            "Add" = @{
                "csoADSCode"=($resourceAttributes | where {$_.AttributeName -eq "csoADSCode"}).Value
                "csoCanonicalName"=($resourceAttributes | where {$_.AttributeName -eq "csoCanonicalName"}).Value
                "csoCanonicalCode"=($resourceAttributes | where {$_.AttributeName -eq "csoCanonicalCode"}).Value
                "csoIsRollup"=($resourceAttributes | where {$_.AttributeName -eq "csoIsRollup"}).Value
                "csoInheritOwner"=($resourceAttributes | where {$_.AttributeName -eq "csoInheritOwner"}).Value
                "DisplayedOwner"=$DisplayedOwner
                "csoSite"=$csoSite
                "Owner"=$Owner
            };
            "Update" = @{
                "csoADSCode"=($resourceAttributes | where {$_.AttributeName -eq "csoADSCode"}).Value
                "csoCanonicalName"=($resourceAttributes | where {$_.AttributeName -eq "csoCanonicalName"}).Value
                "csoCanonicalCode"=($resourceAttributes | where {$_.AttributeName -eq "csoCanonicalCode"}).Value
                "csoIsRollup"=($resourceAttributes | where {$_.AttributeName -eq "csoIsRollup"}).Value
                "csoInheritOwner"=($resourceAttributes | where {$_.AttributeName -eq "csoInheritOwner"}).Value
                "DisplayedOwner"=$DisplayedOwner
                "csoSite"=$csoSite
                "Owner"=$Owner
            };
            "Uninstall" = "DeleteObject" 
        })
    }
    Write-Host "[$(Get-Date)]: Processing [$($Objects.csoRole.Count)] $objectTypeName objects ..."
    ProcessObjects -ObjectType $objectTypeName -HashObjects $Objects.csoRole
    $Duration = (Get-Date) - $StartTime
    Write-Host "[$(Get-Date)]: $objectTypeName Processing Complete, Duration [$($Duration)]"
}

###
### Sites
###
$objectTypeName = "csoSite"
Write-Host "[$(Get-Date)]: Exporting $objectTypeName data changes from FIM platform ..."
$policy = Export-FIMConfig -Uri $uriFIM -customConfig `
    "/$objectTypeName[ObjectID=/Request[(CreatedTime > '$from_date') and (CreatedTime <= '$to_date')]/Target[ObjectType='$objectTypeName']]" -MessageSize 9999999 -AllLocales -OnlyBaseResources

if ($policy.Count -gt 0) {
    Write-Host "[$(Get-Date)]: Found [$($policy.Count)] $objectTypeName objects to process between [$from_date] and [$to_date] ..."
    $Objects.Add($objectTypeName, @{})
    foreach($policyItem in $policy) {
    #$policyItem = $policy[0]
        $resourceAttributes = $policyItem.ResourceManagementObject.ResourceManagementAttributes
    }
    Write-Host "[$(Get-Date)]: Processing [$($Objects."$objectTypeName".Count)] $objectTypeName objects ..."
    #ProcessObjects -ObjectType $objectTypeName -HashObjects $Objects."$objectTypeName"
    $Duration = (Get-Date) - $StartTime
    Write-Host "[$(Get-Date)]: $objectTypeName Processing Complete, Duration [$($Duration)]"
}

###
### csoDepartment
###
$objectTypeName = "csoDepartment"
Write-Host "[$(Get-Date)]: Exporting $objectTypeName data changes from FIM platform ..."
$policy = Export-FIMConfig -Uri $uriFIM -customConfig `
    "/$objectTypeName[ObjectID=/Request[CreatedTime > '$from_date' and not(Operation = 'Create')]/Target[ObjectType='$objectTypeName']]" -MessageSize 9999999 -AllLocales -OnlyBaseResources

if ($policy.Count -gt 0) {
    Write-Host "[$(Get-Date)]: Found [$($policy.Count)] $objectTypeName objects to process since [$from_date] ..."
    $Objects.Add($objectTypeName, @{})
    foreach($policyItem in $policy) {
    #$policyItem = $policy[0]
        $resourceAttributes = $policyItem.ResourceManagementObject.ResourceManagementAttributes
    }
    Write-Host "[$(Get-Date)]: Processing [$($Objects."$objectTypeName".Count)] $objectTypeName objects ..."
    #ProcessObjects -ObjectType $objectTypeName -HashObjects $Objects."$objectTypeName"
    $Duration = (Get-Date) - $StartTime
    Write-Host "[$(Get-Date)]: $objectTypeName Processing Complete, Duration [$($Duration)]"
}

}

###
### csoEntitlement
###
$objectTypeName = "csoEntitlement"
Write-Host "[$(Get-Date)]: Exporting $objectTypeName data changes from FIM platform ..."
$policy = Export-FIMConfig -Uri $uriFIM -customConfig `
    "/$objectTypeName[UserID=/Set[DisplayName='AAA Staff with Entitlements to resync']/ExplicitMember]" -MessageSize 9999999 -AllLocales -OnlyBaseResources
#    "/$objectTypeName[ObjectID=/Request[(CreatedTime > '$from_date') and (CreatedTime <= '$to_date')]/Target[ObjectType='$objectTypeName']]" -MessageSize 9999999 -AllLocales -OnlyBaseResources

$Objects = @{}
if ($policy.Count -gt 0) {
    Write-Host "[$(Get-Date)]: Found [$($policy.Count)] $objectTypeName objects to process between [$from_date] and [$to_date] ..."
    $Objects.Add($objectTypeName, @{})
    foreach($policyItem in $policy) {
    #$policyItem = $policy[0]
        $resourceAttributes = $policyItem.ResourceManagementObject.ResourceManagementAttributes
        $idUserID = "$(($resourceAttributes | where {$_.AttributeName -eq "UserID"}).Value)"
        [string[]]$idcsoRoles = @($resourceAttributes | where {$_.AttributeName -eq "csoRoles"}).Values
        [string[]]$idOwner = @($resourceAttributes | where {$_.AttributeName -eq "Owner"}).Values

        [string]$UserID = LookupFIMObject -Filter "/Person[ObjectID=""{0}""]" -Key $idUserID
        [string[]]$csoRoles = LookupFIMObjects -Filter "/csoRole[ObjectID=""{0}""]" -Keys $idcsoRoles
        if (!$csoRoles) {
            $csoRoles = @()
        }
        [string[]]$Owner = LookupFIMObjects -Filter "/Person[ObjectID=""{0}""]" -Keys $idOwner
        if (!$Owner) {
            $Owner = @()
        }

        [string]$DisplayName = ($resourceAttributes | where {$_.AttributeName -eq "DisplayName"}).Value
        try {
            $Objects."$objectTypeName".Add("$DisplayName",
            @{
                "Add" = @{
                    "UserID"=$UserID
                };
                "Update" = @{
                    "Description"=($resourceAttributes | where {$_.AttributeName -eq "Description"}).Value
                    "csoRecalculate"=$true #($resourceAttributes | where {$_.AttributeName -eq "csoRecalculate"}).Value
                    "idmStartDate"=($resourceAttributes | where {$_.AttributeName -eq "idmStartDate"}).Value
                    "idmEndDate"=($resourceAttributes | where {$_.AttributeName -eq "idmEndDate"}).Value
                    "csoRoles"=$csoRoles
                    "Owner"=$Owner
                };
                "Uninstall" = "DeleteObject" 
            })
        } catch {
            Write-Host $Error.ToString()
            $Error.Clear()
            #throw
        }
    }
    Write-Host "[$(Get-Date)]: Processing [$($Objects."$objectTypeName".Count)] $objectTypeName objects ..."
    ProcessObjects -ObjectType $objectTypeName -HashObjects $Objects."$objectTypeName"
    $Duration = (Get-Date) - $StartTime
    Write-Host "[$(Get-Date)]: $objectTypeName Processing Complete, Duration [$($Duration)]"
}

$Duration = (Get-Date) - $StartTime
Write-Host "[$(Get-Date)]: ALL Processing Complete, Duration [$($Duration)]"


