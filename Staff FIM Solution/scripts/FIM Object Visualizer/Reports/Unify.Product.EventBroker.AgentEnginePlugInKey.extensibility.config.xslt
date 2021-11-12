<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:include href="./Common.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="EventBrokerAgents" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Event Broker Agents                                          -->
  <!--======================================================================================-->
  <xsl:template name="EventBrokerAgents">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Event Broker 3.0 - Agents</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//AgentEngine">
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Test Connections'" />
          <xsl:with-param name="value" select="@testConnections" />
        </xsl:call-template>
      </xsl:for-each>
      <tr>
        <td colspan="2" style="color:#F7FBFA;">
          <xsl:text>-</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//AgentConfigurations/Agent">
        <xsl:sort select="@name"/>
        <tr>
          <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="5">
            <xsl:value-of select="@name"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Type'" />
          <xsl:with-param name="value" select="@type" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'ID'" />
          <xsl:with-param name="value" select="@id" />
        </xsl:call-template>
        <xsl:apply-templates select="Extended/*"/>
        <xsl:if test="position() != last()">
          <tr>
            <td colspan="2" style="color:#F7FBFA;">
              <xsl:text>-</xsl:text>
            </td>
          </tr>
        </xsl:if>
      </xsl:for-each>
    </table>
  </xsl:template>
  <xsl:template match="IdentityBrokerAgent">
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