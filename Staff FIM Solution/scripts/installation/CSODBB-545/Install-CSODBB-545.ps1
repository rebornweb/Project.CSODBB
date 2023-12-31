PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false,[string]$fimSyncServer="occcp-im301")

### Written by Bob Bradley, UNIFY Solutions
###
### Installs the Schema and Policy objects for specified Sync Rules.
###

cls
$ErrorActionPreference = "Stop"

. D:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

#$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = "D:\scripts\installation\CSODBB-545"

###
### Check dependencies
###
if (-not (Test-Path ($WFScriptFolder + "\WFFunctions.ps1"))) {Throw ("Expected to find " + $WFScriptFolder + "\WFFunctions.ps1. If it is in a different location then change or set the $WFScriptFolder variable in the Set-LocalVariables.ps1 script.")}
if (-not (Test-Path $WFLogFolder)) {Throw ("Expected to find " + $WFLogFolder + ". If you want to use a different location for Workflow logging then change or set the $WFLogFolder variable in the Set-LocalVariables.ps1 script. Otherwise, create the folder in the specified location.")}

$filter = "/ActivityInformationConfiguration[ActivityName='UFIM.CustomActivities.UpdateResourceFromWorkflowData']"
$AIC = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $AIC) {Throw "The 'UNIFY-Create update and delete FIM resource activity' activity must be installed."}

## Objects to create are stored in hashtables.
## - The Object Type is the top level of the hashtable
## - The Display Name of the object is the next level
## - Under that we must have Add and Update - where "Add" includes attributes that may only be set at object creation
## - If an attribute is multivalued the values must be stored as an array, even if there is only one value to add.


$Objects = @{}

###
### Sets 
###
### Create new sets
###

$Objects.Add("Set",@{})
$Xpath = "/Person[(starts-with(AccountName, '%')) and (PersonType = 'Staff') and (csoBirthDate &lt; fn:current-dateTime()) and (not(starts-with(csoHRStatus, '%'))) and (ObjectID != /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso-Explicit active staff for remediation" -NoPrefix $true)']/ComputedMember) and ((csoEmployeeStatus = 'Active') or (ObjectID = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso All user activation overrides" -NoPrefix $true)']/ComputedMember))]"
$Objects.Set.Add("cso-All active Non-PHRIS staff user accounts to be provisioned",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="All active non-PHRIS staff user accounts to be provisioned"}
    "Uninstall" = "UpdateObject" 
})

$Xpath = "/Person[(starts-with(AccountName, '%')) and (PersonType = 'Staff') and (csoBirthDate &lt; fn:current-dateTime()) and (starts-with(csoUpnSuffix, '%')) and (starts-with(csoHRStatus, '%')) and (ObjectID != /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso-Explicit active staff for remediation" -NoPrefix $true)']/ComputedMember) and ((csoEmployeeStatus = 'Active') or (ObjectID = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso All user activation overrides" -NoPrefix $true)']/ComputedMember))]"
$Objects.Set.Add("cso-All active PHRIS staff user accounts to be provisioned",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="All active PHRIS staff user accounts to be provisioned"}
    "Uninstall" = "UpdateObject" 
})

$Xpath = "/Person[(starts-with(AccountName, '%')) and (PersonType = 'Staff') and (csoBirthDate &lt; fn:current-dateTime()) and (ObjectID != /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso-Explicit active staff for remediation" -NoPrefix $true)']/ComputedMember) and ((csoEmployeeStatus = 'Active') or (ObjectID = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso All user activation overrides" -NoPrefix $true)']/ComputedMember))]"
$Objects.Set.Add("cso-All active staff user accounts to be provisioned",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="All active staff user accounts to be provisioned"}
    "Uninstall" = "DeleteObject" 
})

ProcessObjects -ObjectType "Set" -HashObjects $Objects.Set

###
###
### Workflows
###
###


