# derived from http://social.technet.microsoft.com/Forums/en-US/e39c6e66-cd65-4011-8b7a-ef9de4bd1e47/using-powershell-to-export-all-users-have-registered-for-selfservice-password-reset-sspr?forum=ilm2

set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant 

set-variable -name CSV -value "d:\scripts\CasualStaff.csv" 

clear 

If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation} 

$Filter = "/Person[starts-with(AccountName,'%') and (csoSites=/csoSite[DisplayName='Casual Pool'])]"

$curObject = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($Filter) -ErrorVariable Err -ErrorAction SilentlyContinue 

[array]$users = $null 

foreach($Object in $curObject) 

{

 $ResetPass = New-Object PSObject

 $UserDisplayName = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "DisplayName"}).Value)
 $UserAccountName = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "AccountName"}).Value)
 $UserEmployeeID = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "EmployeeID"}).Value)

 $ResetPass | Add-Member NoteProperty "DisplayName" $UserDisplayName
 $ResetPass | Add-Member NoteProperty "AccountName" $UserAccountName
 $ResetPass | Add-Member NoteProperty "EmployeeID" $UserEmployeeID

 $Users += $ResetPass

}

$users | export-csv -path $CSV
