### 
### Set-LocalVariables.ps1
###
### Sets variables relevant to this environment and called by other scripts. 
### This allows scripts to be copied between Dev, test and Prod without needing to change variables.
###


[string]$Domain = "dbb"
[string]$DomainName = "dbb.local"
[string]$SearchBase = "DC=dbb,DC=local"

[string]$SQLServer = "occcp-db301"
[string]$SQLInstance = "Default"

[string]$URI = "http://occcp-im201:5725/ResourceManagementService"
[string]$FIMService1 = "occcp-im201"
[string]$FIMSyncService = "occcp-im301"

[string]$ScriptFolder = "D:\Scripts"
[string]$WFScriptFolder = "D:\Scripts\WF"
[string]$WFLogFolder = "D:\Logs\WF"

[string[]]$IncludeScripts = @("D:\Scripts\Shared\FIMFunctions.ps1","D:\Scripts\Shared\InstallationFunctions.ps1")