$Objects.Add("Workflows", @{})
$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity6" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroup.log" XPathFilter="//Request" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for global and domain local group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role from managing universal distribution groups back to managing domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity6" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" XPathFilter="//Request" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for global and domain local group - no ADS code",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role from managing universal distribution groups back to managing domain local/global nested groups - no ADS code";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForUniversalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity1" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ConvertRoleForUniversalGroup.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForUniversalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:NULL&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for universal group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role to managing universal distribution groups in lieu of domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForUniversalGroupWithParent.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity1" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ConvertRoleForUniversalGroupWithParent.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ConvertRoleForUniversalGroupWithParent.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for universal group with parent role",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role with parent role to managing universal distribution groups in lieu of domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain domain local and global role groups",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain domain local and global role groups";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;Description=string:[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;Description=string:[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain domain local and global role groups - no ADS code",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain domain local and global role groups - no ADS code";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.Universal.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.Universal.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:NULL&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain universal role group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain a universal group for selected roles";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.UniversalWithParent.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\LOGS\FIM\cso.ADSGroupManagement.UniversalWithParent.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:UNIFYFIM&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain universal role group with parent role",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain a universal group for selected roles with parent role";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LoggingActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns3="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Default end date" Destination="[//WorkflowData/EndDate]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;indefinite&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity4" />
	<ns0:FunctionActivity Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/UserID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity5" />
	<ns1:DateConversionActivity CurrentRequest="{x:Null}" FunctionParameters="" ResolvedQuery="" WorkflowDataMember="StartDate" DateTimeFormat="yyyyMMdd" SelectFunction="ToLocalTime" DateTimeQueryString="[//Target/idmStartDate]" x:Name="authenticationGateActivity2" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="True" LogMode="minimal" />
	<ns1:DateConversionActivity CurrentRequest="{x:Null}" FunctionParameters="" ResolvedQuery="" WorkflowDataMember="EndDate" DateTimeFormat="yyyyMMdd" SelectFunction="ToLocalTime" DateTimeQueryString="[//Target/idmEndDate]" x:Name="authenticationGateActivity3" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(csoLegacyEmployeeID,'%')]" x:Name="authenticationGateActivity7" ResolvedXpathFilter="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(EmployeeID,'%')]" x:Name="authenticationGateActivity6" ResolvedXpathFilter="{x:Null}" AttributeNames="EmployeeID" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns3:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/csoEntitlement[ObjectID='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]" TargetResource="{x:Null}" ObjectType="csoEntitlement" SaveWorkflowDataStorageMode="Object" DeleteIfFound="False" ExtraAttributes="DisplayName=string:[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]&#xD;&#xA;Description=string:[//Target/UserID/DisplayName] entitlements from [//WorkflowData/StartDate] to [//WorkflowData/EndDate]&#xD;&#xA;csoRecalculate=boolean:true" InsertIfNotFound="False" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set entitlement display name",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Set entitlement display name and mark for role recalculation";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LoggingActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns3="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Default end date" Destination="[//WorkflowData/EndDate]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;indefinite&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity4" />
	<ns0:FunctionActivity Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/UserID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity5" />
	<ns1:DateConversionActivity CurrentRequest="{x:Null}" FunctionParameters="" ResolvedQuery="" WorkflowDataMember="StartDate" DateTimeFormat="yyyyMMdd" SelectFunction="ToLocalTime" DateTimeQueryString="[//Target/idmStartDate]" x:Name="authenticationGateActivity2" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="True" LogMode="minimal" />
	<ns1:DateConversionActivity CurrentRequest="{x:Null}" FunctionParameters="" ResolvedQuery="" WorkflowDataMember="EndDate" DateTimeFormat="yyyyMMdd" SelectFunction="ToLocalTime" DateTimeQueryString="[//Target/idmEndDate]" x:Name="authenticationGateActivity3" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(csoLegacyEmployeeID,'%')]" x:Name="authenticationGateActivity7" ResolvedXpathFilter="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(EmployeeID,'%')]" x:Name="authenticationGateActivity6" ResolvedXpathFilter="{x:Null}" AttributeNames="EmployeeID" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns3:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/csoEntitlement[ObjectID='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]" TargetResource="{x:Null}" ObjectType="csoEntitlement" SaveWorkflowDataStorageMode="Object" DeleteIfFound="False" ExtraAttributes="DisplayName=string:[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]&#xD;&#xA;Description=string:[//Target/UserID/DisplayName] entitlements from [//WorkflowData/StartDate] to [//WorkflowData/EndDate]&#xD;&#xA;csoRecalculate=boolean:true" InsertIfNotFound="False" LogFile="D:\LOGS\FIM\CSO.SetEntitlementDisplayName.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set entitlement display name AuthZ",
