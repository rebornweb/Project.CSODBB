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
          <xsl:text>Identity Broker 4.0 - Agents</xsl:text>
        </td>
      </tr>
      <tr>
        <td colspan="2" style="color:#F7FBFA;">
          <xsl:text>-</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//AgentEngine/Agents/Agent">
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
  <xsl:template match="communicator">
    <tr>
      <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
        <xsl:text>Section</xsl:text>
      </th>
      <td colspan="6">
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Communicator</xsl:text>
      </td>
    </tr>
	<xsl:choose>
		<xsl:when test="@connectionString">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Connection String'" />
			  <xsl:with-param name="value" select="@connectionString" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@endpointAddress">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'End Point'" />
			  <xsl:with-param name="value" select="@endpointAddress" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Impersonation Level'" />
			  <xsl:with-param name="value" select="@endpointTokenImpersonationLevel" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Configuration'" />
			  <xsl:with-param name="value" select="@endpointConfiguration" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'User Name'" />
			  <xsl:with-param name="value" select="@endpointUsername" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Secure Password'" />
			  <xsl:with-param name="value" select="@endpointSecurePassword" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'DB owner'" />
			  <xsl:with-param name="value" select="@owner" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'DB table'" />
			  <xsl:with-param name="value" select="@table" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'DB read threshold'" />
			  <xsl:with-param name="value" select="@readThreshold" />
			</xsl:call-template>
			<xsl:if test="dataConnection">
			  <xsl:call-template name="DataItem">
				<xsl:with-param name="property" select="'DB connection'" />
				<xsl:with-param name="value" select="dataConnection/@name" />
				<xsl:with-param name="colspanValue" select="5" />
			  </xsl:call-template>
			  <xsl:call-template name="DataItem">
				<xsl:with-param name="property" select="'DB connection string'" />
				<xsl:with-param name="value" select="dataConnection/@connectionString" />
				<xsl:with-param name="colspanValue" select="5" />
			  </xsl:call-template>
			  <xsl:if test="filters">
				<xsl:for-each select="filters/filter">
				  <xsl:call-template name="DataItem">
					<xsl:with-param name="property" select="'Filter'" />
					<xsl:with-param name="value" select="concat(@field,@value)" />
					<xsl:with-param name="colspanValue" select="5" />
				  </xsl:call-template>
				</xsl:for-each>
			  </xsl:if>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
    <xsl:if test="filter">
      <tr>
        <th>
          <xsl:call-template name="headstyle" />Field
        </th>
        <th colspan="6">
          <xsl:call-template name="headstyle" />Value
        </th>
      </tr>
      <xsl:apply-templates select="filter">
        <xsl:sort select="@field"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>