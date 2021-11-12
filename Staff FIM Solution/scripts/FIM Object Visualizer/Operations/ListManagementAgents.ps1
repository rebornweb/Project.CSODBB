#----------------------------------------------------------------------------------------------------------
# Name   : ListManagementAgents.ps1
# Created: 12/20/09
# Purpose: Script to display a list of the configured mangement agents
#----------------------------------------------------------------------------------------------------------
 Set-Variable -Name NameSpace -Value "root\MicrosoftIdentityIntegrationServer"         -Option Constant
#----------------------------------------------------------------------------------------------------------
 $xslFilePath     = $MyInvocation.MyCommand.Definition -replace 'ps1','xslt'
 if((Test-Path($xslFilePath))  -eq $false) {throw "XSLT file not found"}

 $lstMA = @(get-wmiobject -class "MIIS_ManagementAgent" -namespace $NameSpace `
                                                        -computername ".")
 If($lstMA.count -eq 0) {Throw "There is no management agent configured"}
 $xmlString = "<ManagementAgents>"
 $lstMA | ForEach{
    $xmlString += "<ManagementAgent>" + 
	              "<Name>$($_.Name)</Name>" + 
			      "</ManagementAgent>"
 }
 $xmlString += "</ManagementAgents>" 
 
 [xml]$xmlDoc = $xmlString
				
 $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
 $xslt.Load($xslFilePath)
  
 $memStream = New-Object System.IO.MemoryStream
 $xslt.Transform($xmlDoc,$null, $memStream)

 $memStream.Position = 0
 $reader = New-Object System.IO.StreamReader $memStream
 $reader.ReadToEnd() | clip			
#------------------------------------------------------------------------------------------------------------  
 Trap 
 {
    $_.Exception.Message | clip
    Exit 1
 }
#------------------------------------------------------------------------------------------------------------