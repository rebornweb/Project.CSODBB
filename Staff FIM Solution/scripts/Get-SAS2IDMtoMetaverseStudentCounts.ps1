﻿#-------------------------------------------------------------------------------
# Get-SAS2IDMtoMetaverseStudentCounts.ps1
#
# Summary report to compare total students count between each of SAS (44), SAS2IDM (1) and MIM Sync (1) databases
#
# Author: Bob Bradley - bob.bradley@unifysolutions.net
#         https://unifysolutions.net/identity/
# Change History
#         28/10/2021 - initial version
#
# Detailed Requirements
# * Identify any identity count disparities for students between each of SAS (44), SAS2IDM (1) and MIM Sync (1) databases
# * Report to be run either scheduled or on demand
# * Summary data to be sent via email as both HTML and CSV attachment
#-------------------------------------------------------------------------------
param(
    [string]$mimServer = "OCCCP-DB301",
    [string]$sasServer = "OCCCP-DB222",
    [string]$logfile = "D:\Logs\Get-SAS2IDMtoMetaverseStudentCounts.log",
    [string]$cssfile = "D:\Scripts\Report.css",
    [string]$outputfile = "D:\Logs\SAS2IDMSchools.csv",
    [string]$company = "CSODBB",
    [string]$subject = "SAS to MIM Metaverse Student Counts report",
    [string]$description = "Summary report to compare total students count between each of SAS (44), SAS2IDM (1) and MIM Sync (1) databases",
    [string]$fromaddress = "MIMPROD@dbb.org.au", 
    [string[]]$toaddress = @("sat.support@dbb.org.au"),
    [string]$ccaddress = "csodbbsupport@unifysolutions.net",
    [string]$smtpserver = "smtp.dbb.local",
    [switch]$debug,
    [switch]$help
)

# quit on errors
$ErrorActionPreference="Stop"

# show help
if ($help) {
    @"
NAME
    Get-SAS2IDMtoMetaverseStudentCounts

SYNOPSIS
    Summary report to compare total students count between each of SAS (44), SAS2IDM (1) and MIM Sync (1) databases.
    
SYNTAX:
    Get-SAS2IDMtoMetaverseStudentCounts [[-mimServer] <string>] [[-sasServer] <string>] [[-logfile] <string>] [[-outputfile] <string>] [-help] [-debug]

PARAMETERS:
    -mimServer <string> 
        The MIM Sync host server. The default value is '.' (localhost SQL in TEST, OCCCP-DB222 in PROD)
    
    -sasServer <string>
        The SAS and SAS2IDM host server. The default value is 'OCCCP-DB222'

    -logfile <string>
        The log file for the last execution record this script. The default value is "D:\Logs\Get-SAS2IDMtoMetaverseStudentCounts.log".

    -cssfile <string>
        The CSS file required by the script for formatting HTML notifications. The default value is "D:\Scripts\Report.css".

    -outputfile <string>
        The CSV file generated by the script. The default value is "D:\Logs\SAS2IDMtoMetaverseStudentCounts.csv".

    -company <string>
        The company for whom this report is generated

    -subject <string>
        The report subject

    -description <string>
        The detailed report description

    -fromaddress <string>
        The notification sender email address

    -toaddress []<string>
        The notification recipient email address(es)

    -ccaddress <string>
        The notification CC recipient email address

    -smtpserver <string>
        The SMTP address (if null or empty string, no email will be sent)

    -debug <switch>
        Enable debug messages.

    -help <switch>
        Display this help message and exit.
        
"@
    exit
}

#------------------------------------------------------------------------------------------------------
# Send Email as an attachment
# Based on https://mdaslam.wordpress.com/2015/12/30/powershell-zip-files-and-send-email-with-attachment/
#------------------------------------------------------------------------------------------------------
Function Create-Zip
{
    Param(
        [String]$ZipFileName)
    End
    {
        [string]$tempPath = "$logFilePath\temp"
        New-Item -Force -ItemType directory -Path $tempPath | Out-Null
        Get-ChildItem "$($logFile.Replace($logFileExtension,".csv"))” | ForEach-Object {Copy-Item $_ $tempPath} | Out-Null

        if (Test-Path -path $("$ZipFileName")) 
        { 
            Remove-Item -Force $("$ZipFileName") | Out-Null
        }

        Add-Type -AssemblyName "System.IO.Compression.FileSystem" 
        [System.IO.Compression.ZipFile]::CreateFromDirectory($tempPath, $("$ZipFileName")) | Out-Null

        Remove-Item -Force -Recurse $tempPath | Out-Null
        Return $("$ZipFileName")
    }
}

