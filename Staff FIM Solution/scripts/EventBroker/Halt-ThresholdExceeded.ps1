<#
    .SYNOPSIS
        Raises (and optionally notifies) a custom exception when speficied import or export thresholds for 'normal' FIM/MIM synchronisation are exceeded.
    .DESCRIPTION
        Written by Bob Bradley (based on a concept by Carol Wapshere)

        Use to check if any objects imported or exported exceed nominated thresholds, or in the special case of full imports if expected data is missing entirely.
        Requires a dropped audit (dsml) file if testing for specifica attribute changes, or targeted object classes in a multi-class MA.

        When using FIM Event Broker, to prevent subsequent steps running without reporting a failure, make any subsequent steps child tasks and set the actions as follows:
         - On Success: Child Step
         - On Failure: Next Step

        In cases where the MA import source is an ECMA1 management agent (e.g. IdB3 or IdB4), stopping the current run is not sufficient.
        When using FIM Event Broker, an additional step is required whereby one or more Event Broker Operation Lists need to be disabled.
        - On failure to disable the operation, the FIM Event Broker scheduler should be stopped.
        - On failure to stop the scheduler, the FIM Event Broker service should be stopped altogether.

    .EXAMPLE
        Halt-ThresholdExceeded.ps1 -MAName "SAS2IDM" -maxAdds 100 -maxUpdates 100 -isFullImport $false -SMTPServer "127.0.0.1" -OperationListsToDisableGUID "9713e644-8d6b-4313-b16f-e85c2d6cd3a5|728ad8a6-9b79-4519-9234-7db3ab941630"
    .PARAMETER MAName
        The Management agent name (mandatory)
    .PARAMETER logFile
        The name of the audit drop file for the targeted run step (optional - default "")
    .PARAMETER isFullImport
        Set to $true if testing a full import run step (optional - default $false)
    .PARAMETER maxAdds
        Threshold for adds (optional - default 1000)
    .PARAMETER maxUpdates
        Threshold for updates (optional - default 1000)
    .PARAMETER maxDeletes
        Threshold for deletes (optional - default 100)
    .PARAMETER addObjectClass
        CS Object class name (optional - default person - required only if logFile parameter is specified)
    .PARAMETER attributes
        (pipe-separated) list of CS attributes for which updates should be filtered (optional - default "")
    .PARAMETER SMTPServer
        SMTP email server if email notifications are required (optional - default "")
    .PARAMETER MsgFrom
        FROM email address where SMTPServer parameter specified (optional - default "")
    .PARAMETER MsgTo
        (pipe-separated) list of TO email addresses where SMTPServer parameter specified (optional - default "")
    .PARAMETER EventLogName
        Event log name if exceptions are to be written to a Windows Event Log (optional - default "Application")
    .PARAMETER EventLogSource
        Event source if exceptions are to be written to a Windows Event Log (optional - default "UNIFY FIM Event Broker")
    .PARAMETER EventBrokerServer
        Event Broker host server name (optional - default "127.0.0.1")
        *** Note - remote host servers will not be supported until this script no longer needs to find the Event Broker registry key locally ***
    .PARAMETER EventBrokerPort
        Event Broker host server port (optional - default "")
    .PARAMETER OperationListsToDisableGUID
        (pipe-separated) list of Event Broker operation list guids to disable (optional - default "")
    .PARAMETER ScheduledTaskName
        (pipe-separated) list of scheduled task name(s) to disable (optional - default "")
    .PARAMETER Debug
        Debug mode (default $false)
#>
PARAM(
    [string]$MAName="SAS2IDM", #"SAS2IDM","Users and Groups"
    [string]$logFile="", #"SAS2IDM.FI.xml",
    [bool]$isFullImport=$true,
    [int]$maxAdds=25,
    [int]$maxUpdates=25,
    [int]$maxDeletes=25,
    [string]$addObjectClass="person",
    [string]$attributes="",
    [string]$SMTPServer = "occcp-ex013",
    [string]$MsgFrom = "MIMPROD@dbb.org.au",
    [string]$MsgTo = "rene.pisani@dbb.org.au|support@unifysolutions.net|bob.bradley@unifysolutions.net",
    [string]$EventLogName = "Application",
    [string]$EventLogSource = "UNIFY MIM Event Broker",
    #[string]$EventBrokerServer=$env:COMPUTERNAME,
    [string]$EventBrokerServer="127.0.0.1",
    [string]$EventBrokerPort="8080",
    [string]$OperationListsToDisableGUID="",
    [string]$ScheduledTaskName="",
    [bool]$Debug=$false
)

