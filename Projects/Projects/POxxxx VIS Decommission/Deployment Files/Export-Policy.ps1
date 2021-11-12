Import-Module C:\UNIFY\UNIFY
Import-Module UNIFY.MIMServiceConfig

$XMLFolder = "E:\Scripts\VIS Decom\Portal Updates"
$ResourceTable = @{
    SynchronizationRule = @(
        "cso-People: All staff are provisioned to and synced with LDS"
        "cso-People: All students are provisioned to and synced with LDS"
    )
    ManagementPolicyRule = @(
        "AAA-Administration: Administrators can delete EREs"
    )
}

Export-MIMServiceResourceDump -Folder $XMLFolder -ResourceTable $ResourceTable

Write-Host "`nResource XML files have been written to $XMLFolder"
