#---------------------------------------------------------------------------------------------------------------------------------------------------------
 "" | clip
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/WorkflowDefinition[not(starts-with(DisplayName,'AAA'))]")
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
 $data | convertfrom-fimresource -file $fileName
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Fix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 $i = 1
 [xml]$xmlDoc = get-content $fileName
 foreach($curNode In $xmlDoc.selectNodes("//ResourceManagementAttribute[AttributeName='XOML']"))
 {
    [xml]$xmlxoml = $curNode.Value 
    If($xmlxoml.SequentialWorkflow.SynchronizationRuleActivity) 
    {
      
       $root = $xmlDoc.CreateElement("SynchronizationRuleActivity")
       $szlist = "SynchronizationRuleId|Action|AttributeId|AddValue|RemoveValue"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($xmlxoml.SequentialWorkflow.SynchronizationRuleActivity.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }

       $curNode.AppendChild($root) | out-null
    }
 }  
 $xmlDoc.Results.SetAttribute("Filter", "WorkflowDefinition")
 $xmlDoc.Results.SetAttribute("Objects", "Workflows")
 $xmlDoc.save($fileName)
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
