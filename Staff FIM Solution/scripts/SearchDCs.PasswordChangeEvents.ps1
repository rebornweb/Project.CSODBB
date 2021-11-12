# Search and locate targeted 4723 events where the identity is NOT svcilm_ma_ad
# Refer to https://serverfault.com/questions/684404/how-to-check-who-reset-the-password-for-a-particular-user-in-active-directory-on

$Parameters = @{}
$Parameters.Add("EventLog_Names", @("Security"))
$Parameters.Add("EventLog_EntryTypes", @("Information"))
$Parameters.Add("EventLog_MaxEvents","100")
$Parameters.Add("EventLog_DataFile_Events", "CSODBB-PROD_WindowsEventLog_[Server]_[EventLog].json")
$RunType = "Full"
$DebugMode = $true
$ScriptDir = "D:\Scripts\DataCollection"
$ThisDataDir = "D:\Logs\EventViewer"
$DebugLogFile = "$ScriptDir\SearchDCs.PasswordChangeEvents.log"

Import-Module -Name $ScriptDir\Unify.Health.psm1 -ErrorAction stop

$domain = Get-ADDomain
#$domain.DomainControllersContainer | Get-ChildItem
#Get-ADDomainController
$dcs = Get-ADObject -LDAPFilter "(objectClass=computer)" -SearchBase $($domain.DomainControllersContainer)
#foreach ($dc in $dcs) {
    $dc = $dcs[0]
    [string]$ComputerName = $dc.Name

            $AvailableEventLogs = Get-EventLog -List -ComputerName $ComputerName | Select-Object "Log"
            foreach ($LogName in $Parameters.EventLog_Names)
            {                
                if ($AvailableEventLogs.Log -contains $LogName)
                {
                    Write-Log -ErrorLevel Information -Console -Message "Export-WindowsEventLogs,Exporting events from $ComputerName, $LogName log"

                    ## Construct the Get-EventLog command based on options
                    $cmd = "Get-EventLog -Index @(4724) -LogName '" + $LogName + "' -EntryType @('" + ($Parameters.EventLog_EntryTypes -join "','") + "')"
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
                        $arr = @()
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
                            $arr += $ht
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

#}