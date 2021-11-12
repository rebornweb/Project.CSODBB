<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:include href="./Common.xslt"/>
  <xsl:include href="./Common.Script.xslt"/>
  <ms:script language='VBScript' implements-prefix="dsml">
<![CDATA[

Option Explicit

Const AD_OPEN_STATIC = 3
Const AD_LOCK_OPTIMISTIC = 3
Const AD_USE_CLIENT = 3

Dim strSQLServer, strDBName
strSQLServer = ReadReg("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\FIMSynchronizationService\Parameters\Server")
strDBName = ReadReg("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\FIMSynchronizationService\Parameters\DBName")

Function ReadReg(RegPath)
     Dim objRegistry, Key
     Set objRegistry = CreateObject("Wscript.shell")
     Key = objRegistry.RegRead(RegPath)
     ReadReg = Key
End Function

Function GetMAName(maGuid)

  GetMAName = maGuid

  Const PktPrivacy = 6
  Const wbemAuthenticationLevelPkt = 6
  Dim Service, Locator, ManagementAgents, MAName, MA
  Set Locator = CreateObject("WbemScripting.SWbemLocator")
  Locator.Security_.AuthenticationLevel = wbemAuthenticationLevelPkt
  Set Service = Locator.ConnectServer("localhost", "root/MicrosoftIdentityIntegrationServer")
	Set ManagementAgents = Service.ExecQuery("Select * from MIIS_ManagementAgent Where Guid = '{" & maGuid & "}'")
  for each MA in ManagementAgents
     GetMAName=MA.Name
     exit for
  next
  Set Locator = Nothing
  Set Service = Nothing
End Function

Function GetRPName(rpGuid)

    GetRPName = rpGuid

    Dim objConnection
    Set objConnection = CreateObject("ADODB.Connection")
    objConnection.Open "Provider=SQLOLEDB;Data Source=" & strSQLServer & ";" & _ 
                      "Trusted_Connection=Yes;Initial Catalog=" & strDBName & ";" 

    Dim objRecordset
    Set objRecordset = CreateObject("ADODB.Recordset")
    objRecordset.CursorLocation = AD_USE_CLIENT

    Dim strSQL, curField
    strSQL = "Select run_profile_name from dbo.mms_run_profile where run_profile_id = '{" & _
        rpGuid & "}' "
    objRecordset.Open strSQL, objConnection, _
                    AD_OPEN_STATIC, AD_LOCK_OPTIMISTIC
    If Not objRecordset.eof Then
      objRecordset.MoveFirst
      For each curField in objRecordset.fields
        GetRPName = objRecordset(Trim(curField.Name))
        Exit For
      Next
    End If
    
    Set objRecordset = Nothing
    Set objConnection = Nothing

End Function

]]>
</ms:script>
  
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="EventBrokerOperations" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Event Broker Agents                                          -->
  <!--======================================================================================-->
  <xsl:template name="EventBrokerOperations">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>Event Broker 3.0 - Operations</xsl:text>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <ul>
            <xsl:apply-templates select="//OperationListConfigurations/OperationList" mode="toc" />
          </ul>
        </td>
      </tr>
      <xsl:apply-templates select="//OperationListConfigurations/OperationList" mode="body">
        <xsl:sort select="@name"/>
      </xsl:apply-templates>
    </table>
  </xsl:template>
  <xsl:template match="OperationList" mode="toc">
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#Oplist:</xsl:text>
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:value-of select="@name"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="OperationList" mode="body">
    <!-- Main Body -->
    <tr>
      <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="5">
        <a>
          <xsl:attribute name="name">
            <xsl:text>OpList:</xsl:text>
            <xsl:value-of select="@name"/>
          </xsl:attribute>
        </a>
        <xsl:value-of select="@name"/>
      </td>
      <td style="text-align:right;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
        <a href="#top">^Top</a>
      </td>
    </tr>
    <!-- Comments -->
    <xsl:if test="Comment">
      <xsl:apply-templates select="Comment" />
    </xsl:if>
    <!-- Operation Properties -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Run on startup'" />
      <xsl:with-param name="value" select="@runOnStartup" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Queue missed'" />
      <xsl:with-param name="value" select="@queueMissed" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Enabled'" />
      <xsl:with-param name="value" select="@enabled" />
    </xsl:call-template>
    <!-- Schedules -->
    <xsl:if test="Schedules/Timing">
      <tr>
        <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
          <xsl:text>Section</xsl:text>
        </th>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Schedules</xsl:text>
        </td>
      </tr>
      <tr>
        <th>
          <xsl:call-template name="headstyle" />Name
        </th>
        <th>
          <xsl:call-template name="headstyle" />Time of day
        </th>
        <th>
          <xsl:call-template name="headstyle" />Use local
        </th>
        <th>
          <xsl:call-template name="headstyle" />Number of days
        </th>
        <th>
          <xsl:call-template name="headstyle" />Start from
        </th>
        <th>
          <xsl:call-template name="headstyle" />Time span
        </th>
      </tr>
      <xsl:apply-templates select="Schedules/Timing"/>
    </xsl:if>
    <!-- Check Operations -->
    <xsl:if test="CheckOperation">
      <tr>
        <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
          <xsl:text>Section</xsl:text>
        </th>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Check Operations</xsl:text>
        </td>
      </tr>
      <tr>
        <th>
          <xsl:call-template name="headstyle" />Plug in
        </th>
        <th>
          <xsl:call-template name="headstyle" />Agent
        </th>
        <th colspan="1">
          <xsl:call-template name="headstyle" />Failure Settings
        </th>
        <th colspan="3">
          <xsl:call-template name="headstyle" />Custom
        </th>
      </tr>
      <xsl:apply-templates select="CheckOperation"/>
    </xsl:if>
      <!-- Operations -->
    <tr>
      <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
        <xsl:text>Section</xsl:text>
      </th>
      <td colspan="5">
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Operations</xsl:text>
      </td>
    </tr>
    <tr>
      <th>
        <xsl:call-template name="headstyle" />Plug in
      </th>
      <th>
        <xsl:call-template name="headstyle" />Agent
      </th>
      <th colspan="1">
        <xsl:call-template name="headstyle" />Failure Settings
      </th>
      <th colspan="3">
        <xsl:call-template name="headstyle" />Custom
      </th>
    </tr>
    <xsl:apply-templates select="Operations/Operation"/>
    <!-- Groups -->
    <xsl:if test="*/Group">
      <tr>
        <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
          <xsl:text>Section</xsl:text>
        </th>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Groups</xsl:text>
        </td>
      </tr>
      <tr>
        <th>
          <xsl:call-template name="headstyle" />Type
        </th>
        <th colspan="5">
          <xsl:call-template name="headstyle" />Name
        </th>
      </tr>
      <xsl:apply-templates select="*/Group" />
    </xsl:if>
    <xsl:if test="position() != last()">
      <tr>
        <td colspan="2" style="color:#F7FBFA;">
          <xsl:text>-</xsl:text>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="Comment">
    <!-- Comment Section -->
    <tr>
      <td align="left" style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#ffffff;font-weight:normal;padding-top:5px" colspan="6">
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Group">
    <!-- Group Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="name(..)"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="dsml:GetGroupName(string(@id))"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Timing">
    <!-- Schedule Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@timeOfDay"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@useLocal"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@numberOfDays"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@startFrom"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="Timespan/@value"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Operation">
    <!-- Operation Section -->
    <tr valign="top">
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="substring-after(@plugIn,'Unify.EventBroker.PlugIn.')"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:if test="Agents/Agent">
          <xsl:value-of select="dsml:GetAgentName(string(Agents/Agent/@id))"/>
        </xsl:if>
      </td>
      <td border="1" colspan="1">
        <xsl:call-template name="centercell" />
        <table width="100%" id="tdata">
          <xsl:call-template name="tablestyle" />
          <xsl:apply-templates select="Failure"/>
        </table>
      </td>
      <td border="1" colspan="2">
        <xsl:call-template name="centercell" />
        <table width="100%" id="tdata">
          <xsl:call-template name="tablestyle" />
          <xsl:apply-templates select="Extended/*"/>
        </table>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="CheckOperation">
    <!-- Check Operation Section -->
    <tr valign="top">
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="substring-after(@plugIn,'Unify.EventBroker.PlugIn.')"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:if test="Agents/Agent">
          <xsl:value-of select="dsml:GetAgentName(string(Agents/Agent/@id))"/>
        </xsl:if>
      </td>
      <td border="1" colspan="1">
        <xsl:call-template name="centercell" />
        <table width="100%" id="tdata">
          <xsl:call-template name="tablestyle" />
          <xsl:apply-templates select="Failure"/>
        </table>
      </td>
      <td border="1" colspan="2">
        <xsl:call-template name="centercell" />
        <table width="100%" id="tdata">
          <xsl:call-template name="tablestyle" />
          <xsl:apply-templates select="Extended/*"/>
        </table>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Failure">
    <!-- Failure Processing Section -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Retry count'" />
      <xsl:with-param name="value" select="@retryCount" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Retry wait period'" />
      <xsl:with-param name="value" select="dsml:TimeFromDuration(string(@retryWaitPeriod))" />
      <!--<xsl:with-param name="value" select="fn:minutes-from-duration(string(@retryWaitPeriod))" />-->
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Success action'" />
      <xsl:with-param name="value" select="@successAction" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Failure action'" />
      <xsl:with-param name="value" select="@failureAction" />
    </xsl:call-template>
  </xsl:template>
  <!-- Custom Plugin Sections -->
  <xsl:template match="Extended/CommitADChanges">
    <!-- AD Commit Changes Plugin -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Operation'" />
      <xsl:with-param name="value" select="'AD Commit changes'" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="Extended/ADSyncChanges">
    <!-- AD Sync Changes Plugin -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Operation'" />
      <xsl:with-param name="value" select="'AD Sync changes'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'OU Name'" />
      <xsl:with-param name="value" select="@ouName" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'LDAP filter'" />
      <xsl:with-param name="value" select="." />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="Extended/IdentityBrokerChanges">
    <!-- Identity Broker Changes Plugin -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Operation'" />
      <xsl:with-param name="value" select="'Identity Broker changes'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Adapter'" />
      <xsl:with-param name="value" select="dsml:GetAdapterName(string(@adapterId))" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="Extended/RunProfile">
    <!-- Run Profile Plugin -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Operation'" />
      <xsl:with-param name="value" select="'Run profile'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Management agent'" />
      <xsl:with-param name="value" select="dsml:GetMAName(string(@managementAgentId))" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Run profile'" />
      <xsl:with-param name="value" select="dsml:GetRPName(string(@runProfileId))" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="Extended/PSChanges">
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Operation'" />
      <xsl:with-param name="value" select="'Execute PowerShell Script'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Script'" />
      <xsl:with-param name="value" select="@PSScript" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="Extended/ClearRunHistory">
    <!-- Clear Run History Plugin -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Operation'" />
      <xsl:with-param name="value" select="'Clear run history'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Delete runs after days'" />
      <xsl:with-param name="value" select="@deleteRunsAfterDays" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Archive file location'" />
      <xsl:with-param name="value" select="@archiveFileLocation" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Custom xsl file path'" />
      <xsl:with-param name="value" select="@customXslFilePath" />
    </xsl:call-template>
  </xsl:template>
  <!-- Agents -->
  <xsl:template match="IdentityBrokerAgent">
    <!-- Identity Broker Agent -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Endpoint address'" />
      <xsl:with-param name="value" select="@EndPointAddress" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Management studio endpoint configuration name'" />
      <xsl:with-param name="value" select="@ManagementStudioEndpointConfigurationName" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Changes endpoint configuration name'" />
      <xsl:with-param name="value" select="@ChangesEndpointConfigurationName" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="AD">
    <!-- AD Agent -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Server'" />
      <xsl:with-param name="value" select="@Server" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'User name'" />
      <xsl:with-param name="value" select="@UserName" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Password'" />
      <xsl:with-param name="value" select="'***'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Authentication'" />
      <xsl:with-param name="value" select="@Authentication" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="FIMAgent">
    <!-- FIM Agent -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Server name'" />
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="string-length(@serverName)='0'">
            <xsl:value-of select="'localhost'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="serverName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'User name'" />
      <xsl:with-param name="value" select="@userName" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Password'" />
      <xsl:with-param name="value" select="'***'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Connection string'" />
      <xsl:with-param name="value" select="'***'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Use standard view'" />
      <xsl:with-param name="value" select="@useStandardView" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Success statuses'" />
      <xsl:with-param name="value" select="@successStatus" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Local instance'" />
      <xsl:with-param name="value" select="@isLocalInstance" />
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>