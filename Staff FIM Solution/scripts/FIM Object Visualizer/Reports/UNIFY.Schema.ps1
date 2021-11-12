#----------------------------------------------------------------------------------------------------------
 Function AddDataItem
 {
    Param([xml]$xmlDoc, [xml.xmlElement]$curNode, $nodeName, $nodeValue = "")
	End
	{
	   $newElement = $xmlDoc.CreateElement($nodeName)
	   $newElement.set_InnerText($nodeValue)
	   $curNode.AppendChild($newElement) | Out-Null
	}
 }
#----------------------------------------------------------------------------------------------------------
 Function GetFIMObjects
 {
    Param($filter)
    End
    {
       $exportObjects = export-fimconfig -uri "http://localhost:5725/resourcemanagementservice" `
                                         –onlyBaseResources `
                                         -customconfig ("$filter") `
                                         -ErrorVariable Err `
                                         -ErrorAction SilentlyContinue 
       if($Err){throw $Err}
       return $exportObjects                                 
    }
 }
#----------------------------------------------------------------------------------------------------------
 Function GetSchemaResourceType
 {
    Param($Id = "", $Name = "", $DisplayName = "", $Desc = "")
    End
    {
       $newRecord = new-object psobject
       $newRecord | add-member noteproperty "Section"     "ResourceType"
       $newRecord | add-member noteproperty "Id"     $Id
       $newRecord | add-member noteproperty "Name"   $Name
       $newRecord | add-member noteproperty "DisplayName"   $DisplayName
       $newRecord | add-member noteproperty "Desc"   $Desc 
       return $newRecord
   }
 }
#----------------------------------------------------------------------------------------------------------
 Function GetSchemaAttribute
 {
    Param($Id = "", $Name = "", $DisplayName = "", $Type = "", $Desc = "", $Mv = "", $StringRegex = "")
    End
    {
       $newRecord = new-object psobject
       $newRecord | add-member noteproperty "Section"     "Attribute"
       $newRecord | add-member noteproperty "Id"     $Id
       $newRecord | add-member noteproperty "Name"   $Name
       $newRecord | add-member noteproperty "DisplayName"   $DisplayName
       $newRecord | add-member noteproperty "DataType"   $DataType
       $newRecord | add-member noteproperty "Desc"   $Desc 
       $newRecord | add-member noteproperty "Mv"   $Mv
       $newRecord | add-member noteproperty "StringRegex"   $StringRegex
       return $newRecord
   }
 }
#----------------------------------------------------------------------------------------------------------
 Function GetSchemaBinding
 {
    Param($Id = "", $Name = "", $DisplayName = "", $Desc = "", $Required = "", $StringRegex = "", $ObjectTypeId = "", $AttributeTypeId = "")
    End
    {
       $newRecord = new-object psobject
       $newRecord | add-member noteproperty "Section"     "Binding"
       $newRecord | add-member noteproperty "Id"     $Id
       $newRecord | add-member noteproperty "Name"   $Name
       $newRecord | add-member noteproperty "DisplayName"   $DisplayName
       $newRecord | add-member noteproperty "Desc"   $Desc 
       $newRecord | add-member noteproperty "Required"   $Required 
       $newRecord | add-member noteproperty "StringRegex"   $StringRegex
       $newRecord | add-member noteproperty "ObjectTypeId"     $ObjectTypeId
       $newRecord | add-member noteproperty "AttributeTypeId"     $AttributeTypeId
       return $newRecord
   }
 }
#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
 $dataList = @()
#----------------------------------------------------------------------------------------------------------
 GetFIMObjects -filter "/AttributeTypeDescription[not(starts-with(DisplayName,'AAA')) and not(contains(DisplayName,'dhs')) and not(contains(DisplayName,'NAB')) and not(contains(DisplayName,'CLINK')) and not(contains(DisplayName,'DEEWR'))]"|
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes} | 
 foreach {
    $Name = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Name"}).Value
    $DisplayName = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "DisplayName"}).Value
    $Id   = (($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2] 
    $DataType = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "DataType"}).Value
    $Desc = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Description"}).Value
    $Mv = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Multivalued"}).Value
    $StringRegex = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "StringRegex"}).Value
    
   $dataList += GetSchemaAttribute -Id $Id `
                                -Name $Name `
                                -DisplayName $DisplayName `
                                -DataType $DataType `
                                -Desc $Desc `
                                -Mv $Mv `
                                -StringRegex $StringRegex
}
#----------------------------------------------------------------------------------------------------------
 GetFIMObjects -filter "/ObjectTypeDescription[not(starts-with(DisplayName,'AAA')) and not(contains(DisplayName,'dhs')) and not(contains(DisplayName,'NAB')) and not(contains(DisplayName,'CLINK')) and not(contains(DisplayName,'DEEWR'))]"|
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes} | 
 foreach {
    $Name = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Name"}).Value
    $DisplayName = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "DisplayName"}).Value
    $Id   = (($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2] 
    $Desc = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Description"}).Value
    
   $dataList += GetSchemaResourceType -Id $Id `
                                -Name $Name `
                                -DisplayName $DisplayName `
                                -Desc $Desc
 }
#----------------------------------------------------------------------------------------------------------
 GetFIMObjects -filter "/BindingDescription[not(starts-with(DisplayName,'AAA')) and not(contains(DisplayName,'dhs')) and not(contains(DisplayName,'NAB')) and not(contains(DisplayName,'CLINK')) and not(contains(DisplayName,'DEEWR'))]"|
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes} | 
 foreach {
    $Name = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Name"}).Value
    $DisplayName = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "DisplayName"}).Value
    $Id   = (($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2] 
    $Desc = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Description"}).Value
    $Required = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "Required"}).Value
    $StringRegex = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "StringRegex"}).Value
    $ObjectTypeId = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "BoundObjectType"}).Value.split(":")[2]
    $AttributeTypeId = ($_.ResourceManagementObject.ResourceManagementAttributes | `
               Where-Object {$_.AttributeName -eq "BoundAttributeType"}).Value.split(":")[2]
    
   $dataList += GetSchemaBinding -Id $Id `
                                -Name $Name `
                                -DisplayName $DisplayName `
                                -Desc $Desc `
                                -Required $Required `
                                -StringRegex $StringRegex `
                                -ObjectTypeId $ObjectTypeId `
                                -AttributeTypeId $AttributeTypeId
}
#----------------------------------------------------------------------------------------------------------
 [xml]$xmlSchema = "<Configurations/>"
 $dataList | foreach{
    $newNode = $xmlSchema.CreateElement("Configuration")
	$xmlSchema.documentElement.AppendChild($newNode) | Out-Null
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "Section"     -nodeValue $_.Section
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "Id"     -nodeValue $_.Id
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "Name"   -nodeValue $_.Name
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "DisplayName"   -nodeValue $_.DisplayName
	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "Desc"     -nodeValue $_.Desc
    if($_.Section -eq "Attribute") {
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "DataType"   -nodeValue $_.DataType
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "Mv"   -nodeValue $_.Mv
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "StringRegex"   -nodeValue $_.StringRegex
	}
    if($_.Section -eq "Binding") {
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "ObjectTypeId"     -nodeValue $_.ObjectTypeId
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "AttributeTypeId"     -nodeValue $_.AttributeTypeId
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "Required"   -nodeValue $_.Required
    	AddDataItem -xmlDoc $xmlSchema -curNode  $newNode -nodeName "StringRegex"   -nodeValue $_.StringRegex
    }
 }
 
 $xmlSchema.Save($fileName)				
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------