Function Get-AuditDropFile {
    <#
    .SYNOPSIS
    Returns content from a FIM MA audit drop file as XML
    .DESCRIPTION
    Uses the global $MaData,$MAName,$logFile parameters combined with the Path value from the FIM Sync registry key to load the corresponding audit drop file.
    .EXAMPLE
    Get-AuditDropFile "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\"
    .PARAMETER Name
    The full file path for the FIM Service
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage='What is the file path for the FIM Sync Service?')]
        [string]$FIMServicePath
    )
    # Data for DELTA imports and EXPORTS is extracted from the specified audit drop file.
    # While data for full imports instead relies on the CSExport process, the audit drop file is still used to check for missing data.
    [string]$MaData = [System.IO.Path]::Combine($FIMServicePath,"MaData")
    [string]$auditDropFile = [System.IO.Path]::Combine($MaData,$MAName,$logFile)
    # Use -ReadCount 0 to load the entire XML file in one step instead of (default) line by line
    [long]$readCount = 0
    if ($Debug) {$readCount = 1}
    [xml]$data = get-content $auditDropFile -ReadCount $readCount
    return ($data)
}

Function Get-CSExportFile {
    <#
    .SYNOPSIS
    Returns content from a FIM MA CS Export file as XML
    .DESCRIPTION
    Uses the global $MaData,$MAName,$logFile parameters combined with the Path value from the FIM Sync registry key to load the corresponding CS Export file.
    .EXAMPLE
    Get-CSExportFile "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\"
    .PARAMETER Name
    The full file path for the FIM Service
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage='What is the file path for the FIM Sync Service?')]
        [string]$FIMServicePath
    )
    # Data for FULL imports is extracted from a file generated from the CSEXPORT FIM utility.
    [string]$MaData = [System.IO.Path]::Combine($FIMServicePath,"MaData")
    [string]$CSExportExe = [System.IO.Path]::Combine($FIMServicePath,"Bin","csexport.exe")
    [string]$csExportDataFile = [System.IO.Path]::Combine($MaData,$MAName,"CSExport.$logFile")
    # Pending imports / include all tower deltas
    $commandArgs = @('/f:m','/o:bd')
    try {
        # Check for existence of csexport.xml. If found delete it.
        if ([System.IO.File]::Exists($csExportDataFile)) {
            [System.IO.File]::Delete($csExportDataFile) | Out-Null
        }
        & $CSExportExe $MAName $csExportDataFile $commandArgs | Out-Null
    } catch {
        throw "Unable to locate CSExport.exe!"
    }
    # Use -ReadCount 0 to load the entire XML file in one step instead of (default) line by line
    [long]$readCount = 0
    if ($Debug) {$readCount = 1}
    [xml]$data = get-content $csExportDataFile -ReadCount $readCount
    return ($data)
}

