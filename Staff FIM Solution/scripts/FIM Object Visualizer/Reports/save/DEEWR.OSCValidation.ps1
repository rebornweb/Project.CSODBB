#---------------------------------------------------------------------------------------------------------------------------------------------------------
 "" | clip
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/DEEWR-claimType","/DEEWR-esg-role[DisplayName='IAMOSC']",`
    "/DEEWR-esg-site[ObjectID=/DEEWR-claim[DEEWR-claimTypeID=/DEEWR-claimType[starts-with(DisplayName,'IAMOSC') or starts-with(DisplayName,'Org')]]/DEEWR-claimValueID]",`
    "/DEEWR-claim[(DEEWR-claimTypeID=/DEEWR-claimType[starts-with(DisplayName,'IAMOSC') or starts-with(DisplayName,'Org')])]") -MessageSize 99999999 -AllLocales
 $data | convertfrom-fimresource -file $fileName
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Save XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# [xml]$xmlDoc = get-content $fileName
# $xmlDoc.save($fileName)
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
