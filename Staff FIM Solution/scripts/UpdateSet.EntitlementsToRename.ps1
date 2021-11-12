# Import the module
cls
Import-Module LithnetRMA;
Get-Date

# Connect to the FIM service instance
Set-ResourceManagementClient -BaseAddress http://localhost:5725;

# Retrieve the set we need to update
$set = Search-Resources -XPath "/Set[DisplayName = 'AAA All entitlements to fix']" -ExpectedObjectType Set #-AttributesToGet @("ComputedMember", "ExplicitMember")

# Initialise our set Explicit Membership (without committing it)
$set.ExplicitMember.Clear()
#Save-Resource $set

# Get current entitlements (only DisplayName, Description and UserID)
[string]$from_date = get-date -Format "yyyy-MM-ddTHH:mm:ss" #"2017-08-04T00:00:00.000"
#$entitlements = Search-Resources -XPath "/csoEntitlement[((idmStartDate <= '$from_date') and (idmEndDate >= '$from_date')) and (UserID=/Person)]" -AttributesToGet @("DisplayName","Description","UserID")
$entitlements = Search-Resources -XPath "/csoEntitlement[(UserID=/Person)]" -AttributesToGet @("DisplayName","Description","UserID")
Write-Host "Total matched entitlements: [$($entitlements.Count)]"

# Initialise our hashtable of Users to be queried
$users = @{}
foreach($entitlement in $entitlements) {
    # Add user to users hashtable if we don't already have it
    #$thisUser = @{}
    #$entitlement = $entitlements[0]
    $key = $entitlement.UserID.Value
    if (!$users.ContainsKey($key)) {
        $user = Get-Resource -ObjectType Person -AttributeName "ObjectID" -AttributeValue $key -AttributesToGet @("DisplayName","AccountName")
        if ($user.DisplayName -and $user.AccountName) {
            $users.Add($key,@{})
            $users."$key".Add("DisplayName",$user.DisplayName)
            $users."$key".Add("AccountName",$user.AccountName)
        } else {
            Write-Host "Error: User cannot be determined for entitlement [$($entitlement.DisplayName)] description [$($entitlement.Description)]!"
        }
    }
    $thisUser = $users."$key"
    if ($entitlement.Description -notlike "*$($thisUser.DisplayName)*") {
        Write-Host "Entitlement [$($entitlement.DisplayName)] description [$($entitlement.Description)] does not contain user displayname [$($thisUser.DisplayName)]"
        $set.ExplicitMember.Add($entitlement.ObjectID) | Out-Null
    }
}
Write-Host "Total user entitlements to fix: [$($set.ExplicitMember.Count)]"

# Update the set
Save-Resource $set
Get-Date
