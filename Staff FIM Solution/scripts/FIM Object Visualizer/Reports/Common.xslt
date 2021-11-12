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
        <!--style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="headstyle"/>
        <xsl:value-of select="$property"/>
      </th>
      <th colspan="{$colspanValue}">
        <!--style="text-align:left;font-weight:normal;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="multiline"/>
        <xsl:call-template name="leftcell"/>
        <!--<xsl:if test="$colspanValue">
          <xsl:attribute name="colspan">
            <xsl:value-of select="$colspanValue"/>
          </xsl:attribute>
        </xsl:if>-->
        <!--
        <xsl:variable name="filter">
          <xsl:choose>
            <xsl:when test="starts-with($value,'urn:uuid:')">
              <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'urn:uuid:'+$value"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="resolvedDisplayName" select="//ResourceManagementObject[ObjectIdentifier=$filter]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
        -->
        <xsl:choose>
          <!--
          <xsl:when test="$resolvedDisplayName">
        -->
          <xsl:when test="starts-with($value,'uuid:')">
            <xsl:variable name="filter" select="substring-before($value,'urn:')"/>
            <xsl:variable name="resolvedDisplayName" select="//ResourceManagementObject[ObjectIdentifier=$filter]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
            <xsl:choose>
              <xsl:when test="$resolvedDisplayName">
                <a href="{concat('#',substring-after($filter,'urn:uuid:'))}">
                  <xsl:value-of select="$resolvedDisplayName"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring-after($value,'uuid:')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="starts-with($value,'urn:uuid:')">
            <!--<xsl:variable name="filter" select="$value" />-->
            <xsl:variable name="resolvedDisplayName" select="//ResourceManagementObject[ObjectIdentifier=$value]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
            <xsl:choose>
              <xsl:when test="$resolvedDisplayName">
                <a href="{concat('#',substring-after($value,'urn:uuid:'))}">
                  <xsl:value-of select="$resolvedDisplayName"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <table width="100%">
                  <xsl:call-template name="tablestyle" />
                  <tr>
                    <td style="background:yellow;">
                      <xsl:value-of select="substring-after($value,'urn:uuid:')"/>
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
  <!-- handle multi-value data item values-->
  <xsl:template name="DataItemMV">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <xsl:param name="colspanProperty" />
    <xsl:param name="colspanValue" />
    <tr valign="top">
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="headstyle"/>
        <xsl:value-of select="$property"/>
      </th>
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;font-weight:normal;padding-left:0px;padding-right:10px;"-->
        <xsl:call-template name="multiline"/>
        <xsl:call-template name="leftcell"/>
        <ul>
          <xsl:for-each select="ms:node-set($value)/string">
            <xsl:variable name="filter" select="text()" />
            <li>
              <xsl:choose>
                <xsl:when test="starts-with($filter,'urn:uuid:')">
                  <xsl:variable name="resolvedDisplayName" select="//ResourceManagementObject[ObjectIdentifier=$filter]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
                  <xsl:choose>
                    <xsl:when test="$resolvedDisplayName">
                      <a href="{concat('#',substring-after($filter,'urn:uuid:'))}">
                        <xsl:value-of select="$resolvedDisplayName"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <table width="100%">
                        <xsl:call-template name="tablestyle" />
                        <tr>
                          <td style="background:yellow;">
                            <xsl:value-of select="substring-after($filter,'urn:uuid:')"/>
                          </td>
                        </tr>
                      </table>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="$property='RequestStatusDetail'">
                  <xsl:value-of select="dsml:GetTextFromXmlText(string($filter))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$filter"/>
                </xsl:otherwise>
              </xsl:choose>
            </li>
          </xsl:for-each>
        </ul>
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
        <!--style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="headstyle"/>
        <xsl:value-of select="$property"/>
      </th>
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;"-->
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
      background:#CCCCCC;
      border-right:#666666 1px solid;
      border-bottom:#666666 1px solid;
      padding-left:10px;
      padding-right:10px;
      font-weight:normal;
      white-space:nowrap;
	  text-align:right;
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a head style                                                         -->
  <!--======================================================================================-->
  <xsl:template name="headstyleL">
    <xsl:attribute name="style">
      background:#CCCCCC;
      border-right:#666666 1px solid;
      border-bottom:#666666 1px solid;
      padding-left:10px;
      padding-right:10px;
      font-weight:normal;
      white-space:nowrap;
	  text-align:left;
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