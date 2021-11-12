<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML">
  <xsl:include href="./Common.xslt"/>
  <xsl:include href="./Common.Script.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="IdentityBrokerAdapters" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Identity Broker Adapters                                     -->
  <!--======================================================================================-->
  <xsl:template name="IdentityBrokerAdapters">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="4">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>Identity Broker 3.0 - Adapter Definitions</xsl:text>
        </td>
      </tr>
      <tr>
        <td colspan="4">
          <xsl:call-template name="reportheadstyle" />
          <ul>
            <xsl:apply-templates select="//AdapterEngineConfigurations/AdapterConfiguration" mode="toc">
              <xsl:sort select="../../@AdapterName"/>
              <xsl:sort select="@AdapterName"/>
            </xsl:apply-templates>
          </ul>
        </td>
      </tr>
      <xsl:apply-templates select="//AdapterEngineConfigurations/AdapterConfiguration" mode="body">
        <xsl:sort select="../../@AdapterName"/>
        <xsl:sort select="@AdapterName"/>
      </xsl:apply-templates>
    </table>
  </xsl:template>
  <xsl:template match="AdapterConfiguration" mode="body">
    <tr>
      <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="3">
        <xsl:choose>
          <xsl:when test="../../@AdapterName">
            <xsl:apply-templates select="../../image" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="image" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>  </xsl:text>
        <a>
          <xsl:attribute name="name">
            <xsl:text>#Adapter:</xsl:text>
            <xsl:if test="../../@AdapterName">
              <xsl:value-of select="../../@AdapterName"/>
              <xsl:text>:</xsl:text>
            </xsl:if>
            <xsl:value-of select="@AdapterName"/>
          </xsl:attribute>
        </a>
        <xsl:if test="../../@AdapterName">
          <xsl:value-of select="../../@AdapterName"/>
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:value-of select="@AdapterName"/>
      </td>
      <td style="text-align:right;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
        <a href="#top">^Top</a>
      </td>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Type'"/>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="../../@AdapterName">
              <xsl:text>Composite</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Single</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Class'" />
        <xsl:with-param name="value" select="@class" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Base Connector'" />
        <xsl:with-param name="value" select="dsml:GetConnectorName(string(@BaseConnectorId))" />
      </xsl:call-template>
    </tr>
    <xsl:if test="dn">
      <tr>
        <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
          <xsl:text>Section</xsl:text>
        </th>
        <td colspan="3">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Distinguished Name Generation</xsl:text>
        </td>
      </tr>
      <tr>
        <th>
          <xsl:call-template name="headstyle" />Name
        </th>
        <th>
          <xsl:call-template name="headstyle" />Key
        </th>
        <th>
          <xsl:call-template name="headstyle" />Value
        </th>
        <th>
          <xsl:call-template name="headstyle" />Attribute type
        </th>
      </tr>
      <xsl:apply-templates select="dn/dnComponent" />
    </xsl:if>
    <xsl:if test="adapterEntityTransformationFactory[@name='ChainList'][adapter]">
      <tr>
        <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
          <xsl:text>Section</xsl:text>
        </th>
        <td colspan="3">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>ChainList Adapters</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="adapterEntityTransformationFactory/adapter" mode="ChainList">
        <xsl:sort select="@name"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  <xsl:template match="adapter" mode="ChainList">
    <xsl:choose>
      <xsl:when test="@name='Relational.dn'">
        <tr>
          <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Reference target</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
            <xsl:value-of select="dn/@target"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Input key'" />
          <xsl:with-param name="value" select="@InputKey" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship connector'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(@RelationshipConnectorId))" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship key'" />
          <xsl:with-param name="value" select="@RelationshipKey" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@name='Relation.Group.dn'">
        <tr>
          <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Reference group target</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
            <xsl:value-of select="@GroupTarget"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Input key'" />
          <xsl:with-param name="value" select="@InputKey" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship connector'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(@RelationshipConnectorId))" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relation key'" />
          <xsl:with-param name="value" select="@RelationKey" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relation reference'" />
          <xsl:with-param name="value" select="@RelationReference" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <tr>
          <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Unexpected Transformation</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
            <xsl:value-of select="@name"/>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
    <tr>
      <th>
        <xsl:call-template name="headstyle" />Name
      </th>
      <th>
        <xsl:call-template name="headstyle" />Key
      </th>
      <th>
        <xsl:call-template name="headstyle" />Value
      </th>
      <th>
        <xsl:call-template name="headstyle" />Attribute type
      </th>
    </tr>
    <xsl:apply-templates select="dn/dnComponent" />
  </xsl:template>
  <xsl:template match="dnComponent">
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@name"/>
      </td>
      <xsl:choose>
        <xsl:when test="@name='Field'">
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@key"/>
          </td>
          <td/>
        </xsl:when>
        <xsl:when test="@name='Constant'">
          <td/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@value"/>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td colspan="2"/>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@attributeType"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="AdapterConfiguration" mode="toc">
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#Adapter:</xsl:text>
          <xsl:if test="../../@AdapterName">
            <xsl:value-of select="../../@AdapterName"/>
            <xsl:text>:</xsl:text>
          </xsl:if>
          <xsl:value-of select="@AdapterName"/>
        </xsl:attribute>
        <xsl:if test="../../@AdapterName">
          <xsl:value-of select="../../@AdapterName"/>
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:value-of select="@AdapterName"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="image">
    <img>
      <xsl:attribute name="alt">
        <xsl:value-of select="../@AdapterName"/>
      </xsl:attribute>
      <xsl:attribute name="src">
        <xsl:text>data:image/jpeg;base64,</xsl:text>
        <xsl:value-of select="node()"/>
      </xsl:attribute>
    </img>
  </xsl:template>
</xsl:stylesheet>