#----------------------------------------------------------------------------------------------------------
 "" | clip 
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
#----------------------------------------------------------------------------------------------------------
$xmlPolicy = Export-FIMConfig -uri http://localhost:5725/resourcemanagementservice -customConfig "/ForestConfiguration","/DomainConfiguration","/ConfigurationInformationConfiguration"`
    ,"/HomepageConfiguration[not(starts-with(DisplayName,'AAA'))]","/SystemResourceRetentionConfiguration[not(starts-with(DisplayName,'AAA'))]"`
    ,"/NavigationBarConfiguration[not(starts-with(DisplayName,'AAA'))]","/PortalUIConfiguration[not(starts-with(DisplayName,'AAA'))]","/ObjectVisualizationConfiguration" -MessageSize 9999999 -AllLocales|
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes}
 
if ($xmlPolicy -eq $null)
{
    Write-Host "Export did not successfully retrieve configuration from FIM.  Please review any error messages and ensure that the arguments to GetFIMObjects are correct."
}
else
{
    # Write-Host "Exported " $xmlPolicy.Count " objects from FIM."
    $xmlPolicy | ConvertFrom-FIMResource -file $fileName
    # Write-Host "Pilot file is saved as " $fileName "."
    if($xmlPolicy.Count -gt 0)
    {
        Write-Host "Export complete."
    }
    else
    {
        Write-Host "While export completed, there were no resources.  Please ensure that the arguments to Export-FIMConfig are correct." 
     }
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Fix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 [xml]$xmlDoc = get-content $fileName
 $szlist1 = "ConfigurationData|StringResources"
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
 
 $xmlDoc.Results.SetAttribute("Filter", "ConfigurationData")
 $xmlDoc.Results.SetAttribute("Objects", "ConfigurationData")
 $xmlDoc.save($fileName)
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------
