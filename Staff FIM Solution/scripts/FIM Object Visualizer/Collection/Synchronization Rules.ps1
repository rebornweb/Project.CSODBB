#---------------------------------------------------------------------------------------------------------------------------------------------------------
  "" | clip
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/SynchronizationRule[not(starts-with(DisplayName,'AAA'))]")
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
 $data | convertfrom-fimresource -file $fileName
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Fix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 [xml]$xmlDoc = get-content $fileName
 $szlist1 = "RelationshipCriteria|ConnectedSystemScope|InitialFlow|PersistentFlow|SynchronizationRuleParameters|ExistenceTest"
 $szlist2 = "Values/string|Value"
 
 foreach($item In $szlist1.Split("|"))
 {
    foreach($nodeList In $xmlDoc.selectNodes("//ResourceManagementAttribute[AttributeName='$item']"))
    {
       foreach($nodeVal In $szlist2.Split("|"))
       { 
          foreach($curNode In $nodeList.selectNodes("$nodeVal"))
          { 
             [xml]$newNode = "<Root>" + $curNode.get_InnerText() + "</Root>"
             $curNode.get_ParentNode().AppendChild($xmlDoc.importNode($newNode.get_DocumentElement().get_FirstChild(), $true)) | out-null
             $curNode.get_ParentNode().RemoveChild($curNode) | out-null
          }
       }
    }
 }
 
 $xmlDoc.Results.SetAttribute("Filter", "SynchronizationRule")
 $xmlDoc.Results.SetAttribute("Objects", "Synchronization Rules")
 $xmlDoc.save($fileName)
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
