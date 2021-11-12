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
    <xsl:variable name="SiteClaimTypeID" select="//ResourceManagementObject[ObjectType='DEEWR-claimType'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value='Site']/ObjectIdentifier" />
    <xsl:variable name="SSCClaimTypeID" select="//ResourceManagementObject[ObjectType='DEEWR-claimType'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value='IAMSSC']/ObjectIdentifier" />
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>Users with Site Claims missing SSCs</xsl:text>
          <!--<xsl:text>Users with SSCs missing Site Claims</xsl:text>-->
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType='Person']" mode="Missing">
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="SiteClaimTypeID" select="$SiteClaimTypeID"/>
        <xsl:with-param name="SSCClaimTypeID" select="$SSCClaimTypeID"/>
      </xsl:apply-templates>
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>SSCs</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$SSCClaimTypeID]" mode="SSC">
        <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        <xsl:with-param name="ObjectTypes" select="$ObjectTypes"/>
      </xsl:apply-templates>
    </table>
  </xsl:template>

  <xsl:template match="ResourceManagementObject" mode="Missing">
    <xsl:param name="SiteClaimTypeID"/>
    <xsl:param name="SSCClaimTypeID"/>
    <xsl:variable name="UserID" select="ObjectIdentifier"/>
    <xsl:variable name="SSCs" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-esg-siteUserID']/Values" />
    <xsl:apply-templates select="//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$UserID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$SiteClaimTypeID]" mode="SiteClaims">
      <xsl:with-param name="UserID" select="$UserID"/>
      <xsl:with-param name="SiteClaimTypeID" select="$SiteClaimTypeID"/>
      <xsl:with-param name="SSCClaimTypeID" select="$SSCClaimTypeID"/>
      <xsl:with-param name="pos" select="position()" />
      <xsl:with-param name="SSCs" select="$SSCs" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- Only list the Site claims where there are no corresponding SSCs -->
  <xsl:template match="ResourceManagementObject" mode="SiteClaims">
    <xsl:param name="UserID"/>
    <xsl:param name="SiteClaimTypeID"/>
    <xsl:param name="SSCClaimTypeID"/>
    <xsl:param name="pos"/>
    <xsl:param name="SSCs"/>
    <xsl:variable name="ClaimValueID" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string" />
    <xsl:if test="(//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$SSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value) or ($SSCs/string)">
      <xsl:if test="not(//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$SSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$SSCs/string])">
        <!--<a name="#{$UserID}" />-->
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property">User</xsl:with-param>
          <xsl:with-param name="value" select="$UserID" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property">Claim Type</xsl:with-param>
          <xsl:with-param name="value" select="$SiteClaimTypeID" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property">SiteClaim</xsl:with-param>
          <xsl:with-param name="value" select="ObjectIdentifier" />
        </xsl:call-template>
        <xsl:for-each select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string">
          <xsl:call-template name="DataItem">
            <xsl:with-param name="property">ClaimValue</xsl:with-param>
            <xsl:with-param name="value" select="." />
          </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$SSCs/string">
          <xsl:variable name="thisSSC" select="." />
          <xsl:if test="not(//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$SSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value=$thisSSC])">
            <xsl:call-template name="DataItem">
              <xsl:with-param name="property">Assigned SSC</xsl:with-param>
              <xsl:with-param name="value" select="." />
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//ResourceManagementObject[ObjectType='DEEWR-claim'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimTypeID']/Values/string=$SSCClaimTypeID][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-claimValueID']/Values/string=$ClaimValueID]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value">
          <xsl:variable name="thisSSC" select="." />
          <xsl:if test="not($SSCs/string=$thisSSC)">
            <xsl:call-template name="DataItem">
              <xsl:with-param name="property">Expected SSC</xsl:with-param>
              <xsl:with-param name="value" select="." />
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
        <tr>
          <td colspan="6">
            <xsl:call-template name="reportheadstyle" />
          </td>
        </tr>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- All SSCs (Persons with IAMSSC claims) -->
  <xsl:template match="ResourceManagementObject" mode="SSC">
    <xsl:param name="ObjectTypes"/>
    <xsl:variable name="SSCUserID" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DEEWR-userID']/Value"/>
    <!-- Complete Person details of each SSC -->
    <xsl:apply-templates select="//ResourceManagementObject[(ObjectType='Person') and (ObjectIdentifier=$SSCUserID)]" mode="detail">
      <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
      <xsl:with-param name="ObjectTypes" select="''" />
    </xsl:apply-templates>
  </xsl:template>
</xsl:stylesheet>