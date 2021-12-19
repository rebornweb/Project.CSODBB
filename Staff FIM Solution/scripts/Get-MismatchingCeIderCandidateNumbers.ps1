#-------------------------------------------------------------------------------
# Get-MismatchingCeIderCandidateNumbers.ps1
#
# Exception report to identify mismatching SAS/ADLDS CeIder values
#
# Author: Bob Bradley - bob.bradley@unifysolutions.net
#         https://unifysolutions.net/identity/
# Change History
#         1/12/2021 - initial version
#         9/12/2021 - add school code
#         16/12/2021 - Include option go get SAS sourced data directly from SAS
#-------------------------------------------------------------------------------
param(
    [string]$sasServer = "OCCCP-DB222",
    [string]$logfile = "D:\Logs\Get-MismatchingCeIderCandidateNumbers.log",
    [string]$cssfile = "D:\Scripts\Report.css",
    [string]$outputfile = "D:\Logs\MismatchingCeIderCandidateNumbers.csv",
    [string]$company = "CSODBB",
    [string]$subject = "Mismatching SAS/ADLDS CeIder values",
    [string]$description = "Exception report to identify mismatching SAS/ADLDS CeIder values",
    [string]$fromaddress = "MIMPROD@dbb.org.au", 
    [string[]]$toaddress = @("csodbbsupport@unifysolutions.net","sat.support@dbb.org.au"),
    [string]$ccaddress = "bob.bradley@unifysolutions.net",
    [string]$smtpserver = "smtp.dbb.local",
    [switch]$debug,
    [switch]$help
)

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

# (USIN Is present ) AND (CandidateNumber Is present ) AND (csoCeIder Is present ) AND (SAS2IDMConnector Is present )
$filter = @(
    New-MVQuery -Attribute "USIN" -Operator IsPresent
    New-MVQuery -Attribute "CandidateNumber" -Operator IsPresent
    New-MVQuery -Attribute "csoCeIder" -Operator IsPresent
    New-MVQuery -Attribute "SAS2IDMConnector" -Operator IsPresent
    #New-MVQuery -Attribute "CandidateNumber" -Operator Equals -Value "115041616"
)

# -- Step #1: initiate logging
if ($debug) {
    Write-Output "$(Get-Date): Generating Report ..."
} else {
    Write-Output "$(Get-Date): Generating Report ..." | Out-File -FilePath $logfile
}

# -- Step #2: Get School table from SAS2IDM
$lookupHT = @{}
# -- Step #3: Get SAS data from 44 schools
if ($sasServer.Length -gt 0) {
    if ($debug) {
        Write-Output "[$(Get-Date)] Getting SAS totals (x44) ..."
    } else {
        Write-Output "[$(Get-Date)] Getting SAS totals (x44) ..." | Out-File -FilePath $logfile -Append
    }
    $db = "SAS2IDM_SAS2IDM_LIVE"
    $sql = @"
exec [dbo].[procSAS2IDM_GetLatestStudentData]
"@
    $conn = "server=$sasServer;database=$db;Integrated Security=SSPI"

    $sqlQueryResult = $null
    try {
        $sqlQueryResult = @(ExecuteSQL -connStr $conn -sql $sql -cmdTimeout 600)
    } catch {
        $err[0]
    }

    if ($sqlQueryResult) {
        [int]$count = 0
        $sqlQueryResult.Where({$_.UniversalIdentificationNumber -and ($_.Archive -eq 'N') -and ($_.PreEnrolment -eq 'N')}) | % { # -and ($_.AlumniType -eq 'S')
            [string]$id = "{0}:{1}" -f $_.UniversalIdentificationNumber, $_.AlumniType 
            [string]$CandidateNumber = $_.CandidateNumber
            if (($id.Length -gt 1) -and ($CandidateNumber.Length -gt 1)) {
                if (!$lookupHT.ContainsKey($id)) {
                    $lookupHT.Add($id,@{})
                    $lookupHT.($id).Add("UniversalIdentificationNumber",$_.UniversalIdentificationNumber)
                    $lookupHT.($id).Add("SchoolID",$_.SchoolID)
                    $lookupHT.($id).Add("CandidateNumber",$_.CandidateNumber)
                    $lookupHT.($id).Add("AlumniType",$_.AlumniType)
                } else { 
                    $count++
                    if ($debug) {
                        Write-Output "[$(Get-Date)] Error reading SAS data for SchoolID [$($_.SchoolID)] ... USIN [$id] already exists! Err#[$count]"
                    } else {
                        Write-Output "[$(Get-Date)] Error reading SAS data for SchoolID [$($_.SchoolID)] ... USIN [$id] already exists! Err#[$count]" | Out-File -FilePath $logfile -Append
                    }
                }
            }
        }
    }
}

