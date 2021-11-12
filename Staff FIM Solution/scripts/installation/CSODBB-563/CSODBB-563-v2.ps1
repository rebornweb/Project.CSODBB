PARAM([string]$uri="http://localhost:5725", [boolean]$UpdateExisting=$true, [boolean]$Uninstall=$false)

### Written by Adrian Corston, UNIFY Solutions
### Template by Carol Wapshere, UNIFY Solutions
###
### CSODBB-563


$ErrorActionPreference = "Stop"

$scriptPath = "D:\Scripts\installation\CSODBB-563"
. D:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

## XML and WMI functions
function getMAGuid (
    [string]$maName="Upstream AD"
) {
    $thisMA = get-wmiobject -class "MIIS_ManagementAgent where Name = '$maName'" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $fimSyncServer
    $thisMA.Guid
}

function getMAName (
    [string]$maGuid="{405DD2A1-8B12-478C-A78B-7D398BE6DC7A}"
) {
    $thisMA = get-wmiobject -class "MIIS_ManagementAgent where Guid = '$maGuid'" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $fimSyncServer
    $thisMA.Name
}

function ReadSRXml
{
    PARAM([string]$srName)
    END
    {
        $HashReturn = @{}

        $XmlFile = "$scriptPath\$srName.xml"
        if (Test-Path $XmlFile)
        {
            [xml]$sr = Get-Content $XmlFile
 
            $HashReturn.Add("ConnectedSystemScope",$sr.SynchronizationRule.ConnectedSystemScope.InnerXml)
            $HashReturn.Add("OutboundScope",$sr.SynchronizationRule.OutboundScope.InnerXml)
            $HashReturn.Add("RelationshipCriteria",$sr.SynchronizationRule.RelationshipCriteria.InnerXml)

            $PersistentFlow = @()
            foreach ($rule in $sr.SynchronizationRule.PersistentFlow."import-flow")
            {
                $PersistentFlow += $rule.OuterXml
            }
            foreach ($rule in $sr.SynchronizationRule.PersistentFlow."export-flow")
            {
                $PersistentFlow += $rule.OuterXml
            }
            $HashReturn.Add("PersistentFlow",$PersistentFlow)

            $InitialFlow = @()
            foreach ($rule in $sr.SynchronizationRule.InitialFlow."import-flow")
            {
                $InitialFlow += $rule.OuterXml
            }
            foreach ($rule in $sr.SynchronizationRule.InitialFlow."export-flow")
            {
                $InitialFlow += $rule.OuterXml
            }
            $HashReturn.Add("InitialFlow",$InitialFlow)

            return $HashReturn
        }
    }
}


## Objects to create are stored in hashtables.
## - The Object Type is the top level of the hashtable
## - The Display Name of the object is the next level
## - Under that we must have Add and Update - where "Add" includes attributes that may only be set at object creation
## - If an attribute is multivalued the values must be stored as an array, even if there is only one value to add.

$Objects = @{}



###
### Attribute: Org Unit
###
$Objects.Add("AttributeTypeDescription", @{})
$Objects.AttributeTypeDescription.Add("csoOrgUnit",
@{
    "Add" = @{"Name"="csoOrgUnit";"DisplayName"="Org Unit"; "DataType"="String"; "Multivalued"="False"};
    "Update" = @{
        "Description"="Active Directory OU prefix for users (e.g. `"Office of the Bishop`"), not including the `"OU=`" prefix string.";
        "StringRegex"="^(Office of the Bishop|CSO|BBI|Parishes|Centacare)?$"
    }
})

### Process csoOrgUnit attribute
ProcessObjects -ObjectType "AttributeTypeDescription" -HashObjects $Objects.AttributeTypeDescription



###
### Bindings for Person (User) and Department object types
###
$Objects.Add("BindingDescription", @{})

$Objects.BindingDescription.Add("Person",@{})
$Objects.BindingDescription.Person.Add("Org Unit",
@{
    "Add" = @{"BoundAttributeType"=(LookupObject -ObjectType "AttributeTypeDescription" -Name "csoOrgUnit");
              "BoundObjectType"=(LookupObject -ObjectType "ObjectTypeDescription" -Name "Person")};
    "Update" = @{"Description"="Active Directory OU prefix for users (e.g. `"Office of the Bishop`"), not including the `"OU=`" prefix string.";
                 "Required"="false"}
})

