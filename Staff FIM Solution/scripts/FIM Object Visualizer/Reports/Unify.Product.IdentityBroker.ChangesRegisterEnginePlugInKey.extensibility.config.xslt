<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:include href="./Common.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="IdentityBrokerRepository" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Identity Broker Repository                                   -->
  <!--======================================================================================-->
  <xsl:template name="IdentityBrokerRepository">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Identity Broker 3.0 - Repository</xsl:text>
        </td>
      </tr>
      <xsl:if test="ChangesRegister/dataConnection">
        <xsl:apply-templates select="ChangesRegister/dataConnection" mode="repository" />
      </xsl:if>
    </table>
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
</xsl:stylesheet>