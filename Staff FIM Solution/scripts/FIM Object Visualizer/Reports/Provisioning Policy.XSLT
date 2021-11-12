<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="ProvTriple" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Provisioning Triple                                          -->
  <!--======================================================================================-->
  <xsl:template name="ProvTriple">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Provisioning Policy Configuration</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//Configuration">
        <xsl:sort select="SRName"/>
        <tr>
          <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="5">
            <xsl:value-of select="SRName"/>
          </td>
        </tr>
          <xsl:call-template name="DataItem">
            <xsl:with-param name="property" select="'SR Name'" />
            <xsl:with-param name="value" select="SRName" />
          </xsl:call-template>

        <xsl:variable name="srtype">
          <xsl:choose>
            <xsl:when test="SRType='0'" >Inbound</xsl:when>
            <xsl:when test="SRType='1'" >Outbound</xsl:when>
            <xsl:otherwise>Inbound and Outbound</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'SR Type'" />
          <xsl:with-param name="value" select="$srtype" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'WF Name'" />
          <xsl:with-param name="value" select="WFName" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'WF Action'" />
          <xsl:with-param name="value" select="WFAction" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'MPR Names'" />
          <xsl:with-param name="value" select="MPRNames" />
        </xsl:call-template>
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
  <!--===================================================================================================================================-->
  <!-- Template to display a data iten                                                                                                   -->
  <!--===================================================================================================================================-->
  <xsl:template name="DataItem">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <tr>
      <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
        <xsl:value-of select="$property"/>
      </th>
      <th style="text-align:left;font-weight:normal;padding-left:10px;padding-right:10px;">
        <xsl:value-of select="$value"/>
      </th>
    </tr>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a table style                                                        -->
  <!--======================================================================================-->
  <xsl:template name="tablestyle">
    <xsl:attribute name="style">
      font-family:Tahoma;
      font-size:11px;
      border-collapse:collapse;
      border-top:1px RGB(212,208,200) solid;
      border-left:1px RGB(212,208,200) solid;
      border-right: 1px RGB(212,208,200) solid;
      border-bottom:1px RGB(212,208,200) solid;
      padding:0px;"
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a report head style                                                  -->
  <!--======================================================================================-->
  <xsl:template name="reportheadstyle">
    <xsl:attribute name="style">
      padding-top:10px;
      padding-bottom:10px;
      padding-left:10px;
      padding-right:10px;
      font-weight:bold;
      background:rgb(234,242,255);
      border-bottom:1px solid rgb(120,172,255)
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>