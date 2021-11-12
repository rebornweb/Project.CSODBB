# Search and locate targeted 4723 events where the identity is NOT svcilm_ma_ad
# Refer to https://serverfault.com/questions/684404/how-to-check-who-reset-the-password-for-a-particular-user-in-active-directory-on

cls

$domain = Get-ADDomain
$dcs = Get-ADObject -LDAPFilter "(objectClass=computer)" -SearchBase $($domain.DomainControllersContainer)

Get-Date

$rpcOK = @()
$rpcErrors = @()
$adminPwdChanges = @()
foreach ($dc in $dcs) {
    #$dc = $dcs[0]
    [string]$ComputerName = $dc.Name
    Write-Host "Searching $ComputerName for admin pwd changes - [$($adminPwdChanges.Count)] found so far ..."
    try {
        $adminPwdChanges += @(Get-WinEvent -ComputerName "$ComputerName.dbb.local" -FilterHashtable @{logname='security'; id=4724;} -MaxEvents 100 -Oldest)
        $rpcOK += @("$ComputerName")
    } catch {
        $rpcErrors += @("$ComputerName")
        "Unable to connect to DC [$ComputerName] due to RPS issues! continuing ..."
        $Error.Clear()
    }
}
Get-Date
Write-Host "Total admin pwd changes - [$($adminPwdChanges.Count)] found!"

$adminPwdChanges | sort {$_.TimeCreated} | select TimeCreated
#$adminPwdChanges[0] | select *
$adminPwdChanges.Count
$dcs.Count
$rpcOK.Count
$rpcErrors.Count

