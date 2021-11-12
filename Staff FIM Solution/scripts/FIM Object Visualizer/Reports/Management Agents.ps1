#----------------------------------------------------------------------------------------------------------
# Name   : ListManagementAgents.ps1
# Created: 12/20/09
# Purpose: Script to display a list of the configured mangement agents
#----------------------------------------------------------------------------------------------------------
 Set-Variable -Name URI       -Value "http://localhost:5725/resourcemanagementservice" -Option constant
#----------------------------------------------------------------------------------------------------------
 Function GetSynchronizationRules 
 {
    Param($ConnectedSystem, $XmlDoc, $CurNode)
	End
	{
	   $CurObject = export-fimconfig -URI $URI `
                                     –onlyBaseResources `
                                     -customconfig ("/SynchronizationRule[ConnectedSystem='$ConnectedSystem'][not(starts-with(DisplayName,'AAA'))]") `
                                     -ErrorVariable Err `
                                     -ErrorAction SilentlyContinue 

	   If($Err){Throw $Err}
       If($CurObject -eq $null) {return}
	   
	   $CurObject | ForEach {
	      $srName   =  ($_.ResourceManagementObject.ResourceManagementAttributes | `
                        Where-Object {$_.AttributeName -eq "DisplayName"}).Value
	      $flowType = ($_.ResourceManagementObject.ResourceManagementAttributes | `
                       Where-Object {$_.AttributeName -eq "FlowType"}).Value
					   
	      $srType = ""
		  Switch($flowType)
		  {
		     0 {$srType = "Inbound"}
			 1 {$srType = "Outbound"}
			 default {$srType = "Duplex"}
		  }
   		  $newNode = $XmlDoc.CreateElement("SynchronizationRule")
		  $newNode.set_InnerText("$srName, $srType") | Out-Null
		  $CurNode.SelectSingleNode("SynchronizationRules").AppendChild($newNode) | Out-Null
	   }
	}
 }
#----------------------------------------------------------------------------------------------------------
 If(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
#----------------------------------------------------------------------------------------------------------
 $lstMA = export-fimconfig -URI $URI `
                           –onlyBaseResources `
                           -customconfig ("/ma-data") `
                           -ErrorVariable Err `
                           -ErrorAction SilentlyContinue 

 If($Err){Throw $Err}
 If($lstMA -eq $null) {Throw "There are no management agents installed"}

 $xmlString = "<ManagementAgents>"
 $lstMA | ForEach {
    $srName   = ($_.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "DisplayName"}).Value
	$srType   = ($_.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "SyncConfig-category"}).Value
	$dsSource = ($_.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "SyncConfig-id"}).Value

    $xmlString += "<ManagementAgent>" + 
	              "<Name>$($srName)</Name>" + 
		          "<ID>$((($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2])</ID>" + 
			      "<Type>$($srType)</Type>" +  
				  "<DataSource>$($dsSource)</DataSource>" +  
				  "<SynchronizationRules/>" +
			      "</ManagementAgent>"
 }
 $xmlString += "</ManagementAgents>" 
 
 [xml]$xmlDoc = $xmlString
 $xmlDoc.ManagementAgents.ManagementAgent | ForEach {
    GetSynchronizationRules -ConnectedSystem $_.DataSource `
	                        -XmlDoc $xmlDoc `
							-CurNode $_
 }

 $xmlDoc.Save($fileName)				
#------------------------------------------------------------------------------------------------------------  
 Trap 
 {
    $_.Exception.Message | clip
    Exit 1
 }
#------------------------------------------------------------------------------------------------------------