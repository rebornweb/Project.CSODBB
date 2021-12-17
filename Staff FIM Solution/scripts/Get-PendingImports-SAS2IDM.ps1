import-module LithnetMiisAutomation
$ma = Get-ManagementAgent -Name "SAS2IDM"
$importAddsDeletes = @($ma.GetPendingImports($false,$false,$true))
$exclude = @("MiddleName", "CeIder", "ReasonLeft", "PhoneHome","DateLeft","CandidateNumber","StartYear","Year","Class")
$include = @("PhysicaldeliveryOfficeName","SchoolID","StudentID","LastName","FirstName","StartDate","UniversalIdentificationNumber","Archive","DOB","Year","Class","PreEnrolment")

$csvHT = @{}
$importAddsDeletes | % {
    $delta = $_.PendingImportDelta
    $dn = $delta.DN
    $csvHT.Add($dn, @{})
    $csvHT.($dn).Add("DN",$dn)
    $csvHT.($dn).Add("Operation",$delta.Operation)
    if ($false) { #($delta.Attributes.Count -gt 0) {
        $delta.Attributes.Keys | % {
            $csvHT.($dn).Add($_,$delta.Attributes.($_).Values[0].Value)
        }
    } else { 
        $delta = $_.SynchronizedHologram
        if ($delta.Attributes.Count -gt 0) {
            #$delta.Attributes.Keys.Where({$_ -notin $exclude}) | % {
            #$delta.Attributes.Keys.Where({$_ -in $include}) | % {
            $include | % {
                [Lithnet.Miiserver.Client.Attribute]$value = $null
                [bool]$hasValue = $delta.Attributes.TryGetValue($_, [ref]$value)
                if ($hasValue) {
                    # experimental
                }
                $csvHT.($dn).Add($_, [string]$value.Values)
            }
        }
    }
}

# -- Step #3: Generate CSV Reports
<#
[string]$filePath = "D:\Logs\PendingImports-SAS.Adds.csv"
if (Test-Path -path $filePath) 
{ 
    Remove-Item -Force $filePath | Out-Null
}
Write-Host "[$(Get-Date)] Writing CSV to $filePath ..."
foreach($csvItem in $csvHT.Keys) {
    if ($csvHT.($csvItem).Operation -eq "Add") {
        [PSCustomObject]$csvHT.($csvItem) | select * | Sort-Object | Export-Csv $filePath –NoTypeInformation -Append
    }
}
#>

[string]$filePath = "D:\Logs\PendingImports-SAS.Deletes.csv"
if (Test-Path -path $filePath) 
{ 
    Remove-Item -Force $filePath | Out-Null
}
Write-Host "[$(Get-Date)] Writing CSV to $filePath ..."
foreach($csvItem in $csvHT.Keys) {
    if ($csvHT.($csvItem).Operation -eq "Delete") {
        [PSCustomObject]$csvHT.($csvItem) | select * | Sort-Object | Export-Csv $filePath –NoTypeInformation -Append -Force
    }
}
