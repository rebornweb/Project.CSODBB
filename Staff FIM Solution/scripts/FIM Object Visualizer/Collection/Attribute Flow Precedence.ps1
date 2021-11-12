#----------------------------------------------------------------------------------------------------------
 Set-Variable -Name URI       -Value "http://localhost:5725/resourcemanagementservice" -Option Constant 
 Set-Variable -Name NameSpace -Value "root\MicrosoftIdentityIntegrationServer" -Option Constant
#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"

  "" | clip
#----------------------------------------------------------------------------------------------------------
 $xmlFilePath = $MyInvocation.MyCommand.Path -replace(".ps1", ".xml") 
 $xslFilePath = $MyInvocation.MyCommand.Path -replace(".ps1", ".xslt")
 If((Test-Path $xslFilePath) -eq $False) {Throw "XSLT file not found"}

 $exportObject = export-fimconfig -uri $URI `
                                  –onlyBaseResources `
                                  -customconfig ("/mv-data") `
                                  -ErrorVariable Err `
                                  -ErrorAction SilentlyContinue 
 If($Err){Throw $Err}
 If($exportObject -eq $null) {Throw "L:FIM MA not found"}
 
 $maData = "<ma-data>" 
 $lstMA = @(get-wmiobject -class "MIIS_ManagementAgent" -namespace $NameSpace -computername ".")
 $lstMA | ForEach{
    $maData += "<ma Name=""$($_.Name)"" Guid=""$($_.Guid)""/>" 
 }
 $maData += "</ma-data>" 
 
 [xml]$xmlDoc = "<root>" + 
                ($exportObject.ResourceManagementObject.ResourceManagementAttributes | 
                 Where-Object {$_.AttributeName -eq "SyncConfig-import-attribute-flow"}).Value + 
		        $maData +
				"</root>"
 $xmlDoc.save($fileName)
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
