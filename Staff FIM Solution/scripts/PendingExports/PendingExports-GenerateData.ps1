PARAM(  [string]$SourceMA = "Staff",
        [string]$ScriptFldr = "D:\Scripts\PendingExports",
        [string]$MaData = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData",
        [string]$DropFile = "export.xml",
        [string]$OutputFile = "export.htm",
        [string]$Template = "PendingExports.xsl",
        [string]$logFilePath = "D:\Logs",
        [string]$logFile = "PendingExports-GenerateData.log",
        [string]$fromaddress = "svcFIM_Service@dbb.local", 
        [string]$toaddress = "rene.pisani@dbb.org.au",
        [string]$bccaddress = "bob.bradley@unifysolutions.net", 
        [string]$CCaddress = "csodbbsupport@unifysolutions.net",
        [string]$smtpserver = "smtp.dbb.local",
        [string]$archiveFileName = "Report.zip"
)

# Usage:
# $SourceMA = source MA name 
# $ScriptFldr = folder context in which this script is to be run
# $MaData = MaData folder for your FIM Sync Server
# $DropFile = file name of audit drop file for EXPORT of source MA
# $OutputFile = file name of target HTM file for EXPORT
# $Template = name of stylesheet file to transform EXPORT audit drop file

# Copyright (c) 2012, Unify Solutions Pty Ltd
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## ---------------------------------------------------------------- ##

# Functions
$line = "---------------------------------------------------------------------------------"
function Write-Output-Banner([string]$msg) {
	Write-Output $line,(" "+$msg),$line
	Write-Output $line,(" "+$msg),$line >> $logFileExt
}

function Write-Output-Text([string]$msg) {
	Write-Output $msg
	Write-Output $msg >> $logFileExt
}

## Check mandatory parameters
if ($MaData.Length.Equals(0)) {
    throw [System.Exception] "MaData parameter not supplied!"
}
if ($SourceMA.Length.Equals(0)) {
    throw [System.Exception] "SourceMA parameter not supplied!"
}

# Check for existence of log file path
if (-not [System.IO.Directory]::Exists($logFilePath)) {
    throw [System.Exception] "Supplied log folder path $logFilePath does not exist!"
}

# Extend log file name with date/time component
$logFileExtension = [System.IO.Path]::GetExtension($logFile)
[string]$logFileExt = [System.IO.Path]::Combine($logFilePath, $logFile.Replace($logFileExtension, "."+(get-date -Format "yyyy-MM-dd")+$logFileExtension))

$xsltTemplateFile = $ScriptFldr + "\" + $Template
$sourceFile = $MaData + "\" + $SourceMA + "\" + $DropFile
#$outFile = $MaData + "\" + $SourceMA + "\" + $OutputFile
# Extend output file name with date/time component
$outFile = [System.IO.Path]::Combine($logFilePath, $OutputFile.Replace(".htm", ".$SourceMA."+(get-date -Format "yyyy-MM-dd")+".htm"))

Write-Output-Banner("Begin PendingExports-GenerateData.ps1 - Date: "+(date))
Write-Output-Text(" - Transforming : "+$sourceFile)
Write-Output-Text(" - Using : "+$xsltTemplateFile)
Write-Output-Text(" - To : "+$outFile)

$xslt = new-object system.xml.xsl.XslTransform
$xslt.load($xsltTemplateFile)
$xslt.Transform($sourceFile,$outFile)
Write-Output-Text(" - Done`n")

#------------------------------------------------------------------------------------------------------
# Send Email as an attachment - define parameters (TODO)
# Based on https://mdaslam.wordpress.com/2015/12/30/powershell-zip-files-and-send-email-with-attachment/
#------------------------------------------------------------------------------------------------------

Function Create-Zip (
    $ZipFileName
) {
    New-Item -Force -ItemType directory -Path $("$logFilePath\temp") | Out-Null
    Get-ChildItem $outFile | ForEach-Object {Copy-Item $_ $("$logFilePath\temp")} | Out-Null

    if (Test-Path -path $("$logFilePath\$ZipFileName")) 
    { 
        Remove-Item -Force $("$logFilePath\$ZipFileName") | Out-Null
    }

    Add-Type -AssemblyName "System.IO.Compression.FileSystem" 
    [System.IO.Compression.ZipFile]::CreateFromDirectory($("$logFilePath\temp"), $("$logFilePath\$ZipFileName")) | Out-Null

    Remove-Item -Force -Recurse $("$logFilePath\temp") | Out-Null
    Return $("$logFilePath\$ZipFileName")
}

if ($smtpserver.Length -gt 0) {
    [string]$Subject = "Pending Exports Report - $SourceMA"
    [string]$body = "Pending export report attached for source MA $SourceMA" #get-content .\content.htm 
    $attachment = Create-Zip -ZipFileName $archiveFileName
    Send-MailMessage -SmtpServer $smtpserver -Body $body -BodyAsHtml -From $fromaddress -To $toaddress -Cc $CCaddress -Bcc $bccaddress -Subject $Subject -Attachments $attachment
    $attachment = $null
}

#------------------------------------------------------------------------------------------------------
 trap
 { 
    #Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Write-Output-Banner("`nError: $($_.Exception.Message)`n")
    Exit
 }
#------------------------------------------------------------------------------------------------------
