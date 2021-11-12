$LookupObjects = @{}
$uriFIM = "http://occcp-as034:5725/ResourceManagementService"

Function LookupFIMObject
{
    PARAM($Filter,$NoPrefix=$true)
    END
    {
      $Key = $Filter.Replace("urn:uuid:","")
      if ($LookupObjects.ContainsKey($Key)) {[string]$ObjectID = $LookupObjects.($Key)}
      else 
      {
        $obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $Key -Uri $uriFIM
        if ($obj)
        {
            if ($obj.Count -gt 1) {Throw "More than one object found matching $Key"}
            [string]$ObjectID = $obj.ResourceManagementObject.ObjectIdentifier
	    $LookupObjects.Add($Key,$ObjectID)
        }
        else
        {
            if (-not $Uninstall) {Throw "Failed to find an object matching $Key"}
            $ObjectID = "none"
        }
     }
     if ($NoPrefix) {Return $ObjectID.Replace("urn:uuid:","")}
     else {Return $ObjectID}
    }
}

#foreach($policyItem in $policy) {
$policyItem = $policy[0]
#}

    $resourceAttributes = $policyItem.ResourceManagementObject.ResourceManagementAttributes
    $idDisplayedOwner = "$(($resourceAttributes | where {$_.AttributeName -eq "DisplayedOwner"}).Value)"
    $idOwner = "$(@($resourceAttributes | where {$_.AttributeName -eq "Owner"}).Values)"
    $idcsoSite = "$(($resourceAttributes | where {$_.AttributeName -eq "csoSite"}).Value)"
    $DisplayedOwner = LookupFIMObject -Filter $("/Person[ObjectID='$($idDisplayedOwner)']")


$Objects.csoRole.Add("cso-Roles with an owner for global groups - no ADS Code",
@{
    "Add" = @{
        "DisplayName"="$(($resourceAttributes | where {$_.AttributeName -eq "DisplayName"}).Value)"
    };
    "Update" = @{
        "csoADSCode"="$(($resourceAttributes | where {$_.AttributeName -eq "csoADSCode"}).Value)"
        "csoCanonicalName"="$(($resourceAttributes | where {$_.AttributeName -eq "csoCanonicalName"}).Value)"
        "csoCanonicalCode"="$(($resourceAttributes | where {$_.AttributeName -eq "csoCanonicalCode"}).Value)"
        "csoIsRollup"="$(($resourceAttributes | where {$_.AttributeName -eq "csoIsRollup"}).Value)"
        "csoInheritOwner"="$(($resourceAttributes | where {$_.AttributeName -eq "csoInheritOwner"}).Value)"
        "DisplayedOwner"="$(LookupFIMObject -Filter $("/Person[ObjectID='$($idDisplayedOwner)']"))"
        "csoSite"="$(LookupFIMObject -Filter $("/csoSite[ObjectID='$($idcsoSite)']"))"
        "Owner"="$(LookupFIMObject -Filter $("/Person[ObjectID='$($idOwner)']"))"
    };
    "Uninstall" = "DeleteObject" 
})
