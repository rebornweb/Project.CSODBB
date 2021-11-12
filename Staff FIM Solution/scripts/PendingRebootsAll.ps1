Import-Module .\Get-PendingReboot.ps1
Import-Module ActiveDirectory

$computers = Get-ADComputer -Filter * -Properties operatingsystem |Where operatingsystem -match 'server' |where {$_.enabled -ne $false} |Sort-Object name
$IAMComputers = $computers.Where({$_.Name -like 'OCCCP*' -or $_.Name -like 'DGLOU*'})
$IAMComputers.Count
$Reboots = Get-PendingReboot -Computer $IAMComputers.Name |where {$_.RebootPending -eq $true}|select computer, LastReboot, CBServicing, WindowsUpdate, CCMClientSDK |ConvertTo-Html -Head $style
