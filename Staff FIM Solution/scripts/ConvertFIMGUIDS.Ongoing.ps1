param (
    $serverPath = "D:\UNIFY\FIM.StaffDeploy",
    $subFolderV4 = "Server", 
    $subFolderV3 = "Server.Prod"
)

# This script is specifically for CSODBB where the GUIDs for MAs and Run Profiles somehow managed to become different in PROD to what they are in both DEV and UAT.

$serverExportFolderV4 = "$serverPath\$subFolderV4"
$serverExportFolderV3 = "$serverPath\$subFolderV3"

# Load all our Sync Server export XML files and construct an Xml document of MA and RP (run profile) nodes with names and guids - starting with the V3 config
$maFiles=get-childitem $serverExportFolderV3 "MA-{*.xml" -rec
[System.Xml.XmlDocument]$maData = "<MAs/>"
$maData.PreserveWhitespace = $true
$isUpdates = $false

foreach ($file in $maFiles) {
    [xml]$content = Get-Content $file.PSPath
    [System.Xml.XmlNode]$ma = $maData.DocumentElement.AppendChild($maData.CreateElement("MA"))
    
    $ma.SetAttribute(“id”, $content."saved-ma-configuration"."ma-data"."id".Replace("{","").Replace("}","").ToLower());
    $ma.SetAttribute(“name”, $content."saved-ma-configuration"."ma-data"."name");
    foreach ($node in $content."saved-ma-configuration"."ma-data"."ma-run-data"."run-configuration") {
        [System.Xml.XmlNode]$rp = $ma.AppendChild($maData.CreateElement("RP"))
        $rp.SetAttribute(“id”, $node."id".Replace("{","").Replace("}","").ToLower());
        $rp.SetAttribute(“name”, $node."name");
        $rp.SetAttribute(“maname”, $content."saved-ma-configuration"."ma-data"."name");
    }
}
$maData.Save("$serverPath\sourceGuids.xml");

# Load (new) V4 config
$maFiles=get-childitem $serverExportFolderV4 "MA-{*.xml" -rec
[System.Xml.XmlDocument]$maData = "<MAs/>"
$maData.PreserveWhitespace = $true
$isUpdates = $false

foreach ($file in $maFiles) {
    [xml]$content = Get-Content $file.PSPath
    [System.Xml.XmlNode]$ma = $maData.DocumentElement.AppendChild($maData.CreateElement("MA"))
    
    $ma.SetAttribute(“id”, $content."saved-ma-configuration"."ma-data"."id".Replace("{","").Replace("}","").ToLower());
    $ma.SetAttribute(“name”, $content."saved-ma-configuration"."ma-data"."name");
    foreach ($node in $content."saved-ma-configuration"."ma-data"."ma-run-data"."run-configuration") {
        [System.Xml.XmlNode]$rp = $ma.AppendChild($maData.CreateElement("RP"))
        $rp.SetAttribute(“id”, $node."id".Replace("{","").Replace("}","").ToLower());
        $rp.SetAttribute(“name”, $node."name");
        $rp.SetAttribute(“maname”, $content."saved-ma-configuration"."ma-data"."name");
    }
}
$maData.Save("$serverPath\targetGuids.xml");

# What we need to do is update the V4 config with the guids from the V3 config matching on MA name

[xml]$maGuidsV3 = get-content ("$serverPath\sourceGuids.xml")
[xml]$maGuidsV4 = get-content ("$serverPath\targetGuids.xml")


foreach ($file in $maFiles) {
    [bool]$isChanged = $false
    [xml]$content = Get-Content $file.PSPath
    [string]$thisMAName = $content."saved-ma-configuration"."ma-data"."name"
    $thisMAGUID = ($maGuidsV3.MAs.MA | where-object {$_.name -eq $thisMAName})."id"
    $thisMAGUIDString = "{$($thisMAGUID)}".ToUpper()
    $oldGUIDString = ""
    #$content."saved-ma-configuration"."ma-data"."id" = $thisMAGUID
    "$thisMAName = $($content."saved-ma-configuration"."ma-data"."id") => $thisMAGUIDString"
    if ($thisMAGUID) {
        $oldGUIDString = $content."saved-ma-configuration"."ma-data"."id"
        $content."saved-ma-configuration"."ma-data"."id" = $thisMAGUIDString
        "updated $thisMAName guid to $($content."saved-ma-configuration"."ma-data"."id")"
        $isChanged = $true
        # Now we need to replace all the run profile guids too ...
        foreach ($node in $content."saved-ma-configuration"."ma-data"."ma-run-data"."run-configuration") {
            $thisRPGUID = (($maGuidsV3.MAs.MA | where-object {$_.name -eq $thisMAName})."RP" | where-object {$_.name -eq $($node.name)})."id"
            $thisRPGUIDString = "{$($thisRPGUID)}".ToUpper()
            if ($thisRPGUID) {
                $node."id" = $thisRPGUIDString
                "updated $($node.name) guid to $($node."id")"
            }
        }
    }
    if ($isChanged) {
        $content.Save("$serverExportFolderV4\$($file.Name)")
        ren "$serverExportFolderV4\$($file.Name)" "$serverExportFolderV4\$($file.Name -Replace $oldGUIDString, $thisMAGUIDString)"
    }
}

# TODO: replace all the MA guids in MV.XML !!!!