Function Read-DropFile {
    <#
    .SYNOPSIS
    Update supplied $Counters hashtable with audit file data
    .DESCRIPTION
    Update supplied $Counters hashtable with values from the supplied FIM Run Profile audit drop file
    .EXAMPLE
    Read-DropFile $Counters $directoryEntries $true
    .PARAMETER Counters
    Hashtable containing counters that are to be set
    .PARAMETER data
    FIM Run Profile audit dropfile xml data
    .PARAMETER typedAddsOnly
    Boolean to indicate if only the typedAdds counter is to be updated (default false)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
          Position=0,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        $Counters,
        [Parameter(Mandatory=$true,
          Position=1,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        [xml]$data,
        [Parameter(Mandatory=$false,
          Position=2,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        [bool]$typedAddsOnly=$false
    )
    # for ADDs only we can qualify the changes by object type - but for deletes and mods this is not possible
    $deltas = $data.SelectNodes("//a:delta",$ns)
    if ($deltas) {
        [long]$attrCount = 0
        [long]$refCount = 0
        $personDeltas = $deltas.Where({$_."primary-objectclass" -eq $addObjectClass})
        # Update typed counter
        $Counters.TypedAdds = $personDeltas.Where({$_."operation" -eq "add"}).Count

        if (!$typedAddsOnly) {
            $updates = $deltas.Where({$_."operation" -eq "update"})
            if ($attributes.Length -gt 0) {
                # We only want to count changes to the specified attribute collection
                [string[]]$attributesToCheck = $attributes.Split('|')
                # Find the largest count of changes across all attributes to check
                foreach ($refName in $attributesToCheck) {
                    $newAttrCount = (($updates.Where({$_."attr"."name" -eq $refName}))).Count
                    if ($newAttrCount -and $newAttrCount -gt $attrCount) {
                        $attrCount = $newAttrCount 
                    }
                }
                # Find the largest count of changes across all reference attributes to check
                foreach ($refName in $attributesToCheck) {
                    $newRefCount = (($updates.Where({$_."dn-attr"."dn-name" -eq $refName}))).Count
                    if ($newRefCount -and $newRefCount -gt $refCount) {
                        $refCount = $newRefCount 
                    }
                }
            }
            # Update counters
            if ($refCount -gt 0 -or $attrCount -gt 0) {
                if ($refCount -gt $attrCount) {
                    $Counters.Updates = $refCount
                } else {
                    $Counters.Updates = $attrCount
                }
            }
            $Counters.Adds = $deltas.Where({$_."operation" -eq "add"}).Count
            $Counters.Deletes = $deltas.Where({$_."operation" -eq "delete"}).Count
        }
    }
}

Function Read-CSExport {
    <#
    .SYNOPSIS
    Update supplied $Counters hashtable with values from the supplied CS export
    .DESCRIPTION
    Update supplied $Counters hashtable with values from the supplied CSExport xml data
    .EXAMPLE
    Read-CSExport $Counters $csExportData
    .PARAMETER Counters
    Hashtable containing counters that are to be set
    .PARAMETER csdata
    Hashtable containing counters that are to be set
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
          Position=0,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        $Counters,
        [Parameter(Mandatory=$true,
          Position=1,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        [xml]$csdata
    )
    # From the audit drop file we can determine all add/update/delete activity
    $deltas = $csdata.SelectNodes("//cs-objects/cs-object[@object-type='$addObjectClass']/pending-import/delta")
    if ($deltas) {
        [long]$attrCount = 0
        [long]$refCount = 0
        $updates = $deltas.Where({$_."operation" -eq "update"})
        if ($attributes.Length -gt 0) {
            # We only want to count changes to the specified attribute collection
            [string[]]$attributesToCheck = $attributes.Split('|')
            # Find the largest count of changes across all attributes to check
            foreach ($refName in $attributesToCheck) {
                $newAttrCount = (($updates.Where({$_."attr"."name" -eq $refName}))).Count
                if ($newAttrCount -and $newAttrCount -gt $attrCount) {
                    $attrCount = $newAttrCount 
                }
            }
            # Find the largest count of changes across all reference attributes to check
            foreach ($refName in $attributesToCheck) {
                $newRefCount = (($updates.Where({$_."dn-attr"."dn-name" -eq $refName}))).Count
                if ($newRefCount -and $newRefCount -gt $refCount) {
                    $refCount = $newRefCount 
                }
            }
        }
        # Update counters
        if (!$isFullImport) {
            # Note - Adds cannot be determined from a CSExport file after a FULL import
            $Counters.Adds = $deltas.Where({$_."operation" -eq "add"}).Count
        }
        $Counters.Deletes = $deltas.Where({$_."operation" -eq "delete"}).Count
        # $Counters.Updates = $updates.Count
        if ($refCount -gt 0 -or $attrCount -gt 0) {
            if ($refCount -gt $attrCount) {
                $Counters.Updates = $refCount
            } else {
                $Counters.Updates = $attrCount
            }
        }
    }
}

Function Remove-InvalidFileNameChars {
    <#
    .SYNOPSIS
    Strip illegal characters from strings containing file name and path
    .DESCRIPTION
    Adapted from example in http://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames.
    Adjusted to exclude both ":" and "\" from the illegal character set
    .EXAMPLE
    Remove-InvalidFileNameChars "C:\Program Files\UNIFY Solutions\Event Broker\Services\Unify.Service.Event.exe" (e.g. the value returned from a reg key)
    .PARAMETER Name
    The string to clean.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage='What is the file name string value to be processed?')]
        [String]$Name
    )

    [string]$invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $invalidChars = $invalidChars.Replace(':','').Replace('\','')
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)

    return ($Name -replace $re)
}

Function Get-OperationListName {
    <#
    .SYNOPSIS
    Return the FIM Event Broker Operation List Name for the supplied guid
    .DESCRIPTION
    Locate and extract the name from the extensibility file using the supplied guid as the unique lookup key.
    .EXAMPLE
    Get-OperationListName -ServiceFilePath "C:\Program Files\UNIFY Solutions\Event Broker\Services\Unify.Service.Event.exe" -GuidAsString 4817898f-08d0-4796-a588-3a3c9fb8f878
    .PARAMETER ServiceFilePath
    Event Broker service full file path
    .PARAMETER GuidAsString
    Operation List GUID
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
          Position=0,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        [string]$ServiceFilePath,
        [Parameter(Mandatory=$true,
          Position=1,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true)]
        [ValidateLength(36,36)]
        [string]$GuidAsString
    )
    begin {
        [string]$FIMExtensibilityExe = Remove-InvalidFileNameChars $ServiceFilePath
        [string]$FIMExtensibilityPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($FIMExtensibilityExe),"Extensibility","Unify.Product.EventBroker.OperationEnginePlugInKey.extensibility.config.xml")
        if ([IO.File]::Exists($FIMExtensibilityPath)) {
            [xml]$Extensibility = Get-Content $FIMExtensibilityPath
        } else {
            Throw "FIM Event Broker extensibility file [$FIMExtensibilityPath] could not be located!"
        }
    }

    process {
        [string]$xPath = "//OperationList[@id='$GuidAsString']/@name"
        $operationNameAttribute = $Extensibility | Select-Xml -XPath $xPath
        return ($operationNameAttribute.ToString())
    }
} 

