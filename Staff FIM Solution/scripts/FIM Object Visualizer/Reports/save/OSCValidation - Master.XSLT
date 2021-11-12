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
  <xsl:include href="./Common.Reports.xslt"/>
  <xsl:template match="/">
    <xsl:call-template name="AdminRoleConfiguration" />
  </xsl:template>
  
  <!--======================================================================================-->
  <!-- Template to display the Portal Admin Role Configuration                              -->
  <!--======================================================================================-->
  <xsl:template name="AdminRoleConfiguration">
    <xsl:variable name="ObjectTypes">
      <objectTypes>
        <xsl:for-each select="//ResourceManagementObject[ObjectType='Person']">
          <xsl:sort select="ObjectType"/>
          <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
          <objectType>
            <xsl:value-of select="ObjectType"/>
          </objectType>
        </xsl:for-each>
      </objectTypes>
    </xsl:variable>
    <xsl:variable name="OrgClaimTypeID" select="//ResourceManagementObject[ObjectType='DEEWR-claimType'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value='Org']/ObjectIdentifier" />
    <xsl:variable name="OSCClaimTypeID" select="//ResourceManagementObject[ObjectType='DEEWR-claimType'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value='IAMOSC']/ObjectIdentifier" />
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>Users with Org Claims missing OSCs</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType='Person']" mode="Missing">
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="OrgClaimTypeID" select="$OrgClaimTypeID"/>
        <xsl:with-param name="OSCClaimTypeID" select="$OSCClaimTypeID"/>
      </xsl:apply-templates>
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>OSCs</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$OSCClaimTypeID]" mode="OSC">
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="ObjectTypes" select="$ObjectTypes"/>
      </xsl:apply-templates>
    </table>
  </xsl:template>

  <xsl:template match="ResourceManagementObject" mode="Missing">
    <xsl:param name="OrgClaimTypeID"/>
    <xsl:param name="OSCClaimTypeID"/>
    <xsl:variable name="UserID" select="ObjectIdentifier"/>
    <xsl:variable name="OSCs" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-esg-orgUserID']/Values" />
    <xsl:apply-templates select="//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$UserID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$OrgClaimTypeID]" mode="Claims">
      <xsl:with-param name="UserID" select="$UserID"/>
      <xsl:with-param name="OrgClaimTypeID" select="$OrgClaimTypeID"/>
      <xsl:with-param name="OSCClaimTypeID" select="$OSCClaimTypeID"/>
      <xsl:with-param name="pos" select="position()" />
      <xsl:with-param name="OSCs" select="$OSCs" />
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- Only list the Org claims where there are no corresponding OSCs -->
  <xsl:template match="ResourceManagementObject" mode="Claims">
    <xsl:param name="UserID"/>
    <xsl:param name="OrgClaimTypeID"/>
    <xsl:param name="OSCClaimTypeID"/>
    <xsl:param name="pos"/>
    <xsl:param name="OSCs"/>
    <xsl:variable name="ClaimValueID" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string" />
    <xsl:if test="not(//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$OSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$OSCs/string])">
      <a name="#{$UserID}" />
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property">User</xsl:with-param>
        <xsl:with-param name="value" select="$UserID" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property">Claim Type</xsl:with-param>
        <xsl:with-param name="value" select="$OrgClaimTypeID" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property">OrgClaim</xsl:with-param>
        <xsl:with-param name="value" select="ObjectIdentifier" />
      </xsl:call-template>
      <xsl:for-each select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string">
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property">ClaimValue</xsl:with-param>
          <xsl:with-param name="value" select="." />
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="$OSCs/string">
        <xsl:variable name="thisOSC" select="." />
        <xsl:if test="not(//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$OSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$thisOSC])">
          <xsl:call-template name="DataItem">
            <xsl:with-param name="property">OSC</xsl:with-param>
            <xsl:with-param name="value" select="." />
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$OSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$OSCs/string]">
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property">Lookup OSC</xsl:with-param>
          <xsl:with-param name="value" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value" />
        </xsl:call-template>
      </xsl:for-each>
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- All OSCs (Persons with IAMOSC claims) -->
  <xsl:template match="ResourceManagementObject" mode="OSC">
    <xsl:param name="ObjectTypes"/>
    <xsl:variable name="OSCUserID" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value"/>
    <!-- Complete Person details of each OSC -->
    <xsl:apply-templates select="//ResourceManagementObject[(ObjectType='Person') and (ObjectIdentifier=$OSCUserID)]" mode="detail">
      <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
      <xsl:with-param name="ObjectTypes" select="''" />
    </xsl:apply-templates>
  </xsl:template>
</xsl:stylesheet>