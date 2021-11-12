###
### UNIFY Functions to include in FIM Portal Workflow scripts.
### Normally run in addition to FIMFunctions.ps1.
###



## Search for an object using ObjectType and Name and return its ResourceID.
## When using directly after creation use -Wait $true to allow rechecking.
## - This script was updated to allow an $Attribute other than DisplayName to be specified, and the value to be passed as $Value
function ObjectExists
{
    PARAM($ObjectType, $DisplayName, $Wait=$false, $Attribute,$Value)
    END
    {
        if ($DisplayName) {$Attribute = "DisplayName";$Value=$DisplayName}
 
        $filter = "/{0}[{1}='{2}']" -f $ObjectType,$Attribute,$Value

        if ($Wait) {$count = 1} else {$count = 10}
        do
        { 
            $fimObj = ExportFromFIM -Filter $filter
            if ($fimObj -eq $null){start-sleep -s $count;$count += 1}
            else {$count = 11}
        }
        while ($count -le 10)

        if ($fimObj -eq $null) {Return 0}
        elseif ($fimObj.Count) {Return 0}
        else {Return ($fimObj.ResourceManagementObject.ObjectIdentifier).Replace("urn:uuid:","")}

    }
}

## Returns the filter in correct format for a Set or Group
function SetFilter
{
    PARAM($XPath)
    END
    {
        $prefilter = '<Filter xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Dialect="http://schemas.microsoft.com/2006/11/XPathFilterDialect" xmlns="http://schemas.xmlsoap.org/ws/2004/09/enumeration">'
        $postfilter = '</Filter>'
        Return ($prefilter + $XPath + $postfilter)
    }
}

## Writes an event to the Application log using the PowershellActivity source log (which must exist).
## Valid values for $Level are Error, Warning, Information, SuccessAudit, and FailureAudit. The default value is Information.
function WriteLog
{
    [CmdletBinding()]
    Param (
      [Parameter(Mandatory = $true,Position = 0,valueFromPipeline=$true)]
      [string]$Message,
      [string]$Level = "Information",
      [boolean]$Fatal = $false
     )

    END
    {
        if ($Verbose -eq $null) {$Verbose = $false}

        if ($Verbose -or $Level -ne "Information") 
        {
            Write-EventLog -LogName Application -Source PowershellActivity -Message ($ScriptName + "`n" + $Message) -EntryType $Level -EventID 0
            if ($Fatal) {Throw $Message}
        }
    }
}


## Imports with logging
Function ImportToFIM
{
    PARAM($ImportObject)
    END
    {
        $Error.clear()
        "Importing change" + ($ImportObject  | Out-String -Width 100) + ($ImportObject.Changes  | Out-String -Width 100) | WriteLog
        try {Import-FIMConfig $ImportObject -ErrorAction SilentlyContinue}
        catch {}
        if ($Error.Count -gt 0)
        {
            if ($Error[0].Exception -ilike '*pending authorization*') {} #Ignore
            else {$Error[0].Exception | WriteLog -Level "Error" -Fatal $true}
        }
    }
}

## Exports with -OnlyBaseResources and logging
Function ExportFromFIM
{
    PARAM($Filter)
    END
    {
        $Error.clear()
        "Exporting FIM objects using filter $Filter"  | WriteLog
        try {$FIMObjects = Export-FIMConfig -CustomConfig $Filter -OnlyBaseResources -ErrorAction SilentlyContinue}
        catch {$Error[0].Exception | WriteLog -Level "Error" -Fatal $true}
        Return $FIMObjects
    }
}


# Returns the requested value for a specifc Attribute in a Request object
Function RequestedValue
{
    PARAM($ReqObj, $Attribute, $Mode='Add')
    END
    {
        $Changes = ($ReqObj.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq 'RequestParameter'}).Values

        [string]$ReturnVal = ""
        foreach ($XmlString in $Changes)
        {
            [xml]$change = $XmlString
            if ($change.RequestParameter.PropertyName -eq $Attribute)
            {
                [string]$value = ""
                $value = $change.RequestParameter.Value."#text"
                if ($value -ne "")
                {
                    if ($ReturnVal -eq ""){$ReturnVal = $value}
                    else {$ReturnVal = $ReturnVal + ";" + $value}
                }
            }
        }
        Return $ReturnVal
    }
}



# Creates an object based on a hashtable as follows:
# - The hashtable must be @{<DisplayName>,@{attribute,value}} with a single DisplayName and multiple attribute,value pairs.
# - The attribute must be listed using its system name.
# - If the attribute is multivaled then the value must be expressed as an array, even if it only has one value in it.
# - For reference values the GUID must be specified. Use the ObjectExists function in the hashtable definition to find the GUID.
Function CreateObjectFromHashtable
{
    PARAM($ObjectType,$Name,$HashValues)
    END
    {
        if ($Verbose)
        {
            "CreateObjectFromHashtable: " + 
            "Object Type: $ObjectType`n" + 
            "Name: $Name`n" + 
            "Values: `n" +
            ($HashValues  | Out-String -Width 100 ) | WriteLog
        }
        
        if (ObjectExists -ObjectType $ObjectType -DisplayName $Name) 
        {
            "$ObjectType $Name already exists" | WriteLog -Level "Warning"
        }
        else
        {
            "Adding $ObjectType $Name..." | WriteLog
            $ImportObject = CreateImportObject -ObjectType $ObjectType
            SetSingleValue $ImportObject "DisplayName" $Name
            foreach ($attr in $HashValues.Keys)
            {
                if ($HashValues.($attr) -is [system.array])
                {
                    foreach ($value in $HashValues.($attr))
                    {
                        AddMultiValue $ImportObject $attr $value
                    }
                }
                else
                {
                    SetSingleValue $ImportObject $attr $HashValues.($attr)
                }
            }
            ImportToFIM -ImportObject $ImportObject
        }
    }
}

## The following function is here to allow object creation hashtables to be copied from the Install scripts to the WF scripts.
## It just calls the ObjectExists function to get the object's GUID and $NoPrefix is not actually used.
Function LookupObject
{
    PARAM($ObjectType,$Name,$NoPrefix)
    END
    {
        Return (ObjectExists -ObjectType $ObjectType -DisplayName $Name)
    }
}


###
### Run for all Workflow scripts
###

$ErrorActionPreference = "Continue"
$AdminGUID = "7fb2b853-24f0-4498-9534-4e10589723c4"
$AdminUrnGUID = "urn:uuid:7fb2b853-24f0-4498-9534-4e10589723c4"

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
$ProgressPreference="SilentlyContinue"

## Log the Request Details
if ($fimwf)
{
    "Request details: " + 
    ($fimwf  | Out-String -Width 100) + "Workflow Data:`n" + 
    ($fimwf.WorkflowDictionary  | Out-String -Width 100 ) | WriteLog
}
