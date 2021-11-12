PARAM ( [string]$InputPath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\NASS\",
    [string]$OutputPath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\NASS\",
    [string]$XmlInputFile = "nassData.xml",
    [string]$LdifOutputFile = "nassData.ldif",
    [string]$XslFile = "XmlToLDIF.NASS.xslt" )

#-------------------------------------------------
# SaveTransformedXML
#-------------------------------------------------
# Usage:        Use the compiled or uncompiled transform approach
#               as appropriate to transform a DSML export file
#               into a DSML MA import file in one of two modes:
#               . IsTemplate = True (memory intensive option - requires XslTransform)
#               . IsTemplate = False (less memory intensive - use standard model XslCompiledTransform)
#-------------------------------------------------
# Bob Bradley, 1 Dec 2011
#-------------------------------------------------
function SaveTransformedXML{
    param ( [string]$XMLPath,
            [boolean]$IsTemplate,
            [string]$XSLPath,
            [string]$XMLOutputPath)
    
    try {
        # Simplistic error handling
        $XSLPath = resolve-path $XSLPath
        if( -not (test-path $XSLPath) ) { throw "Can't find the XSL file" } 
        $XMLPath = resolve-path $XMLPath
        if( -not (test-path $XMLPath) ) { throw "Can't find the XML file" } 
        if ( -not (test-path (split-path $XMLPath)) ) { throw "Can't find the output folder" } 

        # Load XSL Argument List
        $XSLArg = New-Object System.Xml.Xsl.XsltArgumentList
        $XSLArg.Clear() 
        $XSLArg.AddParam("IsTemplate", $Null, $IsTemplate)
 
        if ($IsTemplate) {
            # Load Documents
            $BaseXMLDoc = New-Object System.Xml.XmlDocument
            $BaseXMLDoc.Load($XMLPath)

            # We can't use the XslCompiledTransform here because the XSLT is too memory hungry in this mode
            $EAP = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
            $script:XSLTrans = new-object System.Xml.Xsl.XslTransform
            $ErrorActionPreference = $EAP
   
            # Load xslt file
            $XSLTrans.load( $XSLPath )
        } else {
            # Load Document via an XML reader
            $XMLReader = [System.Xml.XmlReader]::Create($XMLPath)
            $XSLTrans = New-Object System.Xml.Xsl.XslCompiledTransform
            $XSLTrans.Load($XSLPath)
        }
 
        #Perform XSL Transform
        $FinalXMLDoc = New-Object System.Xml.XmlDocument
        $MemStream = New-Object System.IO.MemoryStream
     
        [System.Xml.XmlWriterSettings]$WriterSettings = New-Object System.Xml.XmlWriterSettings
        $WriterSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Fragment
        $XMLWriter = [System.Xml.XmlWriter]::Create($MemStream,$WriterSettings)
        if ($IsTemplate) {
            # Perform transform using XslTransform
            $XSLTrans.Transform($BaseXMLDoc, $XSLArg, $XMLWriter)
        } else {
            # Perform transform using XslCompiledTransform
            $XSLTrans.Transform($XMLReader, $XSLArg, $XMLWriter)
        }
     
        # Load the results
        #$MemStream.Position = 0
        #$FinalXMLDoc.Load($MemStream) 
        #$FinalXMLDoc.Save($XMLOutputPath)
        
        [System.IO.FileStream]$fs = [System.IO.File]::OpenWrite($XMLOutputPath);
        $fs.Write($MemStream.GetBuffer(), 0, $MemStream.Position);
        $fs.Close();
        
        #[System.IO.StreamWriter]$StreamWriter = New-Object System.IO.StreamWriter($XMLOutputPath)
        #$StreamWriter.Write($MemStream.ToString())
        $XMLWriter.Flush()
        }  
    catch {
        return $Error[0]
    }   
}
    
# from: http://huddledmasses.org/convert-xml-with-xslt-in-powershell/
function Convert-WithXslt(
    [string]$originalXmlFilePath, 
    [string]$IsTemplate, 
    [string]$xslFilePath, 
    [string]$outputFilePath) 
{
   ## Simplistic error handling
   $xslFilePath = resolve-path $xslFilePath
   if( -not (test-path $xslFilePath) ) { throw "Can't find the XSL file" } 
   $originalXmlFilePath = resolve-path $originalXmlFilePath
   if( -not (test-path $originalXmlFilePath) ) { throw "Can't find the XML file" } 
   if ( -not (test-path (split-path $originalXmlFilePath)) ) { throw "Can't find the output folder" } 

    # Load Documents
    $BaseXMLDoc = New-Object System.Xml.XmlDocument
    $BaseXMLDoc.Load($originalXmlFilePath)

    # Load XSL Argument List
    $XSLArg = New-Object System.Xml.Xsl.XsltArgumentList
    $XSLArg.Clear() 
    $XSLArg.AddParam("IsTemplate", $Null, $IsTemplate)

   ## Get an XSL Transform object (try for the new .Net 3.5 version first)
   $EAP = $ErrorActionPreference
   $ErrorActionPreference = "SilentlyContinue"
   #$script:xslt = new-object system.xml.xsl.xslcompiledtransform
   #trap [System.Management.Automation.PSArgumentException] 
   #{  # no 3.5, use the slower 2.0 one
   #   $ErrorActionPreference = $EAP
      $script:xslt = new-object system.xml.xsl.xsltransform
   #}
   $ErrorActionPreference = $EAP
   
   ## load xslt file
   $xslt.load( $xslFilePath )
     
   ## transform 
   #$xslt.Transform( $originalXmlFilePath, $XSLArg, $outputFilePath )

    #Perform XSL Transform
    $FinalXMLDoc = New-Object System.Xml.XmlDocument
    $MemStream = New-Object System.IO.MemoryStream
 
    $XMLWriter = [System.Xml.XmlWriter]::Create($MemStream)
    $xslt.Transform($BaseXMLDoc, $XSLArg, $XMLWriter)
    $MemStream.Position = 0
 
    # Load the results
    $FinalXMLDoc.Load($MemStream) 
    $FinalXMLDoc.Save($outputFilePath)
    $XMLWriter.Flush()
}

$debug = $True
$now = Get-Date
if($debug -eq $True) {Write-Host "*** Step #1 starting: " $now " ***"}
Del "$OutputPath$LdifOutputFile"
if($debug -eq $True) {Write-Progress -Activity "Transforming XML" -Status "Transforming XML (template mode) => ./$LdifOutputFile"}
SaveTransformedXML "$InputPath$XmlInputFile" `
    -IsTemplate $False -XSLPath "$OutputPath$XslFile" `
    -XMLOutputPath "$OutputPath$LdifOutputFile"
$now = Get-Date
if($debug -eq $True) {Write-Host "*** All steps finished: " $now " ***"}

