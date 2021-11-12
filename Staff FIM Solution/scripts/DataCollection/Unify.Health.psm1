<#
Unify.Health.psm1 ,v2.4,  written by UNIFY Solutions 2016

Contains functions used by Run-HealthCheck.ps1.

#>

Function Get-HealthModuleVersion
{
    $ScriptVersions.Add("Unify.Health.psm1","2.3.6")
}

#region Logging

Function Write-Log
{ 
<#
.SYNPOSIS
    Writes Message to Debug Log File and/or Console based on Global parameters $SilentMode and $DebugMode
.OUTPUT
    Message written to Debug log file and/or stdout
.PARAMETERS
    Message: The message to log.
    ErrorLevel: The severity (Information, Warning, Error, Fatal). Fatal will terminate all script execution.
    Console: Write the message to the console as well, unless SilentMode is enabled.
             Do not use this switch inside functions that return a value.
DEPENDENCIES
    DebugLogFile Global parameter
.ChangeLog
    Carol Wapshere, 8/9/2016, Re-write.
#>
    PARAM(
        [string] $Message,
        [ValidateSet("Information","Warning","Error","Fatal")] [string] $ErrorLevel,
        [switch] $Console
        )
    END
    {
        if ($DebugMode -and $DebugLogFile) 
        {
            $LogTimestamp = Get-CurrentDateTime -UTC
            $LogEntry = $LogTimestamp + "`t" + $ErrorLevel.ToUpper() + "`t" + $Message
            Add-ContentToFile -FilePath $DebugLogFile -ContentToAdd $LogEntry
        }

        if ($Console.IsPresent -and -not $SilentMode)
        {
            switch ($ErrorLevel)
            {
                "Information" {$Colour = "Green"}
                "Warning" {$Colour = "Yellow"}
                "Error" {$Colour = "Red"}
                "Fatal" {$Colour = "Red"}
            }
            Write-Host $Message -ForegroundColor $Colour
        }

        if ($ErrorLevel -eq "Fatal")
        {
            exit
        }
    }
}

#endregion Logging

#region FileSystem

Function Get-DataFolder 
{
<#
.SYNPOSIS
    Gets the Data folder to use when storing extracted JSON data files. Creates folder if it does not exist.
.OUTPUT
    Full path of timestamped Data folder
.PARAMETERS
    Parameters hashtable
    timestamp: The timestamp string to use for the folder name
.DEPENDENCIES
    DataDir parameter
.ChangeLog
    Carol Wapshere, 8/9/2016, Re-write.
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$timestamp
        )
    END
    {
        Write-Log -ErrorLevel Information  -Message  "Get-DataFolder,starting"

        if (-not $Parameters -or -not $Parameters.General_DataFolder)
        {
            Write-Log -ErrorLevel Fatal  -Message "Get-DataFolder,Did not get a value for DataDir"
        }

        ## Check if Data folder needs to be created
        if (-not (Test-Path $Parameters.General_DataFolder))
        {
            Try
            {
                New-Item -Path $Parameters.General_DataFolder -ItemType Directory | Out-Null
                Write-Log -ErrorLevel Information  -Message  "Get-DataFolder,Folder Created $DataDir."
            }
            Catch
            {
				Write-Log -ErrorLevel Fatal  -Message ("Get-DataFolder,Failed to create folder $DataDir. " + $_.Exception.Message)
            }
        }

        ## Check if Upload folder needs to be created
        if (-not (Test-Path ($Parameters.General_DataUpload))) {New-Item -Path $Parameters.General_DataFolder -ItemType Directory | Out-Null}
        if (-not (Test-Path ($Parameters.General_DataUpload + "\JSON"))) {New-Item -Path ($Parameters.General_DataUpload + "\JSON") -ItemType Directory | Out-Null}
        if (-not (Test-Path ($Parameters.General_DataUpload + "\ANY"))) {New-Item -Path ($Parameters.General_DataUpload + "\ANY") -ItemType Directory | Out-Null}


        ## Create a timestamped folder for this data collection run
		$ThisDataDir = $Parameters.General_DataFolder + "\" + $timestamp
		if (-not (Test-Path $ThisDataDir))
        {
            Try
            {
                New-Item -Path $ThisDataDir -ItemType Directory | Out-Null
                Write-Log -ErrorLevel Information  -Message  "Get-DataFolder,Data Folder Created $ThisDataDir."
            }
            Catch
            {
				Write-Log -ErrorLevel Fatal  -Message ("Get-DataFolder,Failed to create folder $ThisDataDir. " + $_.Exception.Message)
            }
        }

        Return $ThisDataDir
    }
}

Function Add-ContentToFile
{
<#
.SYNPOSIS
    Adds text content to the specified file in UTF8 format.
.OUTPUT
    Updated file.
.PARAMETERS
    FilePath: The full path of the file
    ContentToAdd: The content to add to the file
.ChangeLog
    Carol Wapshere, 8/9/2016, Re-write.
#>
    PARAM (
        [Parameter(Mandatory=$true)][string]$FilePath,
        $ContentToAdd
        )
    END
    {
        ## Removed - causes a logging loop. Write-Log -ErrorLevel Information -Message "Add-ContentToFile, Updating $FilePath"

        if (!(Test-Path $FilePath))
        {
            New-Item -ItemType File -Path $FilePath | Out-Null
            Write-Log -ErrorLevel Information -Message "Add-ContentToFile, Created $FilePath"
        }
        Add-Content -Path $Filepath -Encoding UTF8 -Value $ContentToAdd
    }
}

Function New-ZipFolder
{
<#
.SYNPOSIS
    Creates a zip file with the contents of a folder
.OUTPUT
    The zip file
.PARAMETERS
    SourceFolder: The full path to the folder to be zipped
    ZipFile: The full path to the zip file to be created
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
    Carol Wapshere, 20/9/2016, Remove logging as the log file will now be included in the Zip.
#>
    PARAM (
            [Parameter(Mandatory=$true)][string]$SourceFolder,
            [Parameter(Mandatory=$true)][string]$ZipFile
            )
    END
    {
        Write-Log -ErrorLevel Information -Message "New-ZipFolder,Starting"

        if (Test-Path $SourceFolder)
        {
            Write-Log -ErrorLevel Information -Message "New-ZipFolder,Source folder found $SourceFolder"

            $SaveFolder = split-path -Path $ZipFile -Parent
            if (-not (Test-Path $SaveFolder))
            {
                Write-Log -ErrorLevel Information -Message "New-ZipFolder,Creating folder $SaveFolder"
                New-Item -Path $SaveFolder -ItemType Directory
            }
        
            Write-Log -ErrorLevel Information -Message "New-ZipFolder,Zipping to file $ZipFile"          
            Add-Type -assembly "system.io.compression.filesystem" 
            [io.compression.zipfile]::CreateFromDirectory($SourceFolder, $ZipFile)

            if (Test-Path $ZipFile) {Write-Log -ErrorLevel Information -Message "New-ZipFolder,Folder $SourceFolder compressed successfully"}
            else {Write-Log -ErrorLevel Information -Error "New-ZipFolder,Zip file not created"}
        } 
    }  
}

#endregion FileSystem

#region Utility

