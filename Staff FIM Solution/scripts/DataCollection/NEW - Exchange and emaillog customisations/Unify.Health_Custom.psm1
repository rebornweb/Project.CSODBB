<#
Unify.Health-Custom.psm1

Add functions that gather and export data additional to that covered by the base Unify.Health functions.
It is also possible to override Unify.Health functions - if a function with the same name is added here it will be used instead.

The following functions MUST exist:
 * Get-HealthModuleCustomVersion - Specifies the version number for this script
 * Export-Custom - This is the only function called by Run-HealthCheck.ps1
#>

Function Get-HealthModuleCustomVersion
{
    $ScriptVersions.Add("Unify.Health_Custom.psm1","2.4")
}

Function Export-Custom
{
<#
.SYNPOSIS
    Called by Run-Health.ps1. All custom functions must be run by this function.
.OUTPUT

.PARAMETERS
    Parameters: The Parameters hashtable
    RunType: All or Diff
.DEPENDENCIES    

.ChangeLog
    Adrian Corston, 31/8/2017, CSODBB: Add Exchange ProvisionMBs*.log, UpdateContacts*.log and IDB emaillog.txt
#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$RunType
        )
    END
    {
        Write-Log -ErrorLevel Information -Message "Export-Custom,Starting"

        $ExchangeLogFolder = $Parameters.Custom_ExchangeProvisioningLogFolder
#        $ExchangeLogFolder = "."

        Write-Log -ErrorLevel Information -Message "Export-Custom,Exporting exchange logs from $ExchangeLogFolder"

        # Identify the log files we are checking		
        if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
        {
            $ExchangeLogFiles = @()
            $ExchangeLogFiles += Get-ChildItem -Path $ExchangeLogFolder -Filter "ProvisionMBs*.log" | where {$_.LastWriteTime.ToUniversalTime() -ge $Parameters._LastRunTime}
            $ExchangeLogFiles += Get-ChildItem -Path $ExchangeLogFolder -Filter "UpdateContacts*.log" | where {$_.LastWriteTime.ToUniversalTime() -ge $Parameters._LastRunTime}
            $DeltaTime = Get-Date $Parameters._LastRunTime
        }
        else
        {
            $ExchangeLogFiles = @()
            $ExchangeLogFiles += Get-ChildItem -Path $ExchangeLogFolder -Filter "ProvisionMBs*.log"
            $ExchangeLogFiles += Get-ChildItem -Path $ExchangeLogFolder -Filter "UpdateContacts*.log"
            $DeltaTime = Get-Date 0
        }

        write-host "elf =" $ExchangeLogFolder
        write-host "files =" $ExchangeLogFiles

		# Read and analyse them
        if ($ExchangeLogFiles)
        {
            $DataFile = $ThisDataDir + "\ExchangeLogs.json"
            write-host "datafile =" $DataFile
            [System.IO.StreamWriter]$streamWriter = [System.IO.StreamWriter] $DataFile

			foreach ($file in $ExchangeLogFiles)
            {
                Write-Log -ErrorLevel Information -Message ("Export-Custom,Collating data from {0}" -f $file.Name)
                write-host "file =" $file
				
				# Now extract the execution timestamp and error lines
				# We also grab one line of preceeding context, so the errors are more helpful
				#
				# Example log file format:
				#
                # Begin execution, 08/31/2017 08:59:44
                # Connecting to OCCCP-EX014.dbb.local
                # Mail-enabling CN=jennifer hogan,OU=Centacare,OU=Staff,OU=Users,OU=Diocese,DC=dbb,DC=localjennifer.hogan
                # Error adding recipient: System.Management.Automation.RemoteException: Load balancing failed to find a valid mailbox database.
				#
                $errors = Select-String -context 1,0 "^Begin execution|^Error" $file
                foreach ($e in $errors)
                {
				    # Extract and remember the execution timestamp from the top of each run
				    if ($e.line -match "Begin execution, (\d\d)/(\d\d)/(\d\d\d\d) (\d\d):(\d\d):(\d\d)")
					{
					    $logtime = get-date ("{2}-{0}-{1}T{3}:{4}:{5}" -f ($matches[1..6]))
				    }
					
					# Otherwise it's an error line
					else
					{
                        if ($logtime -ge $DeltaTime)
                        {
                            $ht = @{
                                '_time' = $logtime.toString("yyyy-MM-ddTHH:mm:ss")
                                'HCRecordType'="ExchangeProvisioning_Log"
                                'Detail'= $e.line + " " + $e.context.precontext
                                'Impact'='Error'
                            }
                            $jsonOutput  = ConvertTo-JSON $ht
 #                           write-host $jsonOutput
                            $streamWriter.Write($jsonOutput)
						}
                    }
                }
            }
            $streamWriter.Close()
        }
        else
        {
            Write-Log -ErrorLevel Information -Message "Export-Custom,No recent Exchange log files found in $ExchangeLogFolder"
        }



        $EMailLogPath = $Parameters.Custom_EmailLogPath
#        $EMailLogPath = ".\emaillog.txt"

        Write-Log -ErrorLevel Information -Message "Export-Custom,Exporting EMailLog logs from $EMailLogFolder"

        # Identify the log files we are checking		
        if ($RunType -eq "Delta" -and $Parameters._LastRunTime)
        {
			write-host $EMailLogPath
            $EMailLogFiles = Get-Item $EMailLogPath
            $DeltaTime = Get-Date $Parameters._LastRunTime
        }
        else
        {
            $EMailLogFiles = Get-Item $EMailLogPath
            $DeltaTime = Get-Date 0
        }

		# Read and analyse them
        if ($EMailLogFiles)
        {
            $DataFile = $ThisDataDir + "\EMailLogs.json"
            [System.IO.StreamWriter]$streamWriter = [System.IO.StreamWriter] $DataFile

			foreach ($file in $EMailLogFiles)
            {
                Write-Log -ErrorLevel Information -Message ("Export-Custom,Collating data from {0}" -f $file.Name)

				# Extract the execution timestamp and all log lines
				#
				# Example log file format:
				#
                # ---------- START OF IMPORT, 2017-05-29 00:00:00Z ----------
                # blah blah blah
                # ---------- START OF IMPORT, 2017-05-30 00:00:00Z ----------
				#
                $lines = Get-Content $file
                foreach ($line in $lines)
                {
				    # Extract and remember the execution timestamp from the top of each run
				    if ($line -match "START OF IMPORT, (\d\d\d\d-\d\d-\d\d) (\d\d:\d\d:\d\d)")
					{
					    $logtime = get-date ("{0}T{1}" -f ($matches[1..2]))
				    }
					
					# Otherwise it's a loggable line (if it contains non-whitespace characters)
					elseif ($line -match "\S")
					{
                        if ($logtime -ge $DeltaTime)
                        {
                            $ht = @{
                                '_time' = $logtime.toString("yyyy-MM-ddTHH:mm:ss")
                                'HCRecordType'="EMailLog_Log"
                                'Detail'= "$line"
                                'Impact'='Unknown'
                            }
                            $jsonOutput  = ConvertTo-JSON $ht
#                            write-host $jsonOutput
                            $streamWriter.Write($jsonOutput)
						}
                    }
                }
            }
            $streamWriter.Close()
        }
        else
        {
            Write-Log -ErrorLevel Information -Message "Export-Custom,No recent EMailLog log files found in $EMailLogFolder"
        }

        Write-Log -ErrorLevel Information -Message "Export-Custom,Complete"
    }        
}
