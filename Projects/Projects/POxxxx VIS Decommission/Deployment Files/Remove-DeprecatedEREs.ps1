Remove-MIMServiceResource -Attributes @{ ObjectType="SynchronizationRule"; DisplayName="cso-People: All active staff and students are provisioned to ADLDS" }

Set-MIMServiceResource -Attributes @{ ObjectType="ManagementPolicyRule"; DisplayName="AAA-Administration: Administrators can delete EREs"; Disabled=$false }

$FirstTime = $True
while ($True) {
    $Pager = Search-ResourcesPaged -XPath "/ExpectedRuleEntry[DisplayName='cso-People: All active staff and students are provisioned to ADLDS']"
    if ($Pager.TotalCount -eq 0) { break }
    $Pager.PageSize = 100
    if ($FirstTime) { Write-Host "Deleting $($Pager.TotalCount) EREs" }
    while ($Pager.HasMoreItems) {
        $EREs = $Pager.GetNextpage()
        Write-Host "Processing block of $($EREs.count) EREs"
        foreach ($ERE in $EREs) {
            $ERE | Remove-Resource
        }
    }
    $FirstTime = $False
}

Set-MIMServiceResource -Attributes @{ ObjectType="ManagementPolicyRule"; DisplayName="AAA-Administration: Administrators can delete EREs"; Disabled=$true }