Function Get-ThresholdCountersFromLastRun {
    <#
    .SYNOPSIS
    Get exception text if thresholds exceeded
    .DESCRIPTION
    Determine if thresholds are exceeded by interrogating XML data from last run profile execution of corresponding MA
    Adapted from (former) FIM MVP Craig Martin's post http://www.integrationtrench.com/2010/12/in-search-of-export-not-reimported.html
    .EXAMPLE
    Get-ThresholdCountersFromLastRun
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [bool]$checkAddsOnly = $false
    )

    # Set up counters
    $Counters = @{}
    $Counters.Add("Adds",0)
    $Counters.Add("Updates",0)
    $Counters.Add("Deletes",0)
    $Counters.Add("Renames",0)
    $Counters.Add("DeleteAdds","")
    $Counters.Add("StepType","")
    $Counters.Add("ExceptionText","")

    [string]$ExceptionText = [string]::Empty
    ### Use WMI to get the Management Agent 
    $managementAgent = Get-WmiObject -Class MIIS_ManagementAgent -Namespace root/MicrosoftIdentityIntegrationServer -Filter "name='$MAName'" 

    ### Construct a filter to get the management agent's last run 
    $filter = ("RunNumber='{0}' and MAName='{1}'" -F $managementAgent.RunNumber().ReturnValue, $managementAgent.Name) 

    ### Use WMI to get the RunHistory 
    $theRun = Get-WmiObject -Class MIIS_RunHistory -Namespace root/MicrosoftIdentityIntegrationServer -Filter $filter -ErrorAction SilentlyContinue

    ### Call the RunDetails() method to get the RunHistory RunDetails XML
    if ($theRun) { 
        [xml]$runHistoryDetails = $theRun.RunDetails().ReturnValue 
        if ($runHistoryDetails -ne $null) 
        {
            $Counters.StepType = $runHistoryDetails.SelectSingleNode("//run-details/step-details/step-description/step-type/@type").Value
            [xml.XmlNodeList]$counterNodes = $runHistoryDetails.SelectNodes("//run-details/step-details/staging-counters/*")
            [string]$counterCategory = "stage"
            if ($Counters.StepType -eq "export") {
                $counterNodes = $runHistoryDetails.SelectNodes("//run-details/step-details/export-counters/*")
                $counterCategory = "export"
            }
            if ($counterNodes -and $counterNodes.Count -gt 0) {
                $Counters.Adds = [long]($counterNodes.Where({$_.Name -eq "$counterCategory-add"}))[0].InnerText
                if (!$checkAddsOnly) {
                    $Counters.Updates = [long]($counterNodes.Where({$_.Name -eq "$counterCategory-update"}))[0].InnerText
                    $Counters.Deletes = [long]($counterNodes.Where({$_.Name -eq "$counterCategory-delete"}))[0].InnerText
                    $Counters.Renames = [long]($counterNodes.Where({$_.Name -eq "$counterCategory-rename"}))[0].InnerText
                    $Counters.DeleteAdds = [long]($counterNodes.Where({$_.Name -eq "$counterCategory-delete-add"}))[0].InnerText
                }
            } else {
                $Counters.ExceptionText = "Unable to locate [staging-counters] in query [$filter] result." 
            }
        } 
        else 
        { 
            ### There have been bugs with the WMI provider for ILM/FIM 
            ### When it fails it usually returns null 
            ### But on rare occasions I've also seen it fail with out-of-memory errors (even though the box had 128GB, and over 100GB free) 
            $Counters.ExceptionText = "Unable to read Run details from WMI from query [$filter] result." 
        }
    } else {
        $Counters.ExceptionText = "Exception performing WMI query [$filter]" 
    }

    ### Test counters against each threshold
    if ($Counters.ExceptionText.Length -eq 0) {
        [string]$exceptionTemplate = "Number of [{0}] MA {1} [{2}] exceeds threshold [{3}] for {4} operation!"
        if ($maxAdds -and $maxAdds -gt 0) {
            if ($maxAdds -gt 0) {
                if ($Counters.Adds -ge $maxAdds) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "adds", $Counters.Adds, $maxAdds, $Counters.StepType)}
                elseif ($Counters.Renames -ge $maxAdds) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "renames", $Counters.Adds, $maxAdds, $Counters.StepType)}
            }
        }
        if ($maxUpdates -and $ExceptionText.Length -eq 0) {
            if ($maxUpdates -gt 0) {
                if ($Counters.Updates -ge $maxUpdates) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "updates for [$attributes] attribute(s)", $Counters.Updates, $maxUpdates, $Counters.StepType)}
            }
        }
        if ($maxDeletes -and $ExceptionText.Length -eq 0) {
            if ($maxDeletes -gt 0) {
                if ($Counters.Deletes -ge $maxDeletes) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "deletes", $Counters.Deletes, $maxDeletes, $Counters.StepType)}
                elseif ($Counters.DeleteAdds -ge $maxDeletes) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "delete-adds", $Counters.Adds, $maxAdds, $Counters.StepType)}
            }
        }

        if ($isFullImport -and $ExceptionText.Length -eq 0 -and $Counters.StepType -ne "export") {
            # Throw an exception if there is not at least ONE targetted object change (add) present, since this will cause the MASS deletion of ALL such objects from FIM
            if ($Counters.TypedAdds -eq 0) {$ExceptionText = "No imports for [$Counters.StepType] operation!"}
        }
    }
    # Append error details
    $Counters.ExceptionText = $ExceptionText

    return ($Counters)
}