Function Invoke-SQLQuery
{
<#
.SYNPOSIS
    Connects to a SQL Database and runs a SQL Query
.OUTPUT
    An array of PSObjects, one for each row returned by the query
.PARAMETERS
    Server: The name of the SQL server
    Instance: The SQL Server Instance
    Database: The name of the Database
    ConnectionTimeout: Timeout in seconds (TODO - make this a custom parameter)
    Query: The query to run
.DEPENDENCIES
    The account running the script must have access to the DB.
.ChangeLog
    Carol Wapshere, 10/9/2016, Adapted from http://powershell4sql.codeplex.com
    Carol Wapshere, 20/9/2016, Removed support for custom creds - connection must be integrated.
                               Merged with New-SqlConnection function, so this function also handled the connection.
#>
	PARAM (
        [Parameter(Mandatory=$true)][string] $Server, 
        [Parameter(Mandatory=$true)][string] $Database, 
        [string] $Instance,
        [int] $ConnectionTimeout = 60,
		[Parameter(Mandatory=$true)] [String]$Query
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Invoke-SQLQuery,starting"

        ## Construct connection string
        if ($Instance -and $Instance -ne "" -and $Instance -ne "DEFAULT")
        {
            $SQLServer = $Server + "\" + $Instance
        }
        else
        {
            $SQLServer = $Server
        }
        $cs = "Data Source=$SQLServer;Initial Catalog=$Database;Connect Timeout=$ConnectionTimeout;Integrated Security=true;"
        Write-Log -ErrorLevel Information -Message "Invoke-SQLQuery,Connection String: $cs"

        ## Open SQL connection
        Try
        {
            $SqlConnection = new-object System.Data.SqlClient.SqlConnection
            $SqlConnection.ConnectionString = $cs
            $SqlConnection.Open()
            Write-Log -ErrorLevel Information -Message "Invoke-SQLQuery,Connection opened"
        }
        Catch
        {
            Write-Log -ErrorLevel Error -Console -Message ("Invoke-SQLQuery,Failed to connect to SQL Database $Database. " + $_.Exception.Message)
        }

        ## Run the query
        #Write-Log -ErrorLevel Information -Message ("Invoke-SQLQuery,Running query:`n" + $Query)
        Try
        {
	        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	        $SqlCmd.CommandText = $Query
	        $SqlCmd.Connection = $SqlConnection
	        $reader = $SqlCmd.ExecuteReader()
            Write-Log -ErrorLevel Information -Message "Invoke-SQLQuery,query complete, reading data"
        }
        Catch
        {
            Write-Log -ErrorLevel Error -Message ("Invoke-SQLQuery,Failed to run SQL query. " + $_.Exception.Message)
        }


        ## Read the query response into a data array
		#$data = @()
		$data = New-Object System.Collections.ArrayList
        if ($reader.HasRows)
        {
            do {
                $recordsetIndex++;
                [int] $rec = 0;

                while ($reader.Read()) {
                    $rec++;
                    $record = New-object PSObject

                    for ($i = 0; $i -lt $reader.FieldCount; $i++)
                    {
                        $name = $reader.GetName($i);
                        if ([string]::IsNullOrEmpty($name))
                        {
                            $name = "Column#" + $i.ToString();
                        }
                            
                        $val = $reader.GetValue($i);
                            
                        Add-Member -MemberType NoteProperty -InputObject $record -Name $name -Value $val 
                    }
                        
                    if ($IncludeRecordSetIndex)
                    {
                        Add-Member -MemberType NoteProperty -InputObject $record -Name "RecordSetIndex" -Value $recordsetIndex
                    }

                    #$data += $record
					$data.Add($record) | Out-Null
                }                                                   
                           
            } while ($reader.NextResult())

            $reader.Close()

            if ($data) 
            {
                Write-Log -ErrorLevel Information -Message ("Invoke-SQLQuery,returning {0} rows" -f $data.count)
            }
            else
            {
                Write-Log -ErrorLevel Error -Message "Invoke-SQLQuery,Failed to parse returned data"
            }
        }
        else
        {
            Write-Log -ErrorLevel Information -Message "Invoke-SQLQuery,returned 0 rows"
        }

        ## Close the SQL connection
        $SqlConnection.Close()

        Write-Log -ErrorLevel Information -Message "Invoke-SQLQuery,Complete"
        Return $data
    }
}

Function Convert-ArrayToJson
{
<#
.SYNPOSIS
    Converts an array of PSObjects, Hashtables or Strings into JSON format
.OUTPUT
    JSON formatted string
.PARAMETERS
    UnconvertedArray:
    Compress: 
    Simple:
.ChangeLog
    
#>
    PARAM ($UnconvertedArray, [Switch] $Compress, [Switch] $Simple)
    END
    {

        if($Compress){
            if($Simple){
                $ConvertedArray = $UnconvertedArray | ConvertTo-Json -Compress
            }
            Else{
	#BOB >>
                $ConvertedArray = $UnconvertedArray | ConvertTo-Json -Compress #-Depth 999    
	#BOB <<
            }
        }
        Else{
            if($Simple){
        
                    $ConvertedArray = $UnconvertedArray | ConvertTo-Json
            }
            Else{
	#BOB >>
                $ConvertedArray = $UnconvertedArray | ConvertTo-Json #-Depth 999    
	#BOB <<
            }
        }
        return $ConvertedArray
    }
}

Function Get-CurrentDateTime
{
<#
.SYNPOSIS
    Returns the current time in the specified format
.OUTPUT
    Datetime string
.PARAMETERS
    Format: .NET format, default "s"
    UTC: If specified, returns time in UTC
.DEPENDENCIES
    
.ChangeLog
    
#>
    PARAM (
        [string]$Format = "s",
        [switch]$UTC
        )
    END
    {
        if ($UTC.IsPresent) {$dt = (Get-Date).ToUniversalTime()}
        else {$dt = Get-Date}

        return (Get-Date -Date $dt -Format $Format)
    }
}

Function Get-SavedCred
{
<#
.SYNPOSIS
    Retrieves the saved password from the file and creates a credential object.
.OUTPUT
    Credential object
.PARAMETERS
    CredFile: The file where the password is saved
    Username: The username to use with the password
.DEPENDENCIES
    The CredFile must contain a secure string and must have been saved by the account
    currently running this script.
.ChangeLog
    
#>
    PARAM (
        [Parameter(Mandatory=$true)] [string]$CredFile,
        [Parameter(Mandatory=$true)] [string]$Username
        )
    END
    {
        if  (Test-Path $CredFile) 
        {
            Write-Log -ErrorLevel Information -Message "Get-SavedCred,Attempting to retrieve from $CredFile"
            Try
            {
                $pw = Get-Content $CredFile | ConvertTo-SecureString
                $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
                Return $cred
            }
            Catch
            {
                Return 0
            }
        }
        else
        {
            Write-Log -ErrorLevel Error -Console -Message "Get-SavedCred,$CredFile not found. Please run setup process again using the -UpdateParameters switch and enter 'Y' when prompted about FIM Sync database credentials."
        }
    }
}

#endregion Utility

#region FIMSync


Function Export-FIMSyncMAs
{
<#
.SYNPOSIS
    Queries the FIM Sync database and exports Management Agent names and types.
.OUTPUT
    A single data file containing a list of MAs.
.PARAMETERS
    Parameters: Parameters hashtable
.DEPENDENCIES    
    $Parameters values: FIMSync_DB, FIMSync_DBServer, FIMSync_DBInstance
.ChangeLog
    Carol Wapshere, 21/9/2016, new function
#>
    PARAM ([Parameter(Mandatory=$true)][hashtable]$Parameters)
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-ManagementAgents,Starting"

        $CollectionTime =  Get-CurrentDateTime -UTC

        ## Query Management Agents
        $SqlQuery = @"
select [ma_id],[ma_name],[ma_type]
from [dbo].[mms_management_agent] with (NOLOCK)
"@
        Write-Log -ErrorLevel Information -Message "Export-ManagementAgents,Getting Management Agents"
        $MAs = Invoke-SQLQuery -Server $Parameters.FIMSync_DBServer -Instance $Parameters.FIMSync_DBInstance -Database $Parameters.FIMSync_DB -Query $SqlQuery


        ## Put data in reporting format
        #$arr = @()
		$arr = New-Object System.Collections.ArrayList
        if ($MAs)
        {
            Write-Log -ErrorLevel Information -Message "Export-ManagementAgents,Collating Management Agents"
            foreach ($entry in $MAs)
            {
                $ht = @{
                    '_time' = $CollectionTime
                    'HCRecordType' = "FIMSync_MAs"
                    'ma_id' = $entry.ma_id
                    'ma_name' = $entry.ma_name
                    'ma_type' = $entry.ma_type
                    } 		
			    #$arr += $ht
				$arr.Add($ht) | Out-Null
            }
        }

        Write-Log -ErrorLevel Information -Message ("Export-ManagementAgents,Saving {0} MAs" -f $arr.Count)

        $MAsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
        $FilePath = $ThisDataDir + "\" + $Parameters.FIMSync_DataFile_MAs
        Add-ContentToFile -FilePath $FilePath -ContentToAdd $MAsJSON

        Write-Log -ErrorLevel Information -Message "Export-ManagementAgents,Complete"
    }
}

