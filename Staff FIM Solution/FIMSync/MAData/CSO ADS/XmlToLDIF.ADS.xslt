<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2">
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" />
  <xsl:template match="/">
    <xsl:text>version: 1
</xsl:text>
    <xsl:apply-templates select="csoADSData/workSheets/workSheet" />
    <xsl:apply-templates select="csoADSData/workSheets/workSheet/adsCode" />
    <!--<xsl:text>&#10;</xsl:text>-->
  </xsl:template>
  
  <xsl:template match="workSheet">
    <xsl:variable name="site">
      <xsl:choose>
        <xsl:when test="contains(@name,'-')">
          <xsl:value-of select="substring-before(@name,'-')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@name" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains(@name,'-old')"></xsl:when>
      <xsl:otherwise>
        <xsl:text>
dn: uid=</xsl:text>
        <xsl:value-of select="$site" />
        <xsl:text>,ou=Sites
objectClass: site</xsl:text>
        <xsl:text>
site: </xsl:text>
        <xsl:value-of select="$site" />
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="adsCode">
    <xsl:text>
dn: uid=</xsl:text>
    <xsl:value-of select="@code" />
    <xsl:text>,ou=ADSCodes
objectClass: adsCode</xsl:text>
    <xsl:if test="@parentCode">
      <xsl:text>
parentDn: uid=</xsl:text>
      <xsl:value-of select="@parentCode" />
      <xsl:text>,ou=ADSCodes</xsl:text>
    </xsl:if>
    <xsl:text>
siteDN: uid=</xsl:text>
    <xsl:value-of select="@site" />
    <xsl:text>,ou=Sites</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select="@*">
      <xsl:value-of select="name()" disable-output-escaping="yes" />: <xsl:value-of select="." disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:variable name="rollUpKey" select="@code"/>
    <xsl:apply-templates select="//adsCode[rollUpCode/@code=$rollUpKey]" mode="rollUp" />
    <xsl:apply-templates select="adsCode" />
    <!--<xsl:variable name="groupCode" select="concat(substring(@code,1,6),'0')"></xsl:variable>
    <xsl:if test="substring(@code,7,1)='1'"/>
    <xsl:if test="not(//adsCode[@code=$groupCode])">
      <xsl:call-template name="GenerateGroupLevel">
        <xsl:with-param name="adsCode" select="$groupCode"/>
        <xsl:with-param name="parentCode" select="@parentCode"/>
      </xsl:call-template>
    </xsl:if>-->
  </xsl:template>
  
  <xsl:template match="adsCode" mode="rollUp">
    <xsl:text>rollupDn: uid=</xsl:text>
    <xsl:value-of select="@code" />
    <xsl:text>,ou=ADSCodes
</xsl:text>
  </xsl:template>
  
  <xsl:template name="GenerateGroupLevel">
    <xsl:param name="adsCode"/>
    <xsl:param name="parentCode"/>
    <xsl:text>
dn: uid=</xsl:text>
    <xsl:value-of select="$adsCode" />
    <xsl:text>,ou=ADSCodes
derived=true
name=</xsl:text>
    <xsl:value-of select="$adsCode" />
    <xsl:text>
objectClass: adsCode</xsl:text>
    <xsl:if test="$parentCode">
      <xsl:text>
parentDn: uid=</xsl:text>
      <xsl:value-of select="$parentCode" />
      <xsl:text>,ou=ADSCodes
    </xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
