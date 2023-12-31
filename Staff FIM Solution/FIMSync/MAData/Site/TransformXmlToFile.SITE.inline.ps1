Import-Module "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\Extensions\Common\TransformXmlToFile.ps1";
[string]$InputPath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\Site\"
[string]$OutputPath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\Site\"
[string]$XmlInputFile = "Sites.xml"
[string]$LdifOutputFile = "csoSites.ldif"
[string]$XslFile = "XmlToLDIF.SITE.xslt"

$debug = $False
$now = Get-Date
if($debug -eq $True) {Write-Host "*** Step #1 starting: " $now " ***"}
Del "$OutputPath$LdifOutputFile"
if($debug -eq $True) {Write-Progress -Activity "Transforming XML" -Status "Transforming XML (template mode) => ./$LdifOutputFile"}
SaveTransformedXML "$InputPath$XmlInputFile" `
    -IsTemplate $False -XSLPath "$OutputPath$XslFile" `
    -XMLOutputPath "$OutputPath$LdifOutputFile"
$now = Get-Date
if($debug -eq $True) {Write-Host "*** All steps finished: " $now " ***"}

