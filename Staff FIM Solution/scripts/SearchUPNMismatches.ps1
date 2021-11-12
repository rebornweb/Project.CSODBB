Import-Module LithnetMiisAutomation

$filePath = "D:\Logs\MismatchingUpnSuffixes_070318.csv"
$missingOnly = $true

$mvQueries = @(
    New-MVQuery -Attribute PersonType -Operator Equals -Value "Staff"
    New-MVQuery -Attribute employeeStatus -Operator Equals -Value "active"
)
if ($missingOnly) {
    $filePath = "D:\Logs\MissingUpnSuffixes_070318.csv"
    $mvQueries += New-MVQuery -Attribute csoUpnSuffix -Operator IsNotPresent
    $mvQueries += New-MVQuery -Attribute csoLegacyEmployeeID -Operator NotContains "B"
} else {
    $mvQueries += New-MVQuery -Attribute csoUpnSuffix -Operator IsPresent
}

$mvQueryResult = Get-MVObject -ObjectType Person -Queries $mvQueries
if ($missingOnly) {
    $exceptions = $mvQueryResult
} else {
    $exceptions = $mvQueryResult | Where-Object {$_.Attributes.uid.Values.ValueString -notlike "*$($_.Attributes.csoUpnSuffix.Values.ValueString)"}
}
$users = @{}
foreach ($exception in $exceptions) {
    $obj = [PSCustomObject]@{
        accountName = $exception.Attributes.accountName.Values.ValueString
        displayName = $exception.Attributes.displayName.Values.ValueString
        uid = $exception.Attributes.uid.Values.ValueString
        csoUpnSuffix = $exception.Attributes.csoUpnSuffix.Values.ValueString
        employeeID = $exception.Attributes.employeeID.Values.ValueString
        csoLegacyEmployeeID = $exception.Attributes.csoLegacyEmployeeID.Values.ValueString
    }
    $users.Add($exception.ID,$obj)
}

if (Test-Path -path $filePath) 
{ 
    Remove-Item -Force $filePath | Out-Null
}

foreach ($userKey in $users.Keys) {
    $users.$userKey | Select-Object * | Export-Csv $filePath –NoTypeInformation -Append
}

