if (@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0)
{
    add-pssnapin FIMAutomation
}

# GetAttributeValueFromResource takes an exportObject and attribute name as
# parameters and returns the attribute value.
# If the attribute is not stored in the exportObject, the function returns null.
function GetAttributeValueFromResource
{
    PARAM ($exportObject, $attributeName)
    END
    {
        foreach ($attribute in $exportObject.ResourceManagementObject.ResourceManagementAttributes)
        {             
            if($attribute.AttributeName.Equals($attributeName))
            {
                return $attribute.Value
            }
            
        }
        return $null
    }
}

# Query FIM for all Person resources and store result in exportedObjects.
$queries = @("/csoRole", #[starts-with(DisplayName,'A')]
    "/csoEntitlement",
    "/csoJob",
    "/Group[Type='Security']",
    "/Group[Type='Distribution']",
    "/Person[not(PersonType='staff') and not(PersonType='student') ]",
    "/Person[PersonType='staff']",
    "/Person[PersonType='student']")
$counters = @{}
Get-Date
foreach ($query in $queries) {
    #$query = $queries[0]
    $exportedObjects = Export-FIMConfig -uri "http://localhost:5725/ResourceManagementService" -customConfig $query -onlyBaseResources
    #Write-Host ("The script has exported " + $exportedObjects.Count + " objects based on the filter: " + $query)
    $counters.Add($query,$exportedObjects.Count)
}
Get-Date

# Write all unique Department values into a file.
Write-Host "Writing the counters to file 'Counters.txt'"
$counters | Out-File "D:\scripts\Counters.txt"