### Process User/csoOrgUnit binding
ProcessObjects -ObjectType "BindingDescription" -HashObjects $Objects.BindingDescription.Person

$Objects.BindingDescription.Add("csoDepartment",@{})
$Objects.BindingDescription.csoDepartment.Add("Org Unit",
@{
    "Add" = @{"BoundAttributeType"=(LookupObject -ObjectType "AttributeTypeDescription" -Name "csoOrgUnit");
              "BoundObjectType"=(LookupObject -ObjectType "ObjectTypeDescription" -Name "csoDepartment")};
    "Update" = @{"Description"="Active Directory OU prefix for users in the Department (e.g. `"Office of the Bishop`"), not including the `"OU=`" prefix string.";
                 "Required"="false"}
})

### Process Department/csoOrgUnit binding
ProcessObjects -ObjectType "BindingDescription" -HashObjects $Objects.BindingDescription.csoDepartment


###
### RCDCs
###
### cso-Department View/Modification/Creation
###   Update the ConfigurationData to add the field for csoOrgUnit on the Department forms (Creation, Modification, View)
###
$Objects.Add("RCDCs", @{})

$Objects.RCDCs.Add("cso-Department Creation",
@{
    "Update" = @{"ConfigurationData"=(Get-Content "$scriptPath\cso-Department Creation-RCDC.xml" | Out-String)}
})
$Objects.RCDCs.Add("cso-Department Modification",
@{
    "Update" = @{"ConfigurationData"=(Get-Content "$scriptPath\cso-Department Modification-RCDC.xml" | Out-String)}
})
$Objects.RCDCs.Add("cso-Department View",
@{
    "Update" = @{"ConfigurationData"=(Get-Content "$scriptPath\cso-Department View-RCDC.xml" | Out-String)}
})

### Process RCDCs
ProcessObjects -ObjectType "ObjectVisualizationConfiguration" -HashObjects $Objects.RCDCs -UpdateExisting $true



###
### Search Scopes
###

###
### All departments
### All departments with no UPN suffix
###   Add column for OrgUnit
###
$Objects.Add("SearchScopeConfiguration", @{})
$Objects.SearchScopeConfiguration.Add("All departments",
@{
    "Update" = @{"SearchScopeColumn"="DisplayName;csoDeptID;Description;csoUpnSuffix;csoOrgUnit;csoSourceSystem"}
})
$Objects.SearchScopeConfiguration.Add("All departments with no UPN suffix",
@{
    "Update" = @{"SearchScopeColumn"="DisplayName;csoDeptID;Description;csoUpnSuffix;csoOrgUnit;csoSourceSystem"}
})

### Process SearchScopeConfiguration
ProcessObjects -ObjectType "SearchScopeConfiguration" -HashObjects $Objects.SearchScopeConfiguration -UpdateExisting $true



###
### Permission MPRs
###

$Objects.Add("MPRs", @{})

###
### 1. Permission for Administrators to edit Departments
### (MPR "cso-Administration: Administrators can manage departments" already allows admins to edit all attributes, so no change required)
###

# none needed


###
### 2. Update users when Departments changes
### (MPR "cso-Synchronization: User department properties are set whenever the referenced csoDepartment changes" exists, but needs "csoOrgUnit" added to target resource attribute list)
###
$Objects.MPRs.Add("cso-Synchronization: User department properties are set whenever the referenced csoDepartment changes",
@{
    "Update" = @{"ActionParameter"=@("csoSourceSystem","csoUpnSuffix","csoOrgUnit","Description")}
})

### Process MPRs
ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.MPRs -UpdateExisting $true



###
### Workflows
###

$Objects.Add("Workflow", @{})

