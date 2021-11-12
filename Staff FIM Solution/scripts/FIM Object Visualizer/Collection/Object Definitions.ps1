#--------------------------------------------------------------------------------------------------------------------
 Set-Variable -Name URI          -Value "http://localhost:5725/resourcemanagementservice" -Option Constant 
#---------------------------------------------------------------------------------------------------------------------------------------------------------
  "" | clip
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation}
 $exportData = export-fimconfig -uri $URI `
                                –onlyBaseResources `
                                -customconfig ("/ObjectTypeDescription[not(starts-with(DisplayName,'AAA'))]") `
								-ErrorVariable Err `
                                -ErrorAction SilentlyContinue 
 
 if($Err){throw $Err}
 if($exportData -eq $null) {throw "Object type descriptions not found"}
 $exportData | convertfrom-fimresource -file $fileName
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Fix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 [xml]$xmlDoc = get-content $fileName
 $xmlDoc.Results.SetAttribute("Filter", "ObjectTypeDescription")
 $xmlDoc.Results.SetAttribute("Objects", "ObjectDefinitions")
 $xmlDoc.save($fileName)
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
