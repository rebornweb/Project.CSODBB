#----------------------------------------------------------------------------------------------------------
# Name   : GetResourceByName.ps1
# Created: 01/12/10
# Author : markvi
# Purpose: Script to retrieve object data by name
#----------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant 
#----------------------------------------------------------------------------------------------------------
 "" | clip
 $xmlFilePath = $MyInvocation.MyCommand.Path -replace(".ps1", ".xml") 
 $xmlFilePath | clip
 If($args.count -ne 2) {Throw "Parameter name missing!"}
 $resourceName = $args[0]
 $nameType     = $args[1]
 
 If($nameType -eq 0) {$Filter = "/*[DisplayName='$resourceName']"}
 Else {$Filter = "/*[ObjectID='$resourceName'][not(starts-with(DisplayName,'AAA'))]"}

 If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation}
 $curObject = export-fimconfig -uri $URI `
                               –onlyBaseResources `
                               -customconfig ($Filter)`
     			               -ErrorVariable Err `
                               -ErrorAction SilentlyContinue 

 If($Err){Throw $Err}
 If($curObject -eq $null) {Throw "Resource not found!"} 
 $curObject | convertfrom-fimresource -file $xmlFilePath
#----------------------------------------------------------------------------------------------------------
 Trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------
