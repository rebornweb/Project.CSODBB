PARAM(  [string]$SourceMA = "Staff",
        [string]$ScriptFldr = "D:\Scripts\PendingExports",
        [string]$MaData = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData",
        [string]$DropFile = "csexport.xml",
        [string]$CSExportExe = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\Bin\csexport.exe",
        [string]$logFilePath = "D:\Logs",
        [string]$logFile = "RunCSExport.log",
        [string]$filterOption = "/f:x",
        [string]$outputOption = "/o:d"
)

# Usage:
# $SourceMA = source MA name 
# $ScriptFldr = folder context in which this script is to be run
# $MaData = MaData folder for your FIM Sync Server
# $DropFile = CSEXPORT.EXE output file name for EXPORT of source MA
# CSExportExe = CSEXPORT.EXE path on FIM Sync Server
# $logFilePath = Log file folder
# $logFile = Log file name for RunCSExport.ps1 script

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


$outFile  = $MaData + "\" + $SourceMA + "\" + $DropFile

# Check for existence of csexport.xml. If found delete it.
if ([System.IO.File]::Exists($outFile)) {
    [System.IO.File]::Delete($outFile)
}

Write-Output-Banner("Begin CSExport.ps1 - Date: "+(date))
Write-Output-Text(" - Generating CSExport - To : "+$outFile)

$commandArgs = @($filterOption,$outputOption)
& $CSExportExe $SourceMA $outFile $commandArgs


Write-Output-Text(" - Done`n")

#------------------------------------------------------------------------------------------------------
 trap
 { 
    #Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Write-Output-Banner("`nError: $($_.Exception.Message)`n")
    Exit
 }
#------------------------------------------------------------------------------------------------------
