<#
.SYNOPSIS
    Run-HealthCheck.ps1, v2.4, written by UNIFY Solutions 2016
.DESCRIPTION
    This script may either run be interactively, to ask for parameter values to be specified,
    or on a schedule, to collect health chack data.
.PARAMETERS

    Behaviour parameters:
        RunType:          All|Delta. When "Delta" it extracts data generated after $Parameters._LastRunTime
        UpdateParameters: Interactive mode - cannot be used with otehr switches. Set or confirm saved parameter values.
        Silent:           Use when running scheduled - suppresses all messages to stdout.
        SplunkUpload:     Automatically upload data to Splunk

    Data Collection Type Parameters:
        FIMSync:          Export FIMSync data
        FIMService:       Export FIMService data
        IdentityBroker:   Export IdentityBroker data
        EventBroker:      Export EventBroker data
        WindowsEventLogs: Export Windows Event Log data
        Infrastructure:   Export Server and Database metrics
        Custom:           Run Export-Custom function
#>

# Parameters
param (	
    [ValidateSet("All","Delta")] [String] $RunType = "Delta",
    [Switch] $UpdateParameters,
	[Switch] $Silent,
	[Switch] $SplunkUpload,
    [Switch] $WindowsEventLogs,
    [Switch] $FIMSync,
	[Switch] $FIMService,
	[Switch] $Infrastructure,
	[Switch] $IdentityBroker,
	[Switch] $EventBroker,
    [Switch] $Custom
)

$Global:ScriptVersions = @{"Run-HealthCheck.ps1" = "2.3.3"}

$PSBoundParameters = 1
#region CheckCmdLine

if ($PSVersionTable.PSVersion.Major -lt 3) {Throw "PowerShell version 3 or higher is needed to run this script.";exit}

[boolean]$Global:DataExtractMode = $false
[boolean]$Global:UpdateParametersMode = $false
if ($PSBoundParameters.count -eq 0)
{
    write-error "This script must be run with parameters, either -UpdateParameters or the list of feature options to run."
    return
    ##TODO: turn this into a proper usage statement
}
elseif ($UpdateParameters.IsPresent)
{
    write-host "-UpdateParameters specified. The script will run in interactive mode allowing saved parameters to be updated, and will not extract health check data."
    $UpdateParametersMode = $true
}
else
{
    ## Check if any data extract switches were specified.
    foreach ($param in $MyInvocation.MyCommand.Parameters.Keys)
    {
        if ($param -notin @("UpdateParameters","Silent","Debug","RunType"))
        {        
            if ((Get-Variable -Name $param).Value -eq $true) {$DataExtractMode = $true}
        }
    }
}
if (-not $DataExtractMode -and -not $UpdateParametersMode) 
{
    write-error "This script must be run with parameters, either -UpdateParameters or the list of feature options to run."
    return
    ##TODO: turn this into a proper usage statement
}

#endregion CheckCmdLine

#region Initialise

[boolean] $Global:SilentMode = $Silent.IsPresent
[boolean] $Global:DebugMode = $true
[string] $Global:timestamp = Get-Date -Format "dd-MM-yyyy-HH-mm"

