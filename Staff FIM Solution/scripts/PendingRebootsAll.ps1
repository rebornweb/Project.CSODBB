PARAM(  [string]$fromaddress = "svcFIM_Service@dbb.org.au", 
        [string[]]$toaddress = @("robert.broadley@dbb.org.au"),
        [string]$bccaddress = $null, 
        [string]$CCaddress = "csodbbsupport@unifysolutions.net",
        [string]$smtpserver = "smtp.dbb.local",
        [string]$archiveFileName = $null,
        [string]$Subject = "Pending Reboots Report (including windows update errors)"
)

cls
Set-Location D:\Scripts
Import-Module .\Get-PendingReboot.ps1 -Force
Import-Module ActiveDirectory

$computers = Get-ADComputer -Filter * -Properties operatingsystem |Where operatingsystem -match 'server' |where {$_.enabled -ne $false} |Sort-Object name
$IAMComputers = $computers.Where({$_.Name -like 'OCCCP-IM*' -or $_.Name -like 'OCCCP-DB*' -or $_.Name -like 'OCCCP-EX*' -or $_.Name -like 'OCCCP-DC*' -or $_.Name -like 'DGLOU-AS211' -or $_.Name -like 'OCCCP-AS018'})
#$IAMComputers.Count
[string]$body = ""
$Reboots = Get-PendingReboot -ErrorLog "D:\Scripts\Get-PendingRebootErrors.log" -Computer $IAMComputers.Name |where {$_.RebootPending -eq $true}|select computer, RebootPending, CBServicing, WindowsUpdate, CCMClientSDK
if ($Reboots) {
    $RebootsHTML = $Reboots |ConvertTo-Html -Head $style
    $RebootsHTML | % {
        $body += $_
    }
    Send-MailMessage -SmtpServer $smtpserver -Body $body -BodyAsHtml -From $fromaddress -To $toaddress -Cc $CCaddress -Subject $Subject
}