###
### Update attribute 'csodbbCeIder' with values in Directory
###


cls
CD "E:\Scripts\installation\CelderEnhancement"
Get-Date

[bool]$reset = $false
#$password = Read-Host "Enter password" -AsSecureString # Enter "Password01" here!
#read-host -assecurestring "Enter service account password" | convertfrom-securestring | out-file acc_password.txt
$password = Get-Content ("acc_password.txt") | ConvertTo-SecureString
$tempCredential = New-Object System.Management.Automation.PsCredential "unifyfim\adsync", $password
$networkCredential = $tempCredential.GetNetworkCredential()
#$password = $tempCredential.GetNetworkCredential().Password
#$tempCredential.GetNetworkCredential().UserName

$ldapServer = "localhost:50000"
$LDAPBase = "DC=CSODBB"
Add-Type -AssemblyName System.DirectoryServices.Protocols | Out-Null
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($ldapServer, $networkCredential, [System.DirectoryServices.Protocols.AuthType]::Negotiate) 
$RootDSE = [ADSI]"LDAP://$ldapServer" #/RootDSE"
#$filter = "(&(objectClass=user)(!csodbbCeIder=*)(employeeID=2812836200*))"
$filter = "(&(objectClass=user)(csodbbCeIder=836400054X)(employeeID=2812836400054))"
#$filter = "(&(objectClass=user)(!csodbbCeIder=*)(employeeID=28128362008*))"
#$filter = "(&(objectClass=user)(csodbbCeIder=*Y)(employeeID=28128362008*))"
if ($reset) {
    $filter = "(&(objectClass=user)(csodbbCeIder=*)(employeeID=*))" # Reverse the process for testing
}
$attributes = @("employeeID") 
$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($LDAPBase, $filter, "Subtree", $attributes) 
$Response = $LDAPConnection.SendRequest($Request)

#store user data in HT
$userinfoHT = @{}
foreach ($user in $Response.Entries) {
    [string]$empID = $user.Attributes.employeeid[0]
    
    $userinfoHT.Add($user.DistinguishedName,$empID)
}
"Total users to update: $($userinfoHT.Count)"
[long]$numUpdates = 0
foreach ($key in $userinfoHT.keys) {
    
    [string]$empID = $userinfoHT[$key]
    if ($empID.Length -eq 8) {
        # pre-pend a leading zero
        $empID = "0$empID"
    }
    if ($empID.Length -ge 9) {
        $ModReq = New-Object System.DirectoryServices.Protocols.ModifyRequest
        $ModReq.DistinguishedName = $key
        $ModAttr = New-Object System.DirectoryServices.Protocols.DirectoryAttributeModification
        $ModAttr.Name = "csodbbCeIder"
        if ($reset) {
            $ModAttr.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Delete
        } else {
            $ModAttr.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
            [int]$startPos = $empID.Length - 9
            $ModAttr.Add("$($empID.Substring($startPos))Z") | Out-Null
        }
        $ModReq.Modifications.Add($ModAttr) | Out-Null
        $LDAPConnection.SendRequest($ModReq) | Out-Null
        $numUpdates++
    } else {
        "User [$key] could not be updated - employeeID too short: [$empID]"
    }
}
"Total users updated: $($numUpdates)"
Get-Date