Function Get-ThresholdCounters {
    <#
    .SYNOPSIS
    Get exception text if thresholds exceeded
    .DESCRIPTION
    Determine if thresholds are exceeded by interrogating XML data and construct exception message
    .EXAMPLE
    Get-ThresholdCounters "C:\Program Files\..."
    .PARAMETER FIMServicePath
    FIM Service program files full path
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$FIMServicePath
    )

    # Set up counters
    $Counters = @{}
    $Counters.Add("Adds",0)
    $Counters.Add("TypedAdds",0)
    $Counters.Add("Updates",0)
    $Counters.Add("Deletes",0)
    $Counters.Add("Deltas",0)
    $Counters.Add("StepType","")
    $Counters.Add("ExceptionText","")

    [string]$ExceptionText = [string]::Empty

    [xml]$directoryEntries = Get-AuditDropFile -FIMServicePath $FIMServicePath
    $ns = New-Object Xml.XmlNamespaceManager($directoryEntries.NameTable)
    $ns.AddNamespace( "a", $directoryEntries.DocumentElement.xmlns )

    # Examine delta data
    $Counters.StepType = $directoryEntries.mmsml."step-type"
    $deltas = $directoryEntries.SelectNodes("//a:delta",$ns)
    $Counters.Deltas = $deltas.Count
    if ($Counters.Deltas -gt 0) {
        if ($isFullImport) {
            Read-DropFile -Counters $Counters -data $directoryEntries -typedAddsOnly $true
            [xml]$csExportData = Get-CSExportFile -FIMServicePath $($FIMParams.Path)
            Read-CSExport -csdata $csExportData -Counters $Counters
        } else {
            Read-DropFile -Counters $Counters -data $directoryEntries
        }

        # Perform threshold testing
        [string]$exceptionTemplate = "Number of [{0}] MA {1} [{2}] exceeds threshold [{3}] for {4} operation!"
        if ($maxAdds) {
            if ($maxAdds -gt 0) {
                if ($Counters.Adds -ge $maxAdds) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "adds", $Counters.Adds, $maxAdds, $Counters.StepType)}
            }
        }
        if ($maxUpdates -and $ExceptionText.Length -eq 0) {
            if ($maxUpdates -gt 0) {
                if ($Counters.Updates -ge $maxUpdates) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "updates for [$attributes] attribute(s)", $Counters.Updates, $maxUpdates, $Counters.StepType)}
            }
        }
        if ($maxDeletes -and $ExceptionText.Length -eq 0) {
            if ($maxDeletes -gt 0) {
                if ($Counters.Deletes -ge $maxDeletes) {$ExceptionText = [string]::Format($exceptionTemplate, $MAName, "deletes", $Counters.Deletes, $maxDeletes, $Counters.StepType)}
            }
        }

        if ($isFullImport -and $ExceptionText.Length -eq 0 -and $Counters.StepType -ne "export") {
            # Throw an exception if there is not at least ONE targetted object change (add) present, since this will cause the MASS deletion of ALL such objects from FIM
            if ($Counters.TypedAdds -eq 0) {$ExceptionText = "No [$addObjectClass] imports for [$Counters.StepType] operation!"}
        }
    } else {
        if ($isFullImport -and $Counters.StepType -ne "export") {
            # Shouldn't ever happen, but throw an exception if there is not at least ONE targetted object change (add) present, since this will cause the MASS deletion of ALL such objects from FIM
            $ExceptionText = "No [$addObjectClass] imports for [$Counters.StepType] operation!"
        }
    }

    # Append error details
    $Counters.ExceptionText = $ExceptionText

    return ($Counters)
}

