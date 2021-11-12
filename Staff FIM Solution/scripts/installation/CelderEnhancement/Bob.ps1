cls
CD "E:\Scripts\installation\CelderEnhancement"
Get-Date

#$password = Read-Host "Enter password" -AsSecureString # Enter "Password01" here!
# read-host -assecurestring "Enter service account password" | convertfrom-securestring | out-file password.txt
$password = Get-Content ("password.txt") | ConvertTo-SecureString
$tempCredential = New-Object System.Management.Automation.PsCredential "unifyfim\adsync", $password
$networkCredential = $tempCredential.GetNetworkCredential()
#$password = $tempCredential.GetNetworkCredential().Password
#$tempCredential.GetNetworkCredential().UserName

$ldapServer = "localhost:50000"
$LDAPBase = "DC=CSODBB"
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($ldapServer, $networkCredential, [System.DirectoryServices.Protocols.AuthType]::Negotiate) 
$RootDSE = [ADSI]"LDAP://$ldapServer" #/RootDSE"
$filter = "(&(objectclass=user)(csodbbCeIder=*)(employeeID=*))"
#$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($LDAPBase, $filter, "Subtree", "*") 
$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($LDAPBase, $filter, "Subtree", $null) 
#$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($LDAPBase, $filter, "Subtree", @("employeeID")) 
$Response = $LDAPConnection.SendRequest($Request)

Get-Date

foreach ($user in $Response.Entries) {
    #$user.Attributes
    $user.DistinguishedName
    #"$($user.DistinguishedName):$($user.Attributes.employeeID[0]):$($user.Attributes.csodbbCeIder[0])"
    #"$($user.DistinguishedName):$($user.Attributes.employeeID[0])"
    #"$($user.DistinguishedName)"
}

#$Response.Entries[0].Attributes.employeeid[0]
#$Response.Entries[0].Attributes.csodbbCeIder
