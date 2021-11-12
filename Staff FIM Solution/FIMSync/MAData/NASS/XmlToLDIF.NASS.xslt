<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2" xmlns:user="http://www.unifysolutions.net/namespace">
  <xsl:param name="mode" select="'cso'" />
  <xsl:include href="C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\Extensions\Common\Common.Script.xslt"/>
  <xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ISO-8859-1" />
  <xsl:template match="/">
    <xsl:text>version: 1

</xsl:text>
    <!--<xsl:apply-templates select="nassData/object[
                         (@ObjectType='entitlement' and starts-with(roles/role/@RoleID,'O7'))
                         or (@ObjectType='person' and starts-with(roles/role/@RoleID,'O7'))
                         or (@ObjectType='site') or (@ObjectType='department') or (@ObjectType='organisation')
                         or (@ObjectType='role' and starts-with(@ID,'O7'))]" />-->
    <xsl:apply-templates select="nassData/object" />
  </xsl:template>
  <xsl:template match="object">
    <xsl:text>dn: uid=</xsl:text>
    <xsl:value-of select="@ID" />
    <xsl:text>,ou=</xsl:text>
    <xsl:value-of select="@ObjectType" />
    <xsl:text>,ou=Objects
objectClass: </xsl:text>
    <xsl:value-of select="@ObjectType" />
    <xsl:text>&#10;</xsl:text>
    <xsl:variable name="ObjectType" select="@ObjectType" />
    <xsl:variable name="ObjectID" select="@ID" />
    <xsl:variable name="DepartmentID" select="@ID" />
    <xsl:variable name="OrganisationID" select="@ID" />
    <xsl:for-each select="@*">
      <xsl:choose>
        <xsl:when test="($mode='demo') and ($ObjectType='department') and name()='DepartmentName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetDepartmentName(number($DepartmentID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and ($ObjectType='organisation') and name()='OrganisationName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetOrganisationName(number($OrganisationID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and ($ObjectType='person') and name()='OrganisationName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:choose>
            <xsl:when test=".='Office of the Bishop'">
              <xsl:text>Head Office</xsl:text>
            </xsl:when>
            <xsl:when test=".='Parishes'">
              <xsl:text>Southern Region</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Northern Region</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='PositionTitle'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetPositionTitle(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='PreferredName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeFirstName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='Surname'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeLastName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='GivenName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeFirstName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($mode='demo') and name()='DisplayName'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="user:GetEmployeeLastName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>, </xsl:text>
          <xsl:value-of select="user:GetEmployeeFirstName(number($ObjectID))" disable-output-escaping="yes" />
          <xsl:text>&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="($ObjectType='person' or $ObjectType='entitlement') and name()='ID'">
          <xsl:value-of select="name()" disable-output-escaping="yes" />
          <xsl:text>: B</xsl:text>
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
      <xsl:choose>
        <xsl:when test="$ObjectType='entitlement'">
          <xsl:if test="name()='EmployeeID'">
            <xsl:text>user: uid=</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>,ou=person,ou=Objects</xsl:text>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$ObjectType='person'">
          <xsl:if test="name()='SiteID'">
            <xsl:text>site: uid=</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>,ou=site,ou=Objects</xsl:text>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:if test="name()='DepartmentID'">
            <xsl:text>department: uid=</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>,ou=department,ou=Objects</xsl:text>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:if test="name()='OrganisationID'">
            <xsl:text>organisation: uid=</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>,ou=organisation,ou=Objects</xsl:text>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:if test="@ObjectType='entitlement'">
      <xsl:for-each select="roles/role/@*">
        <xsl:choose>
          <xsl:when test="name()='RoleID'">
            <xsl:text>role: uid=</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>,ou=role,ou=Objects</xsl:text>
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
