#----------------------------------------------------------------------------------------------------------
 Function AppendXmlSection
 {
    Param([xml]$xmlDoc, [xml.xmlElement]$curNode, $testNode, $szlist, $elt)
    End
    {
        [xml]$xmlxoml = $curNode.Value 
        $xmlXoml.SequentialWorkflow.$testNode | where-object {$_ -ne $null} |
        foreach{
           $root = $xmlDoc.CreateElement($elt)
           foreach($item In $szlist.Split("|"))
           {
              $newElem = $xmlDoc.CreateElement($item)
              $newElem.set_InnerText($_.$item) | out-null
              $root.AppendChild($newElem) | out-null
           }
           $curNode.AppendChild($root) | out-null
        }
        # return $curNode
    }
 }
#----------------------------------------------------------------------------------------------------------
 Function GetFIMObjects
 {
    Param($filter)
    End
    {
       $exportObjects = export-fimconfig -uri "http://localhost:5725/resourcemanagementservice" `
                                         –onlyBaseResources `
                                         -customconfig ("$filter") `
                                         -ErrorVariable Err `
                                         -ErrorAction SilentlyContinue 
       if($Err){throw $Err}
       return $exportObjects                                 
    }
 }
#----------------------------------------------------------------------------------------------------------
 "" | clip
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = GetFIMObjects -filter "/WorkflowDefinition[starts-with(DisplayName,'DEEWR-Outbound')]"
# $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/WorkflowDefinition[starts-with(DisplayName,'DEEWR-Outbound')]")
# $data = GetFIMObjects -filter "/*[(ObjectID=/WorkflowDefinition[not(starts-with(DisplayName,'AAA'))])`
#  or (ObjectID=/ManagementPolicyRule[not(starts-with(DisplayName,'AAA'))][ActionWorkflowDefinition=/WorkflowDefinition[not(starts-with(DisplayName,'AAA'))]])`
#  or (ObjectID=/FilterScope/AllowedAttributes) or (ObjectID=/FilterScope/AllowedMembershipReferences)]"
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
 $data | convertfrom-fimresource -file $fileName
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Fix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 [xml]$xmlDoc = get-content $fileName
 foreach($curNode In $xmlDoc.selectNodes("//ResourceManagementAttribute[AttributeName='XOML']"))
 {
    [xml]$xmlxoml = $curNode.Value 
    
    $xmlXoml.SequentialWorkflow.ChildNodes | where-object {$_ -ne $null} |
    foreach{
       [xml.xmlElement]$activityNode = $_
       $root = $xmlDoc.CreateElement($_.LocalName)
       switch($_.LocalName)
       {
            "SynchronizationRuleActivity"
            {
               $szlist = "SynchronizationRuleId|Action|AttributeId|AddValue|RemoveValue"
               foreach($item In $szlist.Split("|"))
               {
                  $newElem = $xmlDoc.CreateElement($item)
                  $newElem.set_InnerText($activityNode.$item) | out-null
                  $root.AppendChild($newElem) | out-null
               }
            }
            default
            {
                  $newElem = $xmlDoc.CreateElement("TODO")
                  $root.AppendChild($newElem) | out-null
            }
       }
       $curNode.AppendChild($root) | out-null
    }
    
    # 1. Sync Rules
    $xmlXoml.SequentialWorkflow.SynchronizationRuleActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("SynchronizationRuleActivity")
       $szlist = "SynchronizationRuleId|Action|AttributeId|AddValue|RemoveValue"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 2. LoggingActivity
    $xmlXoml.SequentialWorkflow.LoggingActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("LoggingActivity")
       $szlist = "LogActivityName|LogFile|OverwriteLogFile|LogMode"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 3. EventBrokerChangesActivity
    $xmlXoml.SequentialWorkflow.EventBrokerChangesActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("EventBrokerChangesActivity")
       $szlist = "EndPointAddress|EndPointConfigurationName|OperationListGuid|Description"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 4. FunctionActivity
    $xmlXoml.SequentialWorkflow.FunctionActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("FunctionActivity")
       $szlist = "Description|Destination|FunctionExpression|isCustomExpression"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 5. LookupPropertiesActivity
    $xmlXoml.SequentialWorkflow.LookupPropertiesActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("LookupPropertiesActivity")
       $szlist = "XPathFilter|AttributeNames|SaveWorkflowDataStorageMode|LogFile|OverwriteLogFile|LogMode"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 6. UpdateResourceFromWorkflowData
    $xmlXoml.SequentialWorkflow.UpdateResourceFromWorkflowData | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("UpdateResourceFromWorkflowData")
       $szlist = "ObjectType|DisplayName|ResourceQuery|ExtraAttributes|DeleteIfFound|InsertIfNotFound|SaveWorkflowDataStorageMode|LogFile|OverwriteLogFile|LogMode"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 7. EmailNotificationActivity
    $xmlXoml.SequentialWorkflow.EmailNotificationActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("EmailNotificationActivity")
       $szlist = "To|EmailTemplate"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    # 8. FilterValidationActivity
    $xmlXoml.SequentialWorkflow.FilterValidationActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("FilterValidationActivity")
       $szlist = "FilterScopeIdentifier"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    #9. GroupValidationActivity
    $xmlXoml.SequentialWorkflow.GroupValidationActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("GroupValidationActivity")
       $szlist = "ValidationSemantics"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    #10. ApprovalActivity
    $xmlXoml.SequentialWorkflow.ApprovalActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("ApprovalActivity")
       $szlist = "Approvers|Threshold|Duration|Escalation|WorkflowServiceAttributes"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
    #11. PWResetActivity
    $xmlXoml.SequentialWorkflow.PWResetActivity | where-object {$_ -ne $null} |
    foreach{

       $root = $xmlDoc.CreateElement("PWResetActivity")
       $szlist = "Timeout|DocumentType|ReferenceProperties|WorkflowServiceAttributes"
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($_.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }

#    AppendXmlSection -xmlDoc $xmlDoc `
#                     -currNode $curNode `
#                     -testNode "SynchronizationRuleActivity" `
#                     -szlist "SynchronizationRuleId|Action|AttributeId|AddValue|RemoveValue" `
#                     -elt "SynchronizationRuleActivity"
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
