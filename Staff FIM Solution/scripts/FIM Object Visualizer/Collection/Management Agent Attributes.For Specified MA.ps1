#----------------------------------------------------------------------------------------------------------
# Name   : Management Agent Attributes.ps1
# Created: 12/20/09
# Purpose: Script to create a list of the management agents and the selected attributes
#----------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice" -option constant 
#----------------------------------------------------------------------------------------------------------
 Function AddAttributes
 {
    Param($XmlDoc, $CurNode, $AttrList)
	End
	{
        [xml]$xmlAttrs = "<root>" + $($AttrList) + "</root>"
        $xmlAttrs.root.attribute | foreach{
            $newNode = $XmlDoc.CreateElement("MaAttribute")
	        $newNode.set_InnerText($_)
	        $CurNode.AppendChild($newNode) | Out-Null
        }

	}
 }
#----------------------------------------------------------------------------------------------------------
 if($args.count -ne 1) {throw "Missing MA name parameter"}
 $maName = $args[0]

 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName   = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
#----------------------------------------------------------------------------------------------------------
 $exportData = export-fimconfig -uri $URI `
                                –onlyBaseResources `
                                -customconfig ("/ma-data[DisplayName='$maName']") `
				-MessageSize 9999999
#                                -customconfig ("/ma-data[DisplayName='$maName']") `
#                                -ErrorVariable Err `
#                                -ErrorAction SilentlyContinue 
 if($Err){throw $Err}
 if($exportData -eq $null) {throw "There are no management agents configured on this system"}
 [xml]$xmlDoc = "<ManagementAgents/>"
 
 $exportData | ForEach{
    $maNode     = $xmlDoc.CreateElement("ManagementAgent")
	$maNameNode = $xmlDoc.CreateElement("MaName")
 
    $maName  = $_.ResourceManagementObject.ResourceManagementAttributes | 
                Where-Object {$_.AttributeName -eq "DisplayName"}

	$maNameNode.set_InnerText($maName.Value)
	$maNode.AppendChild($maNameNode)
    
	$maAttrs = $xmlDoc.CreateElement("MaAttributes")
	$maNode.AppendChild($maAttrs)

	$attrList = $_.ResourceManagementObject.ResourceManagementAttributes | 
                Where-Object {$_.AttributeName -eq "SyncConfig-attribute-inclusion"}
    If($attrList -ne $null) {AddAttributes -XmlDoc $xmlDoc -CurNode $maAttrs -AttrList $attrList.Value} 
	$xmlDoc.documentElement.AppendChild($maNode)
 }				
 $xmlDoc.save($fileName)
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------