@{
    "Add" = @{"RequestPhase"="Authorization"}
    "Update" = @{"Description"="Set entitlement display name in the AuthZ step";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Set default UPN suffix" Destination="[//WorkflowData/upnSuffix]" FunctionExpression="&lt;fn id=&quot;IIF&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Eq&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;[//Target/csoSourceSystem]&lt;/arg&gt;&lt;arg&gt;&quot;PHRIS&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.catholic.edu.au&quot;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.org.au&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity2" />
	<ns0:FunctionActivity Description="Set default Org Unit" Destination="[//WorkflowData/orgUnit]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;Office of the Bishop&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="actionActivity1" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/ObjectID]' and starts-with(csoUpnSuffix,'%')]" x:Name="authenticationGateActivity3" ResolvedXpathFilter="{x:Null}" AttributeNames="csoUpnSuffix=upnSuffix" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetReferencedUserDepartmentProperties.log" OverwriteLogFile="True" LogMode="minimal" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/ObjectID]' and starts-with(csoOrgUnit,'%')]" x:Name="actionActivity2" ResolvedXpathFilter="{x:Null}" AttributeNames="csoOrgUnit=orgUnit" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetReferencedUserDepartmentProperties.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/Person[csoDepartment='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="[//Target/DisplayName]" TargetResource="{x:Null}" ObjectType="Person" SaveWorkflowDataStorageMode="List" DeleteIfFound="False" ExtraAttributes="csoUpnSuffix=string:[//WorkflowData/upnSuffix]&#xD;&#xA;Department=string:[//Target/Description]&#xD;&#xA;csoOrgUnit=string:[//WorkflowData/orgUnit]" InsertIfNotFound="False" LogFile="D:\LOGS\FIM\csoSetReferencedUserDepartmentProperties.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso--Set referenced user department properties",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Set department properties for all users linked to a changing csoDepartment object";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:SequentialWorkflow ActorId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" x:Name="SequentialWorkflow" TargetId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.4.1459.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity Description="Set default upn suffix value" Destination="[//WorkflowData/upnSuffix]" FunctionExpression="&lt;fn id=&quot;IIF&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Eq&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;[//Target/csoDepartment/csoSourceSystem]&lt;/arg&gt;&lt;arg&gt;&quot;PHRIS&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.catholic.edu.au&quot;&lt;/arg&gt;&lt;arg&gt;&quot;@dbb.org.au&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="authenticationGateActivity2" />
	<ns0:FunctionActivity Description="Set default OrgUnit property" Destination="[//WorkflowData/orgUnit]" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;Office of the Bishop&quot;&lt;/arg&gt;&lt;/fn&gt;" x:Name="actionActivity1" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/csoDepartment]' and starts-with(csoUpnSuffix,'%')]" x:Name="authenticationGateActivity3" ResolvedXpathFilter="{x:Null}" AttributeNames="csoUpnSuffix=upnSuffix" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetUserDepartmentProperties.log" OverwriteLogFile="True" LogMode="minimal" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" XPathFilter="/csoDepartment[ObjectID='[//Target/csoDepartment]' and starts-with(csoOrgUnit,'%')]" x:Name="actionActivity2" ResolvedXpathFilter="{x:Null}" AttributeNames="csoOrgUnit=orgUnit" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" LogFile="D:\LOGS\FIM\csoSetUserDepartmentProperties.log" OverwriteLogFile="False" LogMode="minimal" />
	<ns2:UpdateResourceFromWorkflowData ResolvedDisplayName="" CurrentRequest="{x:Null}" NumChangesPending="0" ResourceQuery="/Person[ObjectID='[//Target/ObjectID]']" ResolvedExtraAttributesExpression="" DisplayName="[//Target/DisplayName]" TargetResource="{x:Null}" ObjectType="Person" SaveWorkflowDataStorageMode="Object" DeleteIfFound="False" ExtraAttributes="csoUpnSuffix=string:[//WorkflowData/upnSuffix]&#xD;&#xA;Department=string:[//Target/csoDepartment/Description]&#xD;&#xA;csoOrgUnit=string:[//WorkflowData/orgUnit]" InsertIfNotFound="False" LogFile="D:\LOGS\FIM\csoSetUserDepartmentProperties.log" x:Name="authenticationGateActivity1" ResolvedQuery="{x:Null}" OverwriteLogFile="False" LogMode="minimal" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set user department properties",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Set user department bindings whenever the csoDepartment reference binding changes";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

$XOML =  @"
<ns0:AuthenticationWorkflow x:Name="AuthenticationWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" Mode="Validation" TargetId="00000000-0000-0000-0000-000000000000" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.2592.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"> <ns0:AuthenticationGateActivity ValidationError="{x:Null}" x:Name="authenticationGateActivity1" RegistrationData="{x:Null}" ChallengeResponse="{x:Null}"> <ns0:AuthenticationGateActivity.AuthenticationGate> <ns0:PasswordCheckGate ResponseTimeout="00:05:00" /> </ns0:AuthenticationGateActivity.AuthenticationGate> </ns0:AuthenticationGateActivity> <ns0:AuthenticationGateActivity ValidationError="{x:Null}" x:Name="authenticationGateActivity2" RegistrationData="{x:Null}" ChallengeResponse="{x:Null}"> <ns0:AuthenticationGateActivity.AuthenticationGate> <ns0:LockoutGate LockoutThreshold="3" TimeoutThreshold="3" ResponseTimeout="00:05:00" Timeout="15" /> </ns0:AuthenticationGateActivity.AuthenticationGate> </ns0:AuthenticationGateActivity> <ns0:AuthenticationGateActivity ValidationError="{x:Null}" x:Name="authenticationGateActivity3" RegistrationData="{x:Null}" ChallengeResponse="{x:Null}"> <ns0:AuthenticationGateActivity.AuthenticationGate> <ns0:QAAuthenticationGate ResponseTimeout="00:05:00" NumQsReqCorrectAns="3" NumQsReqRegistration="3" NumQsRandomPresented="3" NumQsDisplayedForReg="3" ValidationError="{x:Null}"> <ns0:QAAuthenticationGate.Questions> <x:Array Type="{x:Type p9:String}" xmlns:p9="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"> <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Question 1</ns1:String> <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Question 2</ns1:String> <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Question 3</ns1:String> </x:Array> </ns0:QAAuthenticationGate.Questions> </ns0:QAAuthenticationGate> </ns0:AuthenticationGateActivity.AuthenticationGate> </ns0:AuthenticationGateActivity> </ns0:AuthenticationWorkflow>
"@
$Objects.Workflows.Add("Password Reset AuthN Workflow",
@{
    "Add" = @{"RequestPhase"="Authentication"}
    "Update" = @{"Description"="Modified for CSODBB";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "UpdateObject"
})

ProcessObjects -ObjectType "WorkflowDefinition" -HashObjects $Objects.Workflows -UpdateExisting $UpdateExisting

<#
cso-Convert role for global and domain local group
cso-Convert role for global and domain local group - no ADS code
cso-Convert role for universal group
cso-Convert role for universal group with parent role
cso-Maintain domain local and global role groups
cso-Maintain domain local and global role groups - no ADS code
cso-Maintain universal role group
cso-Maintain universal role group with parent role
cso-Set entitlement display name
cso-Set entitlement display name AuthZ
cso--Set referenced user department properties
cso-Set user department properties
Password Reset AuthN Workflow
#>

###
###
### MPRs
###

$Objects.Add("MPRs", @{})
# Transition MPRs
$Objects.MPRs.Add("cso-Synchronization: Non-PHRIS users are provisioned and synchronized to AD",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionIn");"ActionParameter"=@("*")}
    "Update" = @{"ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-All active Non-PHRIS staff user accounts to be provisioned");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Users are provisioned to AD"))
                "Description"="Non-PHRIS users are provisioned and synchronized to AD"
                "Disabled"="$false"}
    "Uninstall" = "UpdateObject"
})
$Objects.MPRs.Add("cso-Synchronization: PHRIS users are provisioned and synchronized to AD",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionIn");"ActionParameter"=@("*")}
    "Update" = @{"ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-All active PHRIS staff user accounts to be provisioned");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Users are provisioned to AD"))
                "Description"="PHRIS users are provisioned and synchronized to AD"
                "Disabled"="$false"}
    "Uninstall" = "UpdateObject"
})

$Objects.MPRs.Add("cso-Synchronization: Users are provisioned and synchronized to AD",
@{
    "Add" = @{"ManagementPolicyRuleType"="SetTransition";"GrantRight"="False";"Disabled"="False";"ActionType"=@("TransitionIn");"ActionParameter"=@("*")}
    "Update" = @{"ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-All active staff user accounts to be provisioned");
                "ActionWorkflowDefinition"=@((LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Users are provisioned to AD"))
                "Description"="Users are provisioned and synchronized to AD"
                "Disabled"="$false"}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.MPRs

