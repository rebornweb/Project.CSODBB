#---------------------------------------------------------------------------------------------------------------------------------------------------------
 "" | clip
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/Set[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'QDET')) and not(starts-with(DisplayName,'NAB')) and not(starts-with(DisplayName,'CLINK')) and not(starts-with(DisplayName,'DEEWR'))]",`
    "/ManagementPolicyRule[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'QDET')) and not(starts-with(DisplayName,'NAB')) and not(starts-with(DisplayName,'CLINK')) and not(starts-with(DisplayName,'DEEWR'))]") -MessageSize 9999999 -AllLocales
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
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
