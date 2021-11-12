#----------------------------------------------------------------------------------------------------------
 Function AddDataItem
 {
    Param([xml]$xmlDoc, [xml.xmlElement]$curNode, $nodeName, $nodeValue = "")
	End
	{
	   $newElement = $xmlDoc.CreateElement($nodeName)
	   $newElement.set_InnerText($nodeValue)
	   $curNode.AppendChild($newElement) | Out-Null
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
 Function GetTippleObject
 {
    Param($wfId = "", $wfName = "", $wfAction = "", $srId = "", $srName = "", $srType = "")
    End
    {
       $newRecord = new-object psobject
       $newRecord | add-member noteproperty "SRId"     $srId
       $newRecord | add-member noteproperty "SRName"   $srName
       $newRecord | add-member noteproperty "SRType"   $srType
       $newRecord | add-member noteproperty "WFId"     $wfId 
       $newRecord | add-member noteproperty "WFName"   $wfName
       $newRecord | add-member noteproperty "WFAction" $wfAction 
       $newRecord | add-member noteproperty "MPRNames" ""
       return $newRecord
   }
 }
#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 $dataList = @()
#----------------------------------------------------------------------------------------------------------
 GetFIMObjects -filter "/WorkflowDefinition[not(starts-with(DisplayName,'AAA'))]"|
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes | 
 where-object {$_.AttributeName -eq "XOML"}} |
 foreach {
    $wfName = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "DisplayName"}).Value
    $wfId   = (($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2] 
  
    [xml]$xmlXoml = ($_.ResourceManagementObject.ResourceManagementAttributes | 
                     Where-Object {$_.AttributeName -eq "XOML"}).Value  
    
    $xmlXoml.SequentialWorkflow.SynchronizationRuleActivity | where-object {$_ -ne $null} |
    foreach{
       $dataList += GetTippleObject -wfId $wfId `
                                    -wfName $wfName `
                                    -wfAction $_.Action `
                                    -srId $_.SynchronizationRuleId
    }
 }
#----------------------------------------------------------------------------------------------------------
 GetFIMObjects -filter "/SynchronizationRule[not(starts-with(DisplayName,'AAA'))]" |
 foreach{
    $srName = ($_.ResourceManagementObject.ResourceManagementAttributes | 
               Where-Object {$_.AttributeName -eq "DisplayName"}).Value
    $srId   = ((($_.ResourceManagementObject.ResourceManagementAttributes | 
               Where-Object {$_.AttributeName -eq "ObjectID"}).Value).Split(":"))[2] 
    $srType = ($_.ResourceManagementObject.ResourceManagementAttributes | 
               Where-Object {$_.AttributeName -eq "FlowType"}).Value  
        
    $records = $dataList | where-object {$_.SRId -eq $srId} 
    if($records -ne $null) 
    {
       $records | foreach{
          $_.SRName = $srName
          $_.SRType = $srType
       }
    }
    else{$dataList += GetTippleObject -srId $srId -srName $srName -srType $srType}
 }
#----------------------------------------------------------------------------------------------------------
 GetFIMObjects -filter "/ManagementPolicyRule[not(starts-with(DisplayName,'AAA'))]" |
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes | 
               Where-Object {$_.AttributeName -eq "ActionWorkflowDefinition"}} | 
 foreach{
    $mprName = ($_.ResourceManagementObject.ResourceManagementAttributes | 
                Where-Object {$_.AttributeName -eq "DisplayName"}).Value
                      
    foreach($wfVal in ($_.ResourceManagementObject.ResourceManagementAttributes | 
                       Where-Object {$_.AttributeName -eq "ActionWorkflowDefinition"}).Values)
    {
       foreach($curRec in ($dataList | where-object{$_.WFId -eq ($wfVal.Split(":"))[2]}))
       {
          if($curRec.MPRNames.length -gt 0) {$curRec.MPRNames += ","}
          $curRec.MPRNames += $mprName
       }
    }                  
 }
#----------------------------------------------------------------------------------------------------------
 [xml]$xmlSchema = "<Configurations/>"
 $dataList | foreach{
    $newNode = $xmlSchema.CreateElement("Configuration")
	$xmlSchema.documentElement.AppendChild($newNode) | Out-Null
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "SRId"     -nodeValue $_.SRId
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "SRName"   -nodeValue $_.SRName
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "SRType"   -nodeValue $_.SRType
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "WFId"     -nodeValue $_.WFId
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "WFName"   -nodeValue $_.WFName
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "WFAction" -nodeValue $_.WFAction
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "MPRNames" -nodeValue $_.MPRNames
 }
 
 $xmlSchema.Save($fileName)				
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------