Function Export-FIMRunHistory
{
<#
.SYNPOSIS
    Exports run history. Depending on RunType either exports All or runs since last export.
.OUTPUT
    Exports two JSON files:
        <prefix>_FIMSync_Runs.json with run and sub-step data
        <prefix>_FIMSync_Runs_ErrorObjects.json with details about specific identities in error
.PARAMETERS
    Parameters: The Parameters hashtable
    RunType: All or Diff
.DEPENDENCIES    
    $Parameters values: FIMSync_DB, FIMSync_DBServer, FIMSync_DBInstance    
.ChangeLog
    Carol Wapshere, 27/9/2016, Re-write to use SQL instead of WMI
    Carol Wapshere, 30/9/2016, Split data files into a seperate one for ErrorObjects to simplify reporting
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$RunType
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-FIMRunHistory,starting"

        ## Query Management Agents
        $SqlQuery = @"
SELECT rh.[run_history_id],ma.[ma_name],rh.[run_profile_name],rh.[run_result],rh.[start_date],rh.[end_date],
		sh.[step_history_id],sh.[step_number],sh.[step_result],sh.[start_date] as 'step_start_date',sh.[end_date] as 'step_end_date',
		sh.[ma_connection_information_xml],sh.[ma_discovery_errors_xml],sh.[sync_errors_xml],sh.[mv_retry_errors_xml]
from [dbo].[mms_run_history] rh with (NOLOCK)
join [dbo].[mms_management_agent] ma with (NOLOCK) on rh.[ma_id] = ma.[ma_id]
join [dbo].[mms_step_history] sh with (NOLOCK) on rh.[run_history_id] = sh.[run_history_id]
where rh.is_run_complete = 1
"@
        if ($RunType -eq 'Delta') {$SqlQuery = $SqlQuery + (" and rh.end_date > '{0}'" -f $Parameters._LastRunTime)}

        $Runs = Invoke-SQLQuery -Server $Parameters.FIMSync_DBServer -Instance $Parameters.FIMSync_DBInstance -Database $Parameters.FIMSync_DB -Query $SqlQuery        

        ## Put data in reporting format
        #$arrRuns = @()
		$arrRuns = New-Object System.Collections.ArrayList
        #$arrErrObjs = @()
		$arrErrObjs = New-Object System.Collections.ArrayList
        if ($Runs)
        {
            Write-Log -ErrorLevel Information -Message ("Export-FIMRunHistory,Exported {0} Run Steps, collating data." -f $Runs.Count)
            $htRuns = @{}
            foreach ($Run in $Runs | where {$_.step_number -eq 1})
            {
                try
                {
                    $RunDuration = $Run.end_date - $Run.start_date
                    if ($RunDuration.Days -ne 0) {$Hours = $RunDuration.Days * 24 + $RunDuration.Hours}
                    else {$Hours = $RunDuration.Hours}
                    [string]$RunDurationString = $Hours.ToString().PadLeft("0",2) + ":" + $RunDuration.Minutes.ToString().PadLeft("0",2) + ":" + $RunDuration.Seconds.ToString().PadLeft("0",2)
                } catch {[string]$RunDurationString = ""}

                $htRuns.Add($Run.run_history_id.Guid,@{
                    "_time" = $Run.start_date.ToString("s")
                    "HCRecordType" = "FIMSync_Run"
                    "MaName" = $Run.ma_name
                    "RunID" = $Run.run_history_id
                    "RunStartTime" = $Run.start_date.ToString("s")
                    "RunEndTime" = $Run.end_date.ToString("s")
                    "RunDurationSeconds" = $RunDuration.TotalSeconds
                    "RunDuration" = $RunDurationString
                    "RunStatus" = $Run.run_result
                    "RunProfile" = $Run.run_profile_name
                    "ComputerName" = $Parameters.FIMSync_Server
                    "Steps" = (New-Object System.Collections.ArrayList)
                })
            }
                    #"Steps" = @()
                    #"Steps" = (New-Object System.Collections.ArrayList) #@()

            ## Add step details
            foreach ($Run in $Runs | Where-Object {$_.run_history_id})
            {
                $htStep = @{
                    "StepNumber" = $Run."step_number"
                    "StepStartDate" = $Run."step_start_date".ToString("s")
                    "StepEndDate" = $Run."step_end_date".ToString("s")
                    "StepResult" = $Run."step_result"
                }
                
                if ($Run.ma_connection_information_xml.GetType().Name -ne "DBNull")
                {
                    [xml]$rd = ("<top>" + $Run.ma_connection_information_xml + "</top>")
                    
                    $htStep.Add("StepConnectionResult",$rd.top."connection-result")
                    $htStep.Add("StepConnectionServer",$rd.top.server)
                }
            }
            #$htRuns.($Run.run_history_id.Guid).Steps += $htStep
            $htRuns.($Run.run_history_id.Guid).Steps.Add($htStep) | Out-Null

            foreach ($id in $htRuns.Keys)
            {
                #$arrRuns += $htRuns.($id)
				$arrRuns.Add($htRuns.($id)) | Out-Null
            }

            ## Get objects in Error and put in a seperate array
            foreach ($Run in $Runs | where {$_.run_history_id} | where {$_.sync_errors_xml.GetType().Name -ne "DBNull"})
            {
                [xml]$rd = $Run.sync_errors_xml

                if ($rd."synchronization-errors"."export-error")
                {
                    foreach ($entry in $rd."synchronization-errors"."export-error")
                    {
                        if ($entry."cd-error"."error-literal") {$ErrorMessage = $entry."cd-error"."error-literal"}
                        else {$ErrorMessage = ""}
                        if ($entry."cd-error"."server-error-detail") {$ErrorDetail = $entry."cd-error"."server-error-detail"}
                        else {$ErrorDetail = ""}
                        
                        $htError = @{
                            "_time" = (Get-Date $entry."date-occurred").ToString("s")
                            "HCRecordType" = "FIMSync_Run_ErrorObject"
                            "MaName" = $Run.ma_name
                            "RunID" = $Run.run_history_id
                            "ErrorSyncType" = "export-error"
                            "ErrorDN" = $entry.dn
                            "ErrorFirstOccurred" = (Get-Date $entry."first-occurred").ToString("s")
                            "ErrorType" = $entry."error-type"
                            "ErrorMessage" = $ErrorMessage
                            "ErrorDetail" = $ErrorDetail
                        }
                        try
                        {
                            $TimeInError = (Get-Date $entry."date-occurred") - (Get-Date $entry."first-occurred")
                            $htError.Add("TimeInErrorDays",[math]::round($TimeInError.TotalDays,1))
                        } catch {}

                        #$arrErrObjs += $htError
    					$arrErrObjs.Add($htError) | Out-Null
                    }
                }
                if ($rd."synchronization-errors"."import-error")
                {
                    foreach ($entry in $rd."synchronization-errors"."import-error")
                    {
                        $htError = @{
                            "_time" = (Get-Date $entry."date-occurred").ToString("s")
                            "HCRecordType" = "FIMSync_Run_ErrorObject"
                            "MaName" = $Run.ma_name
                            "RunID" = $Run.run_history_id
                            "ErrorSyncType" = "import-error"
                            "ErrorDN" = $entry.dn
                            "ErrorFirstOccurred" = (Get-Date $entry."first-occurred").ToString("s")
                            "ErrorType" = $entry."error-type"
                            "ErrorAlgorithmStep" = $entry."algorithm-step"
                        }
                        try
                        {
                            $TimeInError = (Get-Date $entry."date-occurred") - (Get-Date $entry."first-occurred")
                            $htError.Add("TimeInErrorDays",[math]::round($TimeInError.TotalDays,1))
                        } catch {}
                        if ($entry."extension-error-info")
                        {
                            $htError.Add("ErrorExtension",$entry."extension-error-info"."extension-name")
                            $htError.Add("ErrorCallStack",$entry."extension-error-info"."call-stack")
                            $htError.Add("ErrorCallSite",$entry."extension-error-info"."extension-callsite")
                        }
                        #$arrErrObjs += $htError
    					$arrErrObjs.Add($htError) | Out-Null
                    }
                }
            } 
        }


        Write-Log -ErrorLevel Information -Message ("Export-FIMRunHistory,Saving {0} Runs" -f $arrRuns.Count)
        $RunsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arrRuns
        $FilePath = $ThisDataDir + "\" + $Parameters.FIMSync_DataFile_Runs
        Add-ContentToFile -FilePath $FilePath -ContentToAdd $RunsJSON

        Write-Log -ErrorLevel Information -Message ("Export-FIMRunHistory,Saving {0} Error Objects" -f $arrErrObjs.Count)
        $ErrObjsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arrErrObjs
        $FilePath = $ThisDataDir + "\" + $Parameters.FIMSync_DataFile_Runs.Replace(".json","_ErrorObjects.json")
        Add-ContentToFile -FilePath $FilePath -ContentToAdd $ErrObjsJSON

        Write-Log -ErrorLevel Information -Message "Export-FIMRunHistory,Complete"
    }
}

Function Export-FIMSyncObjectCounts
{
<#
.SYNPOSIS
    Queries the FIM Sync database and exports Metaverse and Connector object counts per object type.
.OUTPUT
    A single data file containing both Metaverse and CS object counts.
.PARAMETERS
    Parameters: Parameters hashtable
.DEPENDENCIES    
    $Parameters values: FIMSync_DB, FIMSync_DBServer, FIMSync_DBInstance
.ChangeLog
    Carol Wapshere, 12/9/2016, new function
    Carol Wapshere, 21/9/2016, Removed WMI count functions - the data returned from this function is better.
#>
    PARAM ([Parameter(Mandatory=$true)][hashtable]$Parameters)
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-FIMSyncObjectCounts,Starting"

        $CollectionTime =  Get-CurrentDateTime -UTC

        ## Query Metaverse object type counts
        $SqlQuery = @"
select distinct object_type, count(object_id) as count
from dbo.mms_metaverse WITH (nolock)
group by object_type
"@
        Write-Log -ErrorLevel Information -Message "Export-FIMSyncObjectCounts,Getting Metaverse object type counts"
        $MVObjectCounts = Invoke-SQLQuery -Server $Parameters.FIMSync_DBServer -Instance $Parameters.FIMSync_DBInstance -Database $Parameters.FIMSync_DB -Query $SqlQuery


        ## Query CS Object type counts
        $SQLQuery = @"
select distinct object_type, [ma_name], [is_connector], count(object_id) as count
from [dbo].[mms_connectorspace] cs WITH (nolock)
join [dbo].[mms_management_agent] ma WITH (nolock)
on cs.[ma_id] = ma.[ma_id]
where object_type is not null
group by object_type,[ma_name], [is_connector]
order by [ma_name],object_type
"@
        Write-Log -ErrorLevel Information -Message "Export-FIMSyncObjectCounts,Getting Connector Space object type counts"
        $CSObjectCounts = Invoke-SQLQuery -Server $Parameters.FIMSync_DBServer -Instance $Parameters.FIMSync_DBInstance -Database $Parameters.FIMSync_DB -Query $SqlQuery


        ## Put data in reporting format
        #$arr = @()
		$arr = New-Object System.Collections.ArrayList
        if ($MVObjectCounts)
        {
            Write-Log -ErrorLevel Information -Message "Export-FIMSyncObjectCounts,Collating Metaverse object counts"
            foreach ($entry in $MVObjectCounts)
            {
                $ht = @{
                    '_time' = $CollectionTime
                    'HCRecordType' = "FIMSync_MetaverseObjectCount"
                    'ObjectType' = $entry.object_type
                    'Count' = $entry.count
                    } 		
			    #$arr += $ht
				$arr.Add($ht) | Out-Null
            }
        }

        if ($CSObjectCounts)
        {
            Write-Log -ErrorLevel Information -Message "Export-FIMSyncObjectCounts,Collating Connector Space object counts"
            foreach ($MAName in $CSObjectCounts.ma_name | select -Unique)
            {
                foreach ($ObjectType in ($CSObjectCounts | where {$_.ma_name -eq $MAName}).object_type | select -Unique)
                {
                    $ConnectorCount = $CSObjectCounts | where {$_.ma_name -eq $MAName -and $_.object_type -eq $ObjectType -and $_.is_connector -eq 1}
                    $DisconnectorCount = $CSObjectCounts | where {$_.ma_name -eq $MAName -and $_.object_type -eq $ObjectType -and $_.is_connector -eq 0}
                    $ht = @{
                        '_time' = $CollectionTime
                        'HCRecordType' = "FIMSync_ConnectorSpaceObjectCount"
                        'MAName' = $MAName
                        'ObjectType' = $ObjectType
                        'ConnectorCount' = $ConnectorCount.count
                        'DisconnectorCount' = $DisconnectorCount.count
                        }
			        #$arr += $ht
					$arr.Add($ht) | Out-Null
                }
            }
        }

        Write-Log -ErrorLevel Information -Message ("Export-FIMSyncObjectCounts,Saving {0} records" -f $arr.Count)

        $ObjectCountsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
        $FilePath = $ThisDataDir + "\" + $Parameters.FIMSync_DataFile_ObjectCounts
        Add-ContentToFile -FilePath $FilePath -ContentToAdd $ObjectCountsJSON

        Write-Log -ErrorLevel Information -Message "Export-FIMSyncObjectCounts,Complete"
    }
}

