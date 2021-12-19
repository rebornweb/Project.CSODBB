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

Write-Host "[$(Get-Date)]: Analysing MIM MV Integrity ..."
Import-Module LithnetMiisAutomation
[string[]]$mas = @()
$results = @{}

# Get MV Data
if ($getMVData) {
    $queries = @()
    $mvRequiredAttributes | % {
        $queries += New-MVQuery -Attribute $_ -Operator IsPresent
    }
    $mvObjects | % {
        $mvObjName = $_
        $mvResults = @{}
        Write-Host "[$(Get-Date)]: Processing MV Object [$mvObjName] ..."
        #$mvResults.Add($mvObjName, @{})
        Get-MVObject -ObjectType $_ -Queries $queries | % {
            $obj = $_
            $value = @{}
            $obj.Attributes.Keys.Where({$_ -in $mvUniqueAttributes}) | % {
                $value.Add($_, $obj.Attributes.($_).Values.Value)
            }
            #$mvResults.($mvObjName).Add($_.DN, [PSObject]$value)
            $mvResults.Add($_.DN, [PSObject]$value)
        }
        # add to main HT
        #$results.Add($mvObjName,[PSObject]$mvResults.($mvObjName))
        $results.Add($mvObjName,[PSObject]$mvResults)
        Write-Host "[$(Get-Date)]: MV Object [$mvObjName] count [$($mvResults.Count)]"
    }
}

function ConvertFrom-Xml($myXml) {

    $myObject = New-Object PSObject
    if ($myXml.attr) {
        # expand cs attributes
        foreach ($prop in $myXml.attr) # | Get-Member -MemberType Property | select -ExpandProperty Name)
        {
            $myObject | Add-Member NoteProperty $prop.name $prop.value
        }
    } elseif ($myXml.'extension-error-info' -or $myXml.'cd-error') {
        # expand first level of error xml
        foreach ($prop in $myXml | Get-Member -MemberType Property | select -ExpandProperty Name)
        {
            if ($myXml.$prop.GetType().Name -like "*Xml*") {
                # expand second level of xml
                foreach ($prop2 in $myXml.$prop | Get-Member -MemberType Property | select -ExpandProperty Name)
                {
                    if ($myXml.$prop.$prop2.Trim().length -gt 0) {
                        $myObject | Add-Member NoteProperty $prop2 $myXml.$prop.$prop2
                    }
                }
            } else {
                if ($myXml.$prop.Trim().length -gt 0) {
                    $myObject | Add-Member NoteProperty $prop $myXml.$prop
                }
            }
        }
    } elseif ($myXml) {
        $myObject = $myXml
    }
    $myObject
}

# Get MA Errors
Write-Host "[$(Get-Date)]: Analysing MIM Sync Errors ... all MAs ..."
Get-ManagementAgent | select Name | % {$mas+=$_.Name}
#$mas.Where({$_ -eq "Staff"}) | % {
$mas | % {
    [string]$maName = $_
    [string]$trace = "[$(Get-Date)]: MA [$maName] : Import Errors: [{0}], Export Errors: [{1}], Filtered Disconnectors: [{2}], Explicit Disconnectors: [{3}], Placeholders: [{4}], Placeholder Parents: [{5}]"

    Write-Host "[$(Get-Date)]: Processing MA [$maName] ..."
    $ma = Get-ManagementAgent -Name $maName -Reload
    $results.Add($maName, @{})
    $results.($maName).Add("ImportErrors",@{})
    @($ma.GetImportErrors()) | % {
        $csObj = [PSObject]$_
        $csErr = ([xml]$csObj.GetOuterXml()).'cs-object'.'import-errordetail'.'import-status'
        $csImp = ([xml]$csObj.GetOuterXml()).'cs-object'.'pending-import-hologram'.'entry'
        $csSync = ([xml]$csObj.GetOuterXml()).'cs-object'.'synchronized-hologram'.'entry'
        $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName;"error-detail"=ConvertFrom-Xml($csErr);"cs-object"=ConvertFrom-Xml($csSync);"cs-imp"=ConvertFrom-Xml($csImp)}
        $results.($maName)."ImportErrors".Add($_.DN, [PSObject]$csHT)
    }
    $results.($maName).Add("ExportErrors",@{})
    @($ma.GetExportErrors()) | % {
        $csObj = [PSObject]$_
        $csErr = ([xml]$csObj.GetOuterXml()).'cs-object'.'export-errordetail'.'export-status'
        $csExp = ([xml]$csObj.GetOuterXml()).'cs-object'.'unapplied-export-hologram'.'entry'
        $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName;"error-detail"=ConvertFrom-Xml($csErr);"cs-object"=ConvertFrom-Xml($csExp)}
        $results.($maName)."ExportErrors".Add($_.DN, [PSObject]$csHT)
    }
    if ($explicitDisconnectors) {
        $results.($maName).Add("ExplicitDisconnectors",@{})
        @($ma.GetDisconnectors([Lithnet.Miiserver.Client.ConnectorState]::Explicit)) | % {
            $csObj = [PSObject]$_
            $csImp = ([xml]$csObj.GetOuterXml()).'cs-object'.'pending-import-hologram'
            $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName;"cs-object"=$csImp}
            $results.($maName)."ExplicitDisconnectors".Add($_.DN, [PSObject]$csHT)
        }
    }
    if ($filteredDisconnectors) {
        $results.($maName).Add("FilteredDisconnectors",@{})
        @($ma.GetDisconnectors([Lithnet.Miiserver.Client.ConnectorState]::Filtered)) | % {
            $csObj = [PSObject]$_
            $csImp = ([xml]$csObj.GetOuterXml()).'cs-object'.'pending-import-hologram'
            $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName;"cs-object"=$csImp}
            $results.($maName)."FilteredDisconnectors".Add($_.DN, [PSObject]$csHT)
        }
    }
    if ($placeholderDisconnectors) {
        $results.($maName).Add("PlaceholderDisconnectors",@{})
        <#$disconnectors = @($ma.GetDisconnectors([Lithnet.Miiserver.Client.ConnectorState]::Normal))
        if ($disconnectors.Count -gt 0) {
            $disconnectors.Where({$_.IsPlaceholderLink -eq $true}) | % {
                $csObj = [PSObject]$_
                $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName}
                $results.($maName)."PlaceholderDisconnectors".Add($_.DN, [PSObject]$csHT)
            }
        }#>
        @($ma.GetDisconnectors([Lithnet.Miiserver.Client.ConnectorState]::Normal)) | % {
            $_.Where({$_.IsPlaceholderLink -eq $true}) | % {
                $csObj = [PSObject]$_
                $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName}
                $results.($maName)."PlaceholderDisconnectors".Add($_.DN, [PSObject]$csHT)
            }
        }
        if ($results.($maName)."PlaceholderDisconnectors".Count -gt 0) {
            # if there are disconnectors, find their parents ...
            <#$connectors = @($ma.GetConnectors())
            if ($connectors.Count -gt 0) {
                $connectors.Where({$_.IsPlaceholderParent -eq $true}) | % {
                    $csObj = [PSObject]$_
                    $csImp = ([xml]$csObj.GetOuterXml()).'cs-object'.'pending-import-hologram'
                    $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName;"cs-object"=$csImp}
                    $results.($maName)."PlaceholderParents".Add($_.DN, [PSObject]$csHT)
                }
            }#>
            @($ma.GetConnectors()) | % {
                $_.Where({$_.IsPlaceholderParent -eq $true}) | % {
                    $csObj = [PSObject]$_
                    $csImp = ([xml]$csObj.GetOuterXml()).'cs-object'.'pending-import-hologram'
                    $csHT = @{"DN"=$csObj.DN;"MaName"=$csObj.MaName;"cs-object"=$csImp}
                    $results.($maName)."PlaceholderParents".Add($_.DN, [PSObject]$csHT)
                }
            }
        }
    }
    Write-Host ([string]::Format($trace, 
        ($results.($maName).ImportErrors.Count), 
        ($results.($maName).ExportErrors.Count), 
        ($results.($maName).FilteredDisconnectors.Count), 
        ($results.($maName).ExplicitDisconnectors.Count), 
        ($results.($maName).PlaceholderDisconnectors.Count), 
        ($results.($maName).PlaceholderParents.Count)
    ))
}
Write-Host "[$(Get-Date)]: Analysing MIM Sync Errors complete!"