## Get current Script Path
if ($myInvocation.MyCommand.Path -ne $null) {$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Path)}
else {$ScriptDir = (Get-Item -Path ".\" -Verbose).FullName}

## Create Script log file
[string]$Global:DebugLogFile = $ScriptDir + "\Run-HealthCheck.log"
((Get-Date).ToUniversalTime().ToString("s")) + "`tINFORMATION`t" + "Run-HealthCheck.ps1, Starting" | out-file $DebugLogFile -Encoding UTF8

## Load Functions modules
Import-Module -Name $ScriptDir\Unify.Health.psm1 -Force -ErrorAction stop
Import-Module -Name $ScriptDir\Unify.Health_Custom.psm1 -Force -ErrorAction stop

if ((Get-Module).Name -notcontains "Unify.Health")
{    
	Write-Log -ErrorLevel Fatal -Console -Message "Unify.Health module not loaded"
}
Else
{
    Write-Log -ErrorLevel Information -Console -Message "Unify.Health module loaded"
}

if ((Get-Module).Name -notcontains "Unify.Health_Custom")
{    
	Write-Log -ErrorLevel Fatal -Console -Message "Unify.Health_Custom module not loaded"
}
Else
{
    Write-Log -ErrorLevel Information -Console -Message "Unify.Health_Custom module loaded"
}

## Get Module versions
Get-HealthModuleVersion
Get-HealthModuleCustomVersion


###
### Get Parameters
###
. $ScriptDir\Get-Variables.ps1

## Check if Parameters are loaded
if ($Parameters.Count -eq 0)
{
    Write-Log -ErrorLevel Fatal -Console -Message "Failed to load custom Parameters"
}

###
### If -UpdateParameters was specified then we're all done.
###
if ($UpdateParametersMode)
{
    return
}

###
### Setup to do after Parameters have been loaded
###

Write-Log -ErrorLevel Information -Console -Message ($Parameters.Count.ToString() + " custom Parameters loaded")


## Data storage directory for this script run
if (-not $Parameters.General_DataFolder -or $Parameters.General_DataFolder -eq "")
{
    Write-Log -ErrorLevel Fatal -Console -Message "Cannot find a parameter value for General_DataFolder. Please run the script again with -UpdateParameters and ensure a Data Folder is specified."
}
$Global:ThisDataDir = Get-DataFolder -Parameters $Parameters -timestamp $timestamp
Write-Log -ErrorLevel Information -Console -Message "Data staging folder $ThisDataDir"

#endregion Initialise


 

#region DataExtract

## Create Health Script Version file
$DataFile = $Parameters.General_DataFile_Version
Write-Log -ErrorLevel Information -Message "Saving Health script version to $DataFile"
$arr = @()
foreach ($ScriptName in  $ScriptVersions.Keys)
{
    $ht = @{
            '_time' = (Get-CurrentDateTime -UTC)
            'HCRecordType' = "HealthScript_Version"
            'FileName' = $ScriptName
            'Version' = $ScriptVersions.($ScriptName)
            }
    $arr += $ht
}
$GeneralJSON = Convert-ArrayToJson -UnconvertedArray $arr
Add-ContentToFile -FilePath "$ThisDataDir\$DataFile" -ContentToAdd $GeneralJSON


## FEATURE: Export Application Eventlogs
if ($WindowsEventLogs.IsPresent)
{
    if ($Parameters.Feature_WindowsEventLog -eq "Yes")
    {    
        Write-Log -ErrorLevel Information -Console -Message "WindowsEventLogs,Starting export..."   
        Export-WindowsEventLogs -Parameters $Parameters -RunType $RunType
        Write-Log -ErrorLevel Information -Console -Message "WindowsEventLogs,Event log export completed"
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "WindowsEventLogs was requested however it is not configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


## FEATURE: FIMSync
if ($FIMSync.IsPresent)
{
    if ($Parameters.Feature_FIMSync -eq "Yes")
    {
        Write-Log -ErrorLevel Information -Console -Message "FIMSync,Get version..." 
		Export-FIMSyncVersion -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "FIMSync,Get version completed"

        Write-Log -ErrorLevel Information -Console -Message "FIMSync,Starting to export run history..." 
		Export-FIMRunHistory -Parameters $Parameters -RunType $RunType
		Write-Log -ErrorLevel Information -Console -Message "FIMSync,Run history export completed"

        Write-Log -ErrorLevel Information -Console -Message "FIMSync,Starting object count..." 
		Export-FIMSyncObjectCounts -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "FIMSync,Object counts completed"

        Write-Log -ErrorLevel Information -Console -Message "FIMSync,Starting MA export..." 
		Export-FIMSyncMAs -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "FIMSync,MA export completed"
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "FIMSync was requested however it is not configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


## FEATURE: MIM Service
if ($FIMService.IsPresent)
{
    if ($Parameters.Feature_FIMService -eq "Yes")
    {
        Write-Log -ErrorLevel Information -Console -Message "FIMService,Get version..." 
		Export-FIMServiceVersion -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "FIMService,Get version completed"

        Write-Log -ErrorLevel Information -Console -Message "FIMService,Starting object count..." 
		Export-FIMServiceObjectCounts -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "FIMService,Object counts completed"

        Write-Log -ErrorLevel Information -Console -Message "FIMService,Starting to export Request status..." 
		Export-FIMServiceRequests -Parameters $Parameters -RunType $RunType
		Write-Log -ErrorLevel Information -Console -Message "FIMService,Request export completed"
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "FIMService was requested however it is not configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


## FEATURE: Infrastructure
If($Infrastructure.IsPresent)
{
    if ($Parameters.Feature_Infrastructure -eq "Yes")
    {
        if ($Parameters.Infra_Servers)
        {
            Write-Log -ErrorLevel Information -Console -Message "Infrastructure,Starting to get Server stats..." 
		    Export-ServerState -Parameters $Parameters
		    Write-Log -ErrorLevel Information -Console -Message "Infrastructure,Server stats completed"
        }
        if ($Parameters.Infra_DB_All)
        {
            Write-Log -ErrorLevel Information -Console -Message "Infrastructure,Starting to get Database stats..." 
		    Export-DatabaseState -Parameters $Parameters
		    Write-Log -ErrorLevel Information -Console -Message "Infrastructure,Database stats completed"
        }
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "Infrastructure was requested however it is not configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


## FEATURE: Identity Broker
If($IdentityBroker.IsPresent)
{
    if ($Parameters.Feature_IdentityBroker -eq "Yes")
    {
        Write-Log -ErrorLevel Information -Console -Message "IdentityBroker,Get version..." 
		Export-IDBVersion -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "IdentityBroker,Get version completed"

        Write-Log -ErrorLevel Information -Console -Message "IdentityBroker,Starting to get logs..." 
		Export-IDBLogs -Parameters $Parameters -RunType $RunType
		Write-Log -ErrorLevel Information -Console -Message "IdentityBroker,Logs saved to $ThisDataDir"
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "IdentityBroker was requested however it is not configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


## FEATURE: Event Broker
If($EventBroker.IsPresent)
{
    if ($Parameters.Feature_EventBroker -eq "Yes")
    {
        Write-Log -ErrorLevel Information -Console -Message "EventBroker,Get version..." 
		Export-EBVersion -Parameters $Parameters
		Write-Log -ErrorLevel Information -Console -Message "EventBroker,Get version completed"

        Write-Log -ErrorLevel Information -Console -Message "EventBroker,Starting to get logs..." 
		Export-EBLogs -Parameters $Parameters -RunType $RunType
		Write-Log -ErrorLevel Information -Console -Message "EventBroker,Logs saved to $ThisDataDir"
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "EventBroker was requested however it is not configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


## FEATURE: Custom Exports
If($Custom.IsPresent)
{
    if ($Parameters.Keys | Select-String "Custom_")
    {
        Write-Log -ErrorLevel Information -Console -Message "Custom,Starting export..." 
	    Export-Custom -Parameters $Parameters -RunType $RunType
	    Write-Log -ErrorLevel Information -Console -Message "Custom,Export completed"
    }
    else 
    {
        Write-Log -ErrorLevel Warning -Console -Message "Custom was requested however no Custom parameters are configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}

#endregion DataExtract

#region Cleanup

## Update the Parameters file with new LastRunTime
$Parameters._LastRunTime = $Parameters.AlwaysUpdate_LastRunTime
$ParametersJSON = $Parameters | ConvertTo-Json
$ParametersJSON | Out-File -FilePath $Parameters.AlwaysUpdate_ParametersFile -Force
$ScriptRunTime = [math]::round(((get-date).ToUniversalTime() - (get-date $Parameters.AlwaysUpdate_LastRunTime)).TotalSeconds)
Write-Log -ErrorLevel Information -Console -Message ("Run-HealthCheck.ps1,Data collection completed in {0} seconds" -f $ScriptRunTime)

## ZIP the data files
$ZipFile = $Parameters.General_DataUpload + "\JSON\" + $timestamp + ".zip"
New-ZipFolder -SourceFolder $ThisDataDir -ZipFile $ZipFile

####################
# Push to Log Analytics

#-------------------------------------
#Forwarder Config

# Replace with your Workspace ID
$CustomerId = "1be3b063-d1ec-4250-8f21-a685257dee37" 
# Replace with your Primary Key
##$SharedKey = "jn2DHMTxxd4ejkq2ZyyZilUklexgorC+SwD4rP6WrhxvVgBABnf1UphUjrQgL1ke3AEsE9uo/6jXKhlOXraVAg=="

#$SharedKey = "AWsv+xHmi8bmiwMiWzaTUb1VFnzcAztm7eSA56NZj7HeJrQCo6p/DoL/z6KgAzBWciznD/j9QFomoBrvLV+Y/g=="
$SharedKey = "ST/BZ4klwuDSkNJK5A54xu86kYTECfxpYCMrbS12ffU9C6NyAN9hjUkLYDr5WNeHVKAdXHEIq8eBJYzanZSSCQ=="
# Specify a field with the created time for the records
$TimeStampField = "DateValue"
# Specify the name of the record type that you'll be creating
$LogType = "Healthcheck"
#specify the location of the files

#--------------------------------------

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}

Function Post-OMSData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -fileName $fileName `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

	#$response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    #BOB >>
	try {
		$response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
	} catch {
		Write-Log -ErrorLevel Fatal  -Message ("Post-OMSData,Failed to post data to $uri. " + $_.Exception.Message)
	}
	#write-host "Service Responce -- 200:Success | 400+:Fail -- File: $fileName"
    Write-Log -ErrorLevel Information -Console -Message "Service Responce -- 200:Success | 400+:Fail -- File: $fileName"
    #BOB <<
    return $response.StatusCode
	
}

#retrive filenames from chosen directory then Pars filelist into individual names in an array
#BOB >>
#$fileList = Get-ChildItem $ThisDataDir
#$fileNameArray = $fileList -split' '
[string[]]$fileNameArray = Get-ChildItem $ThisDataDir -Name
#BOB <<

#check file names from loghistory.txt against file names from chosen directory
foreach ($fileName in $fileNameArray) {
    #$fileName = $fileNameArray[0]

	#BOB >>
    #$json = @(Get-Content $ZipFile\$fileName)
	#$json = @(Get-Content $fileName)
	$json = @(Get-Content $([System.IO.Path]::Combine($ThisDataDir,$fileName)))
	#Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType 
    #BOB<<
    if ($json -and $json.Length -gt 0) {
	    Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType 
    }
}

## Remove Data Folders
if ((Test-Path $ZipFile) -and (Get-Item $ZipFile).Length -gt 0)
{
    Write-Log -ErrorLevel Information -Console -Message "Extracted data saved to $ZipFile"
    Write-Log -ErrorLevel Information -Console -Message "Removing staging folder"
    Remove-Item -Path $ThisDataDir -Recurse -Force
}

## Old file purge
Get-ChildItem -Path $Parameters.General_DataUpload -Recurse -Filter "*.zip"  | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$Parameters.General_DataRetention)} | Remove-Item -Force
Get-ChildItem -Path $Parameters.General_DataUpload -Recurse -Filter "*.log"  | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$Parameters.General_DataRetention)} | Remove-Item -Force

#endregion Cleanup

#region Upload
if ($SplunkUpload.IsPresent)
{
    if($Parameters.Feature_SplunkUpload -eq 'Yes')
    {
	    Write-Log -ErrorLevel Information -Console -Message "SplunkUpload,Starting data upload..."
        Copy-FolderToAzure -Parameters $Parameters -SourceFolder ($Parameters.General_DataUpload + "\JSON") -DestFolder "JSON"
	    Write-Log -ErrorLevel Information -Console -Message "SplunkUpload,Completed data upload"

        ## Complete the Script Log and upload the file seperately
        $NewLogLocation = $Parameters.General_DataUpload + "\ANY\" + $timestamp + "_Run-HealthCheck.log"
        Move-Item $DebugLogFile -Destination $NewLogLocation
        $DebugLogFile = $NewLogLocation
        Copy-FolderToAzure -Parameters $Parameters -SourceFolder ($Parameters.General_DataUpload + "\ANY") -DestFolder "ANY"
    }
    else
    {
        Write-Log -ErrorLevel Warning -Console -Message "Splunk Upload was requested however has not been configured. Please run '.\Run-HealthCheck.Ps1 -UpdateParameters' to configure missing settings."
    }
}


#endregion Upload
