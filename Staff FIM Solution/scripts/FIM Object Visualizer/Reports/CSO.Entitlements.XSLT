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
  <xsl:include href="./Common.Script.Short.xslt"/>
  <xsl:include href="./Common.Reports.xslt"/>
  <xsl:template match="/">
    <xsl:call-template name="CustomConfiguration" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Custom Configuration                                         -->
  <!--======================================================================================-->
  <xsl:template name="CustomConfiguration">
    <xsl:variable name="ObjectTypes">
      <objectTypes>
        <xsl:for-each select="//ResourceManagementObject[ObjectType!='AttributeTypeDescription'][ObjectType!='ma-data']">
        <!--[ObjectType='ManagementPolicyRule']-->
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
          <xsl:text>Entitlements Policy</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType!='AttributeTypeDescription'][ObjectType!='ma-data']" mode="toc">
        <xsl:sort select="ObjectType"/>
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="ObjectTypes" select="$ObjectTypes" />
      </xsl:apply-templates>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType!='AttributeTypeDescription'][ObjectType!='ma-data']" mode="detail">
        <xsl:sort select="ObjectType"/>
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="ObjectTypes" select="$ObjectTypes" />
      </xsl:apply-templates>
    </table>
  </xsl:template>
</xsl:stylesheet>