if ([System.IO.File]::Exists($resultsFile)) {
    [System.IO.File]::Delete($resultsFile)
}
($results | ConvertTo-Xml -Depth $depth).Save($resultsFile)
#($results | ConvertTo-Json).Save($resultsFile)
$results = @{}

Write-Host "[$(Get-Date)]: MIM XML saved to [$resultsFile]"

<#

PS D:\Scripts> .\Get-AllSyncErrors.ps1 -explicitDisconnectors -placeholderDisconnectors -filteredDisconnectors -getMVData
[04/05/2021 09:07:33]: Analysing MIM MV Integrity ...
[04/05/2021 09:07:33]: Processing MV Object [group] ...
[04/05/2021 09:09:57]: Processing MV Object [person] ...
[04/05/2021 09:18:07]: Processing MV Object [contact] ...
[04/05/2021 09:18:09]: Analysing MIM Sync Errors ... all MAs ...
[04/05/2021 09:18:10]: Processing MA [CSODBB LDS] ...
[04/05/2021 09:18:10]: MA [CSODBB LDS] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [0], Explicit Disconnectors: [0]
[04/05/2021 09:18:10]: Processing MA [Staff] ...
[04/05/2021 09:18:10]: MA [Staff] : Import Errors: [1], Export Errors: [0], Filtered Disconnectors: [22], Explicit Disconnectors: [0]
[04/05/2021 09:39:03]: Processing MA [FIM Portal] ...
[04/05/2021 09:39:03]: MA [FIM Portal] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [3], Explicit Disconnectors: [0]
[04/05/2021 12:34:34]: Processing MA [PHRIS] ...
[04/05/2021 12:34:34]: MA [PHRIS] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [0], Explicit Disconnectors: [0]
[04/05/2021 12:34:38]: Processing MA [Contacts] ...
[04/05/2021 12:34:38]: MA [Contacts] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [3566], Explicit Disconnectors: [0]
[04/05/2021 14:33:29]: Processing MA [Replay FIM Portal] ...
[04/05/2021 14:33:29]: MA [Replay FIM Portal] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [0], Explicit Disconnectors: [0]
[04/05/2021 14:47:41]: Processing MA [Users and Groups] ...
[04/05/2021 14:47:41]: MA [Users and Groups] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [0], Explicit Disconnectors: [0]
[04/05/2021 15:16:36]: Processing MA [SAS2IDM] ...
[04/05/2021 15:16:36]: MA [SAS2IDM] : Import Errors: [0], Export Errors: [0], Filtered Disconnectors: [0], Explicit Disconnectors: [0]
[04/05/2021 15:16:37]: Analysing MIM Sync Errors complete!
Exception calling "Save" with "1" argument(s): "There is not enough space on the disk.
"
At D:\Scripts\Get-AllSyncErrors.ps1:150 char:1
+ ($results | ConvertTo-Xml -Depth $depth).Save($resultsFile)
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : DotNetMethodException
 
[04/05/2021 15:20:10]: MIM XML saved to [C:\Logs\MIMErrors.xml]


#>