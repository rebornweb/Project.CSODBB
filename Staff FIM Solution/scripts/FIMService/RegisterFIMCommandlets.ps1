# From https://social.technet.microsoft.com/wiki/contents/articles/14550.how-to-run-fim-2010-powershell-cmdlets-on-non-fim-machine.aspx
# x86 option:
# *** MUST RUN AS ADMINISTRATOR!!! ***
cls

cd "D:\Scripts\FIMService"
set-alias installutil "$($env:windir)\Microsoft.NET\Framework\v2.0.50727\installutil.exe"
set-alias gacutil "$($env:windir)\Microsoft.NET\Framework\v2.0.50727\installutil.exe"
installutil .\Microsoft.ResourceManagement.Automation.dll
# See https://weblogs.asp.net/adweigert/powershell-install-gac-gacutil-for-powershell for GAC script I adapted here
./GacInstall.ps1 -dll "D:\Scripts\FIMService\Microsoft.ResourceManagement.dll"
./GacInstall.ps1 -dll "D:\Scripts\FIMService\Microsoft.IdentityManagement.Logging.dll"

# Manually copy 3 DLLs from this folder to C:\Program Files\Microsoft Forefront Identity Manager\2010\Service
# then:
add-pssnapin FIMAutomation
