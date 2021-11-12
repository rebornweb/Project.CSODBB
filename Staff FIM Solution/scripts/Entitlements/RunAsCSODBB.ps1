#GetResource -ObjectIdentifier 'E6990B5F-3336-4804-8220-E0A04068AB3F'
$scriptFolder = "E:\Scripts\Entitlements"

$pw = Get-Content ([System.IO.Path]::Combine($scriptFolder,"$scriptFolder\authToken.txt")) | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential "csodbb",$pw 

try {
        $Session = New-PSSession -Credential $cred -ConfigurationName #Microsoft.PowerShell -ComputerName "centrelink-fim"
} catch {
    throw "Error creating remote Exchange PSSession to $ExchangeServerUri with credentials $($CredsAD.UserName)"
}
if ($Session) {
    Import-PSSession $Session -AllowClobber | Out-Null
}


try
{
	#Open a new session on the same box to in order to allow the reset script to run in PS v3.0
	$session = New-PSSession -ConfigurationName Microsoft.PowerShell #-Credential $cred
	
	#Invoke the reset cmdlet in the new session.
	Invoke-Command -Session $session { 
		param($NewPwd,$Identity,$ADServer,$ResetUserCred,$NextLogon)
		E:\Scripts\Entitlements\TriggerEntitlementsHousekeeping.ps1 -NewPwd $NewPwd -Identity $Identity -ADServer $ADServer -ResetUserCred $ResetUserCred -NextLogon $NextLogon
	} -ArgumentList $newPwd,$identity,$ADServer,$resetUserCred,$NextLogon
	if ($session) {Remove-PSSession $session -ErrorAction continue | out-null}
	$Log = log "Password Successfully Reset"
} catch [System.Exception]
{	
	if ($session) {Remove-PSSession $session -ErrorAction continue | out-null}
	$Log = log "Error Setting Password: $_.Exception.Message"
	writeLog
	throw $_.Exception
}