Function Get-ScheduledTask {
    <#
    .SYNOPSIS
    Returns the scheduled task matching the supplied name
    .DESCRIPTION
    Windows 2008 version of native 2012 function of the same name
    Adapted from script posted http://serverfault.com/questions/601933/how-can-i-disable-a-scheduled-task-using-powershell
    Note: Remove this function if running this script on a Win 2012 or later host platform
    .EXAMPLE
    Get-ScheduledTask "Database One Copy Alert"
    .PARAMETER TaskName
    The scheduled task name
    .PARAMETER ComputerName
    The computer name hosting the specified scheduled task
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage='Specify the scheduled task name you wish to access.')]
        [string]$TaskName,
        [Parameter(Mandatory=$false,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage='Specify the computer name hosting the specified scheduled task.')]
        [string]$ComputerName = "localhost"
    )

    $TaskScheduler = New-Object -ComObject Schedule.Service
    $TaskScheduler.Connect($ComputerName)
    $TaskRootFolder = $TaskScheduler.GetFolder('\')
    $Task = $TaskRootFolder.GetTask($TaskName)
    if(-not $?)
    {
        Write-Error "Task $TaskName not found on $ComputerName"
        return
    }
    return ($Task)
}

# Initialisation
$Error.Clear()
$ThresholdCounters = @{}
[string]$ExceptionText = [string]::Empty
[string]$FIMSynchronizationServiceRegKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\FIMSynchronizationService\Parameters"
[string]$FIMEventBrokerServiceRegKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Unify.Service.Event"

