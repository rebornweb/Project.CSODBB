#----------------------------------------------------------------------------------------------------------------------------------------
# Name   : ReplicationDocumenter.ps1
# Created: 20/02/10
# Purpose: Script to document the active metaververse schema and the FIM MA EAFs
#----------------------------------------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice" -option constant 
#----------------------------------------------------------------------------------------------------------------------------------------
 "" | clip
 clear-host
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
#----------------------------------------------------------------------------------------------------------------------------------------
 $exportObject = export-fimconfig -uri $URI `
                                  –onlyBaseResources `
                                  -customconfig ("/mv-data")`
								  -ErrorVariable Err `
                                  -ErrorAction SilentlyContinue 
 if($Err){throw $Err}
 if($exportObject -eq $null) {throw "There is no MV data object on your system!"} 
#----------------------------------------------------------------------------------------------------------------------------------------
 $importFlows = $exportObject.ResourceManagementObject.ResourceManagementAttributes | `
                Where-Object {$_.AttributeName -eq "SyncConfig-import-attribute-flow"}
               
 $schemaData  = $exportObject.ResourceManagementObject.ResourceManagementAttributes | `
                Where-Object {$_.AttributeName -eq "SyncConfig-schema"}
#----------------------------------------------------------------------------------------------------------------------------------------
 $exportObject = export-fimconfig -uri $URI `
                                  –onlyBaseResources `
                                  -customconfig ("/ma-data[SyncConfig-category='FIM']")`
								  -ErrorVariable Err `
                                  -ErrorAction SilentlyContinue 
 if($Err){throw $Err}
 if($exportObject -eq $null) {throw "There is no FIM MA configured on your system!"} 
 $eafFlows = ($exportObject.ResourceManagementObject.ResourceManagementAttributes | 
              Where-Object {$_.AttributeName -eq "SyncConfig-export-attribute-flow"}).Value
#----------------------------------------------------------------------------------------------------------------------------------------
 [xml]$xmlSchema = "<root>" + $importFlows.Value + $schemaData.Value + $eafFlows + "</root>"
 $xmlSchema.Save($fileName)
#----------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
