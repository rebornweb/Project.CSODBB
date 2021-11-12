###
### Update attribute 'csodbbCeIder' with values in Directory
###



CD "E:\Scripts\installation\CelderEnhancement"
Get-Date

#$password = Read-Host "Enter password" -AsSecureString # Enter "Password01" here!
#read-host -assecurestring "Enter service account password" | convertfrom-securestring | out-file acc_password.txt
$password = Get-Content ("password.txt") | ConvertTo-SecureString
$tempCredential = New-Object System.Management.Automation.PsCredential "unifyfim\adsync", $password
$networkCredential = $tempCredential.GetNetworkCredential()
#$password = $tempCredential.GetNetworkCredential().Password
#$tempCredential.GetNetworkCredential().UserName

$ldapServer = "localhost:50000"
$LDAPBase = "DC=CSODBB"
Add-Type -AssemblyName System.DirectoryServices.Protocols | Out-Null
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($ldapServer, $networkCredential, [System.DirectoryServices.Protocols.AuthType]::Negotiate) 
$RootDSE = [ADSI]"LDAP://$ldapServer" #/RootDSE"
$filter = "(&(objectClass=user)(!csodbbCeIder=*)(employeeID=2813*))"
$attributes = @("employeeID") 
$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($LDAPBase, $filter, "Subtree", $attributes) 
$Response = $LDAPConnection.SendRequest($Request)

#store user data in HT
$userinfoHT = @{}
foreach ($user in $Response.Entries) {
    $empID = $Response.Entries[0].Attributes.employeeid[0]
    
    $userinfoHT.Add($user.DistinguishedName,$empID)
}
"Total users to update: $($userinfoHT.Count)"
foreach ($key in $userinfoHT.keys) {
    
    $empID = $userinfoHT[$key]
    $ModReq = New-Object System.DirectoryServices.Protocols.ModifyRequest
    $ModReq.DistinguishedName = $key
    $ModAttr = New-Object System.DirectoryServices.Protocols.DirectoryAttributeModification
    $ModAttr.Name = "csodbbCeIder"
    $ModAttr.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Add
    $ModAttr.Add($empID.Substring(0,9)) | Out-Null
    $ModReq.Modifications.Add($ModAttr) | Out-Null
    $LDAPConnection.SendRequest($ModReq) | Out-Null
}
Get-Date





