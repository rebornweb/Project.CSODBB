#---------------------------------------------------------------------------------------------------------------------------------------------------------
 "" | clip 
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/ManagementPolicyRule[not(starts-with(DisplayName,'AAA')) and not(contains(DisplayName,'NAB')) and not(contains(DisplayName,'CLINK')) and not(contains(DisplayName,'DEEWR'))]",`
    "/Set[DisplayName='All Objects']","/EmailTemplate","/FilterScope","/SynchronizationRule[not(starts-with(DisplayName,'AAA')) and not(FlowType='0')]") -MessageSize 99999999 -AllLocales
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
 $data | convertfrom-fimresource -file $fileName
 [xml]$xmlDoc = get-content $fileName

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Affix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 foreach($curNode In $xmlDoc.selectNodes("//ResourceManagementAttribute[AttributeName='XOML']"))
 {
    [xml]$xmlxoml = $curNode.Value 
    
    $xmlXoml.SequentialWorkflow.ChildNodes | where-object {$_ -ne $null} |
    foreach{
       [xml.xmlElement]$activityNode = $_
       $root = $xmlDoc.CreateElement("Activity")
       $newElem = $xmlDoc.CreateElement("Type")
       $newElem.set_InnerText($_.LocalName) | out-null
       $root.AppendChild($newElem) | out-null
       switch($_.LocalName)
       {
            "SynchronizationRuleActivity"
            {
               $szlist = "SynchronizationRuleId|Action|AttributeId|AddValue|RemoveValue"
            }
            "LoggingActivity"
            {
               $szlist = "LogActivityName|LogFile|OverwriteLogFile|LogMode"
            }
            "EventBrokerChangesActivity"
            {
               $szlist = "EndPointAddress|EndPointConfigurationName|OperationListGuid|Description"
            }
            "FunctionActivity"
            {
               $szlist = "Description|Destination|FunctionExpression|isCustomExpression"
            }
            "LookupPropertiesActivity"
            {
               $szlist = "XPathFilter|AttributeNames|SaveWorkflowDataStorageMode|LogFile|OverwriteLogFile|LogMode"
            }
            "UpdateResourceFromWorkflowData"
            {
               $szlist = "ObjectType|DisplayName|ResourceQuery|ExtraAttributes|DeleteIfFound|InsertIfNotFound|SaveWorkflowDataStorageMode|LogFile|OverwriteLogFile|LogMode"
            }
            "EmailNotificationActivity"
            {
               $szlist = "To|EmailTemplate"
            }
            "FilterValidationActivity"
            {
               $szlist = "FilterScopeIdentifier"
            }
            "GroupValidationActivity"
            {
               $szlist = "ValidationSemantics"
            }
            "ApprovalActivity"
            {
               $szlist = "Approvers|Threshold|Duration|Escalation|WorkflowServiceAttributes"
            }
            "PWResetActivity"
            {
               $szlist = "Timeout|DocumentType|ReferenceProperties|WorkflowServiceAttributes"
            }
            "RequestorValidationActivity"
            {
               $szlist = "OwnerAuthorization"
            }
            "DeleteResourceActivity"
            {
               $szlist = "ResourceId|ActorId"
            }
            default
            {
               $szlist = "TODO"
            }
       }
       foreach($item In $szlist.Split("|"))
       {
          $newElem = $xmlDoc.CreateElement($item)
          $newElem.set_InnerText($activityNode.$item) | out-null
          $root.AppendChild($newElem) | out-null
       }
       $curNode.AppendChild($root) | out-null
    }
 }  
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Fix Sync Rule XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
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
 #---------------------------------------------------------------------------------------------------------------------------------------------------------
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
