PARAM($SingleSR="")
#$SingleSR="Provision AD Users"

### Written by Bob Bradley and Carol Wapshere, UNIFY Solutions
###
### Exports Sync Rules to XML files that can be used with the Install-SyncRules.ps1 script.
###

$ErrorActionPreference = "Stop"

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
. E:\scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

#$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = "E:\Scripts\installation\SyncRules"
Set-Location $scriptPath

function Add-XmlFragment {
    Param(        
        [Parameter(Mandatory=$true)][System.Xml.XmlNode] $xmlElement,
        [Parameter(Mandatory=$true)][string] $text)        
    $xml = $xmlElement.OwnerDocument.ImportNode(([xml]$text).DocumentElement, $true)
    [void]$xmlElement.AppendChild($xml)
}

if ($SingleSR) {$filter = ("/SynchronizationRule[DisplayName = '{0}']" -f $SingleSR)}
else {$filter = "/SynchronizationRule"}
$allSRs = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $allSRs) {Throw "The Sync Rules collection cannot be located."}

foreach ($thisSR in ($allSRs.ResourceManagementObject))
{
    [string]$srName = ($thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "DisplayName" }).Value
    $srName
    [xml]$srXml = New-Object xml
    $srXml.PreserveWhitespace = $false
    $srXml.LoadXml('<SynchronizationRule>
    <ConnectedSystemScope/>
    <OutboundScope/>
    <RelationshipCriteria/>
    <SynchronizationRuleParameters/>
    <InitialFlow/>
    <PersistentFlow/>
</SynchronizationRule>')
    $connectedSystemScope = $thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "ConnectedSystemScope" }
    if ($connectedSystemScope) { 
        Add-XmlFragment -xmlElement ([System.Xml.XmlNode]($srXml.SynchronizationRule.SelectSingleNode("ConnectedSystemScope"))) -text ($connectedSystemScope.Value) 
    }
    $outboundScope = $thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "msidmOutboundScopingFilters" }
    if ($outboundScope) { 
        Add-XmlFragment -xmlElement ([System.Xml.XmlNode]($srXml.SynchronizationRule.SelectSingleNode("OutboundScope"))) -text ($outboundScope.Value) 
        # Set all csValue properties to support the idea of an empty string as a scoping condition
        # (otherwise we have a problem with saving <csValue><csValue> as <csValue />)
        $srXml.SynchronizationRule.OutboundScope.scoping.scope | % {([System.Xml.XmlElement]$_.SelectSingleNode("csValue")).IsEmpty = $false}
    }
    $relationshipCriteria = $thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "RelationshipCriteria" }
    if ($relationshipCriteria) { 
        Add-XmlFragment -xmlElement ([System.Xml.XmlNode]($srXml.SynchronizationRule.SelectSingleNode("RelationshipCriteria"))) -text ($relationshipCriteria.Value) 
    }
    $synchronizationRuleParameters = $thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "SynchronizationRuleParameters" }
    foreach ($value in ($thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "SynchronizationRuleParameters" }).Values)
    {
        Add-XmlFragment -xmlElement ([System.Xml.XmlNode]($srXml.SynchronizationRule.SelectSingleNode("SynchronizationRuleParameters"))) -text $value
    }
    foreach ($value in ($thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "InitialFlow" }).Values)
    {
        Add-XmlFragment -xmlElement ([System.Xml.XmlNode]($srXml.SynchronizationRule.SelectSingleNode("InitialFlow"))) -text $value
        # Set all scoping properties to support the idea of an empty string as a condition
        # (otherwise we have a problem with saving <scoping><scoping> as <scoping />)
        if ($srXml.SynchronizationRule.InitialFlow."import-flow") {
            $srXml.SynchronizationRule.InitialFlow."import-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("scoping")).IsEmpty = $false}
            $srXml.SynchronizationRule.InitialFlow."import-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("src")).IsEmpty = $false}
        }
        if ($srXml.SynchronizationRule.InitialFlow."export-flow") {
            $srXml.SynchronizationRule.InitialFlow."export-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("scoping")).IsEmpty = $false}
            $srXml.SynchronizationRule.InitialFlow."export-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("src")).IsEmpty = $false}
        }
    }
    foreach ($value in ($thisSR.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "PersistentFlow" }).Values)
    {
        Add-XmlFragment -xmlElement ([System.Xml.XmlNode]($srXml.SynchronizationRule.SelectSingleNode("PersistentFlow"))) -text $value
        # Set all scoping properties to support the idea of an empty string as a condition
        # (otherwise we have a problem with saving <scoping><scoping> as <scoping />)
        if ($srXml.SynchronizationRule.PersistentFlow."import-flow") {
            $srXml.SynchronizationRule.PersistentFlow."import-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("scoping")).IsEmpty = $false}
            $srXml.SynchronizationRule.PersistentFlow."import-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("src")).IsEmpty = $false}
        }
        if ($srXml.SynchronizationRule.PersistentFlow."export-flow") {
            $srXml.SynchronizationRule.PersistentFlow."export-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("scoping")).IsEmpty = $false}
            $srXml.SynchronizationRule.PersistentFlow."export-flow" | % {([System.Xml.XmlElement]$_.SelectSingleNode("src")).IsEmpty = $false}
        }
    }
    $srXml.SynchronizationRule
    $pathToSaveTo = [System.IO.Path]::Combine($scriptPath,"$srName.xml".Replace(":",""))
    $srXml.Save($pathToSaveTo)
}