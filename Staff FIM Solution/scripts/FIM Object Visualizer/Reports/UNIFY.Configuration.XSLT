<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:ms="urn:schemas-microsoft-com:xslt" 
                xmlns:dsml="http://www.dsml.org/DSML" 
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xmlns:my="http://schemas.microsoft.com/2006/11/ResourceManagement" 
                xmlns:xd="http://schemas.microsoft.com/office/infopath/2003">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:include href="./Common.xslt"/>
  <xsl:include href="./Common.Script.Short.xslt"/>
  <xsl:template match="/">
    <xsl:call-template name="PortalConfiguration" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Portal Configuration                                         -->
  <!--======================================================================================-->
  <xsl:template name="PortalConfiguration">
    <xsl:variable name="ObjectTypes">
      <objectTypes>
        <xsl:for-each select="//ResourceManagementObject">
          <xsl:sort select="ObjectType"/>
          <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
          <objectType>
            <xsl:value-of select="ObjectType"/>
          </objectType>
        </xsl:for-each>
      </objectTypes>
    </xsl:variable>
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>FIM Portal Configuration - TOC</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject" mode="toc">
        <xsl:sort select="ObjectType"/>
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="ObjectTypes" select="$ObjectTypes" />
      </xsl:apply-templates>
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>FIM Portal Configuration - Detail</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject" mode="detail">
        <xsl:sort select="ObjectType"/>
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="ObjectTypes" select="$ObjectTypes" />
      </xsl:apply-templates>
    </table>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="toc">
    <xsl:param name="ObjectTypes" />
    <xsl:variable name="ObjectType" select="ObjectType" />
    <xsl:variable name="PrevIndex" select="position()-1" />
    <xsl:variable name="PrevObjectType">
      <xsl:choose>
        <xsl:when test="position()=1"></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ms:node-set($ObjectTypes)/objectTypes/objectType[$PrevIndex]/text()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="ObjectType!=$PrevObjectType">
      <tr>
        <td colspan="6">
          <xsl:call-template name="subheadstyle" />
          <xsl:text>Resource Type: </xsl:text>
          <xsl:value-of select="ObjectType/text()"/>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <ol>
            <xsl:apply-templates select="//ResourceManagementObject[ObjectType=$ObjectType]" mode="toc2">
              <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value/text()"/>
              <xsl:with-param name="ObjectType" select="$ObjectType"/>
            </xsl:apply-templates>
          </ol>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="detail">
    <xsl:param name="ObjectTypes" />
    <xsl:variable name="ObjectType" select="ObjectType" />
    <xsl:variable name="PrevIndex" select="position()-1" />
    <xsl:variable name="PrevObjectType">
      <xsl:choose>
        <xsl:when test="position()=1"></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ms:node-set($ObjectTypes)/objectTypes/objectType[$PrevIndex]/text()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="ObjectType!=$PrevObjectType">
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Resource Type: </xsl:text>
          <xsl:value-of select="ObjectType/text()"/>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <xsl:apply-templates select="//ResourceManagementObject[ObjectType=$ObjectType]/ResourceManagementAttributes" mode="detail">
            <xsl:sort select="Value/text()"/>
            <xsl:with-param name="ObjectType" select="$ObjectType"/>
            <xsl:with-param name="ObjectId" select="substring-after(ObjectIdentifier,'urn:uuid:')"/>
          </xsl:apply-templates>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="toc2">
    <xsl:param name="ObjectType" />
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="substring-after(ObjectIdentifier,'urn:uuid:')"/>
        </xsl:attribute>
        <xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="ResourceManagementAttributes" mode="detail">
    <xsl:param name="ObjectType" />
    <xsl:param name="ObjectId" />
    <tr>
      <td colspan="5">
        <xsl:call-template name="subheadstyle" />
        <a>
          <xsl:attribute name="name">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="substring-after(ResourceManagementAttribute[AttributeName='ObjectID']/Value,'urn:uuid:')"/>
          </xsl:attribute>
        </a>
        <xsl:value-of select="position()"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
      </td>
      <td>
        <xsl:call-template name="subheadrightstyle" />
        <a href="#top">^Top</a>
      </td>
    </tr>
    <xsl:for-each select="ResourceManagementAttribute">
      <xsl:choose>
        <xsl:when test="AttributeName='Creator'">
          <!-- do nothing -->
        </xsl:when>
        <xsl:when test="AttributeName='ConfigurationData'">
          <xsl:call-template name="DataItem">
            <xsl:with-param name="property" select="AttributeName" />
            <xsl:with-param name="value" select="'*** embedded xml ***'" />
            <xsl:with-param name="valueSpan" select="5" />
          </xsl:call-template>
          <!--
          <xsl:variable name="innerXml" select="dsml:GetXmlFromXmlText(string(Value),'xmlns:my=&quot;http://schemas.microsoft.com/2006/11/ResourceManagement&quot;')"/>
          <xsl:call-template name="DataItem">
            <xsl:with-param name="property" select="AttributeName" />
            <xsl:with-param name="value" select="ms:node-set($innerXml)" />
            <xsl:with-param name="valueSpan" select="5" />
          </xsl:call-template>
          <xsl:for-each select="ms:node-set($innerXml)/*">
            <xsl:call-template name="DataItem">
              <xsl:with-param name="property" select="name(.)" />
              <xsl:with-param name="value" select="." />
              <xsl:with-param name="valueSpan" select="5" />
            </xsl:call-template>
          </xsl:for-each>
          <xsl:apply-templates select="ms:node-set($innerXml)/my:ObjectControlConfiguration" mode="ConfigurationData"/>
          <xsl:variable 
            name="innerXml" 
            select="dsml:GetNodeListFromText(string(Value),'//my:Control','xmlns:my=&quot;http://schemas.microsoft.com/2006/11/ResourceManagement&quot;')" />
          -->
        </xsl:when>
        <xsl:when test="AttributeName='StringResources'">
          <!--<xsl:variable
            name="innerXml"
            select="dsml:GetNodeListFromText(string(Value),'//SymbolResourcePair','xmlns:xsl=&quot;http://www.w3.org/1999/XSL/Transform&quot;')" />-->
          <xsl:call-template name="DataItem">
            <xsl:with-param name="property" select="AttributeName" />
            <xsl:with-param name="value" select="'*** embedded xml ***'" />
            <xsl:with-param name="valueSpan" select="5" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="Value">
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="Value" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="Values">
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value">
                  <xsl:apply-templates select="Values" mode="multiValue"/>
                </xsl:with-param>
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="my:ObjectControlConfiguration" mode="ConfigurationData">
    <xsl:for-each select="*">
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="name(.)" />
        <xsl:with-param name="value" select="." />
        <xsl:with-param name="valueSpan" select="5" />
      </xsl:call-template>
    </xsl:for-each>
    <!--<xsl:apply-templates />-->
  </xsl:template>
</xsl:stylesheet>