Function Export-FIMSyncVersion
{
<#
.SYNPOSIS
    Exports FIM Sync version.
.OUTPUT
    Exports one JSON file listing FIM Sync Service version
.PARAMETERS
    Parameters: The Parameters hashtable
.DEPENDENCIES    
    FIM Sync must be installed on this server
.ChangeLog
    Carol Wapshere, 20/9/2016, added function
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-FIMSyncVersion,starting"

        $ProgramFolder = "\\" + $Parameters.FIMSync_Server + "\" + $Parameters.FIMSync_ProgramFolder.Replace(":","$")

        if (Test-Path $ProgramFolder)
        {
            $ProgramFile = Get-Item ($ProgramFolder + "\Bin\miiserver.exe")
            if ($ProgramFile)
            {
                $ht = @{
                    '_time' = Get-CurrentDateTime -UTC
                    'HCRecordType' = "FIMSync_Version"
                    'FileName' = $ProgramFile.Name
                    'FileVersion' = $ProgramFile.VersionInfo.FileVersion
                    'ProductVersion' = $ProgramFile.VersionInfo.ProductVersion
                }
                $VersionJSON = Convert-ArrayToJson -Compress -UnconvertedArray @($ht)
                $FilePath = $ThisDataDir + "\" + $Parameters.FIMSync_DataFile_Version
                Add-ContentToFile -FilePath $FilePath -ContentToAdd $VersionJSON
                Write-Log -ErrorLevel Information -Console -Message ("Export-FIMSyncVersion,Saved to file {0}" -f $FilePath)
            }
            else
            {
                Write-Log -ErrorLevel Error -Message ("Export-FIMSyncVersion,Unable to find miiserver.exe at path {0}" -f ($ProgramFolder + "\Bin\miiserver.exe"))
            }
        }
        else
        {
            Write-Log -ErrorLevel Error -Message "Export-FIMSyncVersion,Unable to find FIM Sync Program folder using path $ProgramFolder"
        }
        Write-Log -ErrorLevel Information -Message "Export-FIMSyncVersion,Complete"
    }
}

#endregion FIMSync

#region FIMService

Function Export-FIMServiceRequests
{
<#
.SYNPOSIS
    Queries the FIM Service database for completed Requests and their status.
.OUTPUT
    Data file in JSON format.
.PARAMETERS
    Parameters: Parameters hashtable
    RunType: If "Delta", only gets Requests created after _LastRunTime
.DEPENDENCIES    
    $Parameters DB values: FIMSvc_DB, FIMSvc_DBServer, FIMSvc_DBInstance
    $Parameters File vale: FIMSvc_Datafile_Requests
    User account running the script must have DB access.
.ChangeLog
    Written by Carol Wapshere, 15/9/2016
    Updated by Bob Bradley/Adrian Corston, 22/01/2018 - introduced hashtable joins for performance improvement
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters,
        [Parameter(Mandatory=$true)][string]$RunType,
        [Parameter(Mandatory=$false)][string]$BatchSize=1200
    )
    END
    {
        Write-Log -ErrorLevel Information -Message "Get-FIMServiceRequests,Starting"

        ## SQL query to return completed Requests
        $SqlQuery = @"
select	o.ObjectKey,
		o.ObjectID,
		rname.ValueString as 'DisplayName',
		rstatus.ValueString as 'RequestStatus',
		rstart.ValueDateTime as 'CreatedTime',
		rend.ValueDateTime as 'CompletedTime'
from fim.Objects o with (NOLOCK)
join [fim].[ObjectValueString] rstatus with (NOLOCK) on o.ObjectKey = rstatus.ObjectKey
join [fim].[ObjectValueString] rname with (NOLOCK) on o.ObjectKey = rname.ObjectKey
join [fim].[ObjectValueDateTime] rstart with (NOLOCK) on o.ObjectKey = rstart.ObjectKey
join [fim].[ObjectValueDateTime] rend with (NOLOCK) on o.ObjectKey = rend.ObjectKey
where o.ObjectTypeKey = 26 /* Request */
and rstatus.AttributeKey = 158 /* RequestStatus */
and rname.AttributeKey = 66 /* DisplayName */
and rstart.AttributeKey = 53 /* CreatedTime */
and rend.AttributeKey = 257 /* msidmCompletedTime */
and rstatus.ValueString in ('Completed','Failed','Denied','PostProcessingError')
"@
        if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
        {
            $SqlQuery = $SqlQuery + (" and rend.ValueDateTime > '{0}'" -f (Get-Date -Date $Parameters._LastRunTime -Format "yyyy-MM-dd HH:mm:ss"))
        }

        Write-Log -ErrorLevel Information -Message "Get-FIMServiceRequests,Querying the database for completed Requests"
        $Requests = Invoke-SQLQuery -Server $Parameters.FIMSvc_DBServer -Instance $Parameters.FIMSvc_DBInstance -Database $Parameters.FIMSvc_DB -Query $SqlQuery


        ## Get MPRs where listed
        $SqlQuery = @"
SELECT o.ObjectKey, mprname.[ValueString]
FROM fim.Objects o with (NOLOCK)
join [fim].[ObjectValueDateTime] rend with (NOLOCK) on o.ObjectKey = rend.ObjectKey
join [fim].[ObjectValueReference] AS mpr with (NOLOCK) on o.ObjectKey = mpr.ObjectKey
join [fim].[ObjectValueString] mprname with (NOLOCK) on mpr.ValueReference = mprname.ObjectKey
WHERE o.ObjectTypeKey = 26 /* Request */
and rend.AttributeKey = 257 /* msidmCompletedTime */
and mpr.AttributeKey = 118 /* ManagementPolicy */
and mprname.AttributeKey = 66 /* DisplayName */
"@
        if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
        {
            $SqlQuery = $SqlQuery + (" and rend.ValueDateTime > '{0}'" -f (Get-Date -Date $Parameters._LastRunTime -Format "yyyy-MM-dd HH:mm:ss"))
        }

        Write-Log -ErrorLevel Information -Message "Get-FIMServiceRequests,Querying the database for Request MPRs"
        $RequestMPRs = Invoke-SQLQuery -Server $Parameters.FIMSvc_DBServer -Instance $Parameters.FIMSvc_DBInstance -Database $Parameters.FIMSvc_DB -Query $SqlQuery
        # Convert array to hash table
        $RequestMPRsHash = @{}
        $RequestMPRs | ForEach-Object { 
            $key = $RequestMPRsHash.Add($_.ObjectKey, @{"ValueString" = $_.ValueString})
        }


        ## Get Request Status Detail where available
        $SqlQuery = @"
SELECT o.ObjectKey,rd.[ValueText] 
FROM fim.Objects o with (NOLOCK)
join [fim].[ObjectValueDateTime] rend with (NOLOCK) on o.ObjectKey = rend.ObjectKey
join [fim].[ObjectValueText] rd with (NOLOCK) on o.ObjectKey = rd.ObjectKey
where rd.[AttributeKey]=159 /* RequestStatusDetail */
and rend.AttributeKey = 257 /* msidmCompletedTime */
"@
        if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
        {
            $SqlQuery = $SqlQuery + (" and rend.ValueDateTime > '{0}'" -f (Get-Date -Date $Parameters._LastRunTime -Format "yyyy-MM-dd HH:mm:ss"))
        }

        Write-Log -ErrorLevel Information -Message "Get-FIMServiceRequests,Querying the database for Request Status Detail"
        $RequestDetails = Invoke-SQLQuery -Server $Parameters.FIMSvc_DBServer -Instance $Parameters.FIMSvc_DBInstance -Database $Parameters.FIMSvc_DB -Query $SqlQuery
        $RequestDetailsHash = @{}
        $RequestDetails | ForEach-Object { 
            $key = $RequestDetailsHash.Add($_.ObjectKey, @{"ValueText" = $_.ValueText})
        }


        ## Put data in reporting format
        Write-Log -ErrorLevel Information -Console -Message ("Get-FIMServiceRequests,Collating data for {0} Requests" -f $Requests.count)
        #$arr = @()
		$arr = New-Object System.Collections.ArrayList
        if ($Requests)
        {
            $FilePath = $ThisDataDir + "\" + $Parameters.FIMSvc_DataFile_Requests
            $i = 0
            foreach ($Request in $Requests | Where-Object {$_.CreatedTime})
            {
                $key = $Request.ObjectKey

                $ht = @{
                    '_time' = (Get-Date $Request.CreatedTime -Format "s")
                    'HCRecordType' = "FIMService_Request"
                    'ObjectID' = $Request.ObjectID
                    'DisplayName' = $Request.DisplayName
                    'RequestStatus' = $Request.RequestStatus
                    'CreatedTime' = $Request.CreatedTime
                    'CompletedTime' = $Request.CompletedTime
                    } 

                <#if ($RequestMPRs.ObjectKey -contains $key)
                {
                    $ht.Add('ManagementPolicyRule', @(($RequestMPRs | where {$_.ObjectKey -eq $key}).ValueString))
                }#>
                if ($RequestMPRsHash.Keys -contains $key)
                {
                    $ht.Add('ManagementPolicyRule', @(($RequestMPRsHash[$key].ValueString)))
                }


                <#if ($RequestDetails.ObjectKey -contains $key)
                {
                    $ht.Add('RequestStatusDetail', ($RequestDetails | where {$_.ObjectKey -eq $key}).ValueText)
                }#>
                if ($RequestDetailsHash.Keys -contains $key)
                {
                    $ht.Add('RequestStatusDetail', @(($RequestDetailsHash[$key].ValueText)))
                }

			    #$arr += $ht
				$arr.Add($ht) | Out-Null

                if ($arr.Count -ge $BatchSize)
                {
                    #Write-Log -ErrorLevel Information -Console -Message ("Export-FIMServiceRequests,Converting {0} Requests to JSON for file {1}" -f ($(1+$i) * $BatchSize).ToString(),$FilePath)
                    $RequestsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
                    #Write-Log -ErrorLevel Information -Console -Message ("Export-FIMServiceRequests,Adding {0} Requests JSON content to file {1}" -f ($(1+$i) * $BatchSize).ToString(),$FilePath)
                    Add-ContentToFile -FilePath $FilePath -ContentToAdd $RequestsJSON
                    $i += 1
                    Write-Log -ErrorLevel Information -Console -Message ("Export-FIMServiceRequests,Saved {0} Requests to file {1}" -f ($i * $BatchSize).ToString(),$FilePath)
                    #$arr = @()
                    $arr = New-Object System.Collections.ArrayList
                }
            }
            $RequestsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
            Add-ContentToFile -FilePath $FilePath -ContentToAdd $RequestsJSON
            Write-Log -ErrorLevel Information -Console -Message ("Export-FIMServiceRequests,Saved to {0} Requests file {0}" -f ($i * $BatchSize + $arr.count).ToString(),$FilePath)
        }
        Write-Log -ErrorLevel Information -Message "Get-FIMServiceRequests,Complete"
    }
}

