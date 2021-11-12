<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:include href="./Common.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="IdentityBrokerRoles" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Identity Broker Roles                                      -->
  <!--======================================================================================-->
  <xsl:template name="IdentityBrokerRoles">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Identity Broker 3.0 - Role Definitions</xsl:text>
        </td>
      </tr>
      <xsl:if test="dataConnection">
        <xsl:apply-templates select="dataConnection" />
      </xsl:if>
      <xsl:for-each select="//roleAuthorizations/roleAuthorization">
        <xsl:sort select="@role"/>
        <tr>
          <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="5">
            <xsl:value-of select="@role"/>
          </td>
        </tr>
        <xsl:if test="group">
          <tr>
            <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:text>Section</xsl:text>
            </th>
            <td colspan="1">
              <xsl:call-template name="reportheadstyle" />
              <xsl:text>Groups</xsl:text>
            </td>
          </tr>
          <tr>
            <th>
              <xsl:call-template name="headstyle" />Action
            </th>
            <th colspan="1">
              <xsl:call-template name="headstyle" />Name
            </th>
          </tr>
          <xsl:apply-templates select="group" />
        </xsl:if>
        <xsl:if test="anonymous">
          <tr>
            <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:text>Section</xsl:text>
            </th>
            <td colspan="1">
              <xsl:call-template name="reportheadstyle" />
              <xsl:text>Anonymous</xsl:text>
            </td>
          </tr>
          <tr>
            <th colspan="2">
              <xsl:call-template name="headstyle" />Action
            </th>
          </tr>
          <xsl:apply-templates select="anonymous" />
        </xsl:if>
        <xsl:if test="position() != last()">
          <tr>
            <td colspan="2" style="color:#F7FBFA;">
              <xsl:text>-</xsl:text>
            </td>
          </tr>
        </xsl:if>
      </xsl:for-each>
    </table>
  </xsl:template>
  <xsl:template match="group">
    <!-- Group Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@action"/>
      </td>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@groupName"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="anonymous">
    <!-- Anonymous Section -->
    <tr>
      <xsl:call-template name="multiline" />
      <td colspan="2">
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@action"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="dataConnection">
    <!-- Data connection Section -->
    <tr>
      <td align="left" style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#ffffff;font-weight:normal;padding-top:5px" colspan="6">
        <xsl:value-of select="'Data Connection'"/>
      </td>
    </tr>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Name'" />
      <xsl:with-param name="value" select="@name" />
    </xsl:call-template>
    <xsl:call-template name="DataItem">
      <xsl:with-param name="property" select="'Repository'" />
      <xsl:with-param name="value" select="@repository" />
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>