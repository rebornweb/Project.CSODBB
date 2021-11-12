#---------------------------------------------------------------------------------------------------------------------------------------------------------
 Set-Variable -Name URI          -Value "http://localhost:5725/resourcemanagementservice" -Option Constant 
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 "" | clip 
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
  if($args.count -ne 1) {throw "Missing name parameter"}
 $objectId = $args[0]
 
 $xsltFile     = $MyInvocation.MyCommand.Definition -replace 'ps1','xslt'
 if((Test-Path($xsltFile))  -eq $false) {throw "`nXSLT file not found"}

 If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation}

 $ExportObjects = Export-Fimconfig -uri $URI `
                                   –onlyBaseResources `
                                   -customconfig "/ObjectTypeDescription[ObjectID='$objectId'][not(starts-with(DisplayName,'AAA'))]" `
								   -ErrorVariable Err `
                                   -ErrorAction SilentlyContinue
 If($Err){Throw $Err}
 If($ExportObjects -eq $null) {Throw "There is no object type description with this ID: $Filter"} 
 
 $objectType = ($ExportObjects.ResourceManagementObject.ResourceManagementAttributes | `
                Where-Object {$_.AttributeName -eq "DisplayName"}).Value

 $xmlString = "<Root><Attributes ObjectType=""$objectType"" >"  
 $ExportObjects = Export-Fimconfig -uri $URI `
                                   -customconfig  "/BindingDescription[BoundObjectType=/ObjectTypeDescription[ObjectID='$objectId']][not(starts-with(DisplayName,'AAA'))]"  `
								   -ErrorVariable Err `
                                   -ErrorAction SilentlyContinue
 If($Err){Throw $Err}
 If($ExportObjects -eq $null) {Throw "There are no binding descriptions for this object type available: $Filter"} 
 
 $ExportObjects | 
 Where-Object {$_.ResourceManagementObject.ObjectType -eq "BindingDescription"} |
 ForEach{
    $isRequired  = ($_.ResourceManagementObject.ResourceManagementAttributes | 
                    Where-Object {$_.AttributeName -eq "Required"}).Value
 
    $attributeId =  ((($_.ResourceManagementObject.ResourceManagementAttributes | 
                     Where-Object {$_.AttributeName -eq "BoundAttributeType"}).Value).Split(":"))[2] 
						   
	$attributeObject      = $ExportObjects | Where-Object {$_.ResourceManagementObject.ObjectIdentifier -eq "urn:uuid:$($attributeId)"} 
	
	If($attributeObject -eq $null) {Throw "Object not found"} 
	If( (@($attributeObject)).count -eq 0) {Throw "Object not found"} 
	
	
	$attributeName        = ($attributeObject.ResourceManagementObject.ResourceManagementAttributes |
                             Where-Object {$_.AttributeName -eq "Name"}).Value
	$attributeType        = ($attributeObject.ResourceManagementObject.ResourceManagementAttributes |
                             Where-Object {$_.AttributeName -eq "DataType"}).Value
	$attributeDescription = ($attributeObject.ResourceManagementObject.ResourceManagementAttributes |
                             Where-Object {$_.AttributeName -eq "Description"}).Value

	$xmlString += "<Attribute>"
	$xmlString += "<AttributeName>$attributeName</AttributeName>" 
	$xmlString += "<IsRequired>$isRequired</IsRequired>" 
	$xmlString += "<AttributeType>$attributeType</AttributeType>" 
	$xmlString += "<AttributeDescription>$attributeDescription</AttributeDescription>" 
	$xmlString += "</Attribute>"
 }		  
 
 $xmlString += "</Attributes></Root>"
 [xml]$xmlDoc = $xmlString

 $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
 $xslt.Load($xsltFile)
  
 $memStream = New-Object System.IO.MemoryStream
 $xslt.Transform($xmlDoc,$null,$memStream)

 $memStream.Position = 0
 $reader = New-Object System.IO.StreamReader $memStream
 $reader.ReadToEnd() | clip
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 Trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
