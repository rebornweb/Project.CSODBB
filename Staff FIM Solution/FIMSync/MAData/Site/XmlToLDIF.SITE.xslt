<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2">
  <xsl:param name="mode" select="'cso'" />
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" />
  <xsl:template match="/">
    <xsl:text>version: 1
</xsl:text>
    <xsl:apply-templates select="sites/IdM.dbo.Site" />
  </xsl:template>
  
  <xsl:template match="IdM.dbo.Site">
    <xsl:variable name="site" select="@SiteID" />
    <xsl:text>
dn: uid=</xsl:text>
    <xsl:value-of select="@SiteID" />
    <xsl:text>,ou=Site,ou=Objects
objectClass: site</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="name()='SiteDummy'"></xsl:when>
        <xsl:when test="($mode='demo') and name()='SiteName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="../@SiteDummy" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text><xsl:value-of select="." disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