# Read FIM context from registry
$FIMParams = Get-ItemProperty -Path $FIMSynchronizationServiceRegKey -ErrorAction SilentlyContinue
if (!$FIMParams) {
    $ExceptionText = "FIM Synchronization Service is not installed on this server!  (This script can only be run locally)"
    $ExceptionText += [Environment]::NewLine + [Environment]::NewLine
    $ExceptionText += $Error[0].Exception
} else {
    ## Check mandatory parameters
    if (!($MAName)) {
        $ExceptionText = "MAName parameter not supplied!"
    } elseif ($MAName.Length.Equals(0)) {
        $ExceptionText = "MAName parameter not supplied!"
    }
}

if ($ExceptionText.Length -eq 0) {
    if ($OperationListsToDisableGUID.Length -gt 0) {
        # Read FIM Event Broker context from registry
        $FIMEventBrokerParams = Get-ItemProperty -Path $FIMEventBrokerServiceRegKey -ErrorAction SilentlyContinue
        if (!$FIMEventBrokerParams) {
            $ExceptionText = "FIM Event Broker Service is not installed on this server!"
            $ExceptionText += [Environment]::NewLine + [Environment]::NewLine
            $ExceptionText += $Error[0].Exception
        }
    }
}

if ($ExceptionText.Length -eq 0) {
    if ($logFile -and $logFile.Length -gt 0) {
        $ThresholdCounters = Get-ThresholdCounters -FIMServicePath $($FIMParams.Path) 
        $ExceptionText = $ThresholdCounters.ExceptionText
        if ($ThresholdCounters.ExceptionText.Length -eq 0 -and $ThresholdCounters.Adds -eq 0 -and $ThresholdCounters.StepType -eq "full-import") {
            # Use QMI to check adds only
            $ThresholdCounters = Get-ThresholdCountersFromLastRun -checkAddsOnly $true
            $ExceptionText = $ThresholdCounters.ExceptionText
        }
    } else {
        $ThresholdCounters = Get-ThresholdCountersFromLastRun
        $ExceptionText = $ThresholdCounters.ExceptionText
    }
}

