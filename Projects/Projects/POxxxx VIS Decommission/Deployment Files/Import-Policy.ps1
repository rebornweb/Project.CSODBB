Import-Module C:\UNIFY\UNIFY
Import-Module UNIFY.MIMServiceConfig

$XMLFolder = "E:\Scripts\VIS Decom\Portal Updates"

Import-MIMServiceResourceDump -Folder $XMLFolder
Write-Host "`nResource XML files have been imported from $XMLFolder"
