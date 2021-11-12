PARAM(  [string[]]$ReportNames = @("ExportErrors","ImportErrors","FilteredDisconnectors","NormalDisconnectors","Placeholders","DuplicateUSIN","DuplicateCeIder","EmailAccountNameMismatch"),
        [string]$ScriptFldr = "D:\Scripts\HTA",
        [string]$logFilePath = "D:\Logs",
        [string]$logFile = "MIMErrors.log",
        [string]$outFile = "MIMErrors.html",
        [string]$fromaddress = "svcFIM_Service@dbb.local", 
        [string]$toaddress = "rene.pisani@dbb.org.au",
        [string]$bccaddress = "csodbbsupport@unifysolutions.net", 
        [string]$CCaddress = "bob.bradley@unifysolutions.net",
        [string]$smtpserver = "smtp.dbb.local",
        [string]$archiveFileName = "MIMErrors.zip"
)
# Run selected reports from the XML file AllSQL.xml
# Usage: .\MIMErrors.ps1 -ReportNames @("ImportErrors","ExportErrors","FilteredDisconnectors","NormalDisconnectors","Placeholders")

function ExecuteSQL 
{
    Param(
        [String]$sql="",
        [String]$connStr="",
        [Bool]$dbg=$false)
    End
    {
        if ($sql.Length.Equals(0)) {
            Throw "Mandatory parameter sql not supplied!"
        }
        if ($connStr.Length.Equals(0)) {
            Throw "Mandatory parameter connStr not supplied!"
        }
        $connStr = "server=$svr;database=FIMSynchronizationService;Integrated Security=SSPI"
        #$conn = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=FIMSynchronizationService;Data Source=$svr"
        $sqlConnection = new-object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $connStr
        #if($dbg -eq $true) {Write-Output-Banner "Opening SQL Connection => $conn ..."}
        $sqlConnection.Open()
        [System.Data.SqlClient.SqlCommand]$sqlCommand = new-object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandTimeout = 120
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText= $sql
        #[string]$text = $sqlCommand.CommandText
        #if($dbg -eq $true) {Write-Output-Banner "Executing SQL: [$text]"}
#        [System.Data.SqlClient.SqlDataReader]$reader = $sqlCommand.ExecuteReader()
#        $result = @()
#        while ($reader.Read()) {
#            $result += $reader["Errors"]
#        }
        [System.Data.DataTable]$dataTable = New-Object System.Data.DataTable
        [System.Data.SqlClient.SqlDataAdapter]$sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $sqlAdapter.SelectCommand = $sqlCommand
        $sqlAdapter.Fill($dataTable)

#        $reader.Close()
        #if($dbg -eq $true) {Write-Output-Banner "Result: [$result]"}
        $sqlConnection.Close() 
        if($Err){throw $Err}
        return $dataTable #$result
    }
 }


Function Create-Zip (
    $ZipFileName,
    $LogFilePath,
    $LogFileExtension
){
    # create a new unique folder, copy all files to it, zip it and rename it, returning the zip file name
    $tempPath = New-Guid
    $tempPathFull = [System.IO.Path]::Combine($LogFilePath,$tempPath)
    $zipPathFull = [System.IO.Path]::Combine($LogFilePath,$ZipFileName)
    New-Item -Force -ItemType directory -Path $tempPathFull | Out-Null
    $testPath = "$LogFilePath\*.*"
    if (Test-Path $testPath) {
        Get-ChildItem $testPath -Exclude "*.zip" | ForEach-Object {Copy-Item $_ $tempPathFull} | Out-Null
    }

    if (Test-Path -path $("$logFilePath\$ZipFileName")) 
    { 
        Remove-Item -Force $("$logFilePath\$ZipFileName") | Out-Null
    }

    Add-Type -AssemblyName "System.IO.Compression.FileSystem" 
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempPathFull, $zipPathFull) | Out-Null

    Remove-Item -Force -Recurse $tempPathFull | Out-Null
    Return $zipPathFull
}