[string]$MsgBody = [string]::Empty
if ($Debug) {
    $ThresholdCounters
}
if ($ExceptionText.Length -gt 0) {
    $MsgBody = "FIM Safety Catch Triggered!"
    $MsgBody += [Environment]::NewLine + [Environment]::NewLine
    $MsgBody += "A [$($ThresholdCounters.StepType)] run profile has been aborted on server [$($env:COMPUTERNAME)] due to one or more threshold counters falling outside normal BAU range. "
    $MsgBody += [Environment]::NewLine + "While this does not necessarily mean that the changes are undesirable, manual checks are required before proceeding."
    $MsgBody += [Environment]::NewLine + "The text below indicates details of the specific threshold check being triggered."
    $MsgBody += [Environment]::NewLine + [Environment]::NewLine
    $MsgBody += $ExceptionText
    if ($OperationListsToDisableGUID.Length -gt 0) {
        # Disable Operation List(s)
        $MsgBody += [Environment]::NewLine + [Environment]::NewLine + "Disabling Event Broker operation lists ..."
        try {
            foreach ($OperationListToDisableGUID in $OperationListsToDisableGUID.Split('|')) {
                if ($EventLogName.Length -gt 0) {
                    [string]$opName = Get-OperationListName -ServiceFilePath $($FIMEventBrokerParams.ImagePath) -GuidAsString $OperationListToDisableGUID
                    Write-EventLog -EntryType Information -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message "Disabling Event Broker operation list [$opName] ..."
                }
                [string]$OpListToDisableURI = "http://$($EventBrokerServer):$($EventBrokerPort)/Operation/DisableOperationList/$($OperationListToDisableGUID)"
                $EventBrokerResponse = Invoke-WebRequest -Uri $OpListToDisableURI -Method Post -UseDefaultCredentials -UseBasicParsing
                $MsgBody += [Environment]::NewLine + "Event Broker operation list [$opName] disabled successfully!"
            }
        } catch {
            # Stop Event Broker Scheduler
            $MsgBody += [Environment]::NewLine + [Environment]::NewLine + "Error disabling operation list(s) [$OperationListsToDisableGUID] - disabling Event Broker Scheduler ..."
            [string]$DisableSchedulerURI = "http://$($EventBrokerServer):$($EventBrokerPort)/Home/DisableScheduler"
            try {
                $EventBrokerResponse = Invoke-WebRequest -Uri $DisableSchedulerURI -Method Post -UseDefaultCredentials -UseBasicParsing
                $MsgBody += [Environment]::NewLine + "Event Broker Scheduler stopped successfully!"
            } catch {
                # Stop Event Broker Service entirely!
                $MsgBody += [Environment]::NewLine + "Error disabling Event Broker Scheduler - stopping EvB Service ..."
                $MsgBody += [Environment]::NewLine + $Error[0].ErrorDetails
                if ($EventLogName.Length -gt 0) {
                    Write-EventLog -EntryType Error -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message $($Error[0].ErrorDetails)
                }
                Net Stop Unify.Service.Event
                #throw
                if ($EventLogName.Length -gt 0) {
                    Write-EventLog -EntryType Information -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message "Event Broker service stopped successfully!"
                }
            }
        }
    }
    if ($ScheduledTaskName.Length -gt 0) {
        # Disable Scheduled Task(s)
        $MsgBody += [Environment]::NewLine + [Environment]::NewLine + "Disabling scheduled tasks ..."
        try {
            foreach ($taskName in $ScheduledTaskName.Split('|')) {
                $taskToDisable = Get-ScheduledTask -TaskName $taskName
                if ($taskToDisable) {
                    if ($EventLogName.Length -gt 0) {
                        Write-EventLog -EntryType Information -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message "Stopping and disabling Scheduled Task [$taskName] ..."
                    }
                    $taskToDisable.Stop(0)
                    $taskToDisable.Enabled = $false
                    $MsgBody += [Environment]::NewLine + "Scheduled Task [$taskName] stopped and disabled successfully!"
                } else {
                    if ($EventLogName.Length -gt 0) {
                        Write-EventLog -EntryType Error -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message "Unable to locate and stop/disable Scheduled Task [$taskName]."
                    }
                }
            }
        } catch {
            # Failed to disable scheduled task(s)!
            $MsgBody += [Environment]::NewLine + "Unable to stop/disable one or more Scheduled Task(s) [$ScheduledTaskName]."
            $MsgBody += [Environment]::NewLine + $Error[0].ErrorDetails
            if ($EventLogName.Length -gt 0) {
                Write-EventLog -EntryType Error -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message $($Error[0].ErrorDetails)
            }
        }
    }
    if ($EventLogName.Length -gt 0) {
        Write-EventLog -EntryType Error -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message $MsgBody
    }
    if ($SMTPServer.Length -gt 0) {
        $Error.Clear()
        ## Check mandatory parameters
        if (!($MsgTo) -or !($MsgFrom)) {
            Write-EventLog -EntryType Warning -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message "No mail recipient/sender specified - unable to send FIM Safety Catch notification - continuing ..."
        } elseif ($MsgTo.Length.Equals(0) -or $MsgFrom.Length.Equals(0)) {
            Write-EventLog -EntryType Warning -Source $EventLogSource -LogName $EventLogName -EventId 0 -Message "No mail recipient/sender specified - unable to send FIM Safety Catch notification - continuing ..."
        } else {
            # Send email to nominated recipients
            Send-MailMessage -SmtpServer $SMTPServer -Body $MsgBody -From $MsgFrom -To $($MsgTo.Split('|')) -Subject "FIM Safety Catch" #-Credential $userCredential
        }
    }
    throw [System.Exception] $MsgBody
}


