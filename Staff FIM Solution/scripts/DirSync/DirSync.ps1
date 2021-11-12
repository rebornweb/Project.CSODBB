CD "E:\Scripts\DirSync"
Get-Date

# http://dloder.blogspot.com.au/2012/01/powershell-dirsync-sample.html
Add-Type -AssemblyName System.DirectoryServices.Protocols

If (Test-Path .\cookie.bin –PathType leaf) { 
    [byte[]] $Cookie = Get-Content -Encoding byte –Path .\cookie.bin 
} else { 
    $Cookie = $null 
}

$isDefaultCreds = $false
$isAD = $false # 7 seconds to initialise cookie with AD, 10 seconds with VIS

if ($isDefaultCreds) {
    $RootDSE = [ADSI]"LDAP://RootDSE" 
    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($RootDSE.dnsHostName)
    $LDAPBase = $RootDSE.defaultNamingContext
} else {
    #$password = Read-Host "Enter password" -AsSecureString # Enter "Password01" here!
    # read-host -assecurestring "Enter service account password" | convertfrom-securestring | out-file password.txt
    $password = Get-Content ("password.txt") | ConvertTo-SecureString
    $tempCredential = New-Object System.Management.Automation.PsCredential "dbb\svcidv_ad", $password
    $networkCredential = $tempCredential.GetNetworkCredential()
    #$password = $tempCredential.GetNetworkCredential().Password
    #$tempCredential.GetNetworkCredential().UserName

    if ($isAD) {
        $ldapServer = "10.19.229.10:389"
    } else {
        $ldapServer = "10.19.229.31:389"
    }
    $LDAPBase = "DC=DBB,DC=Local"
    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($ldapServer, $networkCredential, [System.DirectoryServices.Protocols.AuthType]::Negotiate) 
    $RootDSE = [ADSI]"LDAP://$ldapServer" #/RootDSE"
}

if ((Test-Path .\cookie.bin –PathType leaf)) {
    $filter = "(objectclass=*)"
} else {
    $filter = "(noOpClassAndShouldNotBeFound=nothingFound)" # only works for VIS if this is "(objectclass=*)" initially!!!!
}
$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($LDAPBase, $filter, "Subtree", $null) 
$DirSyncRC = New-Object System.DirectoryServices.Protocols.DirSyncRequestControl($Cookie, [System.DirectoryServices.Protocols.DirectorySynchronizationOptions]::IncrementalValues, [System.Int32]::MaxValue) 
$Request.Controls.Add($DirSyncRC) | Out-Null 

$MoreData = $true

while ($MoreData) {

    $Response = $LDAPConnection.SendRequest($Request)

    if ((Test-Path .\cookie.bin –PathType leaf)) {
        $Response.Entries | ForEach-Object { 
            write-host $_.distinguishedName
        }
    }

    ForEach ($Control in $Response.Controls) { 
        If ($Control.GetType().Name -eq "DirSyncResponseControl") { 
            $Cookie = $Control.Cookie 
            $MoreData = $Control.MoreData 
        } 
    } 
    $DirSyncRC.Cookie = $Cookie 
}

Set-Content -Value $Cookie -Encoding byte –Path .\cookie.bin
Get-Date