#------------------------------------------------------------------------------------------------------
# Execute a SQL statement
#------------------------------------------------------------------------------------------------------
function ExecuteSQL 
{
    Param(
        [String]$sql="",
        [String]$connStr="",
        [Int]$cmdTimeout=120,
        [Bool]$dbg=$false)
    End
    {
        if ($sql.Length.Equals(0)) {
            Throw "Mandatory parameter sql not supplied!"
        }
        if ($connStr.Length.Equals(0)) {
            Throw "Mandatory parameter connStr not supplied!"
        }
        $sqlConnection = new-object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $connStr
        if($dbg -eq $true) {Write-Output "Opening SQL Connection => [$($sqlCommand.ConnectionString)] ..." | Out-File -FilePath $logfile -Append}
        $sqlConnection.Open()
        [System.Data.SqlClient.SqlCommand]$sqlCommand = new-object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandTimeout = $cmdTimeout
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText= $sql
        if($dbg -eq $true) {Write-Output "Executing SQL: [$($sqlCommand.CommandText)]" | Out-File -FilePath $logfile -Append}
        [System.Data.DataTable]$dataTable = New-Object System.Data.DataTable
        [System.Data.SqlClient.SqlDataAdapter]$sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $sqlAdapter.SelectCommand = $sqlCommand
        $sqlAdapter.Fill($dataTable)
        $sqlConnection.Close() 
        if($Err){throw $Err}
        return $dataTable #$result
    }
 }

# Initialize hash table for result consolidation
$csvHT = @{}

# initiate logging
if ($debug) {
    Write-Output "$(Get-Date): Generating Report ..."
} else {
    Write-Output "$(Get-Date): Generating Report ..." | Out-File -FilePath $logfile
}

# -- Step #1: Get School table from MIM Sync
Write-Output "[$(Get-Date)] Getting MIM Sync totals ..." | Out-File -FilePath $logfile -Append
[string]$db = "FIMSynchronizationService"
[string]$sql = @"
SELECT [physicalDeliveryOfficeName]
      ,[SchoolID]
      ,count(*) as [NumInMetaverse]
  FROM [dbo].[mms_metaverse] with (nolock)
  where object_type = 'person'
  and SAS2IDMConnector is not null
  group by [physicalDeliveryOfficeName]
      ,[SchoolID]
order by SchoolID
"@
[string]$conn = "server=$mimServer;database=$db;Integrated Security=SSPI"

$sqlQueryResult = ExecuteSQL -connStr $conn -sql $sql

$sqlQueryResult | % {
    [string]$id = $_.SchoolID
    $csvHT.Add($id, @{})
    $csvHT.($id).Add("SchoolID",$id)
    $csvHT.($id).Add("physicalDeliveryOfficeName",$_.physicalDeliveryOfficeName)
    $csvHT.($id).Add("NumInMetaverse",$_.NumInMetaverse)
}

# -- Step #2: Get School table from SAS2IDM
Write-Output "[$(Get-Date)] Getting SAS2IDM totals ..." | Out-File -FilePath $logfile -Append
$db = "SAS2IDM_SAS2IDM_LIVE"
$sql = @"
select SchoolID, count(*) as [SAS2IDMCount]
from dbo.AllSAS2IDMStudents with (nolock)
group by SchoolID
order by SchoolID
"@

$conn = "server=$sasServer;database=$db;Integrated Security=SSPI"
$sqlQueryResult = ExecuteSQL -connStr $conn -sql $sql

$sqlQueryResult | % {
    [string]$id = $_.SchoolID
    $csvHT.($id).Add("SAS2IDMCount",$_.SAS2IDMCount)
    $csvHT.($id).Add("Diff",-[long](0 + ($_.SAS2IDMCount) - ($csvHT.($id).NumInMetaverse)))
}