# -- Step #3: Get MIM metaverse data
$students = @(Get-MVObject -Queries $filter -ObjectType "person")
$csvHT = @{}
$count = 0
$students | % {
    $student = $_
    [string]$USIN = $student.Attributes.USIN.Values[0].ValueString
    [string]$CandidateNumber = $student.Attributes.CandidateNumber.Values[0].ValueString
    [string]$Year = $student.Attributes.Year.Values[0].ValueString
    [string]$physicalDeliveryOfficeName = $student.Attributes.physicalDeliveryOfficeName.Values[0].ValueString
    # use SAS2IDM value in lieu of this if present
    if ($lookupHT.Count -gt 0) {
        [string]$current = "{0}:S" -f $USIN
        [string]$former= "{0}:A" -f $USIN
        if ($lookupHT.ContainsKey($current)) {
            if ($CandidateNumber -ne $lookupHT.($current).CandidateNumber) {
                $CandidateNumber = $lookupHT.($current).CandidateNumber
            }
        } elseif ($lookupHT.ContainsKey($former)) {
            if ($CandidateNumber -ne $lookupHT.($former).CandidateNumber) {
                $CandidateNumber = $lookupHT.($former).CandidateNumber
            }
        } else {
            $count++
            if ($debug) {
                Write-Output "[$(Get-Date)] SAS2IDM record for USIN [$USIN] in school [$physicalDeliveryOfficeName] year [$Year] not found! Err#[$count]" 
            } else {
                Write-Output "[$(Get-Date)] SAS2IDM record for USIN [$USIN] in school [$physicalDeliveryOfficeName] year [$Year] not found! Err#[$count]" | Out-File -FilePath $logfile -Append
            }
        }
    }
    [string]$csoCeIder = $student.Attributes.csoCeIder.Values[0].ValueString
    [string]$firstName = $student.Attributes.firstName.Values[0].ValueString
    [string]$lastName = $student.Attributes.lastName.Values[0].ValueString
    [string]$physicalDeliveryOfficeName = $student.Attributes.physicalDeliveryOfficeName.Values[0].ValueString
    if (!($CandidateNumber -eq $csoCeIder)) {
        $csvHT.Add($USIN, @{"USIN"=$USIN;"CandidateNumber"=$CandidateNumber;"csoCeIder"=$csoCeIder;"firstName"=$firstName;"lastName"=$lastName;"physicalDeliveryOfficeName"=$physicalDeliveryOfficeName})
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

if ($debug) {
    Write-Output "[$(Get-Date)] Writing CSV to $outputfile ..." 
} else {
    Write-Output "[$(Get-Date)] Writing CSV to $outputfile ..." | Out-File -FilePath $logfile -Append
}
foreach($csvItem in $csvHT.Keys) {
    if ($csvItem.Length -gt 0) {
        [PSCustomObject]$csvHT.($csvItem) | select *  | Export-Csv $outputfile –NoTypeInformation -Append
    }
}

if ($smtpserver.Length -gt 0 -and (Test-Path -path $outputfile)) {
    [string]$archiveFileName = $outputfile -ireplace ".CSV",".ZIP"
    [string]$head = get-content $cssfile
    [string]$spacer = "<table><tr><td class='Spacer'/></tr></table>"
    $description = $description + " ($($csvHT.Keys.Count) records affected)" # Add record count to report description)
    [string]$reportData = [PSCustomObject]@{Company=$company;Date="$(Get-Date)";Server="$($env:COMPUTERNAME)";} | select * | ConvertTo-Html -Fragment -PreContent "<h3>$description</h3>" | Out-String
    [string]$reportBody = Get-Content -Path $outputfile | ConvertFrom-Csv | Sort-object physicalDeliveryOfficeName,USIN | ConvertTo-Html -Fragment -PreContent $spacer | Out-String
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

