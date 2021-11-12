#---------------------------------------------------------------------------------------------------------------------------------------------------------
 "" | clip 
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/ManagementPolicyRule[not(starts-with(DisplayName,'AAA'))]")
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
 $data | convertfrom-fimresource -file $fileName

 [xml]$xmlDoc = get-content $fileName
 $xmlDoc.Results.SetAttribute("Filter", "ManagementPolicyRule")
 $xmlDoc.Results.SetAttribute("Objects", "Management Policy Rules")
 $xmlDoc.save($fileName)
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