Function Export-FIMServiceObjectCounts
{
<#
.SYNPOSIS
    Queries the FIM Service database for object counts per object type.
.OUTPUT
    A single JSON data file with one data node per object type.
.PARAMETERS
    Parameters: Parameters hashtable
.DEPENDENCIES    
    $Parameters values: FIMSvc_DB, FIMSvc_DBServer, FIMSvc_DBInstance
    User account running the script must have DB access.
.ChangeLog
    Written by Carol Wapshere, 15/9/2016
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters
    )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-FIMServiceObjectCounts,Starting"

        $CollectionTime = Get-CurrentDateTime -UTC

        ## SQL query to return version
        $SqlQuery = @"
select distinct ot.Name, count(o.ObjectKey) as count
from fim.Objects o WITH (nolock)
join [fim].[ObjectTypeInternal] ot WITH (nolock)
on o.ObjectTypeKey = ot.[Key]
group by ot.Name
"@

        Write-Log -ErrorLevel Information -Message "Export-FIMServiceObjectCounts,Querying the database for object type counts"
        $Counts = Invoke-SQLQuery -Server $Parameters.FIMSvc_DBServer -Instance $Parameters.FIMSvc_DBInstance -Database $Parameters.FIMSvc_DB -Query $SqlQuery

        if ($Counts)
        {
            Write-Log -ErrorLevel Information -Message "Export-FIMServiceObjectCounts,Collating data"
            #$arr = @()
            $arr = New-Object System.Collections.ArrayList
            foreach ($entry in $Counts)
            {
                $ht = @{
                    '_time' = $CollectionTime
                    'HCRecordType' = "FIMService_ObjectCount"
                    'ObjectType' = $entry.Name
                    'Count' = $entry.count
                }
                #$arr += $ht
				$arr.Add($ht) | Out-Null
            }
            $FilePath = $ThisDataDir + "\" + $Parameters.FIMSvc_DataFile_ObjectCounts
            $CountsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
            Add-ContentToFile -FilePath $FilePath -ContentToAdd $CountsJSON
            Write-Log -ErrorLevel Information -Message ("Export-FIMServiceObjectCounts,Saved object counts to {0}" -f $FilePath)
        }
        else
        {
            Write-Log -ErrorLevel Error -Message "Export-FIMServiceObjectCounts,No data returned from SQL query"
        }

        Write-Log -ErrorLevel Information -Message "Export-FIMServiceObjectCounts,Complete"
    }
}

Function Export-FIMServiceVersion
{
<#
.SYNPOSIS
    Exports FIM Service version.
.OUTPUT
    Exports one JSON file listing FIM Service version
.PARAMETERS
    Parameters: The Parameters hashtable
.DEPENDENCIES    
    Queries the FIMService database - need to have DB details in $Parameters.FIMSvc_DB*.
.ChangeLog
    Carol Wapshere, 20/9/2016, added function
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-FIMSvcVersion,starting"

        Write-Log -ErrorLevel Information -Message "Get-FIMSvcVersion,Querying the database for the FIM Service Version"
        $SqlQuery = "select [BinaryVersion] from fim.Version"
        $Version = Invoke-SQLQuery -Server $Parameters.FIMSvc_DBServer -Instance $Parameters.FIMSvc_DBInstance -Database $Parameters.FIMSvc_DB -Query $SqlQuery

        ## Write data file
        if ($Version)
        {
            $ht = @{
                '_time' = Get-CurrentDateTime -UTC
                'HCRecordType' = "FIMService_Version"
                'Version' = $Version.BinaryVersion
            }
            $VersionJSON = Convert-ArrayToJson -Compress -UnconvertedArray @($ht)
            $FilePath = $ThisDataDir + "\" + $Parameters.FIMSvc_DataFile_Version
            Add-ContentToFile -FilePath $FilePath -ContentToAdd $VersionJSON
            Write-Log -ErrorLevel Information -Console -Message ("Export-FIMSvcVersion,Saved to file {0}" -f $FilePath)
        }
        else
        {
            Write-Log -ErrorLevel Error -Message "Export-FIMSvcVersion,Failed to get a version number from the fim.Version table of the FIMService database."
        }
   }
}

#endregion FIMService

#region EventLogs

