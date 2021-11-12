#--------------------------------------------------------------------------------------------------------------------------
# Name       : Metaverse Schema.ps1
# Date       : 07\10\09
# Description: Powershell script to display the metaverse schema.
#--------------------------------------------------------------------------------------------------------------------------
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
 if($exportObject -eq $null) {throw "There is no metaverse data available on your system!"} 
 
 $schemaData = $exportObject.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "SyncConfig-schema"}
               
 [xml]$xmlSchema = $schemaData.Value
 $xmlSchema.Save($fileName)				
#----------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
