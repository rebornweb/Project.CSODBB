<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:ms="urn:schemas-microsoft-com:xslt" 
                xmlns:dsml="http://www.dsml.org/DSML" 
                xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <!--===================================================================================================================================-->
  <!-- Template to display a data iten                                                                                                   -->
  <!--===================================================================================================================================-->
  <xsl:template name="DataItem">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <xsl:param name="colspanProperty" />
    <xsl:param name="colspanValue" />
    <tr valign="top">
      <th colspan="{$colspanProperty}">
        <xsl:call-template name="headstyle"/>
        <xsl:value-of select="$property"/>
      </th>
      <th colspan="{$colspanValue}">
        <xsl:call-template name="multiline"/>
        <xsl:call-template name="leftcell"/>
        <xsl:choose>
          <xsl:when test="$property='visaId' or $property='bindProfileId' or $property='schemaVisaId' or $property='emulatingVisaId'">
            <xsl:variable name="resolvedDisplayName">
              <xsl:choose>
                <xsl:when test="$property='visaId' or $property='schemaVisaId' or $property='emulatingVisaId'">
                  <xsl:value-of select="//configurationSection[@type='VISA'][configurationItem[@name='id']/text()=$value]/configurationItem[@name='name']/text()"/>
                </xsl:when>
                <xsl:when test="$property='bindProfileId'">
                  <xsl:value-of select="//configurationSection[@type='BIND_PROFILE'][configurationItem[@name='id']/text()=$value]/configurationItem[@name='name']/text()"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$resolvedDisplayName">
                <a href="{concat('#Section:',$value)}">
                  <xsl:value-of select="$resolvedDisplayName"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <table width="100%">
                  <xsl:call-template name="tablestyle" />
                  <tr>
                    <td style="background:yellow;">
                      <xsl:value-of select="$value"/>
                    </td>
                  </tr>
                </table>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </th>
    </tr>
  </xsl:template>
  <!--===================================================================================================================================-->
  <!-- Template to display a query data item                                                                                                   -->
  <!--===================================================================================================================================-->
  <xsl:template name="QueryDataItem">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <xsl:param name="colspanProperty" />
    <xsl:param name="colspanValue" />
    <tr>
      <th colspan="{$colspanProperty}">
        <xsl:call-template name="headstyle"/>
        <xsl:value-of select="$property"/>
      </th>
      <th colspan="{$colspanProperty}">
        <xsl:call-template name="multiline"/>
        <xsl:call-template name="leftcell"/>
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
  <!--======================================================================================-->
  <!-- Template to add a head style                                                         -->
  <!--======================================================================================-->
  <xsl:template name="headstyle">
    <xsl:attribute name="style">
      text-align:left;
      background:#CCCCCC;
      border-right:#666666 1px solid;
      border-bottom:#666666 1px solid;
      padding-left:10px;
      padding-right:10px;
      font-weight:normal;
      white-space:nowrap;
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a report subhead style                                                  -->
  <!--======================================================================================-->
  <xsl:template name="subheadstyle">
    <xsl:attribute name="style">
      text-align:left;
      border-bottom:green 1px solid;
      padding-bottom:5px;
      padding-left:10px;
      padding-right:10px;
      background:#e9ffcb;
      font-weight:bold;
      padding-top:5px
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a report subhead-right style                                         -->
  <!--======================================================================================-->
  <xsl:template name="subheadrightstyle">
    <xsl:attribute name="style">
      text-align:right;
      border-bottom:green 1px solid;
      padding-bottom:5px;
      padding-left:10px;
      padding-right:10px;
      background:#e9ffcb;
      font-weight:bold;
      padding-top:5px
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a left cell                                                        -->
  <!--======================================================================================-->
  <xsl:template name="leftcell">
    <xsl:attribute name="style">
      text-align:left;
      font-weight:normal;
      padding-left:10px;
      padding-right:10px;"
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a center cell                                                        -->
  <!--======================================================================================-->
  <xsl:template name="centercell">
    <xsl:attribute name="style">
      padding-left:10px;
      padding-right:10px;
      white-space:nowrap;
      text-align:center;
      font-weight:normal;"
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a section break                                                      -->
  <!--======================================================================================-->
  <xsl:template name="multiline">
    <xsl:if test="(position() mod 2 = 0)">
      <xsl:attribute name="bgcolor">#F5F5DC</xsl:attribute>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>