Function Export-WindowsEventLogs
{
<#
.SYNPOSIS
    Checks the Debug Log File exists and creates if not, or creates a new one and archives the old one based on size.
.OUTPUT
    The full path of the current Debug log file
.PARAMETERS
    Parameters: Parameters hashtable
    RunType: Returns logs since $Parameters._LastRunTime if "Delta" is specified
.DEPENDENCIES    
    Remote management enabled. User account running script has access to read event logs through RCP.
.ChangeLog
    Carol Wapshere, 8/9/2016, Re-write.
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$RunType
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-WindowsEventLogs,Starting"

        foreach ($ComputerName in $Parameters.EventLog_Servers)
        {
            $AvailableEventLogs = Get-EventLog -List -ComputerName $ComputerName | Select-Object "Log"
            foreach ($LogName in $Parameters.EventLog_Names)
            {                
                if ($AvailableEventLogs.Log -contains $LogName)
                {
                    Write-Log -ErrorLevel Information -Console -Message "Export-WindowsEventLogs,Exporting events from $ComputerName, $LogName log"

                    ## Construct the Get-EventLog command based on options
                    $cmd = "Get-EventLog -LogName '" + $LogName + "' -EntryType @('" + ($Parameters.EventLog_EntryTypes -join "','") + "')"
                    if ($ComputerName -ne (hostname)) {$cmd = $cmd + " -ComputerName $ComputerName"}
                    if ($Parameters.EventLog_MaxEvents -match "^[0-9]*$") {$cmd = $cmd + " -Newest " + $Parameters.EventLog_MaxEvents}
                    if ($RunType -eq 'Delta' -and $Parameters._LastRunTime -ne $null) {$cmd = $cmd + " -After " + $Parameters._LastRunTime}

                    ## Run command
                    Write-Log -ErrorLevel Information -Message "Get-WindowsEventLogs,Running $cmd"
                    Try
                    {
                        $Events = Invoke-Expression $cmd
                    }
                    Catch
                    {
                        Write-Log -ErrorLevel Error -Console -Message ("Export-WindowsEventLogs," + $_.Exception.Message)
                    }
                    
                    if ($Events)
                    {
                        Write-Log -ErrorLevel Information -Message "Export-WindowsEventLogs,Collating data"

                        ## Data file    
                        $DataFileName = $Parameters."EventLog_DataFile_Events".Replace("[Server]",$ComputerName).Replace("[EventLog]",$LogName)
                        $DataFilePath = "$ThisDataDir\$DataFileName"

                        ## Write each event to the data file
                        #$arr = @()
                        $arr = New-Object System.Collections.ArrayList
                        foreach ($event in $Events)
                        {
                            $ht = @{
                                '_time' = $event.TimeGenerated.ToUniversalTime().ToString("s")
                                'HCRecordType' = "WindowsEvent_Log"
                                'ComputerName' = $ComputerName
                                'EventLog' = $LogName
                                'EventType'= $event.EntryType.ToString()
                                'EventID' = $event.EventID
                                'EventSource' = $event.Source
                                'EventMessage' = $event.Message
                                'EventCategory' = $event.Category
                                }
                            #$arr += $ht
        					$arr.Add($ht) | Out-Null
                        }
                        $JSONEvents = Convert-ArrayToJson -Compress -UnconvertedArray $arr
                        Add-ContentToFile -FilePath $DataFilePath -ContentToAdd $JSONEvents
                    }
                    else
                    {
                        Write-Log -ErrorLevel Information -Message "Export-WindowsEventLogs,No events returned"
                    }
                }
            }
        }
        Write-Log -ErrorLevel Information -Message "Export-WindowsEventLogs,Complete"
    }
}

#endregion EventLogs

#region Infrastructure

Function Get-DiskSpace
{
<#
.SYNPOSIS
    Gets diskspace stats through a WMI query
.OUTPUT
    A PSObject with information about each local drive
.PARAMETERS
    ComputerName: The server to get disk stats for
.DEPENDENCIES    
    Remote management must be enabled
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
#>
    PARAM($ComputerName)
    END
    {
        Write-Log -ErrorLevel Information -Message "Get-DiskSpace,Getting diskspace for server $ComputerName"
       
        $DiskSpace = Get-WmiObject -Query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -computer $ComputerName | Select-Object SystemName,Caption,VolumeName,`
                            @{Name="Size-GB"; Expression={"{0:N2}" -f ($_.Size/1GB)}},`
                            @{Name="Freespace-GB"; Expression={"{0:N2}" -f ($_.Freespace/1GB)}},` 
                            @{n="PercentFreeSpace";e={"{0:P2}" -f ([long]$_.FreeSpace/[long]$_.Size)}},`
                            @{Name="_time"; Expression={Get-CurrentDateTime -UTC}},`
                            @{Name="HCRecordType"; Expression={"Infra_DiskSpace"}}

        if ($DiskSpace)
        {
            Write-Log -ErrorLevel Information -Message ("Get-DiskSpace,Found {0} local disks" -f $DiskSpace.Caption.count)
            return $DiskSpace
        }
    }
}

Function Get-Services
{
<#
.SYNPOSIS
    Gets status of all Services. NOT USED.
.OUTPUT
    An array of PSObjects with information about each Service
.PARAMETERS
    ComputerName: The server to get stats for
.DEPENDENCIES    
    Remote management must be enabled
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
    Carol Wapshere, 21/9/2016, DISABLED CALL - no real point getting this data.
#>
    PARAM ($ComputerName)
    END
    {
        Write-Log -ErrorLevel Information -Message "Get-Services,Getting service state for server $ComputerName"
       
        $Services = Get-Service -ComputerName $ComputerName | Select-Object Name, DisplayName, Status,`
                                    @{Name="Server"; Expression={$ComputerName}},`
                                    @{Name="_time"; Expression={Get-CurrentDateTime -UTC}},`
                                    @{Name="HCObjectType"; Expression={"Infra_WindowsService"}}

        Write-Log -ErrorLevel Information -Message ("Get-DiskSpace,Found {0} services" -f $Services.Name.count)
        return $Services
    }
}

Function Get-DBSize
{
<#
.SYNPOSIS
    Gets Database size stats through a SQL query
.OUTPUT
    An array of hashtables, one for the Data file and one for the Log file.
.PARAMETERS
    Parameters: The Parameters hashtable
    DB: The name of the Database
.DEPENDENCIES    
    DB server and instance specified in Parameters.
    Script currently only allows one set of credentials for all DBs to be checked as part of the Infrastructure feature.
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
#>
    PARAM ($Parameters,$DB)
    END
    {
        Write-Log -ErrorLevel Information -Message "Get-DBSize,Starting"

        $Server = $Parameters.("Infra_DBServer_" + $DB)
        $Instance = $Parameters.("Infra_DBInstance_" + $DB)

        $CollectionTime = Get-CurrentDateTime -UTC

        $SqlQuery = "SELECT DB_NAME(database_id) AS DatabaseName, Name, Physical_Name, (size*8)/1024.0 Size_MB FROM sys.master_files WHERE DB_NAME(database_id) = '$DB'"
        Write-Log -ErrorLevel Information -Message "Get-DBSize,Querying $DB for size"
        $QueryResponse = Invoke-SQLQuery -Server $Server -Instance $Instance -Database $DB -Query $SqlQuery


        if ($QueryResponse)
        {
            Write-Log -ErrorLevel Information -Message "Get-DBSize,Collating data"
            #$arr = @()
            $arr = New-Object System.Collections.ArrayList
            foreach ($row in $QueryResponse)
            {
                Write-Log -ErrorLevel Information -Message ("Get-DBSize,Returning " + $row.Name)
                $ht = @{
                    '_time'= $CollectionTime
                    'HCRecordType'="Infra_DBSize" 
                    'DatabaseName'= $DB
                    'PhysicalName'=$row.Physical_Name
                    'size'=$row.size_MB
                    }
                #$arr += $ht
				$arr.Add($ht) | Out-Null
            }
            return $arr
        }
        Write-Log -ErrorLevel Information -Message "Get-DBSize,Complete"
    }
}

Function Get-DBIndexState
{
<#
.SYNPOSIS
    Gets Database index fragmentation and other stats
.OUTPUT
    An array of PSObjects, one for each Index
.PARAMETERS
    Parameters: The Parameters hashtable
    DB: The name of the Database
.DEPENDENCIES    
    DB server and instance specified in Parameters.
    User account running the script can query the database.
.ChangeLog
    Carol Wapshere, 20/9/2016, added function
#>
    PARAM ($Parameters,$DB)
    END
    {
        Write-Log -ErrorLevel Information -Message "Get-DBIndexState,Starting"

        $Server = $Parameters.("Infra_DBServer_" + $DB)
        $Instance = $Parameters.("Infra_DBInstance_" + $DB)

        $CollectionTime = Get-CurrentDateTime -UTC

        $SqlQuery = @"
  SELECT object_name(IPS.object_id) AS [TableName], 
   SI.name AS [IndexName], 
   IPS.Index_type_desc, 
   IPS.avg_fragmentation_in_percent, 
   IPS.avg_fragment_size_in_pages, 
   IPS.avg_page_space_used_in_percent, 
   IPS.record_count, 
   IPS.ghost_record_count,
   IPS.fragment_count
FROM sys.dm_db_index_physical_stats(db_id(N'FIMService'), NULL, NULL, NULL , 'DETAILED') IPS
   JOIN sys.tables ST WITH (nolock) ON IPS.object_id = ST.object_id
   JOIN sys.indexes SI WITH (nolock) ON IPS.object_id = SI.object_id AND IPS.index_id = SI.index_id
WHERE ST.is_ms_shipped = 0
ORDER BY 1,5
"@
        Write-Log -ErrorLevel Information -Message "Get-DBIndexState,Querying $DB indexes"
        $QueryResponse = Invoke-SQLQuery -Server $Server -Instance $Instance -Database $DB -Query $SqlQuery


        if ($QueryResponse)
        {
            Write-Log -ErrorLevel Information -Message "Get-DBIndexState,Collating data"
            #$arr = @()
            $arr = New-Object System.Collections.ArrayList
            foreach ($record in $QueryResponse)
            {
                Add-Member -MemberType NoteProperty -InputObject $record -Name "_time" -Value $CollectionTime
                Add-Member -MemberType NoteProperty -InputObject $record -Name "HCRecordType" -Value "Infra_DBIndex"
                Add-Member -MemberType NoteProperty -InputObject $record -Name "DatabaseName" -Value $DB
                #$arr += $record
				$arr.Add($ht) | Out-Null
            }
        }
        Write-Log -ErrorLevel Information -Message "Get-DBIndexState,Complete"
        Return $arr
    }
}

