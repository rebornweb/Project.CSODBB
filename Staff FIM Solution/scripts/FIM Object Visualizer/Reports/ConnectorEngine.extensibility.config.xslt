<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:include href="./Common.xslt"/>
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
      <xsl:apply-templates select="//connectorconfigurations/connectorgroup/connectorconfiguration[connector]" mode="summary" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <ul>
            <xsl:apply-templates select="//connectorconfigurations/connectorgroup/connectorconfiguration[connector]" mode="toc" />
          </ul>
        </td>
      </tr>
      <xsl:for-each select="//connectorconfigurations/connectorgroup/connectorconfiguration[connector]">
        <xsl:sort select="@groupName"/>
        <tr>
          <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="5">
            <xsl:apply-templates select="connector/image" />
            <xsl:text>  </xsl:text>
            <a>
              <xsl:attribute name="name">
                <xsl:text>Connector:</xsl:text>
                <xsl:value-of select="connector/@name"/>
              </xsl:attribute>
            </a>
            <xsl:value-of select="../@groupName"/>
            <xsl:text> : </xsl:text>
            <!--
            <xsl:value-of select="@configuration"/>
            <xsl:text> : </xsl:text>
            <xsl:value-of select="connector/@connector"/>
            <xsl:text> : </xsl:text>
            -->
            <xsl:value-of select="connector/@name"/>
          </td>
          <td style="text-align:right;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
            <a href="#top">^Top</a>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'DB owner'" />
          <xsl:with-param name="value" select="@owner" />
        </xsl:call-template>
        <xsl:apply-templates select="connector/communicator" />
        <xsl:apply-templates select="connector/entitySchema" />
        <xsl:if test="getAllEntities/timing">
          <tr>
            <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:text>Section</xsl:text>
            </th>
            <td colspan="6">
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
              <xsl:call-template name="headstyle" />Offset/Value
            </th>
            <th>
              <xsl:call-template name="headstyle" />Use local
            </th>
          </tr>
          <xsl:apply-templates select="getAllEntities/timing" />
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
  <xsl:template match="timing">
    <!-- Timing Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@name"/>
      </td>
      <xsl:choose>
        <xsl:when test="@name='WeeklyExclusion'">
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@daysToExclude"/>
          </td>
          <td colspan="4"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='DailyExclusion'">
          <td/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@start"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@end"/>
          </td>
          <td/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@UseLocal"/>
          </td>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='Daily'">
          <td colspan="3"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@offset"/>
          </td>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@UseLocal"/>
          </td>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@name='RecurringTimespanStandardTime'">
          <td colspan="3"/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="timespan/@value"/>
          </td>
          <td/>
        </xsl:when>
      </xsl:choose>
    </tr>
    <xsl:apply-templates select="timing" />
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
        <th colspan="5">
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
      <td colspan="5">
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