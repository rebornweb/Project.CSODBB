PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false)

### Includes Workflows for processing policy upgrades at the time of the FIM=>MIM upgrade
###
### Parameters:
###   -UpdateExisting  Checks if Existing objects should be updated 
###   -Uninstall       Reverse changes made by this script


$ErrorActionPreference = "Stop"

###
### Include Scripts
###
. D:\Scripts\shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

$Objects = @{}

###
### Workflows
###

$Objects.Add("Workflows", @{})
$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LoggingActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns3="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity x:Name="authenticationGateActivity4" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;indefinite&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="Default end date" Destination="[//WorkflowData/EndDate]" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity5" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/UserID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" />
	<ns1:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="True" DateTimeQueryString="[//Target/idmStartDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity2" WorkflowDataMember="StartDate" />
	<ns1:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="False" DateTimeQueryString="[//Target/idmEndDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity3" WorkflowDataMember="EndDate" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(csoLegacyEmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity7" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(EmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity6" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="EmployeeID" />
	<ns3:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ObjectType="csoEntitlement" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="Description=string:[//Target/UserID/DisplayName] entitlements from [//WorkflowData/StartDate] to [//WorkflowData/EndDate]&#xD;&#xA;csoRecalculate=boolean:true" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity1" ResourceQuery="/csoEntitlement[ObjectID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set entitlement display name",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Set entitlement display name and mark for role recalculation";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LoggingActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns3="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity x:Name="authenticationGateActivity4" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;indefinite&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="Default end date" Destination="[//WorkflowData/EndDate]" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity5" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/UserID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" />
	<ns1:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="True" DateTimeQueryString="[//Target/idmStartDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity2" WorkflowDataMember="StartDate" />
	<ns1:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="False" DateTimeQueryString="[//Target/idmEndDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity3" WorkflowDataMember="EndDate" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(csoLegacyEmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity7" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(EmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity6" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="EmployeeID" />
	<ns3:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ObjectType="csoEntitlement" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="Description=string:[//Target/UserID/DisplayName] entitlements from [//WorkflowData/StartDate] to [//WorkflowData/EndDate]" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity1" ResourceQuery="/csoEntitlement[ObjectID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set entitlement display name AuthZ",
@{
    "Add" = @{"RequestPhase"="Authorization"}
    "Update" = @{"Description"="Set entitlement display name in the AuthZ step";
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LoggingActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns3="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity x:Name="authenticationGateActivity1" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;01/01/2100 12:00:00 AM&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="Default end date" Destination="[//WorkflowData/dtmEndDate]" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity2" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/UserID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="verbose" x:Name="authenticationGateActivity3" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime=dtmStartDate" />
	<ns2:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="False" DateTimeQueryString="[//WorkflowData/dtmStartDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity4" WorkflowDataMember="StartDate" />
	<ns2:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="False" DateTimeQueryString="[//WorkflowData/dtmEndDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity5" WorkflowDataMember="EndDate" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(csoLegacyEmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity6" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(EmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity7" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="EmployeeID" />
	<ns3:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ObjectType="csoEntitlement" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="idmStartDate=datetime:[//WorkflowData/dtmStartDate]&#xD;&#xA;idmEndDate=datetime:[//WorkflowData/dtmEndDate]&#xD;&#xA;Description=string:[//Target/UserID/DisplayName] entitlements from [//WorkflowData/StartDate] to [//WorkflowData/EndDate]&#xD;&#xA;csoRecalculate=boolean:true" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity8" ResourceQuery="/csoEntitlement[ObjectID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity9" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;NULL&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="initialise roles" Destination="[//WorkflowData/roles]" />
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.RecalculateUserRoles.log" XPathFilter="/csoRole[&#xD;&#xA;&#x9;(ObjectID=/csoEntitlement[&#xD;&#xA;&#x9;&#x9;UserID='[//Target/UserID]' &#xD;&#xA;&#x9;&#x9;and (idmStartDate &lt; fn:current-dateTime()) &#xD;&#xA;&#x9;&#x9;and ((idmEndDate &gt; op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('-P1D'))))&#xD;&#xA;&#x9;]/csoRoles/csoRollUpRole) &#xD;&#xA;&#x9;or (ObjectID=/csoEntitlement[&#xD;&#xA;&#x9;&#x9;UserID='[//Target/UserID]'&#xD;&#xA;&#x9;&#x9;and (idmStartDate &lt; fn:current-dateTime()) &#xD;&#xA;&#x9;&#x9;and ((idmEndDate &gt; op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('-P1D'))))&#xD;&#xA;&#x9;]/csoRoles)&#xD;&#xA;]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity10" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="ObjectID=roles" />
	<ns3:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\CSO.RecalculateUserRoles.log" ObjectType="Person" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/UserID/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="csoRoles=guid[]:[//WorkflowData/roles]" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity11" ResourceQuery="/Person[ObjectID='[//Target/UserID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Set default entitlement dates",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Default entitlement start and end dates, display name and description";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LoggingActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns3="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns0:FunctionActivity x:Name="authenticationGateActivity0" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;indefinite&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="Default start date" Destination="[//WorkflowData/StartDate]" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity1" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;indefinite&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="Default end date" Destination="[//WorkflowData/EndDate]" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity2" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/UserID/csoLegacyEmployeeID]&lt;/arg&gt;&lt;/fn&gt;" Description="Default EmployeeID" Destination="[//WorkflowData/EmployeeID]" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity11" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;UnknownUser&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="Default UserName" Destination="[//WorkflowData/UserName]" />
	<ns1:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="True" DateTimeQueryString="[//Target/idmStartDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity3" WorkflowDataMember="StartDate" />
	<ns1:DateConversionActivity FunctionParameters="" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ResolvedQuery="" DateTimeFormat="yyyyMMdd" LogMode="minimal" CurrentRequest="{x:Null}" OverwriteLogFile="False" DateTimeQueryString="[//Target/idmEndDate]" SelectFunction="ToLocalTime" x:Name="authenticationGateActivity4" WorkflowDataMember="EndDate" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(csoLegacyEmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity5" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="csoLegacyEmployeeID=EmployeeID&#xD;&#xA;ObjectID=UserID&#xD;&#xA;DisplayName=UserName" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" XPathFilter="/Person[ObjectID='[//Target/UserID]' and starts-with(EmployeeID,'%')]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity6" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="EmployeeID&#xD;&#xA;ObjectID=UserID&#xD;&#xA;DisplayName=UserName" />
	<ns3:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\CSO.SetEntitlementDisplayName.log" ObjectType="csoEntitlement" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//WorkflowData/EmployeeID] [//WorkflowData/StartDate]-[//WorkflowData/EndDate]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="Description=string:[//WorkflowData/UserName] entitlements from [//WorkflowData/StartDate] to [//WorkflowData/EndDate]" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity7" ResourceQuery="/csoEntitlement[ObjectID='[//Target/ObjectID]' and csoRoles=/csoRole]" OverwriteLogFile="False" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity8" FunctionExpression="&lt;fn id=&quot;SingleValueAssignment&quot;  isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&quot;NULL&quot;&lt;/arg&gt;&lt;/fn&gt;" Description="initialise roles" Destination="[//WorkflowData/roles]" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\CSO.RecalculateUserRoles.log" XPathFilter="/csoRole[&#xD;&#xA;&#x9;(ObjectID=/csoEntitlement[&#xD;&#xA;&#x9;&#x9;UserID='[//WorkflowData/UserID]' &#xD;&#xA;&#x9;&#x9;and (idmStartDate &lt; fn:current-dateTime()) &#xD;&#xA;&#x9;&#x9;and ((idmEndDate &gt; op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('-P1D'))))&#xD;&#xA;&#x9;]/csoRoles/csoRollUpRole) &#xD;&#xA;&#x9;or (ObjectID=/csoEntitlement[&#xD;&#xA;&#x9;&#x9;UserID='[//WorkflowData/UserID]'&#xD;&#xA;&#x9;&#x9;and (idmStartDate &lt; fn:current-dateTime()) &#xD;&#xA;&#x9;&#x9;and ((idmEndDate &gt; op:add-dayTimeDuration-to-dateTime(fn:current-dateTime(), xs:dayTimeDuration('-P1D'))))&#xD;&#xA;&#x9;]/csoRoles)&#xD;&#xA;]" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity9" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="ObjectID=roles" />
	<ns3:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\CSO.RecalculateUserRoles.log" ObjectType="Person" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//WorkflowData/UserName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="csoRoles=guid[]:[//WorkflowData/roles]" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity10" ResourceQuery="/Person[ObjectID='[//WorkflowData/UserID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Recalculate user roles from current entitlement context and set display name",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Recalculate user roles from current entitlement context and set display name";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

<#$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ADSGroupManagement.Universal.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.Universal.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain universal role group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain a universal group for selected roles";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})#>

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ADSGroupManagement.Universal.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.Universal.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:NULL&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain universal role group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain a universal group for selected roles";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ADSGroupManagement.UniversalWithParent.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.UniversalWithParent.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain universal role group with parent role",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain a universal group for selected roles with parent role";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ADSGroupManagement.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain domain local and global role groups",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain domain local and global role groups";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ADSGroupManagement.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;Description=string:[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns2:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;Description=string:[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Maintain domain local and global role groups - no ADS code",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Maintain domain local and global role groups - no ADS code";
                "RunOnPolicyUpdate"="True"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})


<#$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ADSGroupManagement.Universal.log" XPathFilter="//Request" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ADSGroupManagement.Universal.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for universal group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role to managing universal distribution groups in lieu of domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})#>

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity1" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroup.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:NULL&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for universal group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role to managing universal distribution groups in lieu of domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroupWithParent.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity1" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroupWithParent.log" XPathFilter="//Request" OverwriteLogFile="True" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForUniversalGroupWithParent.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="verbose" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-U&#xD;&#xA;MailNickname=string:[//WorkflowData/AccountName]-U&#xD;&#xA;Description=string:[//Target/DisplayName]&#xD;&#xA;Scope=string:Universal&#xD;&#xA;Type=string:Distribution&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/*[(ObjectType='Person' and csoRoles='[//Target/ObjectID]') or (ObjectType='Group' and Scope='Universal' and csoParentRoleID='[//Target/ObjectID]')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Universal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for universal group with parent role",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role with parent role to managing universal distribution groups in lieu of domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity6" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroup.log" XPathFilter="//Request" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;+&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&lt;fn id=&quot;Right&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/csoADSCode]&lt;/arg&gt;&lt;arg&gt;6&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroup.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/csoADSCode]-[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;csoADSCode=string:[//Target/csoADSCode]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for global and domain local group",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role from managing universal distribution groups back to managing domain local/global nested groups";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

$XOML =  @"
<ns0:SequentialWorkflow x:Name="SequentialWorkflow" ActorId="00000000-0000-0000-0000-000000000000" WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" RequestId="00000000-0000-0000-0000-000000000000" TargetId="00000000-0000-0000-0000-000000000000" xmlns:ns1="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.UpdateResourceActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns:ns2="clr-namespace:UFIM.CustomActivities;Assembly=UFIM.LookupPropertiesActivity, Version=1.0.0.0, Culture=neutral, PublicKeyToken=77071b69c28b13cd" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.0.3732.2, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="False" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="" DeleteIfFound="True" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity6" ResourceQuery="/Group[csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="True" />
	<ns2:LookupPropertiesActivity ResolverWorkflowDataKey="{x:Null}" ResolvedXpathFilter="{x:Null}" LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" XPathFilter="//Request" OverwriteLogFile="False" LogMode="minimal" x:Name="authenticationGateActivity2" SaveWorkflowDataStorageMode="Object" CurrentRequest="{x:Null}" AttributeNames="CreatedTime" />
	<ns0:FunctionActivity x:Name="authenticationGateActivity3" FunctionExpression="&lt;fn id=&quot;Left&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;true&quot;&gt;&lt;arg&gt;&lt;fn id=&quot;ReplaceString&quot; isCustomExpression=&quot;false&quot;&gt;&lt;arg&gt;[//Target/DisplayName]&lt;/arg&gt;&lt;arg&gt;&quot; &quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;&quot;/&quot;&lt;/arg&gt;&lt;arg&gt;&quot;&quot;&lt;/arg&gt;&lt;/fn&gt;&lt;/arg&gt;&lt;arg&gt;56&lt;/arg&gt;&lt;/fn&gt;" Description="Derive account name" Destination="[//WorkflowData/AccountName]" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-G" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-G&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/DisplayName]-G&#xD;&#xA;Scope=string:Global&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Person[csoRoles = '[//Target/ObjectID]']&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity4" ResourceQuery="/Group[Scope='Global' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
	<ns1:UpdateResourceFromWorkflowData LogFile="D:\Logs\FIM\cso.ConvertRoleForGlobalGroupNoADSCode.log" ObjectType="Group" TargetResource="{x:Null}" ResolvedExtraAttributesExpression="" ResolvedQuery="{x:Null}" InsertIfNotFound="True" ResolvedDisplayName="" DisplayName="[//Target/DisplayName]-D" CurrentRequest="{x:Null}" NumChangesPending="0" LogMode="minimal" ExtraAttributes="AccountName=string:[//WorkflowData/AccountName]-D&#xD;&#xA;MailNickname=string:&#xD;&#xA;Description=string:[//Target/DisplayName]-D&#xD;&#xA;Scope=string:DomainLocal&#xD;&#xA;Type=string:Security&#xD;&#xA;Domain=string:DBB&#xD;&#xA;csoRoleID=guid:[//Target/ObjectID]&#xD;&#xA;csoParentRoleID=guid:[//Target/csoParentRoleID]&#xD;&#xA;Filter=string:&amp;lt;Filter xmlns:xsi=&amp;quot;http://www.w3.org/2001/XMLSchema-instance&amp;quot; xmlns:xsd=&amp;quot;http://www.w3.org/2001/XMLSchema&amp;quot; Dialect=&amp;quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&amp;quot; xmlns=&amp;quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&amp;quot;&gt;/Group[(csoRoleID = '[//Target/ObjectID]' and Scope='Global') or (csoParentRoleID = '[//Target/ObjectID]' and Scope='DomainLocal')]&amp;lt;/Filter&gt;&#xD;&#xA;MembershipAddWorkflow=string:None&#xD;&#xA;MembershipLocked=boolean:true&#xD;&#xA;Owner=guid[]:[//Target/Owner]&#xD;&#xA;DisplayedOwner=guid:[//Target/DisplayedOwner]&#xD;&#xA;RetentionPeriod=int:30" DeleteIfFound="False" SaveWorkflowDataStorageMode="Object" x:Name="authenticationGateActivity5" ResourceQuery="/Group[Scope='DomainLocal' and csoRoleID='[//Target/ObjectID]']" OverwriteLogFile="False" />
</ns0:SequentialWorkflow>
"@
$Objects.Workflows.Add("cso-Convert role for global and domain local group - no ADS code",
@{
    "Add" = @{"RequestPhase"="Action"}
    "Update" = @{"Description"="Convert role from managing universal distribution groups back to managing domain local/global nested groups - no ADS code";
                "RunOnPolicyUpdate"="False"
                "XOML" = $XOML}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "WorkflowDefinition" -HashObjects $Objects.Workflows

###
### Sets 
###
### Create new set
###

$Objects.Add("Set",@{})

$Xpath = "/csoRole[(DisplayedOwner = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "All People" -NoPrefix $true)']/ComputedMember) and (csoRequiresUniversalGroup = True) and (csoParentRoleID != /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso-All Roles" -NoPrefix $true)']/ComputedMember)]"
$Objects.Set.Add("cso-Roles with an owner for universal groups",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="Roles with an owner for generating universal distribution groups"}
    "Uninstall" = "DeleteObject" 
})

$Xpath = "/csoRole[(DisplayedOwner = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "All People" -NoPrefix $true)']/ComputedMember) and (csoRequiresUniversalGroup = True) and (csoParentRoleID = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "cso-All Roles" -NoPrefix $true)']/ComputedMember)]"
$Objects.Set.Add("cso-Roles with an owner and parent role for universal groups",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="Roles with an owner and parent role for generating universal distribution groups"}
    "Uninstall" = "DeleteObject" 
})

$Xpath = "/csoRole[(DisplayedOwner = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "All People" -NoPrefix $true)']/ComputedMember) and (not(csoRequiresUniversalGroup = True)) and (starts-with(csoADSCode,'%'))]"
$Objects.Set.Add("cso-Roles with an owner for global groups",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="Roles with an owner for creating global security groups"}
    "Uninstall" = "DeleteObject" 
})

$Xpath = "/csoRole[(DisplayedOwner = /Set[ObjectID = '$(LookupObject -ObjectType "Set" -Name "All People" -NoPrefix $true)']/ComputedMember) and (not(csoRequiresUniversalGroup = True)) and not(starts-with(csoADSCode,'%'))]"
$Objects.Set.Add("cso-Roles with an owner for global groups - no ADS Code",
@{
    "Add" = @{};
    "Update" = @{"Filter"=SetFilter -XPath $Xpath
                "Description" ="Roles with an owner for creating global security groups - no ADS Code"}
    "Uninstall" = "DeleteObject" 
})


ProcessObjects -ObjectType "Set" -HashObjects $Objects.Set

###
###
### MPRs
###

$Objects.Add("MPRs", @{})
$MPRName = "cso-Group Management: Distribution Groups are maintained for selected roles with parent roles"
$ActionParams = @("csoADSCode"
"csoInheritOwner"
"csoIsActive"
"csoIsRollup"
"csoParentRoleID"
"csoRollUpRole"
"csoSite"
"Description"
"DisplayedOwner"
"DisplayName"
"Owner")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$($ActionParams)
                "ActionType"=@("Add","Create","Modify","Remove")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-All Roles")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner and parent role for universal groups")
                "Description"="Distribution Groups are maintained for selected roles with parent roles"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Maintain universal role group with parent role"))}
    "Uninstall" = "DeleteObject"
})

$MPRName = "cso-Group management: All global and domain local groups to be replaced with universal groups are deleted"
$ActionParams = @("csoRequiresUniversalGroup")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$ActionParams
                "ActionType"=@("Modify")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-All Roles")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner for universal groups")
                "Description"="All global and domain local groups to be replaced with universal groups are deleted"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Convert role for universal group"))}
    "Uninstall" = "DeleteObject"
})

$MPRName = "cso-Group management: All global and domain local groups to be replaced with universal groups with a parent role are deleted"
$ActionParams = @("csoRequiresUniversalGroup")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$ActionParams
                "ActionType"=@("Modify")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-All Roles")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner and parent role for universal groups")
                "Description"="All global and domain local groups to be replaced with universal groups with a parent role are deleted"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Convert role for universal group with parent role"))}
    "Uninstall" = "DeleteObject"
})

$MPRName = "cso-Group Management: Global and Domain Local Security Groups are maintained for each role"
$ActionParams = @("csoADSCode"
"csoInheritOwner"
"csoIsActive"
"csoIsRollup"
"csoParentRoleID"
"csoRollUpRole"
"csoSite"
"Description"
"DisplayedOwner"
"DisplayName"
"Owner")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$($ActionParams)
                "ActionType"=@("Add","Create","Modify","Remove")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles for global groups")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner for global groups")
                "Description"="Global and Domain Local Security Groups are maintained for each role"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Maintain domain local and global role groups"))}
    "Uninstall" = "DeleteObject"
})

