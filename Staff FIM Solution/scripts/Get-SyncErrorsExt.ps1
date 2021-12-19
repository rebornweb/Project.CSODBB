Param (
    $resultsFile = "C:\Logs\MIMErrors.xml",
    $mvRequiredAttributes = @("displayName"), #@("uid","accountName"),
    $mvObjects = @("group","person","contact"),
    $mvUniqueAttributes = @("email","uid","displayName","accountName"), # @("mail","employeeID","accountName")
    [switch]$getMVData,
    [switch]$filteredDisconnectors,
    [switch]$explicitDisconnectors,
    [switch]$placeholderDisconnectors,
    [int]$depth = 2
)
#[PSObject]$results = Get-Content $resultsFile
#[xml]$results = Get-Content $resultsFile
#([xml]$results).Objects.Count

[xml]$resultsXml = [xml]::new()
$resultsXml.Load($resultsFile)
$resultsXml.DocumentElement.ChildNodes.ChildNodes.Count