Set-Location $ScriptFldr
[string]$FIMSynchronizationServiceRegKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\FIMSynchronizationService\Parameters"
# Extend log file name with date/time component and initialise
[string]$logFileExtension = ($logFile).Split('.')[1]
[string]$logFileExt = [System.IO.Path]::Combine($logFilePath,$logFile.Replace($logFileExtension,".$(get-date -Format "yyyy-MM-dd").$logFileExtension"))
[string]$cssFileExt = [System.IO.Path]::Combine($ScriptFldr,"table.css")

# Read FIM context from registry
$FIMParams = Get-ItemProperty -Path $FIMSynchronizationServiceRegKey -ErrorAction SilentlyContinue
$svr = $FIMParams.Server
if ($FIMParams.SQLInstance.Length -gt 0) {
    $svr += "\$FIMParams.SQLInstance"
}
$conn = "server=$svr;database=$($FIMParams.DBName);Integrated Security=SSPI"

# Load MIM SQL
[xml]$MIMSQL = Get-Content -Path $([System.IO.Path]::Combine($ScriptFldr,"AllSQL.xml"))

# If $ReportName is not supplied, list all reports and stop
if($ReportNames.Length -eq 0) {
    Write-Host "Reports"
    Write-Host "======="
    foreach($query in $MIMSQL.sqlReporting.queries.query) {
        Write-Host "$($query.name)"
    }
    Write-Host ""
    Write-Host "Report Details"
    Write-Host "=============="
    foreach($query in $MIMSQL.sqlReporting.queries.query) {
        Write-Host "$($query.name):$($query.help.'#cdata-section')"
    }
    Exit
} else {
    # generate each report
    foreach($ReportName in $ReportNames) {
        $ReportSQLNode = $MIMSQL.sqlReporting.queries.query.Where({$_.name -eq $ReportName})
        if ($ReportSQLNode) {
            $sqlQueryResult = ExecuteSQL -connStr $conn -sql $($ReportSQLNode.sql.'#cdata-section')
        }
        if ($sqlQueryResult) {
            # write output to HTML
            $html = $sqlQueryResult | ConvertTo-Html -Title $ReportName -Head "
<h1>$ReportName</h1>`n<h5>Updated: on $(Get-Date)</h5>" -Body $($ReportSQLNode.help.'#cdata-section') -CssUri ".\table.css"
            $outFolder = [System.IO.Path]::Combine($logFilePath,$logFile.Replace($logFileExtension,"")+$(get-date -Format "yyyy-MM-dd"))
            if (![System.IO.Directory]::Exists($outFolder)) {
                [System.IO.Directory]::CreateDirectory($outFolder) | Out-Null
                # copy css file for local href support
                [System.IO.File]::Copy($cssFileExt,[System.IO.Path]::Combine($outFolder,"table.css"))
            }
            [string]$outFileExt = [System.IO.Path]::Combine($outFolder,"$ReportName.html")
            if ([System.IO.File]::Exists($outFileExt)) {
                [System.IO.File]::Delete($outFileExt)
            }
            Add-Content -Path $outFileExt -Value $html
        }
    }
    $outputFileTemplate = [System.IO.Path]::Combine($logFilePath,$logFile.Replace(".log",".*\*.html"))
    if ($smtpserver.Length -gt 0 -and (Test-Path -path $outputFileTemplate)) {
        # Create zip attachment and send reports in an email
        [string]$Subject = "CSODBB MIM (PROD): MIM Errors Report"
        [string]$body = "Various MIM Error reports"
        $attachment = Create-Zip -ZipFileName $archiveFileName -LogFilePath $outFolder -LogFileExtension $logFileExtension
        Send-MailMessage -SmtpServer $smtpserver -Body $body -BodyAsHtml -From $fromaddress -To $toaddress -Cc $CCaddress -Bcc $bccaddress -Subject $Subject -Attachments $attachment
        $attachment = $null
    }
}
