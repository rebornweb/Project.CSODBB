## Adds a mailbox to newly-created user accounts
#
# Targets accounts created by FIM based on following rule:
#   - In the FIM-managed OU
#   - Exchange mail server not present
#
# Needs an account with sufficient Exchange permissions. Password must be in an encrypted file using the following command, run by the
# service account that will be running this script:
#   read-host -assecurestring | convertfrom-securestring | out-file encrypted.txt
#

$PWFile = "E:\FIM\scripts\Exchange\encrypted.txt"
$LogFile = "E:\FIM\scripts\Exchange\log.txt"
$AdminAccount = "mydomain\myExchangeAdminAccount"
$ExchangeCAS = "MyCASServer.mydomain.local"
$SearchBase = "OU=IAMManaged,DC=mydomain,DC=local"

$Filter = "(&(objectCategory=user)(objectClass=user)(!msExchHomeServerName=*))"

$password = get-content $PWFile | convertto-securestring
$UserCredential =  New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $AdminAccount,$password

get-date | out-file -FilePath $LogFile -Encoding 'Default'

"Connecting to $ExchangeCAS" | Add-Content -Path $LogFile
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeCAS1/PowerShell/ -Authentication Kerberos -Credential $UserCredential

Import-PSSession $Session

Import-Module ActiveDirectory

$users = get-aduser -LDAPFilter $Filter -searchbase $SearchBase -searchscope "Subtree"

if ($users -ne $null) {foreach ($user in $users)
{
   "Mail-enabling $user.SamAccountName" | Add-Content -Path $LogFile 
   Enable-Mailbox $user.SamAccountName | Set-Mailbox -SingleItemRecoveryEnabled $true
}}

#Exit-PSSession
Remove-PSSession -session $Session