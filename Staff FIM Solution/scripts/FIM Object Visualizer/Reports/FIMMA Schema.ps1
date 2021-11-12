#----------------------------------------------------------------------------------------------------------------------------------------
# Name   : FIMMA Schema.ps1
# Created: 12/12/09
# Purpose: Script to document the FIM MA schema
#----------------------------------------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice" -option constant 
#----------------------------------------------------------------------------------------------------------------------------------------
 clear-host
  "" | clip
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
#----------------------------------------------------------------------------------------------------------------------------------------
 $exportObject = export-fimconfig -uri $URI `
                                  –onlyBaseResources `
                                  -customconfig ("/ma-data[SyncConfig-category='FIM']")`
								  -ErrorVariable Err `
                                  -ErrorAction SilentlyContinue 
 if($Err){throw $Err}
 if($exportObject -eq $null) {throw "There is no FIM MA configured on your system!"} 
#----------------------------------------------------------------------------------------------------------------------------------------
 $schemaData = $exportObject.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "SyncConfig-private-configuration"}
 [xml]$xmlSchema = $schemaData.Value
 $xmlSchema.Save($fileName) 
#----------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------------------------------------