$MPRName = "cso-Group Management: Global and Domain Local Security Groups are maintained for each role - no ADS Code"
$ActionParams = @("csoADSCode"
"csoInheritOwner"
"csoIsActive"
"csoIsRollup"
"csoParentRoleID"
"csoRollUpRole"
"csoSite"
"Description"
"DisplayedOwner"
"DisplayName"
"Owner")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$($ActionParams)
                "ActionType"=@("Add","Create","Modify","Remove")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles for global groups")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner for global groups - no ADS Code")
                "Description"="Global and Domain Local Security Groups are maintained for each role - no ADS Code"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Maintain domain local and global role groups - no ADS Code"))}
    "Uninstall" = "DeleteObject"
})

$MPRName = "cso-Group management: All universal groups to be replaced with global and domain local groups are deleted"
$ActionParams = @("csoRequiresUniversalGroup")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$ActionParams
                "ActionType"=@("Modify")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles for universal groups")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner for global groups")
                "Description"="All universal groups to be replaced with global and domain local groups are deleted"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Convert role for global and domain local group"))}
    "Uninstall" = "DeleteObject"
})

$MPRName = "cso-Group management: All universal groups to be replaced with global and domain local groups are deleted - no ADS code"
$ActionParams = @("csoRequiresUniversalGroup")
$Objects.MPRs.Add($MPRName,
@{
    "Add" = @{"ManagementPolicyRuleType"="Request";"GrantRight"="false"}
    "Update" = @{"ActionParameter"=$ActionParams
                "ActionType"=@("Modify")
                "PrincipalSet"=(LookupObject -ObjectType "Set" -Name "cso-All synchronised resource modifiers")
                "ResourceCurrentSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles for universal groups")
                "ResourceFinalSet"=(LookupObject -ObjectType "Set" -Name "cso-Roles with an owner for global groups - no ADS code")
                "Description"="All universal groups to be replaced with global and domain local groups are deleted"
                "ActionWorkflowDefinition"=@($(LookupObject -ObjectType "WorkflowDefinition" -Name "cso-Convert role for global and domain local group - no ADS code"))}
    "Uninstall" = "DeleteObject"
})

ProcessObjects -ObjectType "ManagementPolicyRule" -HashObjects $Objects.MPRs

