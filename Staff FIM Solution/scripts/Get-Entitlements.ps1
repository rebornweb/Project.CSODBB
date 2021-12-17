# -- Step #1: Execute Query

# basic MV multi-part query
Import-Module LithnetMiisAutomation
$q1 = New-MVQuery -Attribute "employeeStatus" -Value "Active" -Operator Equals
$q2 = New-MVQuery -Attribute "jobTitle" -Value "Teacher" -Operator Contains
$q3 = New-MVQuery -Attribute "objectSid" -Operator IsPresent
$mvSearchResult = @(Get-MVObject -Queries @($q1,$q2,$q3))
Write-Host "[$(Get-Date)] $($mvSearchResult.Count) found ..."

# OPTIONAL: advanced query condition on result set - get only those users created in the last 28 days
[int]$elapsedDays = 28
[datetime]$dateFrom = (Get-Date).AddDays(-$elapsedDays).ToUniversalTime()
$csvItems = $mvSearchResult.Where({$_.Attributes.objectSid.Values.LineageTime -gt $dateFrom}) | sort {$_.Attributes.objectSid.Values.LineageTime}
Write-Host "[$(Get-Date)] $($csvItems.Count) new users in last $elapsedDays days..."

# -- Step #2: Generate Hash Table from the results (note the use of PSCustomObject - critical for the CSV generation step!!!)
$csvHT = @{}
$csvHeader = @("displayName", "email") # put your Metaverse columns for your CSV here!
$csvItems | % {
    $csvItem = $_
    $htItem = @{}
    $csvHeader | %{
        $htItem.Add($csvItem.Attributes.$_.Name,$csvItem.Attributes.$_.Values.Value)
    }
    # Special - add extra calculation (LineageTime)
    $htItem.Add("adCreatedDate",$csvItem.Attributes.objectSid.Values.LineageTime)
    $csvHT.Add($csvItem.ID,[PSCustomObject]$htItem)
}
$csvHeader += "adCreatedDate"

# -- Step #3: Generate CSV Report
[string]$filePath = "C:\temp\mimReportDemo.csv" #construct a file path here, preferably using script parameters
if (Test-Path -path $filePath) 
{ 
    Remove-Item -Force $filePath | Out-Null
}
Write-Host "[$(Get-Date)] Writing CSV to $filePath ..."
foreach($csvItem in $csvHT.Keys) {
    $csvHT.($csvItem) | select $csvHeader | Export-Csv $filePath –NoTypeInformation -Append
}
