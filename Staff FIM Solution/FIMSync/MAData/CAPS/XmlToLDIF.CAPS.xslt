<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2" xmlns:user="http://www.unifysolutions.net/namespace">
  <xsl:param name="mode" select="'cso'" />
  <xsl:include href="C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\Extensions\Common\Common.Script.xslt"/>
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" />
  <xsl:template match="/">
    <xsl:text>version: 1

</xsl:text>
    <xsl:call-template name="org"/>
    <xsl:apply-templates select="capsData/object[
                         (@ObjectType='entitlement' and starts-with(roles/role/@ADS.CODE,'O7'))
                         or (@ObjectType='site')
                         or (@ObjectType='person' and starts-with(roles/role/@ADS.CODE,'O7'))
                         or (@ObjectType='group' and starts-with(@ID,'O7'))]" />
  </xsl:template>
  <xsl:template name="org">
    <xsl:text>dn: uid=1,ou=organisation,ou=Objects
objectClass: organisation
ObjectType: organisation
ID: 1

</xsl:text>
  </xsl:template>
  <xsl:template match="object">
    <xsl:text>dn: uid=</xsl:text>
    <xsl:choose>
      <xsl:when test="@ObjectType='xxxentitlement'">
        <xsl:value-of select="@PERS.PIN" />
        <xsl:if test="@ADS.START">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="@ADS.START" />
        </xsl:if>
        <xsl:if test="@ADS.END">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="@ADS.END" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@ID" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,ou=</xsl:text>
    <xsl:value-of select="@ObjectType" />
    <xsl:text>,ou=Objects
objectClass: </xsl:text>
    <xsl:value-of select="@ObjectType" />
    <xsl:text>&#10;</xsl:text>
    <xsl:variable name="ObjectType" select="@ObjectType" />
    <xsl:variable name="ObjectID" select="@ID" />
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="($mode='demo') and name()='PERS.PREF.NAME'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeFirstName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='PERS.SURNAME'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeLastName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='PERS.NAMES'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeFirstName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($ObjectType='person' or $ObjectType='entitlement') and name()='ID'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: S</xsl:text>
          <xsl:value-of select="." disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="." disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$ObjectType='entitlement'">
        <xsl:if test="name()='PERS.PIN'">
          <xsl:text>user: uid=</xsl:text>
          <xsl:value-of select="." />
          <xsl:text>,ou=person,ou=Objects</xsl:text>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$ObjectType='person'">
        <xsl:if test="name()='PERS.PIN'">
          <xsl:text>EmployeeID: S</xsl:text>
          <xsl:value-of select="." />
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:if test="name()='SAL.SCHOOL'">
          <xsl:text>site: uid=</xsl:text>
          <xsl:value-of select="." />
          <xsl:text>,ou=site,ou=Objects</xsl:text>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$mode='demo'">
            <xsl:text>organisation: uid=1,ou=organisation,ou=Objects
organisationName: Head Office
</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>organisation: uid=1,ou=organisation,ou=Objects
organisationName: Office of the Bishop
</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="@ObjectType='entitlement'">
      <xsl:for-each select="roles/role/@*">
        <xsl:choose>
          <xsl:when test="name()='ADS.CODE'">
            <xsl:text>group: uid=</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>,ou=group,ou=Objects</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:value-of select="name()" disable-output-escaping="yes" />: <xsl:value-of select="." disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name()" disable-output-escaping="yes" />: <xsl:value-of select="." disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