Function Export-ServerState
{
<#
.SYNPOSIS
    Export Server health stats, including diskspace and service status
.OUTPUT
    Writes data to files specified by $Parameters.Infra_DataFile_Server
.PARAMETERS
    Parameters: Parameters hashtable
.DEPENDENCIES    
    
.ChangeLog
    Carol Wapshere, 13/9/2016
    Carol Wapshere, 20/9/2016, Disabled collecting Services until we're sure we need it
#>
    PARAM ([Parameter(Mandatory=$true)][hashtable]$Parameters)
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-ServerState,Starting"

        foreach ($Server in $Parameters.Infra_Servers)
        {
            Write-Log -ErrorLevel Information -Message "Export-ServerState,Getting stats for $Server"

            $DiskSpace = Get-DiskSpace -ComputerName $Server
            #$Services = Get-Services -ComputerName $Server

            #$arr = @()
            $arr = New-Object System.Collections.ArrayList
            if ($Diskspace) {
                #$arr += $DiskSpace
				$arr.Add($DiskSpace) | Out-Null
            }
            #if ($Services) {$arr += $Services}

            $arrJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
            $DataFile = $Parameters.Infra_DataFile_Server.Replace("[Server]",$Server)
            Add-ContentToFile -FilePath "$ThisDataDir\$DataFile" -ContentToAdd $arrJSON
            Write-Log -ErrorLevel Information -Message "Export-ServerState,Saved to $ThisDataDir\$DataFile"
        }
        Write-Log -ErrorLevel Information -Message "Export-ServerState,Complete"
    }
}

Function Export-DatabaseState
{
<#
.SYNPOSIS
    Export Database health stats
.OUTPUT
    Writes data to files specified by $Parameters.Infra_DataFile_DB
.PARAMETERS
    Parameters: Parameters hashtable
.DEPENDENCIES    
    
.ChangeLog
    Carol Wapshere, 13/9/2016
#>
    PARAM ([Parameter(Mandatory=$true)][hashtable]$Parameters)
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-DatabaseState,starting"

        foreach ($DB in $Parameters.Infra_DB_All)
        {
            Write-Log -ErrorLevel Information -Message "Export-DatabaseState,Getting stats for $DB"
            
            $DBSize = Get-DBSize -DB $DB -Parameters $Parameters
            $DBIndexes = Get-DBIndexState -DB $DB -Parameters $Parameters

            #$arr = @()
            $arr = New-Object System.Collections.ArrayList
            if ($DBSize) {
                #$arr += $DBSize
				$arr.Add($DBSize) | Out-Null
            }
            if ($DBIndexes) {
                #$arr += $DBIndexes
				$arr.Add($DBIndexes) | Out-Null
            }

            $arrJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
            $DataFile = $Parameters.Infra_DataFile_DB.Replace("[DB]",$DB)
            Add-ContentToFile -FilePath "$ThisDataDir\$DataFile" -ContentToAdd $arrJSON
            Write-Log -ErrorLevel Information -Message ("Export-DatabaseState,Saved data to file {0}" -f "$ThisDataDir\$DataFile")
        }
        Write-Log -ErrorLevel Information -Message "Export-DatabaseState,Complete"
    }
}

#endregion Infrastructure

#region IDB

Function Export-IDBVersion
{
<#
.SYNPOSIS
    Exports IDB version, and the version of any extra .dll files found in the Services folder.
.OUTPUT
    Exports one JSON file listing FIM Sync Service version
.PARAMETERS
    Parameters: The Parameters hashtable
.DEPENDENCIES    
    Must be able to access the IdB program folder through a UNC path
.ChangeLog
    Carol Wapshere, 20/9/2016, added function
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-IDBVersion,starting"

        $ProgramFolder = "\\" + $Parameters.IDB_Server + "\" + $Parameters.IDB_ProgramFolder.Replace(":","$") + "\Services"
        $files = Get-ChildItem -Path $ProgramFolder

        if ($files)
        {
            Write-Log -ErrorLevel Information -Message "Export-IDBVersion,starting"
            #$arr = @()
            $arr = New-Object System.Collections.ArrayList
            foreach ($file in $files | where {$_.Name -like "*.exe" -or $_.Name -like "*.dll"})
            {
                $ht = @{
                    '_time' = Get-CurrentDateTime -UTC
                    'HCRecordType'="IdentityBroker_Version"
                    'FileName' = $file.Name
                    'FileVersion' = $file.VersionInfo.FileVersion
                    'ProductVersion'=$file.VersionInfo.ProductVersion
                }
                #$arr += $ht
				$arr.Add($ht) | Out-Null
            }

            $VersionJSON = Convert-ArrayToJson -Compress -UnconvertedArray $arr
            $FilePath = $ThisDataDir + "\" + $Parameters.IDB_DataFile_Version
            Add-ContentToFile -FilePath $FilePath -ContentToAdd $VersionJSON
            Write-Log -ErrorLevel Information -Console -Message ("Export-IDBVersion,Saved to file {0}" -f $FilePath)
        }
        else
        {
            Write-Log -ErrorLevel Error -Message "Export-IDBVersion,Unable to find IDB program files at $ProgramFolder"
        }
        Write-Log -ErrorLevel Information -Message "Export-IDBVersion,Complete"
    }
}

Function Export-IDBLogs
{
<#
.SYNPOSIS
    Exports Identity Broker log files. If RunType is "Delta" then only logs since $Parameters._LastChangeTime are saved.
.OUTPUT
    IdB logs in JSON file foremat
.PARAMETERS
    
.DEPENDENCIES    
    
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
    Carol Wapshere, Matt Davies, 20/10/2016, Performance improvements from looping and using a streamwriter.
	Bob Bradley, 09/08/2017, Fix invalid JSON file by adding missing array punctuation
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$RunType
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-IDBLogs,Starting"

        if ($Parameters.IDB_Server -eq (hostname))
        {
            $LogFolder = $Parameters.IDB_LogFolder
        }
        else
        {
            $LogFolder = "\\" + $Parameters.IDB_Server + "\" + $Parameters.IDB_LogFolder.Replace(":","$")
        }
        Write-Log -ErrorLevel Information -Message "Export-IDBLogs,Exporting logs from $LogFolder"
       
        if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
        {
            $LogFiles = Get-ChildItem -Path $LogFolder -Filter "*.csv" | where {$_.LastWriteTime.ToUniversalTime() -ge $Parameters._LastRunTime}
            $DeltaTime = Get-Date $Parameters._LastRunTime
        }
        else
        { 
            $LogFiles = Get-ChildItem -Path $LogFolder -Filter "*.csv"
            $DeltaTime = Get-Date 0
        }
        if ($LogFiles)
        {
            $DataFile = $ThisDataDir + "\" + $Parameters.IDB_DataFile_Logs
            [System.IO.StreamWriter]$streamWriter = [System.IO.StreamWriter] $DataFile

            #BOB >>
			[bool]$isData = $false
            #BOB <<
			foreach ($file in $LogFiles)
            {
                Write-Log -ErrorLevel Information -Message ("Export-IDBLogs,Collating data from {0}" -f $file.Name)
                $CSVLogs = Import-Csv -Path $file.VersionInfo.FileName -Encoding UTF8 -Header Date,Time,System,Object,Type,Detail,Impact
                #$arr = @()
                #$arr = New-Object System.Collections.ArrayList
                foreach ($log in $CSVLogs)
                {
                    $logtime = $log.Date.Substring(0,4) + "-" + $log.Date.Substring(4,2) + "-" + $log.Date.Substring(6,2) + 'T' + $log.Time
                    if ((Get-Date $logTime) -ge $DeltaTime)
                    {
						#BOB >>
						if ($isData) {
							$streamWriter.Write(",")
						} else {
							$streamWriter.Write("[")
						}
						$isData = $true
						#BOB <<
                        $ht = @{
                            '_time' = Get-CurrentDateTime -UTC
                            'HCRecordType'="IdentityBroker_Log"
                            'Date' = $log.Date
                            'Time' = $log.Time
                            'System'=$log.System                        
                            'Object' = $log.Object
                            'Type' = $log.Type
                            'Detail'=$log.Detail                        
                            'Impact'=$log.Impact                        
                        }
                        $jsonOutput  = ConvertTo-JSON $ht
                        $streamWriter.Write($jsonOutput)
                    }
                }
            }
			#BOB >>
			if ($isData) {
				$streamWriter.Write("]")
			}
			#BOB <<
            $streamWriter.Close()
        }
        else
        {
            Write-Log -ErrorLevel Information -Message "Export-IDBLogs,No recent CSV files found in $LogFolder"
        }
        Write-Log -ErrorLevel Information -Message "Export-IDBLogs,Complete"
    }        
}

#endregion IDB

#region EB

