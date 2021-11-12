PARAM(
    [string]$EntitlementsPath = "D:\Scripts\Entitlements", 
    [string]$RoleUsersFile = "roleUsers.xml",
    [string]$SetName = "cso-All explicit users for roles recalculation",
    [string]$ThisUri = "http://localhost:5725", #"http://occcp-as034:5725"
    [string]$AccountName = "UNIFYFIM\csodbb"
)

# CSODBB-525: Automated Entitlements Housekeeping
# To be run after the following:
# "E:\Scripts\Entitlements\ExecuteSQLXMLProc.ps1" -svr "SQLFIM" -db "FIMService" -xmlFile "E:\Scripts\Entitlements\roleUsers.xml" -timeout 7200

#cls
# Load FIMPowerShell library
cd $EntitlementsPath
. ".\FIMPowerShell.ps1"

$cred = $null
if ($AccountName.Length -gt 0) {
    # Set up creds
    # read-host -assecurestring "Enter CSODBB service account password" | convertfrom-securestring | out-file "$EntitlementsPath\authToken.txt"
    $pw = Get-Content ([System.IO.Path]::Combine($EntitlementsPath,"authToken.txt")) | ConvertTo-SecureString
    $cred = New-Object System.Management.Automation.PSCredential $AccountName,$pw 
}

function AddMembersToSet
{
    PARAM($SetIdentifier, $MemberIdentifiers, $IdentifierName="DisplayName", $Uri = $DefaultUri, $InitializeSet=$true, $Credential=$null)
    END
    {
        $ResolveSet = ResolveObject -ObjectType "Set" -AttributeName $IdentifierName -AttributeValue $SetIdentifier
        if ($Credential) {
            $ResolveSet | Import-FIMConfig -Credential $Credential -Uri $Uri | Out-Null
        } else {
            $ResolveSet | Import-FIMConfig -Uri $Uri | Out-Null
        }
        $ResolveObjects = $NULL
        $ImportObjects = $NULL
        $AddedMembers = $NULL
        $RemovedMembers = $NULL

        if ($InitializeSet) {
            if ($Credential) {
                $ExistingSet = GetResourceForCreds -Credential $Credential -ObjectIdentifier $($ResolveSet.TargetObjectIdentifier.Replace('urn:uuid:','')) -Uri $Uri
            } else {
                $ExistingSet = GetResource -ObjectIdentifier $($ResolveSet.TargetObjectIdentifier.Replace('urn:uuid:','')) -Uri $Uri
            }
            #$ExistingSet = Export-FIMConfig -Uri $Uri -CustomConfig "/Set[ObjectID='$($ResolveSet.TargetObjectIdentifier.Replace('urn:uuid:',''))']"
            foreach($RemovedMember in @($ExistingSet.ResourceManagementObject | Where-Object{$_.ObjectType -eq "Person"}))
            {
                if($RemovedMembers -eq $NULL)
                {
                    $RemovedMembers = @($RemovedMember.ObjectIdentifier)
                }
                else
                {
                    $RemovedMembers += $RemovedMember.ObjectIdentifier
                }
            }
        }

        foreach($MemberIdentifier in $MemberIdentifiers)
        {
            $ImportObject = ResolveObject -ObjectType "Person" -AttributeName "ObjectID" -AttributeValue $MemberIdentifier
            if($AddedMembers -eq $NULL)
            {
                $AddedMembers = @($ImportObject.SourceObjectIdentifier)
            }
            else
            {
                $AddedMembers += $ImportObject.SourceObjectIdentifier
            }
            if($ResolveObjects -eq $NULL)
            {
                $ResolveObjects = @($ImportObject)
            }
            else
            {
                $ResolveObjects += $ImportObject
            }
        }
        
        if($RemovedMembers -ne $NULL) {
            $RemoveImportObject = ModifyImportObject -TargetIdentifier $ResolveSet.TargetObjectIdentifier -ObjectType "Set"
            if ($RemoveImportObject) {
                $RemoveImportObject.SourceObjectIdentifier = $ResolveSet.SourceObjectIdentifier
                foreach($RemovedMember in $RemovedMembers)
                {
                    RemoveMultiValue -ImportObject $RemoveImportObject -AttributeName "ExplicitMember" -NewAttributeValue $RemovedMember -FullyResolved 1
                }
                $ImportObjects = $ResolveObjects + $RemoveImportObject
                if ($Credential) {
                    $ImportObjects | Import-FIMConfig -Uri $Uri -Credential $cred
                } else {
                    $ImportObjects | Import-FIMConfig -Uri $Uri
                }
            }
        }

        $ModifyImportObject = ModifyImportObject -TargetIdentifier $ResolveSet.TargetObjectIdentifier -ObjectType "Set"
        if ($ModifyImportObject) {
            $ModifyImportObject.SourceObjectIdentifier = $ResolveSet.SourceObjectIdentifier
            foreach($AddedMember in $AddedMembers)
            {
                AddMultiValue -ImportObject $ModifyImportObject -AttributeName "ExplicitMember" -NewAttributeValue $AddedMember -FullyResolved 0
            }
            $ImportObjects = $ResolveObjects + $ModifyImportObject
            if ($Credential) {
                $ImportObjects | Import-FIMConfig -Uri $Uri -Credential $cred
            } else {
                $ImportObjects | Import-FIMConfig -Uri $Uri
            }
        }
    }
}

# Load results from prerequisite ExecuteSQLXMLProc step
[xml]$roleUsers = Get-Content -Path ([System.IO.Path]::Combine($EntitlementsPath,$RoleUsersFile))
#AddMembersToSet -SetIdentifier $SetName -MemberIdentifiers $($roleUsers.roleUsers.user.UserIdentifier) -InitializeSet $true -Uri $ThisUri
# Adjusted for PS1 back compatibility:
$userIdentifiers = @()
foreach($ui in $roleUsers.roleUsers.user) {
    $userIdentifiers += $ui.UserIdentifier
}
AddMembersToSet -SetIdentifier $SetName -MemberIdentifiers $userIdentifiers -InitializeSet $true -Uri $ThisUri -Credential $cred

