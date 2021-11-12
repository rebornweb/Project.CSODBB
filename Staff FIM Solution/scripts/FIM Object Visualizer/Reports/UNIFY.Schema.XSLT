<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:include href="./Common.xslt"/>
  <xsl:include href="./Common.Script.Short.xslt"/>
  <xsl:template match="/">
    <xsl:call-template name="PortalSchema" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Provisioning Triple                                          -->
  <!--======================================================================================-->
  <xsl:template name="PortalSchema">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="7">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>FIM Portal Schema Configuration</xsl:text>
        </td>
      </tr>
      <tr>
        <td colspan="7">
          <ol>
            <xsl:apply-templates select="//Configuration[Section='ResourceType']" mode="toc">
              <xsl:sort select="Name"/>
            </xsl:apply-templates>
          </ol>
        </td>
      </tr>
      <tr>
        <td colspan="7">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Resource Types</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//Configuration[Section='ResourceType']" mode="ResourceType">
        <xsl:sort select="ObjectTypeId"/>
        <xsl:sort select="Name"/>
      </xsl:apply-templates>
      <tr>
        <td colspan="7">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Attributes</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//Configuration[Section='Attribute']" mode="Attribute">
        <xsl:sort select="Name"/>
      </xsl:apply-templates>
      <xsl:call-template name="UnboundAttributes" />
    </table>
  </xsl:template>
  <xsl:template match="Configuration" mode="toc">
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text disable-output-escaping="yes">#</xsl:text>
          <xsl:value-of select="Id"/>
        </xsl:attribute>
        <xsl:value-of select="Name"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="Configuration" mode="ResourceType">
    <xsl:variable name="ObjectTypeID" select="Id"/>
    <tr>
      <td colspan="6">
        <xsl:call-template name="subheadstyle" />
        <a>
          <xsl:attribute name="name">
            <xsl:text disable-output-escaping="yes">#</xsl:text>
            <xsl:value-of select="Id"/>
          </xsl:attribute>
        </a>
        <xsl:value-of select="position()"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="Name"/>
      </td>
      <td>
        <xsl:call-template name="subheadrightstyle" />
        <a href="#top">^Top</a>
      </td>
    </tr>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'DisplayName'" />
      <xsl:with-param name="value" select="DisplayName" />
      <xsl:with-param name="colspanValue" select="'6'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Description'" />
      <xsl:with-param name="value" select="Desc" />
      <xsl:with-param name="colspanValue" select="'6'" />
    </xsl:call-template>
    <tr>
      <th>
        <xsl:call-template name="headstyle" />Name
      </th>
      <th>
        <xsl:call-template name="headstyle" />Attribute Type
      </th>
      <th>
        <xsl:call-template name="headstyle" />Description
      </th>
      <th>
        <xsl:call-template name="headstyle" />Required
      </th>
      <th>
        <xsl:call-template name="headstyle" />Type
      </th>
      <th>
        <xsl:call-template name="headstyle" />Multi-valued
      </th>
      <th>
        <xsl:call-template name="headstyle" />Regex
      </th>
    </tr>
    <xsl:apply-templates select="//Configuration[Section='Binding'][ObjectTypeId=$ObjectTypeID]" mode="Binding">
      <xsl:sort select="Name"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="Configuration" mode="Binding">
    <xsl:variable name="AttributeTypeId" select="AttributeTypeId/text()"/>
    <xsl:variable name="AttributeType" select="//Configuration[Id=$AttributeTypeId]/Name/text()"/>
    <xsl:if test="not($AttributeType='CreatedTime') 
            and not($AttributeType='Creator') 
            and not($AttributeType='DeletedTime') 
            and not($AttributeType='DetectedRulesList') 
            and not($AttributeType='ExpectedRulesList') 
            and not($AttributeType='ExpirationTime') 
            and not($AttributeType='Locale') 
            and not($AttributeType='MVObjectID') 
            and not($AttributeType='ObjectID') 
            and not($AttributeType='ResourceTime')">
      <tr>
        <xsl:call-template name="multiline" />
        <td>
          <xsl:value-of select="DisplayName"/>
        </td>
        <td>
          <a>
            <xsl:attribute name="href">
              <xsl:text disable-output-escaping="yes">#</xsl:text>
              <xsl:value-of select="AttributeTypeId"/>
            </xsl:attribute>
            <xsl:value-of select="$AttributeType"/>
          </a>
        </td>
        <td>
          <xsl:value-of select="Desc"/>
        </td>
        <td>
          <xsl:value-of select="Required"/>
        </td>
        <td>
          <xsl:value-of select="//Configuration[Id=$AttributeTypeId]/DataType/text()"/>
        </td>
        <td>
          <xsl:value-of select="//Configuration[Id=$AttributeTypeId]/Mv/text()"/>
        </td>
        <td>
          <xsl:if test="StringRegex">
            <xsl:if test="not(string-length(normalize-space(StringRegex))='0')">
              <xsl:value-of select="dsml:ReplaceString(dsml:ReplaceString(string(StringRegex),'|',' |'),'+',' +')" />
            </xsl:if>
          </xsl:if>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="Configuration" mode="Attribute">
    <tr>
      <td colspan="6">
        <xsl:call-template name="subheadstyle" />
        <a>
          <xsl:attribute name="name">
            <xsl:text disable-output-escaping="yes">#</xsl:text>
            <xsl:value-of select="Id"/>
          </xsl:attribute>
        </a>
        <xsl:value-of select="position()"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="Name"/>
      </td>
      <td>
        <xsl:call-template name="subheadrightstyle" />
        <a href="#top">^Top</a>
      </td>
    </tr>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'DisplayName'" />
      <xsl:with-param name="value" select="DisplayName" />
      <xsl:with-param name="colspanValue" select="'6'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Description'" />
      <xsl:with-param name="value" select="Desc" />
      <xsl:with-param name="colspanValue" select="'6'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'DataType'" />
      <xsl:with-param name="value" select="DataType" />
      <xsl:with-param name="colspanValue" select="'6'" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Multivalue'" />
      <xsl:with-param name="value" select="Mv" />
      <xsl:with-param name="colspanValue" select="'6'" />
    </xsl:call-template>
    <xsl:if test="StringRegex">
      <xsl:if test="not(string-length(normalize-space(StringRegex))='0')">
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Regex'" />
          <xsl:with-param name="value" select="dsml:ReplaceString(dsml:ReplaceString(string(StringRegex),'|',' |'),'+',' +')" />
          <xsl:with-param name="colspanValue" select="'6'" />
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:if test="position() != last()">
      <tr>
        <td colspan="7" style="color:#F7FBFA;">
          <xsl:text>-</xsl:text>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <!-- the following are attributes which do not occur in any binding to a resource-->
  <xsl:template name="UnboundAttributes">
    <tr>
      <td colspan="7">
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Unbound Attributes</xsl:text>
      </td>
    </tr>
    <tr>
      <td colspan="7" style="background:yellow;">
        <xsl:apply-templates select="//Configuration[Section='Attribute']" mode="Unbound">
          <xsl:sort select="Name"/>
        </xsl:apply-templates>
      </td>
    </tr>
  </xsl:template>
  <!-- the following are attributes which do not occur in any binding to a resource-->
  <xsl:template match="Configuration" mode="Unbound">
    <xsl:variable name="t" select="'file:///D:/Scripts/FIM.ScriptBox/FIM%20Object%20Visualizer/FIM%20Object%20Visualizer.hta'"/>
    <xsl:variable name="Id" select="Id"/>
    <xsl:variable name="IsBound">
      <xsl:choose>
        <xsl:when test="//Configuration[Section='Binding'][AttributeTypeId=$Id]">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$IsBound='0'">
      <li>
        <a>
          <xsl:attribute name="href">
            <xsl:text disable-output-escaping="yes">#</xsl:text>
            <xsl:value-of select="Id"/>
          </xsl:attribute>
          <xsl:value-of select="Name"/>
        </a>
      </li>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>