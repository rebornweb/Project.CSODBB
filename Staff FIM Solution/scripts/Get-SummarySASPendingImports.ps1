# load the MA
$ma = Get-ManagementAgent -Name "SAS2IDM" -Reload
# get pending import changes
$pendingDeletes = @($ma.GetPendingImports($false,$false,$true))
$pendingMods = @($ma.GetPendingImports($false,$true,$false))
$pendingAdds = @($ma.GetPendingImports($true,$false,$false))
$pendingDeletes.Count
$pendingMods.Count
$pendingAdds.Count

# get a summary list of schools that have changed
$schoolsWithDeletes = @($pendingDeletes.SynchronizedHologram.Attributes.PhysicaldeliveryOfficeName.Values | Sort-Object -Unique)
$schoolsWithMods = @($pendingMods.SynchronizedHologram.Attributes.PhysicaldeliveryOfficeName.Values | Sort-Object -Unique
$schoolsWithAdds = @($pendingAdds.SynchronizedHologram.Attributes.PhysicaldeliveryOfficeName.Values | Sort-Object -Unique

# inspect the deletions
$pendingDeletesHT = @{}
$pendingDeletes | % {
    $student = @{}
    $student.Add("PhysicaldeliveryOfficeName", $_.SynchronizedHologram.Attributes.PhysicaldeliveryOfficeName.Values)
    $student.Add("UniversalIdentificationNumber", $_.SynchronizedHologram.Attributes.UniversalIdentificationNumber.Values)
    $student.Add("FirstName", $_.SynchronizedHologram.Attributes.FirstName.Values)
    $student.Add("LastName", $_.SynchronizedHologram.Attributes.LastName.Values)
    $student.Add("AlumniType", $_.SynchronizedHologram.Attributes.AlumniType.Values)
    $pendingDeletesHT.Add($_.SynchronizedHologram.Attributes.UniversalIdentificationNumber.Values, $student)
}

# get summary data in school order
$schoolsWithDeletes | % {
    [string]$school = $_
    $pendingDeletesHT.Values.Where({$_.PhysicaldeliveryOfficeName -eq "$school"}) | ft
}
