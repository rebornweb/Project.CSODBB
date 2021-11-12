Param(
    [string]$FIMService = "localhost", 
    [string]$MAName = "DEV ADMA", 
    [string]$archiveFolder = "D:\Logs\FIMSyncService\PendingExports",
# Debug variable enables Write-Host and Write-Progress commands
# *** NOTE: $debug must be $False in order to run this from Event Broker!!! ***
    [boolean]$debug = $False,
# TODO: write this data to a SQL database
# Allow the writing of a hard-copy of the XML file (with inserted XSL reference) to be optional
    [boolean]$writeToArchiveFolder = $true
)
#----------------------------------------------------------------------------------------------------------
 "" | clip

# 1. Set up/derive additional variables and libraries
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $sourceFolder = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\$MAName\"
 $fileNameNoPath = $myInvocation.mycommand.Name -replace ".ps1",".xml"
 $fileName = "$dataFolder\$fileNameNoPath"
 $sourceFileName = "$sourceFolder\$fileNameNoPath"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $now = Get-Date
 if($debug -eq $true) {Write-Host "*** Setup successdul. Commencing transformation. Time: "$now " ***"}

# 2. Copy XML drop file to data folder
 copy-item $sourceFileName -destination $dataFolder
 $now = Get-Date
 if($debug -eq $true) {Write-Host "*** xml file colied to $dataFolder. Time: "$now}

# 3. (Optional) Save XML file to archive folder with extracted XML and referenced XSLT
 if($writeToArchiveFolder) {
     # Re-load XML from file (only do this for the current data)
     [xml]$xmlDoc = get-content $fileName
     $now = Get-Date
     if($debug -eq $true) {Write-Host "*** get-content complete. Time: " $now " ***"}
     # Append stylesheet reference and save archive xml
     [string]$datePart = Get-Date -format "yyyyMMddTHHmmss"
     $archiveFileName = "$archiveFolder\$MAName.$datePart.xml"
     [xml]$xmlArchive = new-object Xml
     $xmlArchive.LoadXml($xmlDoc.OuterXml)
     if($debug -eq $true) {Write-Host "*** XML history $archiveFileName reloaded: " $now " ***"}
     $xmlpi = $xmlArchive.CreateProcessingInstruction("xml-stylesheet", "type=""text/xsl"" href=""./PendingExports.xsl""")
     $newNode = $xmlArchive.AppendChild($xmlpi)
     # move the PI node to the top
     $docRoot = $xmlArchive.RemoveChild($xmlArchive.documentElement)
     $newerNode = $xmlArchive.AppendChild($docRoot)
     $xmlArchive.save($archiveFileName)
     if($debug -eq $true) {Write-Host "*** XML history $archiveFileName saved with PI: " $now " ***"}
 }
 
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
