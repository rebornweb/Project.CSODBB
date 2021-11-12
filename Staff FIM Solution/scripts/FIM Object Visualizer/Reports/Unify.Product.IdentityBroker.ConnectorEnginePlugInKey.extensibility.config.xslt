<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:include href="./Common.xslt"/>
  <xsl:include href="./Common.Script.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="IdentityBrokerConnectors" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Identity Broker Connectors                                   -->
  <!--======================================================================================-->
  <xsl:template name="IdentityBrokerConnectors">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>Identity Broker 3.0 - Connector Definitions</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//dataConnection[@repository]" mode="repository"/>
      <!--<xsl:apply-templates select="//connectorconfigurations/connectorconfiguration[connector]" mode="summary" />-->
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <ul>
            <xsl:apply-templates select="//connectorconfigurations/connectorconfiguration[connector[not(starts-with(@name,'ZZ'))]]" mode="toc" />
          </ul>
        </td>
      </tr>
      <xsl:for-each select="//connectorconfigurations/connectorconfiguration[connector]">
        <xsl:sort select="@name"/>
        <tr>
          <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="6">
            <xsl:apply-templates select="connector/image" />
            <xsl:text>  </xsl:text>
            <a>
              <xsl:attribute name="name">
                <xsl:text>Connector:</xsl:text>
                <xsl:value-of select="connector/@name"/>
              </xsl:attribute>
            </a>
			<xsl:value-of select="substring-after(connector/@connector,'Unify.Connectors.')"/>
            <xsl:text> Connector : </xsl:text>
            <xsl:value-of select="connector/@name"/>
          </td>
          <td style="text-align:right;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
            <a href="#top">^Top</a>
          </td>
        </tr>
        <xsl:apply-templates select="connector/entitySchema" />
        <xsl:apply-templates select="connector/Agents/Agent" />
        <xsl:if test="substring-before(substring-after(connector/@connector,'Unify.Connectors.'),'.')='PeopleSoft'">
          <xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Enabled'" />
			  <xsl:with-param name="value" select="connector/@enabled" />
			</xsl:call-template>
          <xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Audit Level'" />
			  <xsl:with-param name="value" select="connector/@auditLevel" />
			</xsl:call-template>
          <xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Queue Missed'" />
			  <xsl:with-param name="value" select="connector/@queueMissed" />
			</xsl:call-template>
          <!--xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Image'" />
			  <xsl:with-param name="value" select="connector/@image" />
			</xsl:call-template>-->
        </xsl:if>
        <xsl:apply-templates select="connector/Extended[*]">
			<xsl:with-param name="type" select="substring-after(connector/@connector,'Unify.Connectors.')" />
		</xsl:apply-templates>
        <xsl:if test="getAllEntities/Timing or polling/Timing">
          <tr>
            <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:text>Section</xsl:text>
            </th>
            <td colspan="7">
              <xsl:call-template name="reportheadstyle" />
              <xsl:text>Schedule</xsl:text>
            </td>
          </tr>
          <tr>
            <th>
              <xsl:call-template name="headstyle" />Name
            </th>
            <th>
              <xsl:call-template name="headstyle" />Days to exclude
            </th>
            <th>
              <xsl:call-template name="headstyle" />Start
            </th>
            <th>
              <xsl:call-template name="headstyle" />End
            </th>
            <th>
              <xsl:call-template name="headstyle" />Day of Week
            </th>
            <th>
              <xsl:call-template name="headstyle" />Offset/Value
            </th>
            <th>
              <xsl:call-template name="headstyle" />Use local
            </th>
          </tr>
          <xsl:apply-templates select="getAllEntities/Timing" />
          <xsl:apply-templates select="polling/Timing" />
        </xsl:if>
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
  <xsl:template match="connectorconfiguration" mode="summary">
    <xsl:if test="position()='1'">
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Configuration'" />
        <xsl:with-param name="value" select="@configuration" />
        <xsl:with-param name="colspanValue" select="5" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Connector Class'" />
        <xsl:with-param name="value" select="connector/@connector" />
        <xsl:with-param name="colspanValue" select="5" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match="connectorconfiguration" mode="toc">
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#Connector:</xsl:text>
          <xsl:value-of select="connector/@name"/>
        </xsl:attribute>
        <xsl:value-of select="connector/@name"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="Timing">
    <!-- Timing Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="name(../.)"/>
		<xsl:text>:</xsl:text>
        <xsl:value-of select="@name"/>
      </td>
      <xsl:choose>
        <xsl:when test="@name='WeekExclusion'">
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@daysToExclude"/>
          </td>
          <td colspan="4"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='DayExclusion'">
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@daysToExclude"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="Timing/@startFrom"/>
          </td>
          <td colspan="1"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@dayOfWeek"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="Timing/Timespan/@value"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@useLocal"/>
          </td>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='OnceOff'">
          <td colspan="1"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@startFrom"/>
          </td>
          <td colspan="3"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@useLocal"/>
          </td>
         </xsl:when>
        <xsl:when test="@name='Daily'">
          <td colspan="1"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@startFrom"/>
          </td>
          <td colspan="1"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@dayOfWeek"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@timeOfDay"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@useLocal"/>
          </td>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='Weekly'">
          <td colspan="1"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@startFrom"/>
          </td>
          <td colspan="1"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@dayOfWeek"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@timeOfDay"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@useLocal"/>
          </td>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='RecurringTimespanStandardTime'">
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@daysToExclude"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@startFrom"/>
          </td>
          <td colspan="2"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="Timespan/@value"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@useLocal"/>
          </td>
        </xsl:when>
      </xsl:choose>
    </tr>
    <!--<xsl:apply-templates select="Timing" />-->
  </xsl:template>
  <xsl:template match="dataConnection" mode="repository">
    <!-- Data connection Section -->
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Data connection'" />
      <xsl:with-param name="value" select="@name" />
      <xsl:with-param name="colspanValue" select="5" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Repository'" />
      <xsl:with-param name="value" select="@repository" />
      <xsl:with-param name="colspanValue" select="5" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="Agent">
    <!-- Operation Section -->
    <tr>
      <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
        <xsl:text>Section</xsl:text>
      </th>
      <td colspan="6">
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Agent</xsl:text>
      </td>
    </tr>
    <tr valign="top">
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
		  <xsl:value-of select="@type"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
		  <xsl:value-of select="dsml:GetIdBAgentName(string(@id))"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Extended">
	<xsl:param name="type"/>
    <tr>
      <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
        <xsl:text>Section</xsl:text>
      </th>
      <td colspan="6">
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Implemented Methods - </xsl:text>
		<xsl:value-of select="$type"/>
      </td>
    </tr>
    <tr>
      <th>
		<xsl:choose>
			<xsl:when test="$type='PowerShell'">
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Get All Entities'" />
				  <xsl:with-param name="value" select="@GetAllEntities" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Add Entities'" />
				  <xsl:with-param name="value" select="@AddEntities" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Update Entities'" />
				  <xsl:with-param name="value" select="@UpdateEntities" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Delete Entities'" />
				  <xsl:with-param name="value" select="@DeleteEntities" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Delete All Entities'" />
				  <xsl:with-param name="value" select="@DeleteAllEntities" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Get Schema'" />
				  <xsl:with-param name="value" select="@GetSchema" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Poll Entity Changes'" />
				  <xsl:with-param name="value" select="@PollEntityChanges" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type='SharePoint.List'">
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'List Name'" />
				  <xsl:with-param name="value" select="@listName" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Row Limit'" />
				  <xsl:with-param name="value" select="@rowLimit" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'View Name'" />
				  <xsl:with-param name="value" select="@viewName" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Polling Change Token Offset'" />
				  <xsl:with-param name="value" select="@pollingChangeTokenOffset" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Debug'" />
				  <xsl:with-param name="value" select="@debug" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type='CSV'">
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'File'" />
				  <xsl:with-param name="value" select="file/text()" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type='Direct'">
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Owner'" />
				  <xsl:with-param name="value" select="communicator/@owner" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Table'" />
				  <xsl:with-param name="value" select="communicator/@table" />
				</xsl:call-template>
				<xsl:call-template name="DataItem">
				  <xsl:with-param name="property" select="'Read Threshold'" />
				  <xsl:with-param name="value" select="communicator/@readThreshold" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
      </th>
    </tr>
  </xsl:template>
  <xsl:template match="entitySchema">
    <tr>
      <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
        <xsl:text>Section</xsl:text>
      </th>
      <td colspan="6">
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Entity Schema</xsl:text>
      </td>
    </tr>
    <tr>
      <th>
        <xsl:call-template name="headstyle" />Name
      </th>
      <th>
        <xsl:call-template name="headstyle" />Validator
      </th>
      <th>
        <xsl:call-template name="headstyle" />Read only
      </th>
      <th>
        <xsl:call-template name="headstyle" />Required
      </th>
      <th colspan="2">
        <xsl:call-template name="headstyle" />Key
      </th>
    </tr>
    <xsl:apply-templates select="field">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
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
  <xsl:template match="image">
    <img>
      <xsl:attribute name="alt">
        <xsl:value-of select="../@name"/>
      </xsl:attribute>
      <xsl:attribute name="src">
        <xsl:text>data:image/jpeg;base64,</xsl:text>
        <xsl:value-of select="node()"/>
      </xsl:attribute>
    </img>
  </xsl:template>
  <xsl:template match="filter">
    <!-- Connector Filter Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@field"/>
      </td>
      <td colspan="6">
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@value"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="field">
    <!-- Connector Field Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@validator"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@readonly"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@required"/>
      </td>
      <td colspan="2">
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@key"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>