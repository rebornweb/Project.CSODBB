cd C:\Windows\Microsoft.NET\Framework64\v2.0.50727

set-alias installutil $env:windir\Microsoft.NET\Framework\v2.0.50727\installutil

installutil -i "F:\Program Files\Microsoft Forefront Identity Manager\2010\Service\Microsoft.ResourceManagement.Automation.dll"

#set-alias gacutil C:\Windows\Microsoft.NET\Framework\v2.0.50727\
#gacutil -i "F:\Program Files\Microsoft Forefront Identity Manager\2010\Service\Microsoft.ResourceManagement.dll"
#gacutil -i "F:\Program Files\Microsoft Forefront Identity Manager\2010\Service\Microsoft.IdentityManagement.Logging.dll"

Get-PSSnapin FIMAutomation -Registered | Add-PSSnapin