# -- Step #3: Get SAS data from 44 schools
Write-Output "[$(Get-Date)] Getting SAS totals (x44) ..." | Out-File -FilePath $logfile -Append
$sql = @"
exec [dbo].[procSAS2IDM_GetLatestStudentData]
"@

$sqlQueryResult = $null
try {
    $sqlQueryResult = @(ExecuteSQL -connStr $conn -sql $sql -cmdTimeout 600)
} catch {
    $err[0]
}

if ($sqlQueryResult) {
    $SASStudents = @{} # USIN must be globally unique - often this breaks with human error involved ...
    $sqlQueryResult.Where({$_.UniversalIdentificationNumber -and ($_.AlumniType -eq 'S')}) | % {
        $UniversalIdentificationNumber = $_.UniversalIdentificationNumber
        $SchoolID = $_.SchoolID
        if (!$SASStudents.ContainsKey($UniversalIdentificationNumber)) {
            if ($UniversalIdentificationNumber -and $SchoolID) {
                $SASStudents.Add($UniversalIdentificationNumber, @{})
                $SASStudents.($UniversalIdentificationNumber).Add("SchoolID",$SchoolID)
            }
        } else {
            Write-Output "[$(Get-Date)] Error reading SAS data for SchoolID [$SchoolID] ... USIN [$UniversalIdentificationNumber] already exists for SchoolID [$($SASStudents.($UniversalIdentificationNumber).SchoolID)] " | Out-File -FilePath $logfile -Append
        }
    }

    $csvHT.Keys | % {
        $schoolID = $_
        [Int]$sasCount = $SASStudents.Values.Where({$_.SchoolID -eq $schoolID}).Count
        $csvHT.($schoolID).Add("SASCount",$sasCount)
        $csvHT.($schoolID).Add("SASDiff",-[long](0 + ($sasCount) - ($csvHT.($schoolID).NumInMetaverse)))
    }
}

# -- Step #4: Generate CSV Report
# Extend log file name with date/time component
[string]$logFileExtension = [System.IO.Path]::GetExtension($logFile)
[string]$logFileExt = [System.IO.Path]::Combine($logFilePath, $logFile.Replace($logFileExtension, "."+(get-date -Format "yyyy-MM-dd")+$logFileExtension))
[string]$logFilePath = [System.IO.Path]::GetDirectoryName($logfile)
[string]$outputfile = $logFile.Replace($logFileExtension,".csv")
if (Test-Path -path $outputfile) 
{ 
    Remove-Item -Force $outputfile | Out-Null
}

Write-Output "[$(Get-Date)] Writing CSV to $outputfile ..." | Out-File -FilePath $logfile -Append
foreach($csvItem in $csvHT.Keys) {
    if ($csvItem.Length -gt 0) {
        [PSCustomObject]$csvHT.($csvItem) | select "SchoolID","physicalDeliveryOfficeName","NumInMetaverse","SAS2IDMCount","Diff","SASCount","SASDiff" | Export-Csv $outputfile –NoTypeInformation -Append
    }
}

if ($smtpserver.Length -gt 0) {
    [string]$archiveFileName = $outputfile -ireplace ".CSV",".ZIP"
    [string]$head = get-content $cssfile
    [string]$spacer = "<table><tr><td class='Spacer'/></tr></table>"
    [string]$reportData = [PSCustomObject]@{Company=$company;Date="$(Get-Date)";Server="$($env:COMPUTERNAME)";} | select * | ConvertTo-Html -Fragment -PreContent "<h3>$description</h3>" | Out-String
    [string]$reportBody = Get-Content -Path $outputfile | ConvertFrom-Csv | Sort-object physicalDeliveryOfficeName | ConvertTo-Html -Fragment -PreContent $spacer | Out-String
    [string]$body = ConvertTo-Html -Head $head -PostContent $reportBody -PreContent "<h1>$subject</h1>",$reportData
    $attachment = Create-Zip -ZipFileName $archiveFileName
    Send-MailMessage -SmtpServer $smtpserver -Body $body -BodyAsHtml -From $fromaddress -To $toaddress -Cc $ccaddress -Subject $subject -Attachments $attachment
    $attachment = $null
}
        
# finalise logging
if ($debug) {
    Write-Output "$(Get-Date): Report generated OK!"
} else {
    Write-Output "$(Get-Date): Report generated OK!" | Out-File -FilePath $logfile -Append
}