Function Export-EBVersion
{
<#
.SYNPOSIS
    Exports EB version, based on the version of the Unify.Service.Event.exe file.
.OUTPUT
    Exports one JSON file listing Event Broker version
.PARAMETERS
    Parameters: The Parameters hashtable
.DEPENDENCIES    
    Must be able to access the EB program folder through a UNC path
.ChangeLog
    Carol Wapshere, 20/9/2016, added function
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-EBVersion,Starting"

        $ProgramFile = "\\" + $Parameters.EB_Server + "\" + $Parameters.EB_ProgramFolder.Replace(":","$") + "\Services\Unify.Service.Event.exe"
        $file = Get-ChildItem -Path $ProgramFile

        if ($file)
        {
            $ht = @{
                '_time' = Get-CurrentDateTime -UTC
                'HCRecordType'="EventBroker_Version"
                'FileName' = $file.Name
                'FileVersion' = $file.VersionInfo.FileVersion
                'ProductVersion'=$file.VersionInfo.ProductVersion
            }

            $VersionJSON = Convert-ArrayToJson -Compress -UnconvertedArray @($ht)
            $FilePath = $ThisDataDir + "\" + $Parameters.EB_DataFile_Version
            Add-ContentToFile -FilePath $FilePath -ContentToAdd $VersionJSON
            Write-Log -ErrorLevel Information -Console -Message ("Export-EBVersion,Saved to file {0}" -f $FilePath)
        }
        else
        {
            Write-Log -ErrorLevel Error -Message "Export-EBVersion,Unable to find $ProgramFile"
        }
        Write-Log -ErrorLevel Information -Message "Export-EBVersion,Complete"
    }
}

Function Export-EBLogs
{
<#
.SYNPOSIS
    Exports Event Broker log files. If RunType is "Delta" then only logs since $Parameters._LastChangeTime are saved.
.OUTPUT
    EB logs in JSON file foremat
.PARAMETERS
    
.DEPENDENCIES    
    
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$RunType
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-EBLogs,Starting"

        if ($Parameters.EB_Server -eq (hostname))
        {
            $LogFolder = $Parameters.EB_LogFolder
        }
        else
        {
            $LogFolder = "\\" + $Parameters.EB_Server + "\" + $Parameters.EB_LogFolder.Replace(":","$")
        }
        Write-Log -ErrorLevel Information -Message "Export-EBLogs,Exporting logs from $LogFolder"

        $LogFiles = Get-ChildItem -Path $LogFolder -Filter "*.csv"
        if ($LogFiles)
        {
            #$AllLogs = @()
            $AllLogs = New-Object System.Collections.ArrayList
            Write-Log -ErrorLevel Information -Message ("Export-EBLogs,Found {0} files" -f $LogFiles.count)

            foreach ($file in $LogFiles)
            {
                if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
                {
                    if ($file.LastWriteTime.ToUniversalTime() -ge $Parameters._LastRunTime)
                    {
                        $CSVLogs = Import-Csv -Path $file.VersionInfo.FileName -Encoding UTF8 -Header Date,Time,System,Object,Type,Detail,Impact `
                                        | select-object Date,Time,System,Object,Type,Detail,Impact, `
                                                        @{Name='_time';Expression={$_.Date.Substring(0,4) + "-" + $_.Date.Substring(4,2) + "-" + $_.Date.Substring(6,2) + 'T' + $_.Time}}, `
                                                        @{Name='HCRecordType';Expression={'EventBroker_Log'}}
                        #$AllLogs += $CSVLogs | where {(Get-Date $_."_time") -ge $Parameters._LastRunTime}
				        $AllLogs.Add(($CSVLogs | where {(Get-Date $_."_time") -ge $Parameters._LastRunTime})) | Out-Null
                    }
                }
                else
                {
                    $CSVLogs = Import-Csv -Path $file.VersionInfo.FileName -Encoding UTF8 -Header Date,Time,System,Object,Type,Detail,Impact `
                                    | select-object Date,Time,System,Object,Type,Detail,Impact, `
                                                    @{Name='_time';Expression={$_.Date.Substring(0,4) + "-" + $_.Date.Substring(4,2) + "-" + $_.Date.Substring(6,2) + 'T' + $_.Time}}, `
                                                    @{Name='HCRecordType';Expression={'EventBroker_Log'}}
                    #$AllLogs += $CSVLogs
					$AllLogs.Add($CSVLogs) | Out-Null
                }
            }

            $DataFile = $Parameters.EB_DataFile_Logs
            $AllLogsJSON = Convert-ArrayToJson -Compress -UnconvertedArray $AllLogs
            Add-ContentToFile -FilePath "$ThisDataDir\$DataFile" -ContentToAdd $AllLogsJSON
            Write-Log -ErrorLevel Information -Message ("Export-EBLogs,Saved data to {0}" -f $DataFile)
        }
        else
        {
            Write-Log -ErrorLevel Information -Message "Export-EBLogs,No CSV files found in $LogFolder"
        }
        Write-Log -ErrorLevel Information -Message "Export-EBLogs,Complete"
    }        
}
#endregion EB
  
#region SplunkUpload

Function Test-AzCopyIsInstalled 
{
<#
.SYNPOSIS
    Queries installed products through WMI looking for "Microsoft Azure Storage Tools*"
.OUTPUT
    Boolean value indicating if the product was found
.PARAMETERS
    
.DEPENDENCIES    
    
.ChangeLog
    Carol Wapshere, 13/9/2016, Re-write.
#>
    PARAM ()
    END
    {
        [boolean] $found = $false

        $AzCopyInstalledWmi = Get-WmiObject -Class Win32_Product | sort-object Name | select Name | where {$_.Name -like "Microsoft Azure Storage Tools*"}

        If ($AzCopyInstalledWmi){ $found = $true }
    
        return $found
    }
}

Function Copy-FolderToAzure
{
<#
.SYNPOSIS
    Uses AzCopy to upload the contents of a folder to Azure storage.
    Only new or updated files are uploaded.
.OUTPUT
    
.PARAMETERS
    Parameters: Parameters hashtable
    SoureFolder: Full path to the local folder containing files to upload
    DestFolder: The name only of the destination folder, if applicable. Eg., "JSON". This will be appended to the Azure URL.
    NoLog: Specify when uploading the Script Log file to suppress attempting to write to it.
.DEPENDENCIES    
    
.ChangeLog
    Carol Wapshere, 4/10/2016, Now allows spaces in the AzCopy path
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable] $Parameters,
        [Parameter(Mandatory=$true)][string] $SourceFolder,
        [string] $DestFolder
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Copy-FolderToAzure,Starting"

        $AzCopyDir = $Parameters.AlwaysUpdate_ScriptDir + "\AzCopy"
        $AzCopyProgram = $AzCopyDir + "\AzCopy.exe"
        $AzCopyLog = $AzCopyDir + "\AzCopy.log"


        if (-not (Test-Path $AzCopyProgram))
        {
            Write-Log -ErrorLevel Fatal -Console -Message "Copy-FolderToAzure,Failed to find $AzCopyProgram"
            return
        }
        if (-not (Test-Path $SourceFolder))
        {
            Write-Log -ErrorLevel Error -Message "Copy-FolderToAzure,Failed to find upload folder at $SourceFolder"
            return
        }


        ## Clean up unfinished journal files from a previous run, if they still exist
        Get-ChildItem $AzCopyDir -Filter "*.jnl" | Remove-Item

        Write-Log -ErrorLevel Information -Message "Copy-FolderToAzure,Get SAS Key"
        ## Note: a dummy username is passed to allow creation of the $Cred object so we can get access to the password. The username is not actually used in the authentication to Azure.
        $Cred = Get-SavedCred -CredFile $Parameters.Splunk_CredFile -UserName "NotRequired"

        if ($DestFolder)
        {
            $DestURL = $Parameters.Splunk_AzureStorageURL + "/" + $DestFolder
        }
        else
        {
            $DestURL = $Parameters.Splunk_AzureStorageURL
        }

        $AzCopyArgs = '/Source:"{0}" /Dest:"{1}" /DestSAS:"{2}" /V:"{3}" /Z:"{4}" /XO /S /Y' -f $SourceFolder,$DestURL,$Cred.GetNetworkCredential().Password,$AzCopyLog,$AzCopyDir
        Write-Log -ErrorLevel Information -Message ("Copy-FolderToAzure,Verbose logging enabled to {0}" -f $AzCopyLog)
            
        Write-Log -ErrorLevel Information -Message "Copy-FolderToAzure,AzCopy starting"
        Try
        {
            #$stdout = Invoke-Expression ('&"{0}" {1}' -f $AzCopyProgram, $AzCopyArgs)
            Set-Location $AzCopyDir
            $stdout = cmd.exe /c ("AzCopy.exe " + $AzCopyArgs) 2`>`&1 
            Set-Location $Parameters.AlwaysUpdate_ScriptDir

            $Response = $stdout -join " "
            if ($Response.Contains("WARNING")) {$ErrorLevel = "Warning";}
            if ($Response.Contains("ERROR")) {$ErrorLevel = "Error";}
            else {$ErrorLevel = "Information"}

            Write-Log -ErrorLevel $ErrorLevel -Console -Message ("Copy-FolderToAzure," + $Response)
        }
        Catch
        {
        $_.Exception;
            Write-Log -ErrorLevel Error -Console -Message ("Copy-FolderToAzure,Upload failed. See $AzCopyLog for details.")
        }   
    }
}
#endregion SplunkUpload



