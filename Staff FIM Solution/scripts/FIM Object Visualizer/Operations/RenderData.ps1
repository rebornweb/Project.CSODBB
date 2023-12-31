#----------------------------------------------------------------------------------------------------------
# Name   : RenderData.ps1
# Created: 02/20/10
# Author : markvi
# Purpose: Script to render data from an export file
#----------------------------------------------------------------------------------------------------------
 "" | clip
 If($args.count -lt 2) {Throw "File parametermissing!"}
 $xmlFileName = $args[0]
 $xslFileName = $args[1]

 $xslParamName=""
 $xslParamValue=""
 
 If($args.count -gt 2)
 {
    $xslParamName  = $args[2]
    $xslParamValue = $args[3]
 }	
 
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $xmlFilePath = "$curFolder\$xmlFileName.xml"
 $xslFilePath = "$curFolder\$xslFileName.xslt"
 If((Test-Path $xmlFilePath) -eq $False) {Throw "XML data file not found"}
 If((Test-Path $xslFilePath) -eq $False) {Throw "XSLT file not found"}
  
 [xml]$xmlDoc = Get-Content $xmlFilePath

 $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
 $xslt.Load($xslFilePath)
  
 $memStream = New-Object System.IO.MemoryStream
 
 If($xslParamName.Length -gt 0)
 {
    $argList = New-Object System.Xml.Xsl.XsltArgumentList
    $argList.AddParam($xslParamName, "", $xslParamValue)
    $xslt.Transform($xmlDoc,$argList, $memStream)
 }
 else
 {
    $xslt.Transform($xmlDoc,$null, $memStream)
 }

 $memStream.Position = 0
 $reader = New-Object System.IO.StreamReader $memStream
 $reader.ReadToEnd() | clip
#----------------------------------------------------------------------------------------------------------
 Trap 
 { 
    $_.Exception.Message + ", " + $_.Exception.GetType().FullName | clip
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------