###
### 1. cso-Set user department properties
### Update this existing workflow to add activities to set a person's csoOrgUnit from their Department's csoOrgUnit
### The workflow is triggered on a Person object when their Dept attribute changes
###
$Objects.Workflow.Add("cso-Set user department properties",
@{
    "Update" = @{"XOML" = @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Set default upn suffix value" Destination="[//WorkflowData/upnSuffix]" FunctionExpression="&lt;fn id=&quot;IIF&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Eq&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;[//Target/csoDepartment/csoSourceSystem]&lt;/arg&gt;&lt;arg&gt;&quot;PHRIS&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.catholic.edu.au&quot;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.org.au&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity2" />
	<ns0:FunctionActivity Description="Set default OrgUnit property" Destination="[//WorkflowData/orgUnit]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;Office of the Bishop&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="actionActivity1" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/csoDepartment]' and starts-with(csoUpnSuffix,'%')]" x:Name="authenticationGateActivity3" ResolvedXpathFilter="{x:Null}" AttributeNames="csoUpnSuffix=upnSuffix" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetUserDepartmentProperties.log" OverwriteLogFile="True" LogMode="minimal" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/csoDepartment]' and starts-with(csoOrgUnit,'%')]" x:Name="actionActivity2" ResolvedXpathFilter="{x:Null}" AttributeNames="csoOrgUnit=orgUnit" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetUserDepartmentProperties.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/Person[ObjectID='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="[//Target/DisplayName]" TargetResource="{x:Null}" ObjectType="Person" SaveWorkflowDataStorageMode="Object" DeleteIfFound="False" ExtraAttributes="csoUpnSuffix=string:[//WorkflowData/upnSuffix]&#xA;Department=string:[//Target/csoDepartment/Description]&#xA;csoOrgUnit=string:[//WorkflowData/orgUnit]" InsertIfNotFound="False" LogFile="D:\LOGS\FIM\csoSetUserDepartmentProperties.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@}
})

###
### 2. cso--Set referenced user department properties
### Update this existing workflow to add activities to set a person's csoOrgUnit from their Department's csoOrgUnit
### The workflow is triggered on a Department object when its attributes change
###
$Objects.Workflow.Add("cso--Set referenced user department properties",
@{
    "Update" = @{"XOML" = @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Set default UPN suffix" Destination="[//WorkflowData/upnSuffix]" FunctionExpression="&lt;fn id=&quot;IIF&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Eq&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;[//Target/csoSourceSystem]&lt;/arg&gt;&lt;arg&gt;&quot;PHRIS&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.catholic.edu.au&quot;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.org.au&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity2" />
	<ns0:FunctionActivity Description="Set default Org Unit" Destination="[//WorkflowData/orgUnit]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;Office of the Bishop&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="actionActivity1" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/ObjectID]' and starts-with(csoUpnSuffix,'%')]" x:Name="authenticationGateActivity3" ResolvedXpathFilter="{x:Null}" AttributeNames="csoUpnSuffix=upnSuffix" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetReferencedUserDepartmentProperties.log" OverwriteLogFile="True" LogMode="minimal" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/ObjectID]' and starts-with(csoOrgUnit,'%')]" x:Name="actionActivity2" ResolvedXpathFilter="{x:Null}" AttributeNames="csoOrgUnit=orgUnit" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetReferencedUserDepartmentProperties.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/Person[csoDepartment='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="[//Target/DisplayName]" TargetResource="{x:Null}" ObjectType="Person" SaveWorkflowDataStorageMode="List" DeleteIfFound="False" ExtraAttributes="csoUpnSuffix=string:[//WorkflowData/upnSuffix]&#xA;Department=string:[//Target/Description]&#xA;csoOrgUnit=string:[//WorkflowData/orgUnit]" InsertIfNotFound="False" LogFile="D:\LOGS\FIM\csoSetReferencedUserDepartmentProperties.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@}
})

### Process workflows
ProcessObjects -ObjectType "WorkflowDefinition" -HashObjects $Objects.Workflow -UpdateExisting $true



###
### Sync Rules
###

$Objects.Add("SynchronizationRules", @{})

###
### 1. cso Staff: provisioned and synchronized with AD
###   Update the persistent attribute flows to use csoOrgUnit instead of csoOrganisationName when constructing the AD OU
###

$hashSRXml = ReadSRXml -srName "cso Staff provisioned and synchronised with AD"
$Objects.SynchronizationRules.Add("cso Staff: provisioned and synchronised with AD",
@{
    "Update" = @{
        "InitialFlow" = $hashSRXml.InitialFlow
        "PersistentFlow" = $hashSRXml.PersistentFlow
    }
})

### Process sync rules
ProcessObjects -ObjectType "SynchronizationRule" -HashObjects $Objects.SynchronizationRules -UpdateExisting $true
