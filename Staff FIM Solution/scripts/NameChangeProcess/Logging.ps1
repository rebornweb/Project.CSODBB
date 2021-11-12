#Logging Module

Class LogEntry {
    [string]$logFile
    [bool]$debug = $false
    [string]$dateFormatFilename = "yyyyMMdd"
    [string]$dateFormatLineEntry = "HH:mm:ss.fff tt : "
    [string]$dateFormatDebugEntry = "HH:mm:ss.fff tt"
    [int]$maxRetries = 3
    [int]$retryWait = 500 #Milliseconds
    [string]$logText = ""
	
    LogEntry([string]$logFolder, [string]$logFilenameTemplate, [bool]$debug) {
        $logDate = get-date -f $this.dateFormatFilename
        $logFilename = $logFilenameTemplate -f $logDate
        if ($logFolder[$logFolder.length - 1] -ne "\") {
            $logFilename = "\" + $logFilename
        }
        $this.logFile = $logFolder + $logFilename
        $this.debug = $debug
    }
	
    Append([string]$logString) {
        $lineTime = get-date -f $this.dateFormatLineEntry
        $newLine = $lineTime + $logString + "`r`n"
        $this.logText = $this.logText + $newLine
    }
	
    DebugMsg([string]$logString) {
        if ($this.debug) {
            $lineTime = get-date -f $this.dateFormatDebugEntry
            $newLine = $lineTime + " Debug : " + $logString + "`r`n"
            $this.logText = $this.logText + $newLine
        }
    }
	
    DebugMapping([object]$mapping) {
        $mapProps = $mapping | Get-Member -membertype properties
        $msg = "Mapping("
        foreach ($p in $mapProps) {
            $pName = $p.Name
            $msg = $msg + " " + $pName + ":" + $mapping.$pName + ";"
        }
        $msg = $msg + ")"
        $this.DebugMsg($msg)
    }
	
    DebugHash([object]$hash) {
        $msg = "Hash("
        foreach ($r in $hash.GetEnumerator()) {
            $msg = $msg + " " + $r.Key + ":" + $r.Value + ";"
        }
        $msg = $msg + ")"
        $this.DebugMsg($msg)
    }
	
    DebugValue([string]$varName, [object]$obj) {
        $objVal = "Null"
        if ($obj) {
            $objVal = $obj.ToString()
        }
        $msg = $varName + " : " + $objVal
        $this.DebugMsg($msg)
    }
	
    DebugArray([string]$varName, [object]$obj) {
        $msg = $varName + " : " 
        foreach ($it in $obj) {
            $msg = $msg + $it.ToString() + "; "
        }
        $this.DebugMsg($msg)
    }
	
    LogEmptyLines([int]$numLines) {
        $emptyCount = 0
        while ($emptyCount -lt $numLines) {
            $this.Append("")
            $emptyCount++
        }
    }

    LogError([string]$logString) {
        $lineTime = get-date -f $this.dateFormatLineEntry
        $newLine = $lineTime + " ERROR : " + $logString + "`r`n"
        $this.logText = $this.logText + $newLine
    }
    
    LogError([System.Exception]$exc) {
        $this.Append("Message: " + $exc.Message)
        $this.Append("Stacktrace: " + $exc.StackTrace)
        $this.Append("")
    }
	
    LogTerminate([string]$logString) {
        $this.Append($logString)
        $this.Append("Terminating Run")
        $this.WriteEntry()
        throw $logString
    }
	
    LogFatalError([System.Exception]$exc) {
        $this.LogError($exc)
        $this.Append("Terminating Run")
        $this.WriteEntry()
        throw $exc
    }

    WriteEntry() {
        $writeOk = $false
        $attempts = 0
        while (-not $writeOk) {
            try {			
                $this.logText | out-file -Filepath $this.logFile -append
                $writeOk = $true  
            }
            catch [System.Exception] {
                if ($attempts -eq $this.maxRetries) {
                    throw $_.Exception
                }
                $attempts = $attempts + 1
                Start-Sleep -m $this.retryWait
            }				
        }
    }

    Flush() {
        $writeOk = $false
        $attempts = 0
        while (-not $writeOk) {
            try {			
                $this.logText | Out-File -Filepath $this.logFile -append
                $this.logText = "";
                $writeOk = $true  
            }
            catch [System.Exception] {
                if ($attempts -eq $this.maxRetries) {
                    throw $_.Exception
                }
                $attempts = $attempts + 1
                Start-Sleep -m $this.retryWait
            }				
        }
    }
}